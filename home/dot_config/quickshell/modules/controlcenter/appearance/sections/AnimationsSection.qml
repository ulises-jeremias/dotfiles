pragma ComponentBehavior: Bound

import ".."
import "../../components"
import qs.components
import qs.components.controls
import qs.components.containers
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

CollapsibleSection {
    id: root

    required property var rootPane

    title: qsTr("Animations")
    showBackground: true

    // Accessibility toggles: semantic shortcuts for the animation scale slider
    SwitchRow {
        label: qsTr("Disable animations")
        checked: rootPane.animDurationsScale <= 0.05
        onToggled: checked => {
            rootPane.animDurationsScale = checked ? 0.01 : 1.0;
            rootPane.saveConfig();
        }
    }

    SwitchRow {
        label: qsTr("Reduce motion")
        checked: rootPane.animDurationsScale > 0.05 && rootPane.animDurationsScale <= 0.35
        enabled: rootPane.animDurationsScale > 0.05
        onToggled: checked => {
            rootPane.animDurationsScale = checked ? 0.3 : 1.0;
            rootPane.saveConfig();
        }
    }

    SectionContainer {
        contentSpacing: Appearance.spacing.normal

        SliderInput {
            Layout.fillWidth: true

            label: qsTr("Animation duration scale")
            value: rootPane.animDurationsScale
            from: 0.01
            to: 5.0
            decimals: 2
            suffix: "×"
            validator: DoubleValidator {
                bottom: 0.01
                top: 5.0
            }

            onValueModified: newValue => {
                rootPane.animDurationsScale = newValue;
                rootPane.saveConfig();
            }
        }
    }
}
