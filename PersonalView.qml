import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Dialogs

Item {
    id: root

    property var auth: null
    property var personal: null
    property var checkin: null
    property var adminUser: null
    property var adminGroup: null
    property var gemini: null
    property var pdfExporter: null
    property var theme: null
    signal backRequested()

    readonly property int myUserId: auth ? auth.currentUserId : -1
    readonly property var myUser: {
        if (!adminUser || myUserId < 0) return null
        return adminUser.users.find(function(u) { return u.id === myUserId })
    }
    readonly property var myGroup: {
        if (!adminGroup || !myUser || myUser.groupId <= 0) return null
        return adminGroup.groups.find(function(g) { return g.id === myUser.groupId })
    }
    readonly property var myStats: personal && myUserId > 0
                                   ? personal.getMyStats(myUserId)
                                   : { totalHours: 0, daysCheckedIn: 0, attendanceRate: 0, avgPerDay: 0 }

    // Khi danh sách users thay đổi → ép re-evaluate myUser, myStats
    Connections {
        target: adminUser
        function onUsersChanged() { /* trigger re-binding */ }
    }
    Connections {
        target: checkin
        function onCheckinsChanged() { /* trigger re-binding */ }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ===== HEADER =====
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            color: theme ? theme.colors.headerBg : "#1f1f2e"; z: 10

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20; anchors.rightMargin: 20
                spacing: 12

                Button {
                    text: "← Trở về"
                    onClicked: root.backRequested()
                }

                Label {
                    text: "👤 Trang cá nhân"
                    color: theme ? theme.colors.headerText : "white"; font.pixelSize: 16; font.bold: true
                    Layout.leftMargin: 12
                }

                Item { Layout.fillWidth: true }

                Label {
                    text: auth ? (auth.currentDisplayName || auth.currentUsername) : ""
                    color: theme ? theme.colors.headerSubText : "#ddd"; font.pixelSize: 13
                }
            }
        }

        // ===== SCROLLABLE =====
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: availableWidth
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 16

                // ===== Banner profile =====
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 200
                    Layout.topMargin: 16
                    Layout.leftMargin: 20
                    Layout.rightMargin: 20
                    radius: 10
                    border.color: "#222"; border.width: 2
                    clip: true

                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "#0ea5e9" }
                        GradientStop { position: 0.5; color: "#22d3ee" }
                        GradientStop { position: 1.0; color: "#a7f3d0" }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 14

                        // Avatar tròn
                        Rectangle {
                            Layout.preferredWidth: 88
                            Layout.preferredHeight: 88
                            radius: 44
                            color: "white"
                            border.color: "#fff"; border.width: 3

                            Image {
                                anchors.fill: parent
                                anchors.margins: 3
                                source: myUser && myUser.avatarPath ? _toStr(myUser.avatarPath) : ""
                                sourceSize.width: 88
                                sourceSize.height: 88
                                fillMode: Image.PreserveAspectCrop
                                visible: source !== ""
                                asynchronous: true
                                cache: true
                                clip: true
                            }
                            Label {
                                anchors.centerIn: parent
                                visible: !myUser || !myUser.avatarPath
                                text: "👤"
                                font.pixelSize: 48
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Label {
                                text: myUser ? (myUser.fullName || myUser.username) : ""
                                color: "white"
                                font.pixelSize: 24; font.bold: true
                                style: Text.Outline; styleColor: "#000"
                            }
                            Label {
                                text: myUser
                                      ? "@" + myUser.username + " · "
                                        + (myUser.role === "admin" ? "Quản trị viên" : "Thành viên")
                                        + (myGroup ? " · 👥 " + myGroup.name : "")
                                      : ""
                                color: "white"
                                font.pixelSize: 13
                                style: Text.Outline; styleColor: "#000"
                            }
                        }

                        ColumnLayout {
                            spacing: 6
                            Button {
                                text: "✏️ Chỉnh sửa hồ sơ"
                                onClicked: {
                                    editFullName.text = myUser ? _toStr(myUser.fullName) : ""
                                    editAvatarPath    = myUser ? _toStr(myUser.avatarPath) : ""
                                    editProfileDialog.open()
                                }
                            }
                            Button {
                                text: "🔒 Đổi mật khẩu"
                                onClicked: {
                                    pwdOld.text = ""
                                    pwdNew.text = ""
                                    pwdConfirm.text = ""
                                    pwdError.text = ""
                                    changePwdDialog.open()
                                }
                            }
                            Button {
                                text: "📊 AI Phân Tích"
                                onClicked: {
                                    if (root.gemini && root.checkin && root.auth) {
                                        var history = root.checkin.getMyHistory(root.auth.currentUserId)
                                        root.gemini.analyzeProgress(JSON.stringify(history))
                                    }
                                }
                            }
                            Button {
                                text: "📄 Xuất PDF"
                                enabled: !!root.pdfExporter && !!root.checkin && root.myUserId > 0
                                onClicked: {
                                    if (root.pdfExporter && root.myUserId > 0) {
                                        pdfPreviewDialog.report = root.pdfExporter.buildPersonalReport(root.myUserId)
                                        pdfPreviewDialog.open()
                                    }
                                }
                            }
                        }
                    }
                }

                // ===== 4 thẻ stats nhanh =====
                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 20; Layout.rightMargin: 20
                    spacing: 12

                    Repeater {
                        model: [
                            { icon: "⏱️", label: "Tổng giờ học", value: myStats.totalHours.toFixed(2) + "h", bg: "#fef3c7" },
                            { icon: "📅", label: "Số ngày check-in", value: myStats.daysCheckedIn + "/25", bg: "#dbeafe" },
                            { icon: "✅", label: "Chuyên cần", value: myStats.attendanceRate + "%", bg: "#dcfce7" },
                            { icon: "📈", label: "TB mỗi ngày", value: myStats.avgPerDay.toFixed(2) + "h", bg: "#fce7f3" }
                        ]
                        delegate: Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: 90
                            radius: 10
                            color: theme && theme.isDark ? Qt.darker(modelData.bg, 2.5) : modelData.bg
                            border.color: theme && theme.isDark ? "#334155" : "#e2e8f0"; border.width: 1

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 4
                                Label { text: modelData.icon + " " + modelData.label; color: theme ? theme.colors.textMuted : "#475569"; font.pixelSize: 12 }
                                Label { text: modelData.value; color: theme ? theme.colors.text : "#0f172a"; font.pixelSize: 22; font.bold: true }
                            }
                        }
                    }
                }

                // ===== Placeholder cho A.4 + A.5 =====
                PersonalStatsSection {
                    Layout.fillWidth: true
                    Layout.leftMargin: 20; Layout.rightMargin: 20
                    personal: root.personal
                    userId: root.myUserId
                }

                // Placeholder còn lại cho A.5
                PersonalHistorySection {
                    Layout.fillWidth: true
                    Layout.leftMargin: 20; Layout.rightMargin: 20
                    personal: root.personal
                    userId: root.myUserId
                }

                Item { Layout.preferredHeight: 24 }
            }
        }
    }

    // ===== Properties phụ trợ cho dialog =====
    property var editAvatarPath: ""

    // Helper: ép url/QJSValue/string → string an toàn
    function _toStr(v) {
        if (v === undefined || v === null) return ""
        return "" + v
    }

    // ===== Dialog: Sửa hồ sơ =====
    Dialog {
        id: editProfileDialog
        modal: true
        anchors.centerIn: Overlay.overlay
        width: 460
        title: "✏️ Chỉnh sửa hồ sơ"
        standardButtons: Dialog.Save | Dialog.Cancel

        ColumnLayout {
            anchors.fill: parent
            spacing: 12

            Label {
                text: "Tên đăng nhập (không sửa được):"
                font.pixelSize: 12; color: "#64748b"
            }
            Label {
                text: myUser ? "@" + myUser.username : ""
                font.pixelSize: 14; font.bold: true
            }

            Label {
                text: "Họ tên:"
                Layout.topMargin: 8
            }
            TextField {
                id: editFullName
                Layout.fillWidth: true
                placeholderText: "Nhập họ tên đầy đủ..."
            }

            Label {
                text: "Ảnh đại diện:"
                Layout.topMargin: 8
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Rectangle {
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 80
                    radius: 40
                    color: "#f1f5f9"
                    border.color: "#cbd5e1"; border.width: 1

                    Image {
                        anchors.fill: parent
                        anchors.margins: 2
                        source: _toStr(editAvatarPath)
                        sourceSize.width: 80
                        sourceSize.height: 80
                        fillMode: Image.PreserveAspectCrop
                        visible: source !== ""
                        asynchronous: true
                        cache: true
                        clip: true
                    }
                    Label {
                        anchors.centerIn: parent
                        visible: editAvatarPath === ""
                        text: "👤"; font.pixelSize: 36
                    }
                }

                ColumnLayout {
                    spacing: 6
                    Button {
                        text: "📁 Chọn ảnh..."
                        onClicked: avatarFileDialog.open()
                    }
                    Button {
                        text: "🗑️ Xóa ảnh"
                        enabled: editAvatarPath !== ""
                        onClicked: editAvatarPath = ""
                    }
                }
            }
        }

        onAccepted: {
            if (!personal || !myUser) return
            personal.updateMyProfile(myUserId, {
                fullName: editFullName.text.trim(),
                avatarPath: editAvatarPath
            })
        }
    }

    FileDialog {
        id: avatarFileDialog
        title: "Chọn ảnh đại diện"
        nameFilters: ["Ảnh (*.png *.jpg *.jpeg *.bmp *.gif)"]
        onAccepted: editAvatarPath = _toStr(selectedFile)
    }

    // ===== Dialog: Đổi mật khẩu =====
    Dialog {
        id: changePwdDialog
        modal: true
        anchors.centerIn: Overlay.overlay
        width: 420
        title: "🔒 Đổi mật khẩu"
        standardButtons: Dialog.Save | Dialog.Cancel

        ColumnLayout {
            anchors.fill: parent
            spacing: 10

            Label { text: "Mật khẩu hiện tại:" }
            TextField {
                id: pwdOld
                Layout.fillWidth: true
                echoMode: TextInput.Password
                placeholderText: "••••••"
            }

            Label { text: "Mật khẩu mới (ít nhất 6 ký tự):"; Layout.topMargin: 4 }
            TextField {
                id: pwdNew
                Layout.fillWidth: true
                echoMode: TextInput.Password
                placeholderText: "••••••"
            }

            Label { text: "Xác nhận mật khẩu mới:"; Layout.topMargin: 4 }
            TextField {
                id: pwdConfirm
                Layout.fillWidth: true
                echoMode: TextInput.Password
                placeholderText: "••••••"
            }

            Label {
                id: pwdError
                Layout.fillWidth: true
                color: "#dc2626"
                font.pixelSize: 12
                visible: text !== ""
                wrapMode: Label.WordWrap
            }
        }

        // Chặn đóng nếu validate fail
        onAccepted: {
            pwdError.text = ""
            if (pwdOld.text === "" || pwdNew.text === "" || pwdConfirm.text === "") {
                pwdError.text = "⚠️ Vui lòng điền đủ 3 ô."
                changePwdDialog.open()
                return
            }
            if (pwdNew.text.length < 6) {
                pwdError.text = "⚠️ Mật khẩu mới phải ≥ 6 ký tự."
                changePwdDialog.open()
                return
            }
            if (pwdNew.text !== pwdConfirm.text) {
                pwdError.text = "⚠️ Mật khẩu xác nhận không khớp."
                changePwdDialog.open()
                return
            }
            if (pwdNew.text === pwdOld.text) {
                pwdError.text = "⚠️ Mật khẩu mới phải khác mật khẩu cũ."
                changePwdDialog.open()
                return
            }
            if (auth) auth.changePassword(pwdOld.text, pwdNew.text)
        }
    }

    // Lắng nghe kết quả đổi mật khẩu từ MockAuthController
    Connections {
        target: auth
        function onPasswordChanged() {
            pwdSuccessPopup.open()
        }
        function onPasswordChangeFailed(reason) {
            pwdError.text = "❌ " + (reason || "Mật khẩu hiện tại không đúng.")
            changePwdDialog.open()
        }
    }

    // Popup thông báo đổi mật khẩu thành công
    Dialog {
        id: pwdSuccessPopup
        modal: true
        anchors.centerIn: Overlay.overlay
        width: 360
        title: "✅ Thành công"
        standardButtons: Dialog.Ok

        Label {
            anchors.fill: parent
            text: "Đổi mật khẩu thành công!"
            wrapMode: Label.WordWrap
        }
    }

    // ===== AI Result Popup (Người C) =====
    Dialog {
        id: aiResultDialog
        modal: true
        anchors.centerIn: Overlay.overlay
        width: 500
        title: "📊 AI Phân Tích Tiến Độ"
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
    PdfPreviewDialog {
        id: pdfPreviewDialog
        pdfExporter: root.pdfExporter
    }
}