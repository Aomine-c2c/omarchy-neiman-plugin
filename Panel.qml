import QtQuick
import Quickshell
import qs.Commons
import qs.Ui

Panel {
    id: root
    moduleName: "io.github.aomine-c2c.neiman"
    manageIpc: false

    property var anchorItem: null
    property var hostWidget: null

    function open() {
        if (root.hostWidget && typeof root.hostWidget.refreshTelemetry === "function")
            root.hostWidget.refreshTelemetry()
        root.controller.show()
    }

    function close() {
        root.controller.hide()
    }

    function switchPanel(direction) {
        if (root.bar && typeof root.bar.switchPanelFrom === "function")
            return root.bar.switchPanelFrom(root.hostWidget || root, direction)
        return false
    }

    KeyboardPanel {
        id: panel
        anchorItem: root.anchorItem
        owner: root.hostWidget || root
        bar: root.bar
        open: root.opened
        focusTarget: keyCatcher
        contentWidth: panel.fittedContentWidth(Style.space(340))
        contentHeight: panel.fittedContentHeight(content.implicitHeight)

        PanelKeyCatcher {
            id: keyCatcher
            anchors.fill: parent
            onCloseRequested: root.close()
            onTabRequested: function(direction) {
                root.switchPanel(direction)
            }

            Column {
                id: content
                width: parent.width
                spacing: Style.space(10)

                // Header: Brand + Live Connection Status
                Column {
                    width: parent.width
                    spacing: Style.space(2)

                    Text {
                        width: parent.width
                        text: root.hostWidget ? root.hostWidget.activeCompanyName : "NEIMAN OS"
                        color: root.barForeground
                        font.family: root.bar ? root.bar.fontFamily : Style.font.family
                        font.pixelSize: Style.font.subtitle
                        font.bold: true
                        wrapMode: Text.WordWrap
                    }

                    Text {
                        width: parent.width
                        text: root.hostWidget ? root.hostWidget.lastStatusMessage : "Initializing..."
                        color: root.barForeground
                        opacity: 0.72
                        font.family: root.bar ? root.bar.fontFamily : Style.font.family
                        font.pixelSize: Style.font.caption
                        wrapMode: Text.WordWrap
                    }
                }

                // Quick Launch & Bootstrap Actions
                Row {
                    width: parent.width
                    spacing: Style.space(6)

                    Rectangle {
                        width: (parent.width - Style.space(12)) / 3
                        height: Style.space(30)
                        radius: Style.space(6)
                        color: "#22FFFFFF"
                        border.color: "#44FFFFFF"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "Desktop"
                            color: root.barForeground
                            font.pixelSize: Style.font.caption
                            font.bold: true
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (root.hostWidget)
                                    root.hostWidget.launchDesktop()
                                root.close()
                            }
                        }
                    }

                    Rectangle {
                        width: (parent.width - Style.space(12)) / 3
                        height: Style.space(30)
                        radius: Style.space(6)
                        color: "#22FFFFFF"
                        border.color: "#44FFFFFF"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "Rust TUI"
                            color: root.barForeground
                            font.pixelSize: Style.font.caption
                            font.bold: true
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (root.hostWidget)
                                    root.hostWidget.launchTui()
                                root.close()
                            }
                        }
                    }

                    Rectangle {
                        width: (parent.width - Style.space(12)) / 3
                        height: Style.space(30)
                        radius: Style.space(6)
                        color: "#22FFFFFF"
                        border.color: "#44FFFFFF"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "Refresh"
                            color: root.barForeground
                            font.pixelSize: Style.font.caption
                            font.bold: true
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (root.hostWidget)
                                    root.hostWidget.refreshTelemetry()
                            }
                        }
                    }
                }

                // 1-Click Install / Bootstrap NEIMAN (shown when offline)
                Rectangle {
                    visible: !(root.hostWidget && root.hostWidget.backendOnline)
                    width: parent.width
                    height: Style.space(34)
                    radius: Style.space(6)
                    color: "#3310B981"
                    border.color: "#8810B981"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "Install / Start NEIMAN Full Application"
                        color: root.barForeground
                        font.pixelSize: Style.font.caption
                        font.bold: true
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.hostWidget)
                                root.hostWidget.installOrBootstrapNeiman()
                        }
                    }
                }

                // Pending Approvals Section with Inline Approve / Reject
                Column {
                    width: parent.width
                    spacing: Style.space(6)
                    visible: root.hostWidget && root.hostWidget.pendingApprovals && root.hostWidget.pendingApprovals.length > 0

                    Text {
                        width: parent.width
                        text: "PENDING APPROVALS (" + (root.hostWidget ? root.hostWidget.pendingApprovals.length : 0) + ")"
                        color: "#F59E0B"
                        font.pixelSize: Style.font.caption
                        font.bold: true
                    }

                    Repeater {
                        model: root.hostWidget ? root.hostWidget.pendingApprovals.slice(0, 3) : []
                        delegate: Rectangle {
                            required property var modelData
                            width: content.width
                            implicitHeight: aprCol.implicitHeight + Style.space(12)
                            radius: Style.space(6)
                            color: "#1AF59E0B"
                            border.color: "#55F59E0B"
                            border.width: 1

                            Column {
                                id: aprCol
                                anchors.fill: parent
                                anchors.margins: Style.space(6)
                                spacing: Style.space(4)

                                Text {
                                    width: parent.width
                                    text: modelData.title || modelData.action || "Approval Gate"
                                    color: root.barForeground
                                    font.pixelSize: Style.font.caption
                                    font.bold: true
                                    wrapMode: Text.WordWrap
                                }

                                Row {
                                    spacing: Style.space(6)

                                    Rectangle {
                                        width: Style.space(76)
                                        height: Style.space(24)
                                        radius: Style.space(4)
                                        color: "#3310B981"
                                        Text {
                                            anchors.centerIn: parent
                                            text: "Approve"
                                            color: root.barForeground
                                            font.pixelSize: Style.font.caption
                                            font.bold: true
                                        }
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (root.hostWidget)
                                                    root.hostWidget.decideApproval(modelData.id, "APPROVED")
                                            }
                                        }
                                    }

                                    Rectangle {
                                        width: Style.space(64)
                                        height: Style.space(24)
                                        radius: Style.space(4)
                                        color: "#33EF4444"
                                        Text {
                                            anchors.centerIn: parent
                                            text: "Reject"
                                            color: root.barForeground
                                            font.pixelSize: Style.font.caption
                                            font.bold: true
                                        }
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (root.hostWidget)
                                                    root.hostWidget.decideApproval(modelData.id, "REJECTED")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Live 14-State Agent Roster
                Column {
                    width: parent.width
                    spacing: Style.space(4)

                    Text {
                        width: parent.width
                        text: "LIVE AGENTS (" + (root.hostWidget ? root.hostWidget.liveAgents.length : 0) + ")"
                        color: root.barForeground
                        opacity: 0.75
                        font.pixelSize: Style.font.caption
                        font.bold: true
                    }

                    Text {
                        visible: !(root.hostWidget && root.hostWidget.liveAgents && root.hostWidget.liveAgents.length > 0)
                        width: parent.width
                        text: root.hostWidget && root.hostWidget.backendOnline
                            ? "No active agent sessions reported yet."
                            : "Start NEIMAN to view live 14-state agent telemetry."
                        color: root.barForeground
                        opacity: 0.6
                        font.pixelSize: Style.font.caption
                        wrapMode: Text.WordWrap
                    }

                    Repeater {
                        model: root.hostWidget ? root.hostWidget.liveAgents.slice(0, 6) : []
                        delegate: Rectangle {
                            required property var modelData
                            width: content.width
                            implicitHeight: agCol.implicitHeight + Style.space(10)
                            radius: Style.space(6)
                            color: "#14FFFFFF"
                            border.color: "#22FFFFFF"
                            border.width: 1

                            Column {
                                id: agCol
                                anchors.fill: parent
                                anchors.margins: Style.space(5)
                                spacing: Style.space(2)

                                Text {
                                    width: parent.width
                                    text: (modelData.agent_name || "Agent") + "  [" + (modelData.state || "IDLE") + "]"
                                    color: root.barForeground
                                    font.pixelSize: Style.font.caption
                                    font.bold: true
                                    elide: Text.ElideRight
                                }

                                Text {
                                    width: parent.width
                                    text: modelData.current_task || "Standing by"
                                    color: root.barForeground
                                    opacity: 0.7
                                    font.pixelSize: Style.font.caption
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
