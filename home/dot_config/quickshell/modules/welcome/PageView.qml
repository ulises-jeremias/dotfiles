import qs.components
import qs.components.containers
import qs.components.controls
import qs.services
import qs.config
import qs.modules.welcome
import QtQuick
import QtQuick.Layouts
import ".."

// Page shell shared by all Welcome content pages: vertical flickable with
// a hero header. Callers place PageHeader first, then ActionCards.
StyledFlickable {
    id: root

    default property alias content: content.data

    contentHeight: content.implicitHeight
    flickableDirection: Flickable.VerticalFlick
    clip: true

    StyledScrollBar.vertical: StyledScrollBar {
        flickable: root
    }

    ColumnLayout {
        id: content

        width: root.width
        spacing: Appearance.spacing.normal
    }
}
