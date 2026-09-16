"""Factory shell defaults: config/shell.default.json must equal the shell's
in-code defaults key by key.

The factory file mirrors exactly what Config.qml serializeConfig() persists
on save (the key set the shell itself reads back through its JsonAdapter),
with values taken from the per-area *Config.qml initializers.

Documented omissions (each asserted below with its reason):
- dashboard.updateInterval: serializeDashboard() reads
  DashboardConfig.updateInterval, which does not exist (only
  media/resourceUpdateInterval); the value is undefined at runtime, so
  JSON.stringify never writes the key. Pre-existing upstream quirk, left
  untouched.
- services.useTwelveHourClock: computed from Qt.locale() at runtime; left
  unset so first-run locale detection still applies.
- paths.wallpaperDir: runtime default is `${Paths.pictures}/Wallpapers`
  (XDG-aware); left unset so per-host resolution still applies.
"""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CONFIG_QML = ROOT / "config" / "Config.qml"
FACTORY = ROOT / "config" / "shell.default.json"

# (section, key, ...) paths intentionally absent from the factory file.
OMITTED = {
    ("dashboard", "updateInterval"),
    ("services", "useTwelveHourClock"),
    ("paths", "wallpaperDir"),
}


class _Parser:
    """Minimal parser for the object literals returned by serialize*()."""

    def __init__(self, text):
        self.s = text
        self.i = 0

    def _ws(self):
        while self.i < len(self.s):
            if self.s[self.i].isspace():
                self.i += 1
            elif self.s.startswith("//", self.i):
                while self.i < len(self.s) and self.s[self.i] != "\n":
                    self.i += 1
            else:
                break

    def _string(self):
        q = self.s[self.i]
        assert q in "\"'", f"unexpected {q!r} at {self.i}"
        self.i += 1
        out = []
        while self.s[self.i] != q:
            if self.s[self.i] == "\\":
                out.append(self.s[self.i:self.i + 2])
                self.i += 2
            else:
                out.append(self.s[self.i])
                self.i += 1
        self.i += 1
        return "".join(out)

    def _key(self):
        self._ws()
        if self.s[self.i] in "\"'":
            return self._string()
        m = re.match(r"[A-Za-z_$][\w$]*", self.s[self.i:])
        assert m, f"no key at offset {self.i}: {self.s[self.i:self.i+20]!r}"
        self.i += len(m.group(0))
        return m.group(0)

    def _skip_value(self):
        # Skip one value; return the parsed subtree for '{...}' objects so
        # callers get the nested key structure, else None.
        self._ws()
        if self.s[self.i] == "{":
            return self._object()
        if self.s[self.i] in "\"'":
            self._string()
            return None
        depth = {"(": 0, "[": 0}
        while self.i < len(self.s):
            c = self.s[self.i]
            if c in "\"'":
                self._string()
                continue
            if c == "(":
                depth["("] += 1
            elif c == ")":
                depth["("] -= 1
            elif c == "[":
                depth["["] += 1
            elif c == "]":
                if depth["["] == 0:
                    break
                depth["["] -= 1
            elif c in ",}" and depth["("] == 0 and depth["["] == 0:
                break
            self.i += 1
        return None

    def _object(self):
        assert self.s[self.i] == "{"
        self.i += 1
        keys = {}
        while True:
            self._ws()
            if self.s[self.i] == "}":
                self.i += 1
                return keys
            key = self._key()
            self._ws()
            assert self.s[self.i] == ":", f"no colon after {key!r}"
            self.i += 1
            keys[key] = self._skip_value()
            self._ws()
            if self.s[self.i] == ",":
                self.i += 1

    def parse_function_object(self):
        # Body is `return { ... };` possibly preceded by try/config noise.
        at = self.s.index("return", self.i)
        brace = self.s.index("{", at)
        self.i = brace
        return self._object()


def _fn_body(text, name):
    start = text.index(f"function {name}()")
    brace = text.index("{", start)
    depth = 0
    for i in range(brace, len(text)):
        if text[i] == "{":
            depth += 1
        elif text[i] == "}":
            depth -= 1
            if depth == 0:
                return text[brace:i + 1]
    raise AssertionError(f"unbalanced braces in {name}")


def _expected_tree():
    text = CONFIG_QML.read_text()
    sections = _Parser(_fn_body(text, "serializeConfig")).parse_function_object()
    tree = {}
    for section in sections:
        body = _fn_body(text, f"serialize{section[0].upper()}{section[1:]}")
        tree[section] = _Parser(body).parse_function_object()
    return tree


def _check_keys(path, expected, actual):
    if isinstance(expected, dict):
        assert isinstance(actual, dict), f"{path or 'root'}: object expected"
        for key, sub in expected.items():
            if (*path, key) in OMITTED:
                assert key not in actual, f"{'.'.join([*path, key])} must stay omitted"
                continue
            assert key in actual, f"missing key {'.'.join([*path, key])}"
            _check_keys([*path, key], sub, actual[key])
        extra = set(actual) - set(expected) - {p[-1] for p in OMITTED if p[:-1] == tuple(path)}
        assert not extra, f"{path or 'root'}: unexpected keys {sorted(extra)}"
    # Non-object values (arrays/scalars) are opaque to the key check; values
    # are pinned by test_factory_values_match_code_defaults.


def _get(factory, dotted):
    node = factory
    for part in dotted.split("."):
        node = node[part]
    return node


def test_factory_key_structure_matches_serialize_functions():
    expected = _expected_tree()
    factory = json.loads(FACTORY.read_text())
    assert set(factory) == set(expected), (
        f"top-level mismatch: missing={set(expected) - set(factory)} "
        f"extra={set(factory) - set(expected)}"
    )
    _check_keys([], expected, factory)


def test_factory_values_match_code_defaults():
    factory = json.loads(FACTORY.read_text())
    bar_src = (ROOT / "config" / "BarConfig.qml").read_text()
    cases = [
        # appearance (AppearanceConfig.qml; anim literals mirror the adapter)
        ("appearance.theme", "hornero-dark"),
        ("appearance.rounding.scale", 1),
        ("appearance.font.family.sans", "Rubik"),
        ("appearance.font.family.mono", "CaskaydiaCove NF"),
        ("appearance.font.family.material", "Material Symbols Rounded"),
        ("appearance.anim.mediaGifSpeedAdjustment", 300),
        ("appearance.anim.sessionGifSpeed", 0.7),
        ("appearance.transparency.enabled", False),
        ("appearance.transparency.base", 0.85),
        # general (GeneralConfig.qml; qsTr() yields the plain source string)
        ("general.apps.terminal", ["foot"]),
        ("general.idle.lockBeforeSleep", True),
        ("general.idle.timeouts.1.idleAction", "dpms off"),
        ("general.battery.criticalLevel", 3),
        ("general.battery.warnLevels.0.level", 20),
        ("general.battery.warnLevels.2.critical", True),
        # background (BackgroundConfig.qml; video section is not serialized)
        ("background.enabled", True),
        ("background.desktopClock.position", "bottom-right"),
        ("background.desktopClock.shadow.blur", 0.4),
        ("background.visualiser.autoHide", True),
        # bar (BarConfig.qml)
        ("bar.position", "left"),
        ("bar.style", "attached"),
        ("bar.floatingMargin", 8),
        ("bar.workspaces.shown", 5),
        ("bar.workspaces.showWindowsOnSpecialWorkspaces", True),
        ("bar.workspaces.capitalisation", "preserve"),
        ("bar.status.showNetwork", True),
        ("bar.status.showAudio", False),
        ("bar.sizes.innerWidth", 40),
        ("bar.entries.0.id", "logo"),
        ("bar.entries.8.id", "power"),
        # border resolves Appearance tokens at scale 1: padding.normal=10,
        # rounding.large=25 (BorderConfig.qml)
        ("border.frameEnabled", True),
        ("border.thickness", 10),
        ("border.rounding", 25),
        # dashboard (DashboardConfig.qml; updateInterval intentionally absent)
        ("dashboard.dragThreshold", 50),
        ("dashboard.performance.showGpu", True),
        ("dashboard.sizes.mediaCoverArtSize", 150),
        # controlCenter / lock ratios are 16/9 in code (ControlCenterConfig,
        # LockConfig.qml)
        ("controlCenter.sizes.ratio", 16 / 9),
        ("launcher.maxShown", 7),
        ("launcher.specialPrefix", "@"),
        ("launcher.useFuzzy.wallpapers", False),
        ("launcher.sizes.itemHeight", 57),
        ("launcher.actions.7.name", "Random"),
        ("launcher.actions.12.command.2", ""),
        ("launcher.actions.15.command.0", "dots-settings-gui"),
        # notifs / osd
        ("notifs.defaultExpireTimeout", 5000),
        ("notifs.clearThreshold", 0.3),
        ("notifs.sizes.badge", 20),
        ("osd.hideDelay", 2000),
        ("osd.enableMicrophone", False),
        # session / winfo / lock / utilities / sidebar
        ("session.dragThreshold", 30),
        ("session.commands.hibernate.1", "hibernate"),
        ("session.sizes.button", 80),
        ("winfo.sizes.detailsWidth", 500),
        ("lock.maxFprintTries", 3),
        ("lock.sizes.centerWidth", 600),
        ("utilities.maxToasts", 4),
        ("utilities.toasts.nowPlaying", False),
        ("utilities.vpn.provider", ["netbird"]),
        ("sidebar.sizes.width", 430),
        # services (ServiceConfig.qml; useTwelveHourClock intentionally
        # absent because it is locale-computed)
        ("services.visualiserBars", 45),
        ("services.audioIncrement", 0.1),
        ("services.maxVolume", 1.0),
        ("services.smartScheme", True),
        ("services.defaultPlayer", "Spotify"),
        ("services.playerAliases.0.to", "YT Music"),
        # paths (UserPaths.qml; wallpaperDir intentionally absent, XDG-aware)
        ("paths.sessionGif", "root:/assets/kurukuru.gif"),
        ("paths.mediaGif", "root:/assets/bongocat.gif"),
    ]
    for dotted, want in cases:
        node = factory
        for part in dotted.split("."):
            node = node[int(part)] if isinstance(node, list) else node[part]
        assert node == want, f"{dotted}: got {node!r}, want {want!r}"
    # Glyph-bearing bar labels must be byte-exact copies of the QML source.
    for key in ("label", "occupiedLabel", "activeLabel"):
        m = re.search(rf"property string {key}: \"(.*?)\"", bar_src)
        assert m, f"{key} default not found in BarConfig.qml"
        assert factory["bar"]["workspaces"][key] == m.group(1), f"bar.workspaces.{key} glyph mismatch"


def test_factory_documents_omissions():
    for path in OMITTED:
        node = json.loads(FACTORY.read_text())
        for part in path[:-1]:
            node = node[part]
        assert path[-1] not in node, f"omitted key {'.'.join(path)} present"


def test_missing_user_config_is_not_an_error():
    # Existing behavior (config/Config.qml): the FileView reads
    # ${Paths.config}/shell.json and its onLoadFailed handler ignores a
    # missing file, so first run with compiled defaults is not an error.
    text = CONFIG_QML.read_text()
    assert "${Paths.config}/shell.json" in text
    m = re.search(r"onLoadFailed:\s*err\s*=>\s*\{(.*?)\}", text, re.DOTALL)
    assert m, "Config.qml FileView must keep its onLoadFailed handler"
    assert "FileViewError.FileNotFound" in m.group(1), (
        "missing shell.json (FileNotFound) must stay a tolerated case"
    )
