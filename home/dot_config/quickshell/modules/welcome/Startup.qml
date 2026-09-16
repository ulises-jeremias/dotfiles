import qs.modules.welcome
import QtQuick

// Login-time auto-open for the Welcome Center. Evaluates exactly once,
// only after BOTH the persisted state (State.ready) and the session
// marker probe (Session.markerKnown) have resolved, so first paint is
// never blocked and a slow disk can never cause a double open. When the
// guard passes, the sighting is recorded (single writer) and the window
// opens on the start page.
QtObject {
    id: root

    property bool _done: false

    Component.onCompleted: Qt.callLater(root.evaluate)

    Connections {
        target: State
        function onReadyChanged(): void {
            root.evaluate();
        }
    }

    Connections {
        target: Session
        function onMarkerKnownChanged(): void {
            root.evaluate();
        }
    }

    function evaluate(): void {
        if (root._done)
            return;
        if (!State.ready || !Session.markerKnown)
            return;
        root._done = true;
        if (Session.shouldAutoOpen)
            Welcome.open("start");
    }
}
