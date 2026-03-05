import Quickshell
import Quickshell.Wayland

PanelWindow {
    required property string name

    WlrLayershell.namespace: `hornero-${name}`
    color: "transparent"
}
