import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Item {
    id: root

    property var notification: null
    property var auth: null
    property var adminUser: null
    property int currentUserId: -1

    signal navigateRequested(string link, int refId)

    implicitWidth: 44
    implicitHeight: 36

    property int _tick: 0
    Connections {
        target: notification
        function onNotifAdded(id, uid)     { root._tick++ }
        function onNotifRead(id)           { root._tick++ }
        function onAllMarkedRead(uid)      { root._tick++ }
        function onNotifDeleted(id)        { root._tick++ }
    }

    readonly property int unreadCount: {
        _tick
        if (!notification || currentUserId <= 0) return 0
        return notification.getUnreadCount(currentUserId)
    }

    Rectangle {
        id: bellBg
        anchors.fill: parent
        radius: 8
        color: bellMa.containsMouse ? "#ffffff22" : "transparent"
        border.color: bellMa.containsMouse ? "#ffffff44" : "transparent"
        border.width: 1

        Label {
            anchors.centerIn: parent
            text: "🔔"
            font.pixelSize: 20
        }

        // Badge
        Rectangle {
            visible: unreadCount > 0
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: -2
            anchors.topMargin: -2
            implicitHeight: 18
            implicitWidth: Math.max(18, badgeLbl.implicitWidth + 8)
            radius: 9
            color: "#ef4444"
            border.color: "white"
            border.width: 2

            Label {
                id: badgeLbl
                anchors.centerIn: parent
                text: unreadCount > 99 ? "99+" : unreadCount
                color: "white"
                font.pixelSize: 10
                font.bold: true
            }

            // Pulse khi có unread
            SequentialAnimation on scale {
                running: unreadCount > 0
                loops: Animation.Infinite
                NumberAnimation { to: 1.15; duration: 600; easing.type: Easing.InOutSine }
                NumberAnimation { to: 1.00; duration: 600; easing.type: Easing.InOutSine }
            }
        }

        MouseArea {
            id: bellMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (centerPopup.opened) centerPopup.close()
                else centerPopup.open()
            }
        }
    }

    NotificationCenter {
        id: centerPopup
        notification: root.notification
        auth: root.auth
        adminUser: root.adminUser
        currentUserId: root.currentUserId

        // Đặt popup ngay dưới bell, lệch về bên trái để fit trong window
        x: -width + root.width
        y: root.height + 6

        onNavigateRequested: function(link, refId) {
            root.navigateRequested(link, refId)
        }
    }
}