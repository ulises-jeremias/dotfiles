import qs.modules.welcome as WelcomeModule
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

    // NOTE: Connections {} cannot be a child of QtObject (no default
    // property), so signals are wired imperatively. The welcome import is
    // aliased because unqualified State collides with QtQuick.State.
    // Same lifetime as the singletons, no disconnect needed.
    Component.onCompleted: {
        WelcomeModule.State.readyChanged.connect(root.evaluate);
        WelcomeModule.Session.markerKnownChanged.connect(root.evaluate);
        Qt.callLater(root.evaluate);
    }

    function evaluate(): void {
        if (root._done)
            return;
        if (!WelcomeModule.State.ready || !WelcomeModule.Session.markerKnown)
            return;
        root._done = true;
        if (WelcomeModule.Session.shouldAutoOpen)
            WelcomeModule.Welcome.open("start");
    }
}
