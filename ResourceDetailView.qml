import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Item {
    id: root

    property var auth: null
    property var resource: null
    property var adminUser: null
    property var adminGroup: null
    property int resourceId: -1

    signal backRequested()

    readonly property var info: resource && resourceId > 0
        ? resource.getResourceById(resourceId) : null

    readonly property var uploaderUser: {
        if (!info || !adminUser || !adminUser.users) return null
        for (var i = 0; i < adminUser.users.length; i++) {
            if (adminUser.users[i].username === info.uploadedBy) return adminUser.users[i]
        }
        return null
    }

    readonly property var groupObj: {
        if (!info || info.groupId === 0 || !adminGroup || !adminGroup.groups) return null
        for (var i = 0; i < adminGroup.groups.length; i++) {
            if (adminGroup.groups[i].id === info.groupId) return adminGroup.groups[i]
        }
        return null
    }

    readonly property string currentUsername: auth ? (auth.currentUsername || "") : ""
    readonly property int currentUserId: {
        if (!adminUser || !currentUsername) return -1
        var us = adminUser.users || []
        for (var i = 0; i < us.length; i++)
            if (us[i].username === currentUsername) return us[i].id
        return -1
    }

    property int _likeTick: 0
    Connections {
        target: resource
        function onLikeToggled(rid, uid, liked) { root._likeTick++ }
        function onCommentAdded(id, rid)        { root._likeTick++ }
        function onCommentDeleted(id)           { root._likeTick++ }
    }

    readonly property int likeCount: {
        _likeTick
        return resource && resourceId > 0 ? resource.getLikeCount(resourceId) : 0
    }
    readonly property bool iLiked: {
        _likeTick
        return resource && resourceId > 0 && currentUserId > 0
            ? resource.hasLiked(resourceId, currentUserId) : false
    }

    function _typeColor(t) {
        if (t === "pdf")   return "#dc2626"
        if (t === "video") return "#7c3aed"
        if (t === "audio") return "#0891b2"
        if (t === "link")  return "#16a34a"
        return "#64748b"
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            color: "#1f1f2e"; z: 10

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20; anchors.rightMargin: 20
                spacing: 12

                Button {
                    text: "← Trở về"
                    onClicked: root.backRequested()
                }
                Label {
                    text: "📚 Chi tiết tài liệu"
                    color: "white"; font.pixelSize: 16; font.bold: true
                    Layout.leftMargin: 12
                }
                Item { Layout.fillWidth: true }
                Label {
                    text: info ? info.title : ""
                    color: "#ddd"; font.pixelSize: 13
                    elide: Label.ElideRight
                    Layout.maximumWidth: 400
                }
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: availableWidth
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 16

                Rectangle {
                    visible: !info
                    Layout.fillWidth: true
                    Layout.preferredHeight: 200
                    Layout.topMargin: 16
                    Layout.leftMargin: 20; Layout.rightMargin: 20
                    color: "#fef2f2"
                    border.color: "#fca5a5"; border.width: 1
                    radius: 10

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 8
                        Label {
                            text: "❌ Không tìm thấy tài liệu"
                            color: "#dc2626"
                            font.pixelSize: 18; font.bold: true
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Label {
                            text: "Tài liệu có thể đã bị xoá hoặc ID không hợp lệ."
                            color: "#7f1d1d"
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }

                Rectangle {
                    visible: !!info
                    Layout.fillWidth: true
                    Layout.preferredHeight: 140
                    Layout.topMargin: 16
                    Layout.leftMargin: 20; Layout.rightMargin: 20
                    radius: 10
                    border.color: "#222"; border.width: 2
                    clip: true

                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "#6d28d9" }
                        GradientStop { position: 0.5; color: "#a855f7" }
                        GradientStop { position: 1.0; color: "#ec4899" }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 14

                        Rectangle {
                            Layout.preferredWidth: 100
                            Layout.preferredHeight: 100
                            radius: 16
                            color: "white"
                            border.color: "#fff"; border.width: 3
                            Label {
                                anchors.centerIn: parent
                                text: info ? resource.typeIcon(info.type) : ""
                                font.pixelSize: 56
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            RowLayout {
                                spacing: 8

                                Rectangle {
                                    color: root._typeColor(info ? info.type : "")
                                    radius: 4
                                    implicitHeight: 22
                                    implicitWidth: typeBadge.implicitWidth + 16
                                    Label {
                                        id: typeBadge
                                        anchors.centerIn: parent
                                        text: info ? resource.typeLabel(info.type).toUpperCase() : ""
                                        color: "white"
                                        font.pixelSize: 11; font.bold: true
                                    }
                                }

                                Rectangle {
                                    visible: !!groupObj
                                    color: "#ffffff66"
                                    radius: 4
                                    implicitHeight: 22
                                    implicitWidth: groupBadge.implicitWidth + 16
                                    border.color: "white"
                                    Label {
                                        id: groupBadge
                                        anchors.centerIn: parent
                                        text: "👥 " + (groupObj ? groupObj.name : "")
                                        color: "white"
                                        font.pixelSize: 11; font.bold: true
                                    }
                                }

                                Rectangle {
                                    visible: info && info.groupId === 0
                                    color: "#10b981"
                                    radius: 4
                                    implicitHeight: 22
                                    implicitWidth: 90
                                    Label {
                                        anchors.centerIn: parent
                                        text: "🌐 CHUNG"
                                        color: "white"
                                        font.pixelSize: 11; font.bold: true
                                    }
                                }
                            }

                            Label {
                                text: info ? info.title : ""
                                color: "white"
                                font.pixelSize: 22; font.bold: true
                                style: Text.Outline; styleColor: "#000"
                                Layout.fillWidth: true
                                wrapMode: Label.WordWrap
                            }

                            Label {
                                text: info ? ("📅 " + info.addedAt + "  ·  ⬆️ " + info.uploadedBy) : ""
                                color: "white"
                                font.pixelSize: 12
                                style: Text.Outline; styleColor: "#000"
                            }
                        }
                    }
                }

                Rectangle {
                    visible: !!info
                    Layout.fillWidth: true
                    Layout.leftMargin: 20; Layout.rightMargin: 20
                    Layout.preferredHeight: urlCol.implicitHeight + 24
                    color: "white"
                    border.color: "#e2e8f0"; border.width: 1
                    radius: 10

                    ColumnLayout {
                        id: urlCol
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        Label {
                            text: "🔗 ĐƯỜNG DẪN TÀI LIỆU"
                            color: "#475569"
                            font.pixelSize: 11; font.bold: true
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 38
                                color: "#f1f5f9"
                                radius: 6
                                border.color: "#cbd5e1"; border.width: 1
                                Label {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10; anchors.rightMargin: 10
                                    verticalAlignment: Label.AlignVCenter
                                    text: info ? info.url : ""
                                    color: "#0f172a"
                                    elide: Label.ElideMiddle
                                    font.family: "Consolas"
                                    font.pixelSize: 12
                                }
                            }

                            Button {
                                text: "📋"
                                ToolTip.text: "Copy URL"
                                ToolTip.visible: hovered
                                onClicked: {
                                    if (info) {
                                        urlClipboard.text = info.url
                                        urlClipboard.selectAll()
                                        urlClipboard.copy()
                                        copiedHint.visible = true
                                        copiedTimer.restart()
                                    }
                                }
                            }
                            Button {
                                text: "🌐 Mở trong trình duyệt"
                                highlighted: true
                                onClicked: if (info) Qt.openUrlExternally(info.url)
                            }
                        }

                        Label {
                            id: copiedHint
                            visible: false
                            text: "✅ Đã copy!"
                            color: "#16a34a"; font.pixelSize: 11
                        }
                        Timer {
                            id: copiedTimer
                            interval: 1500
                            onTriggered: copiedHint.visible = false
                        }
                        TextEdit {
                            id: urlClipboard
                            visible: false
                        }
                    }
                }

                Rectangle {
                    visible: !!info
                    Layout.fillWidth: true
                    Layout.leftMargin: 20; Layout.rightMargin: 20
                    Layout.preferredHeight: uploaderRow.implicitHeight + 24
                    color: "white"
                    border.color: "#e2e8f0"; border.width: 1
                    radius: 10

                    RowLayout {
                        id: uploaderRow
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        Rectangle {
                            Layout.preferredWidth: 56
                            Layout.preferredHeight: 56
                            radius: 28
                            color: uploaderUser ? "#a855f7" : "#94a3b8"
                            Label {
                                anchors.centerIn: parent
                                text: {
                                    if (!info) return "?"
                                    var n = (uploaderUser && uploaderUser.fullName)
                                            ? uploaderUser.fullName : info.uploadedBy
                                    return n.length > 0 ? n.charAt(0).toUpperCase() : "?"
                                }
                                color: "white"
                                font.pixelSize: 24; font.bold: true
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Label {
                                text: "📤 NGƯỜI ĐĂNG"
                                color: "#475569"
                                font.pixelSize: 10; font.bold: true
                            }
                            Label {
                                text: {
                                    if (!info) return ""
                                    if (uploaderUser && uploaderUser.fullName)
                                        return uploaderUser.fullName + "  (@" + info.uploadedBy + ")"
                                    return "@" + info.uploadedBy
                                }
                                color: "#0f172a"
                                font.pixelSize: 15; font.bold: true
                            }
                            Label {
                                visible: !!groupObj || (info && info.groupId === 0)
                                text: groupObj
                                    ? "👥 " + groupObj.name
                                    : "🌐 Tài liệu chung cho cả lớp"
                                color: "#64748b"
                                font.pixelSize: 12
                            }
                            Label {
                                text: info ? "📅 Đăng ngày " + info.addedAt : ""
                                color: "#94a3b8"
                                font.pixelSize: 11
                            }
                        }
                    }
                }

                Rectangle {
                    visible: !!info
                    Layout.fillWidth: true
                    Layout.leftMargin: 20; Layout.rightMargin: 20
                    Layout.preferredHeight: 60
                    color: "white"
                    border.color: "#e2e8f0"; border.width: 1
                    radius: 10

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16; anchors.rightMargin: 16
                        spacing: 12

                        Button {
                            id: likeBtn
                            enabled: currentUserId > 0
                            text: iLiked ? "❤️  Đã thích" : "🤍  Thích"
                            onClicked: {
                                if (currentUserId > 0)
                                    resource.toggleLike(resourceId, currentUserId)
                            }
                            background: Rectangle {
                                radius: 8
                                color: iLiked
                                    ? (likeBtn.hovered ? "#f43f5e" : "#ec4899")
                                    : (likeBtn.hovered ? "#f1f5f9" : "white")
                                border.color: iLiked ? "#be185d" : "#cbd5e1"
                                border.width: 1
                                implicitWidth: 130
                                implicitHeight: 38
                            }
                            contentItem: Label {
                                text: likeBtn.text
                                color: iLiked ? "white" : "#0f172a"
                                font.bold: true
                                font.pixelSize: 13
                                horizontalAlignment: Label.AlignHCenter
                                verticalAlignment: Label.AlignVCenter
                            }
                        }

                        Label {
                            text: {
                                if (likeCount === 0) return "Chưa có ai thích — hãy là người đầu tiên!"
                                if (iLiked && likeCount === 1) return "Bạn đã thích tài liệu này"
                                if (iLiked) return "Bạn và " + (likeCount - 1) + " người khác đã thích"
                                return likeCount + " người đã thích"
                            }
                            color: "#64748b"
                            font.pixelSize: 13
                            Layout.fillWidth: true
                        }
                    }
                }

                ResourceCommentsSection {
                    visible: !!info
                    Layout.fillWidth: true
                    Layout.leftMargin: 20; Layout.rightMargin: 20
                    auth: root.auth
                    resource: root.resource
                    adminUser: root.adminUser
                    resourceId: root.resourceId
                    currentUserId: root.currentUserId
                    currentRole: root.auth ? (root.auth.currentRole || "") : ""
                }

                Item { Layout.preferredHeight: 24 }
            }
        }
    }
}