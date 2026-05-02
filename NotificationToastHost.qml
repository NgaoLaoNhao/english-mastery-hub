import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Item {
    id: host

    property var auth: null
    property var notification: null
    property var adminUser: null

    // Callback khi click toast: nhận link string ("resource:1", "group:2", ...)
    signal toastClicked(string link, int refId)

    readonly property string currentUsername: auth ? (auth.currentUsername || "") : ""
    readonly property int currentUserId: {
        if (!adminUser || !currentUsername) return -1
        var us = adminUser.users || []
        for (var i = 0; i < us.length; i++)
            if (us[i].username === currentUsername) return us[i].id
        return -1
    }

    // Buffer các toast đang hiển thị (model cho Repeater)
    property var _toasts: []
    property int _toastNextKey: 1
    readonly property int _maxVisible: 3

    // ===== Hook signal notifAdded =====
    Connections {
        target: notification
        function onNotifAdded(id, recipientUserId) {
            if (recipientUserId !== host.currentUserId) return  // chỉ toast cho mình
            var n = notification.getById(id)
            if (!n) return

            var arr = host._toasts.slice()
            arr.unshift({
                key: host._toastNextKey++,
                notifId: n.id,
                type: n.type,
                title: n.title,
                body: n.body,
                link: n.link,
                refId: n.refId
            })
            // Giới hạn hiển thị
            if (arr.length > host._maxVisible) arr = arr.slice(0, host._maxVisible)
            host._toasts = arr
        }
    }

    function _removeByKey(k) {
        host._toasts = host._toasts.filter(function(t) { return t.key !== k })
    }

    // ===== Toast stack — neo bottom-right =====
    ColumnLayout {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 20
        anchors.bottomMargin: 20
        spacing: 10
        z: 9999

        Repeater {
            model: host._toasts

            delegate: Rectangle {
                id: toast
                required property var modelData
                Layout.preferredWidth: 340
                Layout.preferredHeight: tCol.implicitHeight + 24

                radius: 10
                color: "white"
                border.width: 1
                border.color: "#e2e8f0"

                // Slide-in animation
                opacity: 0
                x: 60
                Component.onCompleted: {
                    slideIn.start()
                    autoDismiss.start()
                }
                NumberAnimation on opacity {
                    id: slideIn
                    to: 1
                    duration: 250
                    easing.type: Easing.OutCubic
                }
                NumberAnimation on x {
                    to: 0
                    duration: 250
                    easing.type: Easing.OutCubic
                    running: slideIn.running
                }

                // Slide-out animation
                NumberAnimation {
                    id: slideOut
                    target: toast
                    properties: "opacity"
                    to: 0
                    duration: 200
                    onStopped: host._removeByKey(toast.modelData.key)
                }

                // Auto-dismiss timer
                Timer {
                    id: autoDismiss
                    interval: 4000
                    onTriggered: slideOut.start()
                }

                // Drop shadow giả
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -2
                    z: -1
                    radius: 12
                    color: "transparent"
                    border.color: "#0f172a22"
                    border.width: 2
                }

                // Color stripe bên trái theo type
                Rectangle {
                    width: 4
                    height: parent.height - 8
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    anchors.verticalCenter: parent.verticalCenter
                    radius: 2
                    color: notification ? notification.typeColor(toast.modelData.type) : "#64748b"
                }

                MouseArea {
                    id: hoverArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    // Pause timer khi hover
                    onEntered: autoDismiss.stop()
                    onExited:  autoDismiss.restart()

                    onClicked: {
                        if (notification) notification.markRead(toast.modelData.notifId)
                        host.toastClicked(toast.modelData.link || "", toast.modelData.refId || 0)
                        slideOut.start()
                    }
                }

                ColumnLayout {
                    id: tCol
                    anchors.fill: parent
                    anchors.margins: 12
                    anchors.leftMargin: 16
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Label {
                            text: notification ? notification.typeIcon(toast.modelData.type) : "🔔"
                            font.pixelSize: 18
                        }
                        Label {
                            text: toast.modelData.title
                            color: "#0f172a"
                            font.pixelSize: 13; font.bold: true
                            elide: Label.ElideRight
                            Layout.fillWidth: true
                        }
                        Button {
                            text: "✕"
                            flat: true
                            implicitWidth: 24
                            implicitHeight: 24
                            onClicked: slideOut.start()
                        }
                    }

                    Label {
                        text: toast.modelData.body
                        color: "#475569"
                        font.pixelSize: 12
                        wrapMode: Label.Wrap
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }
}