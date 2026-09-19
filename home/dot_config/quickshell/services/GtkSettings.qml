pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Native GTK application layer (issue #2, migration step (a)).
//
// Applies GTK themes, icon themes, and color-scheme policy through the
// deterministic `gsettings` desktop APIs first, falling back to
// `horneroctl appearance gtk` where `gsettings` is absent.
// See docs/NATIVE-APPEARANCE.md.
Singleton {
    id: root

    property string _lastError: ""
    readonly property string lastError: _lastError

    property bool _busy: false
    readonly property bool busy: _busy

    // Pending request fields (single-flight; ThemePipeline serializes jobs).
    property string _gtkTheme: ""
    property string _iconTheme: ""
    property string _themeId: ""
    property string _policy: ""
    property bool _darkMode: true
    property var _compatCommand: []
    property string _nativeKind: "full"
    property string _compatKind: "full"

    // Live current values from native `gsettings` reads (empty until queried).
    property string liveGtkTheme: ""
    property string liveIconTheme: ""
    property string liveColorScheme: ""

    signal applyFinished(bool ok, string error)

    // Deterministic mapping from a normalized policy
    // (follow | default | prefer-light | prefer-dark, see
    // ThemePipeline.normalizeGtkColorScheme) to the
    // org.gnome.desktop.interface color-scheme value. "follow" resolves
    // against the shell dark mode so the result is always explicit.
    function toGsettingsScheme(policy: string, darkMode: bool): string {
        const raw = (policy ?? "").toLowerCase().replace(/_/g, "-");
        switch (raw) {
        case "prefer-light":
        case "light":
            return "prefer-light";
        case "prefer-dark":
        case "dark":
            return "prefer-dark";
        case "default":
        case "auto":
            return "default";
        case "follow":
        case "":
            return darkMode ? "prefer-dark" : "prefer-light";
        default:
            return "";
        }
    }

    function applyFull(gtkTheme: string, iconTheme: string, themeId: string, policy: string, darkMode: bool): void {
        _gtkTheme = gtkTheme || "";
        _iconTheme = iconTheme || "";
        _themeId = themeId || "";
        _policy = policy || "";
        _darkMode = !!darkMode;
        _startApply("full");
    }

    function applyGtkTheme(theme: string): void {
        _gtkTheme = theme || "";
        _iconTheme = "";
        _themeId = "";
        _policy = "";
        _startApply("gtk");
    }

    function applyIconTheme(theme: string): void {
        _gtkTheme = "";
        _iconTheme = theme || "";
        _themeId = "";
        _policy = "";
        _startApply("icons");
    }

    function applyColorScheme(policy: string, darkMode: bool): void {
        _gtkTheme = "";
        _iconTheme = "";
        _themeId = "";
        _policy = policy || "";
        _darkMode = !!darkMode;
        _startApply("color-scheme");
    }

    function refreshLive(): void {
        liveQueryProc.running = true;
    }

    function _startApply(kind: string): void {
        _busy = true;
        _lastError = "";
        _compatCommand = _compatFor(kind);
        // Theme-pack ids resolve through `horneroctl appearance gtk theme`
        // (native pack lookup), falling back to the compat adapter below.
        if (kind === "full" && _themeId && (!_gtkTheme || _gtkTheme === "auto")) {
            _compatKind = kind;
            compatProc.running = true;
            return;
        }
        _nativeKind = kind;
        nativeProc.running = true;
    }

    function _finishApply(ok: bool, err: string): void {
        _busy = false;
        if (!ok)
            _lastError = err || "GTK apply failed";
        root.applyFinished(ok, ok ? "" : _lastError);
    }

    // Fallback for hosts where `gsettings` is absent; see docs/COMPAT.md.
    function _compatFor(kind: string): var {
        if (kind === "gtk")
            return ["horneroctl", "appearance", "gtk", "apply", _gtkTheme, "--yes"];
        if (kind === "icons")
            return ["horneroctl", "appearance", "gtk", "set-icons", _iconTheme, "--yes"];
        if (kind === "color-scheme")
            return ["horneroctl", "appearance", "gtk", "color-scheme", _policy || "follow", "--yes"];
        return ["bash", "-c", `
set -euo pipefail
policy="\${DOTS_GTK_COLOR_SCHEME:-}"
if [[ -n "\${DOTS_THEME_ID:-}" && ( -z "\${DOTS_GTK_THEME:-}" || "\${DOTS_GTK_THEME}" == "auto" ) ]]; then
  horneroctl appearance gtk theme "\${DOTS_THEME_ID}" --yes || true
  if [[ -n "\$policy" ]]; then
    horneroctl appearance gtk color-scheme "\$policy" --yes || true
  else
    horneroctl appearance gtk sync-color-scheme --yes || true
  fi
elif [[ -n "\${DOTS_GTK_THEME:-}" && "\${DOTS_GTK_THEME}" != "auto" ]]; then
  if [[ -n "\$policy" ]]; then
    horneroctl appearance gtk apply "\${DOTS_GTK_THEME}" "\${DOTS_ICON_THEME:-}" "\$policy" --yes || true
  else
    horneroctl appearance gtk apply "\${DOTS_GTK_THEME}" "\${DOTS_ICON_THEME:-}" --yes || true
  fi
elif [[ -n "\${DOTS_ICON_THEME:-}" ]]; then
  horneroctl appearance gtk set-icons "\${DOTS_ICON_THEME}" --yes || true
  if [[ -n "\$policy" ]]; then
    horneroctl appearance gtk color-scheme "\$policy" --yes || true
  else
    horneroctl appearance gtk sync-color-scheme --yes || true
  fi
else
  if [[ -n "\$policy" ]]; then
    horneroctl appearance gtk color-scheme "\$policy" --yes || true
  else
    horneroctl appearance gtk sync-color-scheme --yes || true
  fi
fi
`];
    }

    // Native apply: deterministic gsettings writes. Exits 99 when gsettings
    // is unavailable so the caller falls through to the compat adapter.
    Process {
        id: nativeProc

        command: ["bash", "-c", `
set -euo pipefail
command -v gsettings >/dev/null 2>&1 || exit 99
if [[ -n "\${HORNERO_GTK_THEME:-}" && "\${HORNERO_GTK_THEME}" != "auto" ]]; then
  gsettings set org.gnome.desktop.interface gtk-theme "\${HORNERO_GTK_THEME}"
  gsettings set org.gnome.desktop.wm.preferences theme "\${HORNERO_GTK_THEME}"
fi
if [[ -n "\${HORNERO_ICON_THEME:-}" ]]; then
  gsettings set org.gnome.desktop.interface icon-theme "\${HORNERO_ICON_THEME}"
fi
if [[ -n "\${HORNERO_COLOR_SCHEME:-}" ]]; then
  gsettings set org.gnome.desktop.interface color-scheme "\${HORNERO_COLOR_SCHEME}"
fi
`]
        environment: ({
            "HORNERO_GTK_THEME": root._gtkTheme,
            "HORNERO_ICON_THEME": root._iconTheme,
            "HORNERO_COLOR_SCHEME": root.toGsettingsScheme(root._policy, root._darkMode)
        })
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                root._finishApply(true, "");
                return;
            }
            // Native apply failed or gsettings is missing: thin compat
            // fallback (see _compatFor debt note above).
            root._compatKind = root._nativeKind;
            compatProc.running = true;
        }
    }

    Process {
        id: compatProc

        command: root._compatCommand
        environment: ({
            "DOTS_GTK_THEME": root._gtkTheme,
            "DOTS_ICON_THEME": root._iconTheme,
            "DOTS_THEME_ID": root._themeId,
            "DOTS_GTK_COLOR_SCHEME": root._policy
        })
        onExited: (exitCode, exitStatus) => {
            root._finishApply(true, "");
        }
    }

    // Native live queries: current GTK/icon theme and color-scheme via
    // gsettings. Emits three lines (gtk-theme, icon-theme, color-scheme);
    // empty output means gsettings is unavailable and callers keep their
    // `horneroctl appearance gtk` live queries as fallback.
    Process {
        id: liveQueryProc

        command: ["bash", "-c", `
set -uo pipefail
command -v gsettings >/dev/null 2>&1 || exit 99
gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null | tr -d "'"
gsettings get org.gnome.desktop.interface icon-theme 2>/dev/null | tr -d "'"
gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null | tr -d "'"
`]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split("\n").map(line => line.trim()).filter(line => line.length > 0);
                if (lines.length > 0 && lines[0] !== "Unknown")
                    root.liveGtkTheme = lines[0];
                if (lines.length > 1 && lines[1] !== "Unknown")
                    root.liveIconTheme = lines[1];
                if (lines.length > 2)
                    root.liveColorScheme = root.normalizeLiveScheme(lines[2]);
            }
        }
    }

    function normalizeLiveScheme(value: string): string {
        const raw = (value ?? "").toLowerCase().replace(/_/g, "-").replace(/['"]/g, "");
        switch (raw) {
        case "prefer-light":
        case "light":
            return "prefer-light";
        case "prefer-dark":
        case "dark":
            return "prefer-dark";
        case "default":
            return "default";
        default:
            return "";
        }
    }
}
