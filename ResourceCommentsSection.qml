import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Rectangle {
    id: root

    property var auth: null
    property var resource: null
    property var adminUser: null
    property int resourceId: -1
    property int currentUserId: -1
    property string currentRole: ""

    Layout.fillWidth: true
    Layout.preferredHeight: col.implicitHeight + 24
    color: "white"
    border.color: "#e2e8f0"; border.width: 1
    radius: 10

    // Re-evaluate khi comment thay đổi
    property int _tick: 0
    Connections {
        target: resource
        function onCommentAdded(id, rid)   { root._tick++ }
        function onCommentDeleted(id)      { root._tick++ }
    }

    readonly property var comments: {
        _tick // depend
        return resource && resourceId > 0 ? resource.getComments(resourceId) : []
    }

    function _userById(uid) {
        if (!adminUser || uid < 0) return null
        var us = adminUser.users || []
        for (var i = 0; i < us.length; i++)
            if (us[i].id === uid) return us[i]
        return null
    }

    // Format ISO datetime → "HH:mm" nếu hôm nay, ngược lại "DD/MM HH:mm"
    function _fmtTime(iso) {
        if (!iso) return ""
        var d = new Date(iso)
        if (isNaN(d.getTime())) return iso
        var now = new Date()
        var sameDay = d.getFullYear() === now.getFullYear()
                   && d.getMonth() === now.getMonth()
                   && d.getDate() === now.getDate()
        var hh = ("0" + d.getHours()).slice(-2)
        var mm = ("0" + d.getMinutes()).slice(-2)
        if (sameDay) return "Hôm nay " + hh + ":" + mm
        var dd = ("0" + d.getDate()).slice(-2)
        var mo = ("0" + (d.getMonth() + 1)).slice(-2)
        return dd + "/" + mo + " " + hh + ":" + mm
    }

    function _canDeleteComment(c) {
        if (!c) return false
        if (currentRole === "admin") return true
        return c.userId === currentUserId
    }

    function _avatarColor(uid) {
        var palette = ["#a855f7", "#ec4899", "#f97316", "#10b981",
                       "#0ea5e9", "#eab308", "#6366f1", "#ef4444"]
        var idx = Math.abs(uid) % palette.length
        return palette[idx]
    }

    ColumnLayout {
        id: col
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            Label {
                text: "💬 BÌNH LUẬN"
                color: "#475569"
                font.pixelSize: 11; font.bold: true
            }
            Rectangle {
                color: "#e0e7ff"
                radius: 10
                implicitHeight: 20
                implicitWidth: cntLabel.implicitWidth + 14
                Label {
                    id: cntLabel
                    anchors.centerIn: parent
                    text: comments.length
                    color: "#3730a3"
                    font.pixelSize: 11; font.bold: true
                }
            }
            Item { Layout.fillWidth: true }
        }

        // Empty state
        Rectangle {
            visible: comments.length === 0
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            color: "#f8fafc"
            border.color: "#e2e8f0"; border.width: 1
            radius: 8
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 4
                Label {
                    text: "💭"
                    font.pixelSize: 28
                    Layout.alignment: Qt.AlignHCenter
                }
                Label {
                    text: "Chưa có bình luận nào — hãy là người đầu tiên!"
                    color: "#94a3b8"
                    font.pixelSize: 12; font.italic: true
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }

        // Comment list — Repeater (không dùng ListView trong ColumnLayout)
        Repeater {
            model: root.comments
            delegate: Rectangle {
                id: cItem
                required property var modelData
                Layout.fillWidth: true
                Layout.preferredHeight: cRow.implicitHeight + 16
                color: "#fafafa"
                border.color: "#e5e7eb"; border.width: 1
                radius: 8

                readonly property var u: root._userById(cItem.modelData.userId)

                RowLayout {
                    id: cRow
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 10

                    // Avatar
                    Rectangle {
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        Layout.alignment: Qt.AlignTop
                        radius: 18
                        color: root._avatarColor(cItem.modelData.userId)
                        Label {
                            anchors.centerIn: parent
                            text: {
                                if (cItem.u && cItem.u.fullName && cItem.u.fullName.length > 0)
                                    return cItem.u.fullName.charAt(0).toUpperCase()
                                if (cItem.u && cItem.u.username && cItem.u.username.length > 0)
                                    return cItem.u.username.charAt(0).toUpperCase()
                                return "?"
                            }
                            color: "white"
                            font.pixelSize: 16; font.bold: true
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6
                            Label {
                                text: cItem.u && cItem.u.fullName
                                      ? cItem.u.fullName
                                      : (cItem.u && cItem.u.username ? "@" + cItem.u.username : "User #" + cItem.modelData.userId)
                                color: "#0f172a"
                                font.pixelSize: 13; font.bold: true
                            }
                            Label {
                                text: "·  " + root._fmtTime(cItem.modelData.createdAt)
                                color: "#94a3b8"
                                font.pixelSize: 11
                            }
                            Item { Layout.fillWidth: true }
                            Button {
                                visible: root._canDeleteComment(cItem.modelData)
                                text: "🗑"
                                flat: true
                                ToolTip.text: "Xóa bình luận"
                                ToolTip.visible: hovered
                                implicitHeight: 24
                                implicitWidth: 28
                                onClicked: confirmDelCmt.askDelete(cItem.modelData.id)
                            }
                        }

                        Label {
                            text: cItem.modelData.body
                            color: "#1f2937"
                            font.pixelSize: 13
                            wrapMode: Label.Wrap
                            Layout.fillWidth: true
                        }
                    }
                }
            }
        }

        // ===== Form: Thêm bình luận =====
        Rectangle {
            visible: currentUserId > 0
            Layout.fillWidth: true
            Layout.preferredHeight: formCol.implicitHeight + 16
            Layout.topMargin: 8
            color: "#f8fafc"
            border.color: "#cbd5e1"; border.width: 1
            radius: 8

            ColumnLayout {
                id: formCol
                anchors.fill: parent
                anchors.margins: 8
                spacing: 6

                Label {
                    text: "✏️ Viết bình luận"
                    color: "#475569"
                    font.pixelSize: 11; font.bold: true
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 70
                    color: "white"
                    border.color: "#cbd5e1"; border.width: 1
                    radius: 6
                    clip: true

                    ScrollView {
                        anchors.fill: parent
                        anchors.margins: 4
                        TextArea {
                            id: bodyField
                            placeholderText: "Nhập nội dung bình luận..."
                            wrapMode: TextArea.Wrap
                            background: null
                            font.pixelSize: 13
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Label {
                        text: bodyField.text.length + " ký tự"
                        color: "#94a3b8"
                        font.pixelSize: 11
                    }
                    Item { Layout.fillWidth: true }
                    Button {
                        text: "Hủy"
                        enabled: bodyField.text.length > 0
                        onClicked: bodyField.text = ""
                    }
                    Button {
                        text: "💬 Gửi"
                        highlighted: true
                        enabled: bodyField.text.trim().length > 0 && currentUserId > 0
                        onClicked: {
                            resource.addComment(resourceId, currentUserId, bodyField.text)
                            bodyField.text = ""
                        }
                    }
                }
            }
        }

        // Notice nếu chưa login
        Rectangle {
            visible: currentUserId <= 0
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            color: "#fef3c7"
            border.color: "#fbbf24"; border.width: 1
            radius: 6
            Label {
                anchors.centerIn: parent
                text: "⚠️ Bạn cần đăng nhập để bình luận"
                color: "#92400e"
                font.pixelSize: 12
            }
        }
    }

    // Dialog xác nhận xóa comment
    Dialog {
        id: confirmDelCmt
        property int cmtId: -1
        function askDelete(id) {
            cmtId = id
            open()
        }
        title: "Xóa bình luận"
        modal: true
        anchors.centerIn: Overlay.overlay
        standardButtons: Dialog.Yes | Dialog.No
        onAccepted: if (cmtId > 0) resource.deleteComment(cmtId)
        Label { text: "Bạn có chắc muốn xóa bình luận này?" }
    }
}