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
        // Enable the target, disable all others
        const arr = [];
        for (let i = 0; i < Config.utilities.vpn.provider.length; i++) {
            const raw = Config.utilities.vpn.provider[i];
            const isObj = typeof raw === "object" && raw !== null;
            if (isObj) {
                const copy = Object.assign({}, raw);
                copy.enabled = (i === idx);
                arr.push(copy);
            } else {
                // Convert string to object so we can store enabled flag
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

    // pendingSwitchIndex: when we need to disable current provider first
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
            // This provider is already active — just connect/disconnect
            VPN.toggle();
        } else if (VPN.connected) {
            // Another provider is connected — disconnect first, then switch
            root.pendingSwitchIndex = idx;
            VPN.disconnect();
        } else {
            // Just enable this one and connect
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

                                Behavior on color { CAnim {} }
                            }
                        }

                        // Add provider button
                        StyledRect {
                            Layout.fillWidth: true
                            radius: Appearance.rounding.normal
                            color: Colours.layer(Colours.palette.m3surfaceContainerHigh, 1)
                            implicitHeight: addRow.implicitHeight + Appearance.padding.normal * 2

                            StateLayer {
                                function onClicked(): void { vpnDialog.openForAdd(); }
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

                        // Empty state
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

                        // Provider list
                        Repeater {
                            model: root.providers

                            Item {
                                id: providerItem
                                required property var modelData
                                readonly property bool isSelected: root.session.vpn.active !== null &&
                                                                   root.session.vpn.active.index === modelData.index
                                readonly property bool isConnected: modelData.enabled && VPN.connected

                                Layout.fillWidth: true
                                implicitHeight: provCard.implicitHeight

                                StyledRect {
                                    id: provCard
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    radius: Appearance.rounding.normal
                                    color: providerItem.isSelected
                                        ? Colours.layer(Colours.palette.m3secondaryContainer, 1)
                                        : Colours.layer(Colours.palette.m3surfaceContainer, 1)
                                    implicitHeight: provRow.implicitHeight + Appearance.padding.normal * 2

                                    Behavior on color { CAnim {} }

                                    StateLayer {
                                        color: providerItem.isSelected
                                            ? Colours.palette.m3onSecondaryContainer
                                            : Colours.palette.m3onSurface
                                        function onClicked(): void {
                                            root.session.vpn.active = providerItem.modelData;
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
                                            color: providerItem.isConnected
                                                ? Colours.palette.m3primary
                                                : providerItem.modelData.enabled
                                                    ? Colours.palette.m3outline
                                                    : Colours.layer(Colours.palette.m3surfaceContainerHighest, 1)

                                            Behavior on color { CAnim {} }
                                        }

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 2

                                            StyledText {
                                                Layout.fillWidth: true
                                                text: providerItem.modelData.displayName
                                                font.pointSize: Appearance.font.size.normal
                                                font.weight: providerItem.modelData.enabled ? 600 : 400
                                                elide: Text.ElideRight
                                            }

                                            StyledText {
                                                visible: providerItem.modelData.interface !== ""
                                                text: providerItem.modelData.interface
                                                color: Colours.palette.m3onSurfaceVariant
                                                font.pointSize: Appearance.font.size.smaller
                                                elide: Text.ElideRight
                                            }
                                        }

                                        // Connect/disconnect toggle
                                        StyledRect {
                                            implicitWidth: implicitHeight
                                            implicitHeight: linkIcon.implicitHeight + Appearance.padding.smaller * 2
                                            radius: Appearance.rounding.full
                                            color: providerItem.modelData.enabled && VPN.connected
                                                ? Colours.palette.m3primary
                                                : Colours.layer(Colours.palette.m3surfaceContainerHigh, 2)

                                            Behavior on color { CAnim {} }

                                            StateLayer {
                                                function onClicked(): void {
                                                    root.toggleProvider(providerItem.modelData.index);
                                                }
                                            }

                                            MaterialIcon {
                                                id: linkIcon
                                                anchors.centerIn: parent
                                                text: providerItem.modelData.enabled && VPN.connected
                                                    ? "link_off"
                                                    : "link"
                                                color: providerItem.modelData.enabled && VPN.connected
                                                    ? Colours.palette.m3onPrimary
                                                    : Colours.palette.m3onSurfaceVariant
                                                font.pointSize: Appearance.font.size.normal

                                                Behavior on color { CAnim {} }
                                            }
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

        // Right — details or empty state (60%)
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

                        // ── Header ────────────────────────────────────────────
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Appearance.spacing.normal

                            StyledRect {
                                radius: Appearance.rounding.normal
                                color: Colours.layer(
                                    detailsCol.active.enabled && VPN.connected
                                        ? Colours.palette.m3primaryContainer
                                        : Colours.palette.m3surfaceContainerHigh,
                                    2)
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

                                Behavior on color { CAnim {} }
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

                        // ── Connection control ────────────────────────────────
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
                                            // Disable without enabling another
                                            const raw = Config.utilities.vpn.provider[detailsCol.active.index];
                                            const obj = typeof raw === "object" ? Object.assign({}, raw) : { name: String(raw) };
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

                        // ── Provider info ─────────────────────────────────────
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

                                component InfoRow: RowLayout {
                                    required property string label
                                    required property string value
                                    Layout.fillWidth: true
                                    spacing: Appearance.spacing.normal
                                    StyledText {
                                        text: parent.label
                                        color: Colours.palette.m3outline
                                        font.pointSize: Appearance.font.size.small
                                    }
                                    Item { Layout.fillWidth: true }
                                    StyledText {
                                        text: parent.value
                                        font.pointSize: Appearance.font.size.small
                                        elide: Text.ElideLeft
                                    }
                                }

                                InfoRow {
                                    label: qsTr("Type")
                                    value: detailsCol.active.name ?? ""
                                }

                                InfoRow {
                                    label: qsTr("Interface")
                                    value: detailsCol.active.interface !== "" ? detailsCol.active.interface : "—"
                                }
                            }
                        }

                        // ── Actions ───────────────────────────────────────────
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

    // ── Add / Edit dialog ─────────────────────────────────────────────────────
    Item {
        id: vpnDialog

        property bool visible_: false
        property bool isEdit: false
        property int editIndex: -1

        // Form fields
        property string selectedType: "netbird"
        property string displayName: ""
        property string interface_: ""

        // Dialog state: "type-select" | "form"
        property string step: "type-select"

        function openForAdd() {
            isEdit = false;
            editIndex = -1;
            selectedType = "netbird";
            displayName = "";
            interface_ = "";
            step = "type-select";
            visible_ = true;
        }

        function openForEdit(provider) {
            isEdit = true;
            editIndex = provider.index;
            selectedType = provider.name;
            displayName = provider.displayName;
            interface_ = provider.interface;
            step = "form";
            visible_ = true;
        }

        function close() {
            visible_ = false;
        }

        function pickType(type) {
            selectedType = type;
            const builtin = root.builtinDefaults[type];
            if (builtin) {
                displayName = builtin.displayName;
                interface_ = builtin.interface;
            } else {
                displayName = "";
                interface_ = "";
            }
            // wireguard and "custom" go to form; others save directly
            if (type === "wireguard" || type === "custom") {
                if (type === "custom") {
                    displayName = "";
                    interface_ = "";
                }
                step = "form";
            } else {
                save();
            }
        }

        function save() {
            const obj = {
                name:        selectedType,
                displayName: displayName || (root.builtinDefaults[selectedType]?.displayName ?? selectedType),
                interface:   interface_ || (root.builtinDefaults[selectedType]?.interface ?? "")
            };

            if (isEdit && editIndex >= 0) {
                // Preserve enabled state
                const raw = Config.utilities.vpn.provider[editIndex];
                if (typeof raw === "object" && raw !== null && raw.enabled === true)
                    obj.enabled = true;
                root.updateProvider(editIndex, obj);
                // Refresh active if we edited the selected provider
                if (root.session.vpn.active?.index === editIndex)
                    root.session.vpn.active = root.providers[editIndex] ?? null;
            } else {
                root.addProvider(obj);
            }
            close();
        }

        // Overlay backdrop
        anchors.fill: parent
        visible: visible_
        z: 100

        Rectangle {
            anchors.fill: parent
            color: Qt.alpha(Colours.palette.m3scrim, 0.4)

            Behavior on opacity { Anim { duration: Appearance.anim.durations.small } }
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

            ColumnLayout {
                id: dialogContent
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: Appearance.padding.large
                spacing: Appearance.spacing.normal

                // Title
                StyledText {
                    text: vpnDialog.isEdit ? qsTr("Edit provider") : qsTr("Add VPN provider")
                    font.pointSize: Appearance.font.size.larger
                    font.weight: 600
                }

                // ── Step: type selection ──────────────────────────────────────
                ColumnLayout {
                    visible: vpnDialog.step === "type-select"
                    Layout.fillWidth: true
                    spacing: Appearance.spacing.small

                    StyledText {
                        text: qsTr("Choose provider type")
                        color: Colours.palette.m3outline
                        font.pointSize: Appearance.font.size.small
                    }

                    component TypeCard: StyledRect {
                        required property string type
                        required property string label
                        required property string icon
                        required property string subtitle

                        Layout.fillWidth: true
                        radius: Appearance.rounding.normal
                        color: Colours.layer(Colours.palette.m3surfaceContainer, 1)
                        implicitHeight: typeRow.implicitHeight + Appearance.padding.normal * 2

                        StateLayer {
                            function onClicked(): void { vpnDialog.pickType(parent.type); }
                        }

                        RowLayout {
                            id: typeRow
                            anchors.fill: parent
                            anchors.margins: Appearance.padding.normal
                            spacing: Appearance.spacing.normal

                            MaterialIcon {
                                text: parent.parent.icon
                                color: Colours.palette.m3primary
                                font.pointSize: Appearance.font.size.large
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                StyledText {
                                    text: parent.parent.label
                                    font.pointSize: Appearance.font.size.normal
                                    font.weight: 500
                                }
                                StyledText {
                                    text: parent.parent.subtitle
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

                    TypeCard { type: "netbird";   label: "NetBird";         icon: "lan";      subtitle: qsTr("Open source secure network") }
                    TypeCard { type: "tailscale"; label: "Tailscale";       icon: "hub";      subtitle: qsTr("Zero-config mesh VPN") }
                    TypeCard { type: "warp";      label: "Cloudflare WARP"; icon: "shield";   subtitle: qsTr("Fast DNS + encrypted tunneling") }
                    TypeCard { type: "wireguard"; label: "WireGuard";       icon: "vpn_lock"; subtitle: qsTr("Kernel-level encrypted tunnel") }
                    TypeCard { type: "custom";    label: qsTr("Custom…");   icon: "tune";     subtitle: qsTr("Manual connect / disconnect commands") }

                    TextButton {
                        Layout.alignment: Qt.AlignRight
                        text: qsTr("Cancel")
                        onClicked: vpnDialog.close()
                    }
                }

                // ── Step: form ───────────────────────────────────────────────
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
                        text: vpnDialog.displayName
                        onTextChanged: vpnDialog.displayName = text
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
                        text: qsTr("Used for: wg-quick up <interface>")
                        color: Colours.palette.m3outlineVariant
                        font.pointSize: Appearance.font.size.smaller
                        wrapMode: Text.Wrap
                    }

                    StyledText {
                        visible: vpnDialog.selectedType === "custom"
                        Layout.fillWidth: true
                        text: qsTr("Connect / disconnect commands use the interface name as their argument. For fully custom commands, edit shell.json directly.")
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
