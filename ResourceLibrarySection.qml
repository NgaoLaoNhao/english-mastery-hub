import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: root
    Layout.fillWidth: true
    spacing: 12

    property var resource: null
    property var auth: null
    property var adminUser: null
    property var adminGroup: null
    property string filterType: "all"

    readonly property string currentRole:     auth ? (auth.currentRole     || "") : ""
    readonly property string currentUsername: auth ? (auth.currentUsername || "") : ""
    readonly property int currentUserId: {
        if (!adminUser || !currentUsername) return -1
        var us = adminUser.users || []
        for (var i = 0; i < us.length; i++)
            if (us[i].username === currentUsername) return us[i].id
        return -1
    }

    readonly property bool canAdd: {
        if (currentRole === "admin") return true
        if (!adminGroup || currentUserId < 0) return false
        var gs = adminGroup.groups || []
        for (var i = 0; i < gs.length; i++)
            if (gs[i].leaderId === currentUserId) return true
        return false
    }
    function canDelete(item) {
        if (!item) return false
        if (currentRole === "admin") return true
        if (!adminGroup || currentUserId < 0) return false
        var gs = adminGroup.groups || []
        for (var i = 0; i < gs.length; i++)
            if (gs[i].id === item.groupId && gs[i].leaderId === currentUserId) return true
        return false
    }

    readonly property var filtered: {
        if (!resource) return []
        return resource.getByType(filterType)
    }

    BannerHero {
        Layout.fillWidth: true
        title: "📚 KHO TÀI LIỆU"
        subtitle: "Tài liệu chung & của từng nhóm"
        emoji: "📚"
        colorStart: "#6d28d9"
        colorMid:   "#a855f7"
        colorEnd:   "#ec4899"
        height: 110
    }

    // Toolbar
    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        Label { text: "Loại:"; color: "#475569" }
        ComboBox {
            id: typeBox
            Layout.preferredWidth: 180
            model: [
                { v: "all",   t: "Tất cả" },
                { v: "pdf",   t: "📄 PDF" },
                { v: "video", t: "🎬 Video" },
                { v: "audio", t: "🎧 Audio" },
                { v: "link",  t: "🔗 Liên kết" }
            ]
            textRole: "t"
            valueRole: "v"
            onActivated: root.filterType = currentValue
        }
        Item { Layout.fillWidth: true }
        Button {
            visible: root.canAdd
            text: "➕ Thêm tài liệu"
            onClicked: addDlg.open()
        }
    }

    // List
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 8

        Label {
            visible: root.filtered.length === 0
            text: "Chưa có tài liệu nào ở mục này."
            color: "#94a3b8"
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 16
            Layout.bottomMargin: 16
        }

        Repeater {
            model: root.filtered
            delegate: Rectangle {
                required property var modelData
                Layout.fillWidth: true
                Layout.preferredHeight: row.implicitHeight + 20
                radius: 10
                color: ma.containsMouse ? "#f8fafc" : "white"
                border.color: "#e2e8f0"
                border.width: 1

                MouseArea {
                    id: ma
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Qt.openUrlExternally(modelData.url)
                }

                RowLayout {
                    id: row
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 12

                    Rectangle {
                        Layout.preferredWidth: 56
                        Layout.preferredHeight: 56
                        radius: 8
                        color: {
                            var t = modelData.type
                            if (t === "pdf")   return "#fee2e2"
                            if (t === "video") return "#dbeafe"
                            if (t === "audio") return "#fef3c7"
                            if (t === "link")  return "#dcfce7"
                            return "#f1f5f9"
                        }
                        Label {
                            anchors.centerIn: parent
                            text: root.resource ? root.resource.typeIcon(modelData.type) : "📎"
                            font.pixelSize: 28
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Label {
                            text: modelData.title
                            font.pixelSize: 15
                            font.bold: true
                            color: "#0f172a"
                            elide: Label.ElideRight
                            Layout.fillWidth: true
                        }
                        Label {
                            text: (root.resource ? root.resource.typeLabel(modelData.type) : modelData.type)
                                  + "  •  Đăng bởi " + modelData.uploadedBy
                                  + "  •  " + modelData.addedAt
                                  + (modelData.groupId > 0 ? "  •  Nhóm #" + modelData.groupId : "  •  Chung")
                            color: "#64748b"
                            font.pixelSize: 12
                        }
                    }

                    Button {
                        text: "Mở"
                        onClicked: Qt.openUrlExternally(modelData.url)
                    }
                    Button {
                        visible: root.canDelete(modelData)
                        text: "🗑"
                        ToolTip.text: "Xóa"
                        ToolTip.visible: hovered
                        onClicked: {
                            confirmDel.itemId = modelData.id
                            confirmDel.itemTitle = modelData.title
                            confirmDel.open()
                        }
                    }
                }
            }
        }
    }

    // Dialog: Thêm tài liệu
    Dialog {
        id: addDlg
        title: "Thêm tài liệu mới"
        modal: true
        anchors.centerIn: Overlay.overlay
        width: 460
        standardButtons: Dialog.Ok | Dialog.Cancel
        onAccepted: {
            if (!titleField.text.trim() || !urlField.text.trim()) return
            var gid = 0
            if (currentRole !== "admin" && adminGroup && currentUserId > 0) {
                var gs = adminGroup.groups || []
                for (var i = 0; i < gs.length; i++)
                    if (gs[i].leaderId === currentUserId) { gid = gs[i].id; break }
            }
            resource.addResource(
                titleField.text.trim(),
                typeAdd.currentValue,
                urlField.text.trim(),
                currentUsername,
                gid
            )
            titleField.text = ""; urlField.text = ""; typeAdd.currentIndex = 0
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 8
            Label { text: "Tiêu đề" }
            TextField { id: titleField; Layout.fillWidth: true; placeholderText: "VD: Cambridge B1 — Chương 3" }
            Label { text: "Loại" }
            ComboBox {
                id: typeAdd
                Layout.fillWidth: true
                model: [
                    { v: "pdf",   t: "📄 PDF" },
                    { v: "video", t: "🎬 Video" },
                    { v: "audio", t: "🎧 Audio" },
                    { v: "link",  t: "🔗 Liên kết" }
                ]
                textRole: "t"
                valueRole: "v"
            }
            Label { text: "URL" }
            TextField { id: urlField; Layout.fillWidth: true; placeholderText: "https://..." }
        }
    }

    // Dialog xác nhận xóa
    Dialog {
        id: confirmDel
        property int itemId: -1
        property string itemTitle: ""
        title: "Xác nhận xóa"
        modal: true
        anchors.centerIn: Overlay.overlay
        standardButtons: Dialog.Yes | Dialog.No
        onAccepted: if (itemId > 0) resource.deleteResource(itemId)
        Label { text: "Xóa tài liệu \"" + confirmDel.itemTitle + "\"?" }
    }
}