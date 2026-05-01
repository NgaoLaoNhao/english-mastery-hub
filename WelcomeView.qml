import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Item {
    id: root
    property var auth: null
    property var checkin: null
    property var adminUser: null
    property var adminGroup: null
    property var appSettings: null
    property var topController: null
    property var resource: null
    property var gemini: null
    signal logoutRequested()
    signal openAdminPanel()
    signal openPersonal()
    signal openGroupDetail(int groupId)
    signal openTopDetail(int userId)
    readonly property bool isAdmin: auth && auth.currentRole === "admin"

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ===== STICKY HEADER =====
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            color: "#1f1f2e"; z: 10
            RowLayout {
                anchors.fill: parent; anchors.leftMargin: 20; anchors.rightMargin: 20; spacing: 12
                Label {
                    text: "📚 English Mastery Hub"
                    color: "white"; font.pixelSize: 16; font.bold: true
                }
                Item { Layout.fillWidth: true }

                // ===== CLICKABLE USERNAME (mở Trang cá nhân) =====
                Rectangle {
                    id: userChip
                    Layout.preferredHeight: 36
                    Layout.preferredWidth: nameLabel.implicitWidth + 20
                    color: userMa.containsMouse ? "#33334d" : "transparent"
                    radius: 6
                    border.color: userMa.containsMouse ? "#4b5563" : "transparent"
                    border.width: 1

                    Label {
                        id: nameLabel
                        anchors.centerIn: parent
                        text: auth ? ("👋 " + (auth.currentDisplayName || auth.currentUsername)) : ""
                        color: "#ddd"; font.pixelSize: 13
                    }

                    MouseArea {
                        id: userMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.openPersonal()
                        ToolTip.text: "Mở trang cá nhân"
                        ToolTip.visible: containsMouse
                        ToolTip.delay: 500
                    }
                }

                Button { text: "🛠 Quản trị"; visible: root.isAdmin; onClicked: root.openAdminPanel() }
                Button { text: "🚪 Đăng xuất"; onClicked: root.logoutRequested() }
            }
        }

        // ===== SCROLLABLE =====
        ScrollView {
            Layout.fillWidth: true; Layout.fillHeight: true
            contentWidth: availableWidth; clip: true

            ColumnLayout {
                width: parent.width
                spacing: 14

                // Greeting strip
                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 50
                    Layout.topMargin: 16; Layout.leftMargin: 20; Layout.rightMargin: 20
                    color: "#eef6ff"; radius: 8; border.color: "#cfe0f4"
                    Label {
                        anchors.left: parent.left; anchors.leftMargin: 14
                        anchors.verticalCenter: parent.verticalCenter
                        text: auth
                              ? "Xin chào, " + (auth.currentDisplayName || auth.currentUsername)
                                + "  ·  " + (auth.currentRole === "admin" ? "Quản trị" : "Thành viên")
                              : ""
                        font.pixelSize: 15
                    }
                }

                // ===== Callout: Tài liệu =====
                EditableCallout {
                    Layout.leftMargin: 20; Layout.rightMargin: 20
                    emoji: "📚"
                    title: "TOÀN BỘ TÀI LIỆU QUAN TRỌNG"
                    body: appSettings ? appSettings.importantDocsLabel : ""
                    linkUrl: appSettings ? appSettings.importantDocsUrl : ""
                    canEdit: root.isAdmin
                    bgColor: "#fff7e6"; borderColor: "#daa520"
                    onEditClicked: {
                        editDocsLabel.text = appSettings ? appSettings.importantDocsLabel : ""
                        editDocsUrl.text   = appSettings ? appSettings.importantDocsUrl : ""
                        editDocsDialog.open()
                    }
                }

                // ===== Callout: Thông báo =====
                EditableCallout {
                    Layout.leftMargin: 20; Layout.rightMargin: 20
                    emoji: "📢"
                    title: "THÔNG BÁO QUAN TRỌNG"
                    body: appSettings ? appSettings.announcement : ""
                    canEdit: root.isAdmin
                    bgColor: "#fff0f0"; borderColor: "#e74c3c"
                    onEditClicked: {
                        editAnnouncement.text = appSettings ? appSettings.announcement : ""
                        editAnnouncementDialog.open()
                    }
                }

                // ===== 2-COLUMN: Check-in | Wanted =====
                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 20; Layout.rightMargin: 20
                    spacing: 14
                    CheckinSection {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        auth: root.auth
                        checkin: root.checkin
                    }
                    WantedBoardSection {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        auth: root.auth
                        checkin: root.checkin
                        gemini: root.gemini                      // ← Người C thêm
                    }
                }

                // ===== Đã check-in hôm nay =====
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 20; Layout.rightMargin: 20
                    spacing: 0
                    CheckedInTodaySection {
                        checkin: root.checkin
                    }
                }
                // ===== Phase A2: Challenge Progress =====
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 20; Layout.rightMargin: 20
                    spacing: 0
                    ChallengeProgressSection {
                        auth: root.auth
                        checkin: root.checkin
                    }
                }

                // ===== Phase A2: Lịch sử cá nhân =====
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 20; Layout.rightMargin: 20
                    spacing: 0
                    CheckinHistorySection {
                        auth: root.auth
                        checkin: root.checkin
                    }
                }
                // ===== Phase A3: Top Board =====
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 20; Layout.rightMargin: 20
                    spacing: 0
                    TopBoardSection {
                        topController: root.topController
                        onUserClicked: function(uid) { root.openTopDetail(uid) }
                    }
                }

                // ===== Phase A3: Groups =====
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 20; Layout.rightMargin: 20
                    spacing: 0
                    GroupsBoardSection {
                        topController: root.topController
                        onGroupClicked: function(gid) { root.openGroupDetail(gid) }
                    }
                }
                ResourceLibrarySection {
                    Layout.fillWidth: true
                    resource: root.resource
                    auth: root.auth
                    adminUser: root.adminUser
                    adminGroup: root.adminGroup
                }
                // Future placeholder
                // ===== Phase A5: Backend Admin Tools =====
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 20; Layout.rightMargin: 20; Layout.bottomMargin: 24
                    spacing: 0
                    BackendAdminToolsSection {
                        auth: root.auth
                        adminUser: root.adminUser
                        adminGroup: root.adminGroup
                        checkin: root.checkin
                        resource: root.resource
                        onOpenAdminPanelRequested: root.openAdminPanel()
                    }
                }
            }
        }
    }

    // ===== Dialog: Edit Documents =====
    Dialog {
        id: editDocsDialog
        modal: true
        anchors.centerIn: Overlay.overlay
        width: 480
        title: "📚 Sửa Tài liệu quan trọng"
        standardButtons: Dialog.Save | Dialog.Cancel

        ColumnLayout {
            anchors.fill: parent; spacing: 10
            Label { text: "Mô tả/Tiêu đề:" }
            TextField { id: editDocsLabel; Layout.fillWidth: true }
            Label { text: "URL/Link:" }
            TextField { id: editDocsUrl; Layout.fillWidth: true; placeholderText: "https://..." }
        }
        onAccepted: {
            if (appSettings) appSettings.updateImportantDocs(editDocsLabel.text, editDocsUrl.text)
        }
    }

    // ===== Dialog: Edit Announcement =====
    Dialog {
        id: editAnnouncementDialog
        modal: true
        anchors.centerIn: Overlay.overlay
        width: 480
        title: "📢 Sửa Thông báo"
        standardButtons: Dialog.Save | Dialog.Cancel

        ColumnLayout {
            anchors.fill: parent; spacing: 10
            Label { text: "Nội dung thông báo:" }
            TextArea {
                id: editAnnouncement
                Layout.fillWidth: true
                Layout.preferredHeight: 100
                wrapMode: TextArea.Wrap
            }
        }
        onAccepted: {
            if (appSettings) appSettings.updateAnnouncement(editAnnouncement.text)
        }
    }
    // ===== AI Result Popup =====
    Dialog {
        id: aiResultDialog
        modal: true
        anchors.centerIn: Overlay.overlay
        width: 500
        title: "🤖 AI Assistant"
        standardButtons: Dialog.Ok

        ColumnLayout {
            anchors.fill: parent; spacing: 10
            BusyIndicator {
                running: gemini && gemini.isLoading
                Layout.alignment: Qt.AlignHCenter
                visible: running
            }
            ScrollView {
                Layout.fillWidth: true
                Layout.preferredHeight: 250
                TextArea {
                    text: gemini ? gemini.lastResponse : ""
                    readOnly: true
                    wrapMode: TextArea.Wrap
                    font.pixelSize: 13
                }
            }
        }
    }

    Connections {
        target: gemini
        function onResponseReceived(text) { aiResultDialog.open() }
        function onErrorOccurred(error) {
            aiResultDialog.title = "❌ Lỗi AI"
            aiResultDialog.open()
        }
    }

}