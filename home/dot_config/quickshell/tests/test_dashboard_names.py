"""Dashboard component-name contract: no QML component file may shadow a
Qt built-in attached-only type (QtQuick.Keys is the classic case: a
sibling Keys.qml is silently ignored and `Keys {}` fails at load with
"only available via attached properties", which qmllint does not catch
and which takes the whole shell down). Every bare component reference
in the dashboard Content must resolve to a same-directory file whose
name is not on the shadow denylist."""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DASH = ROOT / "modules" / "dashboard"
CONTENT = DASH / "Content.qml"

# Qt built-in attached-only (non-instantiable) type names that must never
# be reused as component file names anywhere under modules/.
SHADOW_DENYLIST = {
    "Keys",  # QtQuick.Keys attached type; broke the shell in #51.
    "LayoutMirroring",  # QtQuick.LayoutMirroring attached type.
}


def _qml_component_names():
    return [p.stem for p in ROOT.glob("modules/**/*.qml")]


def test_no_component_shadows_builtin_attached_type():
    hits = sorted(set(_qml_component_names()) & SHADOW_DENYLIST)
    assert not hits, f"component names shadow Qt attached types: {hits}"


def test_dashboard_content_references_resolve_to_files():
    text = CONTENT.read_text()
    refs = re.findall(r"sourceComponent:\s*(\w+)\s*\{", text)
    assert refs, "expected sourceComponent references in dashboard Content"
    siblings = {p.stem for p in DASH.glob("*.qml")}
    missing = sorted(set(refs) - siblings)
    assert not missing, f"dashboard references without a same-dir file: {missing}"
