import QtQuick
import Quickshell
import qs.Ui

BarWidget {
    id: root
    moduleName: "io.github.aomine-c2c.neiman"

    readonly property bool opened: panelLoader.item ? panelLoader.item.opened === true : false
    readonly property bool popoutSwitchClosing: panelLoader.item ? panelLoader.item.popoutSwitchClosing === true : false

    property string apiUrl: "http://127.0.0.1:8000"
    property int pollIntervalSec: 10

    property bool backendOnline: false
    property string activeCompanyId: ""
    property string activeCompanyName: "NEIMAN OS"
    property var liveAgents: []
    property var pendingApprovals: []
    property string lastStatusMessage: "Connecting to NEIMAN backend..."

    function open() {
        if (panelLoader.item)
            panelLoader.item.open()
    }

    function close() {
        if (panelLoader.item)
            panelLoader.item.close()
    }

    function toggle() {
        if (panelLoader.item)
            panelLoader.item.toggle()
    }

    function closeForPopoutSwitch() {
        if (panelLoader.item)
            panelLoader.item.closeForPopoutSwitch()
    }

    function injectPanel() {
        if (!panelLoader.item)
            return
        panelLoader.item.bar = root.bar
        panelLoader.item.anchorItem = button
        panelLoader.item.hostWidget = root
    }

    function fetchJson(path, onSuccess, onError) {
        var xhr = new XMLHttpRequest()
        xhr.open("GET", root.apiUrl + path)
        xhr.timeout = 4000
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE)
                return
            if (xhr.status >= 200 && xhr.status < 300) {
                try {
                    onSuccess(JSON.parse(xhr.responseText))
                } catch (e) {
                    if (onError)
                        onError("Invalid JSON response")
                }
            } else {
                if (onError)
                    onError("HTTP " + xhr.status)
            }
        }
        xhr.ontimeout = function() {
            if (onError)
                onError("Timeout")
        }
        xhr.send()
    }

    function postJson(path, payload, onDone) {
        var xhr = new XMLHttpRequest()
        xhr.open("POST", root.apiUrl + path)
        xhr.setRequestHeader("Content-Type", "application/json")
        xhr.timeout = 5000
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && onDone)
                onDone(xhr.status >= 200 && xhr.status < 300)
        }
        xhr.send(JSON.stringify(payload))
    }

    function refreshTelemetry() {
        fetchJson("/api/v1/companies", function(companies) {
            root.backendOnline = true
            if (Array.isArray(companies) && companies.length > 0) {
                root.activeCompanyId = companies[0].id || ""
                root.activeCompanyName = companies[0].name || "NEIMAN OS"
                root.lastStatusMessage = "Connected · " + root.activeCompanyName
                fetchCompanyDetails(root.activeCompanyId)
            } else {
                root.activeCompanyId = ""
                root.liveAgents = []
                root.pendingApprovals = []
                root.lastStatusMessage = "Online · No organization initialized"
            }
        }, function() {
            root.backendOnline = false
            root.liveAgents = []
            root.pendingApprovals = []
            root.lastStatusMessage = "Backend offline (" + root.apiUrl + ")"
        })
    }

    function fetchCompanyDetails(companyId) {
        if (!companyId)
            return
        fetchJson("/api/v1/companies/" + companyId + "/activity/reconcile", function(sessions) {
            if (Array.isArray(sessions))
                root.liveAgents = sessions
        }, null)
        fetchJson("/api/v1/companies/" + companyId + "/governance/approvals?status=PENDING", function(approvals) {
            if (Array.isArray(approvals))
                root.pendingApprovals = approvals
        }, null)
    }

    function decideApproval(approvalId, decision) {
        if (!root.activeCompanyId || !approvalId)
            return
        postJson(
            "/api/v1/companies/" + root.activeCompanyId + "/governance/approvals/" + approvalId + "/decide",
            { decision: decision, reviewer_notes: "Decided from Omarchy Bar Plugin" },
            function(ok) {
                root.lastStatusMessage = ok
                    ? ("Approval " + decision + ": " + approvalId)
                    : "Approval decision failed"
                root.refreshTelemetry()
            }
        )
    }

    function launchDesktop() {
        Quickshell.execDetached(["sh", "-c", "command -v neiman-desktop >/dev/null 2>&1 && neiman-desktop || ~/.local/bin/neiman-desktop"])
    }

    function launchTui() {
        Quickshell.execDetached(["sh", "-c", "xdg-terminal-exec neiman-cli 2>/dev/null || alacritty -e neiman-cli 2>/dev/null || kitty neiman-cli 2>/dev/null || foot neiman-cli"])
    }

    function installOrBootstrapNeiman() {
        var scriptPath = Qt.resolvedUrl("install-neiman.sh").toString().replace("file://", "")
        Quickshell.execDetached(["sh", "-c", "xdg-terminal-exec bash '" + scriptPath + "' 2>/dev/null || bash '" + scriptPath + "'"])
        root.lastStatusMessage = "Launching NEIMAN installer / bootstrapper..."
    }

    implicitWidth: button.implicitWidth
    implicitHeight: button.implicitHeight
    onBarChanged: injectPanel()

    Component.onCompleted: refreshTelemetry()

    Timer {
        id: pollTimer
        interval: Math.max(5, root.pollIntervalSec) * 1000
        running: true
        repeat: true
        onTriggered: root.refreshTelemetry()
    }

    Loader {
        id: panelLoader
        active: true
        source: Qt.resolvedUrl("Panel.qml")
        visible: false
        onLoaded: {
            root.injectPanel()
            Qt.callLater(root.injectPanel)
        }
    }

    WidgetButton {
        id: button
        anchors.fill: parent
        bar: root.bar
        text: {
            if (!root.backendOnline)
                return "○ NEIMAN"
            var activeCount = root.liveAgents.length
            var aprCount = root.pendingApprovals.length
            return aprCount > 0
                ? ("● NEIMAN " + activeCount + "A · " + aprCount + "!")
                : ("● NEIMAN " + activeCount + "A")
        }
        tooltipText: root.lastStatusMessage
        onPressed: function(buttonCode) {
            if (buttonCode === Qt.LeftButton)
                root.toggle()
        }
    }
}
