pragma ComponentBehavior: Bound

import ".."
import "../components"
import qs.components
import qs.components.controls
import qs.components.effects
import qs.components.containers
import qs.services
import qs.config
import Quickshell
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property Session session

    anchors.fill: parent

    // ── Built-in provider defaults ────────────────────────────────────────────
    readonly property var builtinDefaults: ({
        netbird:   { name: "netbird",   displayName: "NetBird",         interface: "wt0",           icon: "lan" },
        tailscale: { name: "tailscale", displayName: "Tailscale",       interface: "tailscale0",    icon: "hub" },
        warp:      { name: "warp",      displayName: "Cloudflare WARP", interface: "CloudflareWARP",icon: "shield" },
        wireguard: { name: "wireguard", displayName: "WireGuard",       interface: "wg0",           icon: "vpn_lock" }
    })

    // Provider type cards data for the dialog
    readonly property var providerTypes: [
        { type: "netbird",   label: "NetBird",         icon: "lan",      subtitle: qsTr("Open source secure network") },
        { type: "tailscale", label: "Tailscale",       icon: "hub",      subtitle: qsTr("Zero-config mesh VPN") },
        { type: "warp",      label: "Cloudflare WARP", icon: "shield",   subtitle: qsTr("Fast DNS + encrypted tunneling") },
        { type: "wireguard", label: "WireGuard",       icon: "vpn_lock", subtitle: qsTr("Kernel-level encrypted tunnel") },
        { type: "custom",    label: qsTr("Custom…"),   icon: "tune",     subtitle: qsTr("Manual connect / disconnect commands") }
    ]

    // ── Reactive computed provider list ───────────────────────────────────────
    readonly property var providers: {
        return Config.utilities.vpn.provider.map((raw, i) => {
            const isObj = typeof raw === "object" && raw !== null;
            const name = isObj ? (raw.name || "custom") : String(raw);
            const builtin = root.builtinDefaults[name];
            return {
                index:       i,
                name:        name,
                displayName: isObj ? (raw.displayName || builtin?.displayName || name) : (builtin?.displayName || name),
                interface:   isObj ? (raw.interface || builtin?.interface || "") : (builtin?.interface || ""),
                enabled:     isObj ? (raw.enabled === true) : false,
                icon:        builtin?.icon ?? "vpn_key",
                raw:         raw
            };
        });
    }

    // ── Mutation helpers ──────────────────────────────────────────────────────
    function addProvider(obj) {
        const arr = [];
        for (let i = 0; i < Config.utilities.vpn.provider.length; i++)
            arr.push(Config.utilities.vpn.provider[i]);
        arr.push(obj);
        Config.utilities.vpn.provider = arr;
        Config.save();
    }

    function updateProvider(idx, obj) {
        const arr = [];
        for (let i = 0; i < Config.utilities.vpn.provider.length; i++)
            arr.push(i === idx ? obj : Config.utilities.vpn.provider[i]);
        Config.utilities.vpn.provider = arr;
        Config.save();
    }

    function deleteProvider(idx) {
        const arr = [];
        for (let i = 0; i < Config.utilities.vpn.provider.length; i++) {
            if (i !== idx) arr.push(Config.utilities.vpn.provider[i]);
        }
        Config.utilities.vpn.provider = arr;
        if (root.session.vpn.active !== null && root.session.vpn.active.index === idx)
            root.session.vpn.active = null;
        Config.save();
    }

    function setActive(idx) {
        const arr = [];
        for (let i = 0; i < Config.utilities.vpn.provider.length; i++) {
            const raw = Config.utilities.vpn.provider[i];
            const isObj = typeof raw === "object" && raw !== null;
            if (isObj) {
                const copy = {};
                for (const k in raw) copy[k] = raw[k];
                copy.enabled = (i === idx);
                arr.push(copy);
            } else {
                const name = String(raw);
                const builtin = root.builtinDefaults[name] || {};
                arr.push({
                    name:        name,
                    displayName: builtin.displayName || name,
                    interface:   builtin.interface || "",
                    enabled:     (i === idx)
                });
            }
        }
        Config.utilities.vpn.provider = arr;
        Config.save();
    }

    property int pendingSwitchIndex: -1

    Connections {
        target: VPN
        function onConnectedChanged() {
            if (!VPN.connected && root.pendingSwitchIndex >= 0) {
                const idx = root.pendingSwitchIndex;
                root.pendingSwitchIndex = -1;
                root.setActive(idx);
                VPN.connect();
            }
        }
    }

    function toggleProvider(idx) {
        const provider = root.providers[idx];
        if (!provider) return;
        if (provider.enabled) {
            VPN.toggle();
        } else if (VPN.connected) {
            root.pendingSwitchIndex = idx;
            VPN.disconnect();
        } else {
            root.setActive(idx);
            VPN.connect();
        }
    }

    // ── Split layout ──────────────────────────────────────────────────────────
    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Left — provider list (40%)
        Item {
            Layout.preferredWidth: Math.floor(parent.width * 0.4)
            Layout.minimumWidth: 180
            Layout.fillHeight: true

            ClippingRectangle {
                anchors.fill: parent
                anchors.margins: Appearance.padding.normal
                anchors.leftMargin: 0
                anchors.rightMargin: Appearance.padding.normal / 2
                radius: leftBorder.innerRadius
                color: "transparent"

                StyledFlickable {
                    id: listFlick
                    anchors.fill: parent
                    anchors.margins: Appearance.padding.large
                    anchors.leftMargin: Appearance.padding.large
                    anchors.rightMargin: Appearance.padding.large + Appearance.padding.normal / 2
                    flickableDirection: Flickable.VerticalFlick
                    contentHeight: listCol.implicitHeight

                    StyledScrollBar.vertical: StyledScrollBar { flickable: listFlick }

                    ColumnLayout {
                        id: listCol
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        spacing: Appearance.spacing.small

                        // Header
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Appearance.spacing.small

                            StyledText {
                                Layout.fillWidth: true
                                text: qsTr("VPN")
                                font.pointSize: Appearance.font.size.larger
                                font.weight: 500
                            }

                            StyledRect {
                                visible: VPN.connected || VPN.connecting
                                radius: Appearance.rounding.full
                                color: VPN.connected ? Colours.palette.m3primary : Colours.layer(Colours.palette.m3surfaceContainerHigh, 2)
                                implicitWidth: connChip.implicitWidth + Appearance.padding.normal * 2
                                implicitHeight: connChip.implicitHeight + Appearance.padding.smaller

                                StyledText {
                                    id: connChip
                                    anchors.centerIn: parent
                                    text: VPN.connecting ? qsTr("…") : qsTr("On")
                                    color: VPN.connected ? Colours.palette.m3onPrimary : Colours.palette.m3onSurfaceVariant
                                    font.pointSize: Appearance.font.size.smaller
                                    font.weight: 600
                                }
                            }
                        }

                        // Add provider button
                        StyledRect {
                            Layout.fillWidth: true
                            radius: Appearance.rounding.normal
                            color: Colours.layer(Colours.palette.m3surfaceContainerHigh, 1)
                            implicitHeight: addRow.implicitHeight + Appearance.padding.normal * 2

                            StateLayer {
                                function onClicked() { vpnDialog.openForAdd(); }
                            }

                            RowLayout {
                                id: addRow
                                anchors.fill: parent
                                anchors.margins: Appearance.padding.normal
                                spacing: Appearance.spacing.normal

                                MaterialIcon {
                                    text: "add"
                                    color: Colours.palette.m3primary
                                    font.pointSize: Appearance.font.size.normal
                                }
                                StyledText {
                                    text: qsTr("Add provider")
                                    color: Colours.palette.m3primary
                                    font.pointSize: Appearance.font.size.normal
                                    font.weight: 500
                                }
                            }
                        }

                        StyledText {
                            visible: root.providers.length === 0
                            Layout.fillWidth: true
                            Layout.topMargin: Appearance.spacing.normal
                            text: qsTr("No providers configured")
                            color: Colours.palette.m3outline
                            font.pointSize: Appearance.font.size.smaller
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.Wrap
                        }

                        // Provider list — one StyledRect per item, no inline component
                        Repeater {
                            model: root.providers

                            StyledRect {
                                id: provCard
                                required property var modelData
                                readonly property bool isSelected: root.session.vpn.active !== null &&
                                                                   root.session.vpn.active.index === provCard.modelData.index
                                readonly property bool isConnected: provCard.modelData.enabled && VPN.connected

                                Layout.fillWidth: true
                                radius: Appearance.rounding.normal
                                color: provCard.isSelected
                                    ? Colours.layer(Colours.palette.m3secondaryContainer, 1)
                                    : Colours.layer(Colours.palette.m3surfaceContainer, 1)
                                implicitHeight: provRow.implicitHeight + Appearance.padding.normal * 2

                                StateLayer {
                                    color: provCard.isSelected
                                        ? Colours.palette.m3onSecondaryContainer
                                        : Colours.palette.m3onSurface
                                    function onClicked() {
                                        root.session.vpn.active = provCard.modelData;
                                    }
                                }

                                RowLayout {
                                    id: provRow
                                    anchors.fill: parent
                                    anchors.margins: Appearance.padding.normal
                                    spacing: Appearance.spacing.normal

                                    // Status dot
                                    StyledRect {
                                        implicitWidth: 8
                                        implicitHeight: 8
                                        radius: Appearance.rounding.full
                                        color: provCard.isConnected
                                            ? Colours.palette.m3primary
                                            : provCard.modelData.enabled
                                                ? Colours.palette.m3outline
                                                : Colours.layer(Colours.palette.m3surfaceContainerHighest, 1)
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2

                                        StyledText {
                                            Layout.fillWidth: true
                                            text: provCard.modelData.displayName
                                            font.pointSize: Appearance.font.size.normal
                                            font.weight: provCard.modelData.enabled ? 600 : 400
                                            elide: Text.ElideRight
                                        }

                                        StyledText {
                                            visible: provCard.modelData.interface !== ""
                                            text: provCard.modelData.interface
                                            color: Colours.palette.m3onSurfaceVariant
                                            font.pointSize: Appearance.font.size.smaller
                                            elide: Text.ElideRight
                                        }
                                    }

                                    // Connect/disconnect toggle
                                    StyledRect {
                                        id: linkBtn
                                        implicitWidth: implicitHeight
                                        implicitHeight: linkIcon.implicitHeight + Appearance.padding.smaller * 2
                                        radius: Appearance.rounding.full
                                        color: provCard.modelData.enabled && VPN.connected
                                            ? Colours.palette.m3primary
                                            : Colours.layer(Colours.palette.m3surfaceContainerHigh, 2)

                                        StateLayer {
                                            function onClicked() {
                                                root.toggleProvider(provCard.modelData.index);
                                            }
                                        }

                                        MaterialIcon {
                                            id: linkIcon
                                            anchors.centerIn: parent
                                            text: provCard.modelData.enabled && VPN.connected ? "link_off" : "link"
                                            color: provCard.modelData.enabled && VPN.connected
                                                ? Colours.palette.m3onPrimary
                                                : Colours.palette.m3onSurfaceVariant
                                            font.pointSize: Appearance.font.size.normal
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            InnerBorder {
                id: leftBorder
                leftThickness: 0
                rightThickness: Appearance.padding.normal / 2
            }
        }

        // Right — details (60%)
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ClippingRectangle {
                anchors.fill: parent
                anchors.margins: Appearance.padding.normal
                anchors.leftMargin: 0
                anchors.rightMargin: Appearance.padding.normal / 2
                radius: rightBorder.innerRadius
                color: "transparent"

                // Empty state
                Item {
                    anchors.fill: parent
                    visible: root.session.vpn.active === null

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: Appearance.spacing.normal

                        MaterialIcon {
                            Layout.alignment: Qt.AlignHCenter
                            text: "vpn_key"
                            color: Colours.palette.m3outlineVariant
                            font.pointSize: Appearance.font.size.extraLarge * 2
                        }

                        StyledText {
                            Layout.alignment: Qt.AlignHCenter
                            text: qsTr("Select a provider")
                            color: Colours.palette.m3outline
                            font.pointSize: Appearance.font.size.normal
                        }
                    }
                }

                // Provider details
                StyledFlickable {
                    id: detailsFlick
                    visible: root.session.vpn.active !== null
                    anchors.fill: parent
                    anchors.margins: Appearance.padding.large * 2
                    anchors.leftMargin: Appearance.padding.large
                    flickableDirection: Flickable.VerticalFlick
                    contentHeight: detailsCol.implicitHeight

                    StyledScrollBar.vertical: StyledScrollBar { flickable: detailsFlick }

                    ColumnLayout {
                        id: detailsCol
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        spacing: Appearance.spacing.normal

                        readonly property var active: root.session.vpn.active ?? ({})

                        // Header
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Appearance.spacing.normal

                            StyledRect {
                                radius: Appearance.rounding.normal
                                color: Colours.layer(
                                    detailsCol.active.enabled && VPN.connected
                                        ? Colours.palette.m3primaryContainer
                                        : Colours.palette.m3surfaceContainerHigh, 2)
                                implicitWidth: 48
                                implicitHeight: 48

                                MaterialIcon {
                                    anchors.centerIn: parent
                                    text: detailsCol.active.icon ?? "vpn_key"
                                    color: detailsCol.active.enabled && VPN.connected
                                        ? Colours.palette.m3onPrimaryContainer
                                        : Colours.palette.m3onSurfaceVariant
                                    font.pointSize: Appearance.font.size.extraLarge
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                StyledText {
                                    text: detailsCol.active.displayName ?? ""
                                    font.pointSize: Appearance.font.size.larger
                                    font.weight: 600
                                }

                                StyledText {
                                    text: {
                                        if (!detailsCol.active.enabled) return qsTr("Disabled")
                                        if (VPN.connecting) return qsTr("Connecting…")
                                        if (VPN.connected) return qsTr("Connected")
                                        return qsTr("Enabled")
                                    }
                                    color: detailsCol.active.enabled && VPN.connected
                                        ? Colours.palette.m3primary
                                        : Colours.palette.m3outline
                                    font.pointSize: Appearance.font.size.small
                                }
                            }
                        }

                        // Connection control
                        StyledRect {
                            Layout.fillWidth: true
                            radius: Appearance.rounding.normal
                            color: Colours.layer(Colours.palette.m3surfaceContainer, 1)
                            implicitHeight: connCol.implicitHeight + Appearance.padding.large * 2

                            ColumnLayout {
                                id: connCol
                                anchors.fill: parent
                                anchors.margins: Appearance.padding.large
                                spacing: Appearance.spacing.small

                                StyledText {
                                    text: qsTr("Connection")
                                    font.pointSize: Appearance.font.size.normal
                                    font.weight: 500
                                }

                                SwitchRow {
                                    label: qsTr("Set as active provider")
                                    checked: detailsCol.active.enabled ?? false
                                    onToggled: checked => {
                                        if (checked)
                                            root.setActive(detailsCol.active.index);
                                        else {
                                            const raw = Config.utilities.vpn.provider[detailsCol.active.index];
                                            const obj = (typeof raw === "object" && raw !== null) ? {} : { name: String(raw) };
                                            if (typeof raw === "object" && raw !== null)
                                                for (const k in raw) obj[k] = raw[k];
                                            obj.enabled = false;
                                            root.updateProvider(detailsCol.active.index, obj);
                                        }
                                    }
                                }

                                RowLayout {
                                    visible: detailsCol.active.enabled ?? false
                                    Layout.fillWidth: true
                                    spacing: Appearance.spacing.normal

                                    TextButton {
                                        enabled: !VPN.connecting
                                        text: VPN.connected ? qsTr("Disconnect") : qsTr("Connect")
                                        type: VPN.connected ? TextButton.Filled : TextButton.Tonal
                                        onClicked: VPN.toggle()
                                    }

                                    StyledText {
                                        visible: VPN.connected
                                        text: qsTr("via %1").arg(VPN.interfaceName)
                                        color: Colours.palette.m3outline
                                        font.pointSize: Appearance.font.size.smaller
                                    }
                                }
                            }
                        }

                        // Provider info — inlined (was component InfoRow)
                        StyledRect {
                            Layout.fillWidth: true
                            radius: Appearance.rounding.normal
                            color: Colours.layer(Colours.palette.m3surfaceContainer, 1)
                            implicitHeight: infoCol.implicitHeight + Appearance.padding.large * 2

                            ColumnLayout {
                                id: infoCol
                                anchors.fill: parent
                                anchors.margins: Appearance.padding.large
                                spacing: Appearance.spacing.small

                                StyledText {
                                    text: qsTr("Provider details")
                                    font.pointSize: Appearance.font.size.normal
                                    font.weight: 500
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: Appearance.spacing.normal
                                    StyledText {
                                        text: qsTr("Type")
                                        color: Colours.palette.m3outline
                                        font.pointSize: Appearance.font.size.small
                                    }
                                    Item { Layout.fillWidth: true }
                                    StyledText {
                                        text: detailsCol.active.name ?? ""
                                        font.pointSize: Appearance.font.size.small
                                        elide: Text.ElideLeft
                                    }
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: Appearance.spacing.normal
                                    StyledText {
                                        text: qsTr("Interface")
                                        color: Colours.palette.m3outline
                                        font.pointSize: Appearance.font.size.small
                                    }
                                    Item { Layout.fillWidth: true }
                                    StyledText {
                                        text: (detailsCol.active.interface !== "" ? detailsCol.active.interface : null) ?? "—"
                                        font.pointSize: Appearance.font.size.small
                                        elide: Text.ElideLeft
                                    }
                                }
                            }
                        }

                        // Actions
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Appearance.spacing.small

                            TextButton {
                                text: qsTr("Edit")
                                type: TextButton.Tonal
                                onClicked: vpnDialog.openForEdit(detailsCol.active)
                            }

                            TextButton {
                                text: qsTr("Delete")
                                type: TextButton.Tonal
                                onClicked: {
                                    if (detailsCol.active.enabled && VPN.connected)
                                        VPN.disconnect();
                                    root.deleteProvider(detailsCol.active.index);
                                }
                            }
                        }
                    }
                }
            }

            InnerBorder {
                id: rightBorder
                leftThickness: Appearance.padding.normal / 2
                rightThickness: Appearance.padding.normal
            }
        }
    }

    // ── Add / Edit dialog overlay ─────────────────────────────────────────────
    // Plain Item overlay — no inline components with required property
    Item {
        id: vpnDialog

        property bool visible_: false
        property bool isEdit: false
        property int editIndex: -1
        property string selectedType: "netbird"
        property string displayName_: ""
        property string interface_: ""
        property string step: "type-select"  // "type-select" | "form"

        function openForAdd() {
            isEdit = false;
            editIndex = -1;
            selectedType = "netbird";
            displayName_ = "";
            interface_ = "";
            step = "type-select";
            visible_ = true;
        }

        function openForEdit(provider) {
            isEdit = true;
            editIndex = provider.index;
            selectedType = provider.name;
            displayName_ = provider.displayName;
            interface_ = provider.interface;
            step = "form";
            visible_ = true;
        }

        function close() { visible_ = false; }

        function pickType(type) {
            selectedType = type;
            const builtin = root.builtinDefaults[type];
            if (builtin) {
                displayName_ = builtin.displayName;
                interface_ = builtin.interface;
            } else {
                displayName_ = "";
                interface_ = "";
            }
            if (type === "wireguard" || type === "custom") {
                if (type === "custom") { displayName_ = ""; interface_ = ""; }
                step = "form";
            } else {
                save();
            }
        }

        function save() {
            const builtin = root.builtinDefaults[selectedType];
            const obj = {
                name:        selectedType,
                displayName: displayName_ || builtin?.displayName || selectedType,
                interface:   interface_ || builtin?.interface || ""
            };
            if (isEdit && editIndex >= 0) {
                const raw = Config.utilities.vpn.provider[editIndex];
                if (typeof raw === "object" && raw !== null && raw.enabled === true)
                    obj.enabled = true;
                root.updateProvider(editIndex, obj);
                if (root.session.vpn.active?.index === editIndex)
                    root.session.vpn.active = root.providers[editIndex] ?? null;
            } else {
                root.addProvider(obj);
            }
            close();
        }

        anchors.fill: parent
        visible: visible_
        z: 100

        // Backdrop — includes MouseArea to close on outside click
        Rectangle {
            anchors.fill: parent
            color: Qt.alpha(Colours.palette.m3scrim, 0.4)

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    // Only close if click is outside the dialog card
                    if (!dialogCard.contains(mapToItem(dialogCard, mouseX, mouseY)))
                        vpnDialog.close();
                }
            }
        }

        // Dialog card
        StyledRect {
            id: dialogCard
            anchors.centerIn: parent
            width: Math.min(parent.width - Appearance.padding.large * 4, 420)
            implicitHeight: dialogContent.implicitHeight + Appearance.padding.large * 2
            radius: Appearance.rounding.normal
            color: Colours.palette.m3surfaceContainerHigh

            Elevation {
                anchors.fill: parent
                radius: parent.radius
                level: 3
            }

            // Prevent clicks on card from reaching the backdrop MouseArea
            MouseArea {
                anchors.fill: parent
                onClicked: {}
            }

            ColumnLayout {
                id: dialogContent
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: Appearance.padding.large
                spacing: Appearance.spacing.normal

                StyledText {
                    text: vpnDialog.isEdit ? qsTr("Edit provider") : qsTr("Add VPN provider")
                    font.pointSize: Appearance.font.size.larger
                    font.weight: 600
                }

                // ── Type selection step ───────────────────────────────────────
                ColumnLayout {
                    visible: vpnDialog.step === "type-select"
                    Layout.fillWidth: true
                    spacing: Appearance.spacing.small

                    StyledText {
                        text: qsTr("Choose provider type")
                        color: Colours.palette.m3outline
                        font.pointSize: Appearance.font.size.small
                    }

                    // Repeater over JS array — no inline component, direct modelData access
                    Repeater {
                        model: root.providerTypes

                        StyledRect {
                            id: typeCard
                            required property var modelData
                            Layout.fillWidth: true
                            radius: Appearance.rounding.normal
                            color: Colours.layer(Colours.palette.m3surfaceContainer, 1)
                            implicitHeight: typeRow.implicitHeight + Appearance.padding.normal * 2

                            StateLayer {
                                function onClicked() { vpnDialog.pickType(typeCard.modelData.type); }
                            }

                            RowLayout {
                                id: typeRow
                                anchors.fill: parent
                                anchors.margins: Appearance.padding.normal
                                spacing: Appearance.spacing.normal

                                MaterialIcon {
                                    text: typeCard.modelData.icon
                                    color: Colours.palette.m3primary
                                    font.pointSize: Appearance.font.size.large
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    StyledText {
                                        text: typeCard.modelData.label
                                        font.pointSize: Appearance.font.size.normal
                                        font.weight: 500
                                    }
                                    StyledText {
                                        text: typeCard.modelData.subtitle
                                        color: Colours.palette.m3outline
                                        font.pointSize: Appearance.font.size.smaller
                                    }
                                }

                                MaterialIcon {
                                    text: "chevron_right"
                                    color: Colours.palette.m3outline
                                    font.pointSize: Appearance.font.size.normal
                                }
                            }
                        }
                    }

                    TextButton {
                        Layout.alignment: Qt.AlignRight
                        text: qsTr("Cancel")
                        onClicked: vpnDialog.close()
                    }
                }

                // ── Form step ─────────────────────────────────────────────────
                ColumnLayout {
                    visible: vpnDialog.step === "form"
                    Layout.fillWidth: true
                    spacing: Appearance.spacing.small

                    StyledText {
                        text: qsTr("Display name")
                        color: Colours.palette.m3outline
                        font.pointSize: Appearance.font.size.small
                    }

                    StyledTextField {
                        id: displayNameField
                        Layout.fillWidth: true
                        placeholderText: root.builtinDefaults[vpnDialog.selectedType]?.displayName ?? qsTr("My VPN")
                        text: vpnDialog.displayName_
                        onTextChanged: vpnDialog.displayName_ = text
                    }

                    StyledText {
                        Layout.topMargin: Appearance.spacing.small
                        text: qsTr("Network interface")
                        color: Colours.palette.m3outline
                        font.pointSize: Appearance.font.size.small
                    }

                    StyledTextField {
                        id: interfaceField
                        Layout.fillWidth: true
                        placeholderText: root.builtinDefaults[vpnDialog.selectedType]?.interface ?? "wg0"
                        text: vpnDialog.interface_
                        onTextChanged: vpnDialog.interface_ = text
                    }

                    StyledText {
                        visible: vpnDialog.selectedType === "wireguard"
                        Layout.fillWidth: true
                        text: qsTr("Used as: wg-quick up <interface>")
                        color: Colours.palette.m3outlineVariant
                        font.pointSize: Appearance.font.size.smaller
                        wrapMode: Text.Wrap
                    }

                    StyledText {
                        visible: vpnDialog.selectedType === "custom"
                        Layout.fillWidth: true
                        text: qsTr("For fully custom commands, edit utilities.vpn.provider in shell.json directly.")
                        color: Colours.palette.m3outlineVariant
                        font.pointSize: Appearance.font.size.smaller
                        wrapMode: Text.Wrap
                    }

                    RowLayout {
                        Layout.topMargin: Appearance.spacing.small
                        Layout.fillWidth: true
                        spacing: Appearance.spacing.small

                        Item { Layout.fillWidth: true }

                        TextButton {
                            text: qsTr("Back")
                            visible: !vpnDialog.isEdit
                            onClicked: vpnDialog.step = "type-select"
                        }

                        TextButton {
                            text: qsTr("Cancel")
                            onClicked: vpnDialog.close()
                        }

                        TextButton {
                            text: vpnDialog.isEdit ? qsTr("Save") : qsTr("Add")
                            type: TextButton.Tonal
                            onClicked: vpnDialog.save()
                        }
                    }
                }
            }
        }
    }

    InnerBorder {
        leftThickness: 0
        rightThickness: Appearance.padding.normal
    }
}
