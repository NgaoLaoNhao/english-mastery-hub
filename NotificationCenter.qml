import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Popup {
    id: root

    property var notification: null
    property var auth: null
    property var adminUser: null
    property int currentUserId: -1

    signal navigateRequested(string link, int refId)

    width: 380
    height: 480
    modal: false
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
    padding: 0

    background: Rectangle {
        color: "white"
        radius: 12
        border.color: "#e2e8f0"
        border.width: 1
        layer.enabled: true
    }

    // Tick để re-evaluate khi có thay đổi
    property int _tick: 0
    Connections {
        target: notification
        function onNotifAdded(id, uid)     { root._tick++ }
        function onNotifRead(id)           { root._tick++ }
        function onAllMarkedRead(uid)      { root._tick++ }
        function onNotifDeleted(id)        { root._tick++ }
    }

    readonly property var items: {
        _tick
        if (!notification || currentUserId <= 0) return []
        return notification.getForUser(currentUserId)
    }
    readonly property int unreadCount: {
        _tick
        if (!notification || currentUserId <= 0) return 0
        return notification.getUnreadCount(currentUserId)
    }

    function _userById(uid) {
        if (!adminUser || uid < 0) return null
        var us = adminUser.users || []
        for (var i = 0; i < us.length; i++) if (us[i].id === uid) return us[i]
        return null
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Header
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 52
            color: "#1f1f2e"
            radius: 12

            // Che radius 2 góc dưới
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 12
                color: "#1f1f2e"
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 8
                spacing: 8

                Label {
                    text: "🔔 Thông báo"
                    color: "white"
                    font.pixelSize: 15
                    font.bold: true
                }
                Rectangle {
                    visible: unreadCount > 0
                    color: "#ef4444"
                    radius: 10
                    implicitHeight: 18
                    implicitWidth: badgeLbl.implicitWidth + 12
                    Label {
                        id: badgeLbl
                        anchors.centerIn: parent
                        text: unreadCount + " mới"
                        color: "white"
                        font.pixelSize: 10
                        font.bold: true
                    }
                }
                Item { Layout.fillWidth: true }
                Rectangle {
                    visible: unreadCount > 0
                    color: markAllMa.containsMouse ? "#ffffff22" : "transparent"
                    radius: 6
                    implicitHeight: 28
                    implicitWidth: markAllLbl.implicitWidth + 18
                    border.color: markAllMa.containsMouse ? "#ffffff44" : "transparent"
                    border.width: 1

                    Label {
                        id: markAllLbl
                        anchors.centerIn: parent
                        text: "✓ Đọc tất cả"
                        color: "white"
                        font.pixelSize: 12
                        font.bold: true
                    }
                    MouseArea {
                        id: markAllMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (notification && currentUserId > 0)
                                notification.markAllRead(currentUserId)
                        }
                        ToolTip.text: "Đánh dấu tất cả đã đọc"
                        ToolTip.visible: containsMouse
                        ToolTip.delay: 400
                    }
                }

                Rectangle {
                    color: closeMa.containsMouse ? "#ef444466" : "transparent"
                    radius: 6
                    implicitHeight: 28
                    implicitWidth: 28

                    Label {
                        anchors.centerIn: parent
                        text: "✕"
                        color: "white"
                        font.pixelSize: 14
                        font.bold: true
                    }
                    MouseArea {
                        id: closeMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.close()
                    }
                }
            }
        }

        // Empty state
        Item {
            visible: items.length === 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 6
                Label {
                    text: "📭"
                    font.pixelSize: 48
                    Layout.alignment: Qt.AlignHCenter
                }
                Label {
                    text: "Chưa có thông báo nào"
                    color: "#94a3b8"
                    font.pixelSize: 13
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }

        // List
        ScrollView {
            visible: items.length > 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: availableWidth
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 0

                Repeater {
                    model: root.items
                    delegate: Rectangle {
                        id: nItem
                        required property var modelData
                        Layout.fillWidth: true
                        Layout.preferredHeight: nRow.implicitHeight + 16
                        color: !modelData.read
                                ? (nMa.containsMouse ? "#eff6ff" : "#f0f9ff")
                                : (nMa.containsMouse ? "#f8fafc" : "white")
                        border.color: "#f1f5f9"
                        border.width: 1

                        readonly property color stripeColor:
                            notification ? notification.typeColor(modelData.type) : "#64748b"

                        // Stripe bên trái
                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: 3
                            color: nItem.stripeColor
                            visible: !modelData.read
                        }

                        MouseArea {
                            id: nMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (notification && !modelData.read)
                                    notification.markRead(modelData.id)
                                if (modelData.link)
                                    root.navigateRequested(modelData.link, modelData.refId || 0)
                                root.close()
                            }
                        }

                        RowLayout {
                            id: nRow
                            anchors.fill: parent
                            anchors.margins: 10
                            anchors.leftMargin: 14
                            spacing: 10

                            // Icon
                            Rectangle {
                                Layout.preferredWidth: 36
                                Layout.preferredHeight: 36
                                Layout.alignment: Qt.AlignTop
                                radius: 18
                                color: Qt.lighter(nItem.stripeColor, 1.7)
                                Label {
                                    anchors.centerIn: parent
                                    text: notification ? notification.typeIcon(modelData.type) : "🔔"
                                    font.pixelSize: 18
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 4
                                    Label {
                                        text: modelData.title || ""
                                        color: "#0f172a"
                                        font.pixelSize: 13
                                        font.bold: !modelData.read
                                        elide: Label.ElideRight
                                        Layout.fillWidth: true
                                    }
                                    Rectangle {
                                        visible: !modelData.read
                                        Layout.preferredWidth: 8
                                        Layout.preferredHeight: 8
                                        radius: 4
                                        color: "#3b82f6"
                                    }
                                }

                                Label {
                                    text: modelData.body || ""
                                    color: "#475569"
                                    font.pixelSize: 12
                                    wrapMode: Label.Wrap
                                    Layout.fillWidth: true
                                    maximumLineCount: 2
                                    elide: Label.ElideRight
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 6
                                    Label {
                                        text: notification ? notification.relativeTime(modelData.createdAt) : ""
                                        color: "#94a3b8"
                                        font.pixelSize: 10
                                    }
                                    Item { Layout.fillWidth: true }
                                    Button {
                                        text: "🗑"
                                        flat: true
                                        ToolTip.text: "Xóa"
                                        ToolTip.visible: hovered
                                        implicitHeight: 20
                                        implicitWidth: 22
                                        onClicked: {
                                            if (notification) notification.deleteNotif(modelData.id)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}