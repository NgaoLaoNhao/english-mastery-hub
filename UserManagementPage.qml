import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Item {
    id: root
    property var adminUser: null

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        // Toolbar
        RowLayout {
            Layout.fillWidth: true
            Button {
                text: "➕ Tạo user"
                highlighted: true
                onClicked: createDialog.open()
            }
            Item { Layout.fillWidth: true }
            Label {
                text: "Tổng: " + (adminUser ? adminUser.users.length : 0) + " user"
                color: "#666"
            }
        }

        // Table
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#fafafa"
            border.color: "#ddd"
            border.width: 1

            ListView {
                id: userList
                anchors.fill: parent
                anchors.margins: 1
                clip: true
                model: adminUser ? adminUser.users : []

                header: Rectangle {
                    width: ListView.view.width
                    height: 38
                    color: "#e8e8e8"
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8
                        Label { text: "ID"; Layout.preferredWidth: 30; font.bold: true }
                        Label { text: ""; Layout.preferredWidth: 32 }
                        Label { text: "Username"; Layout.preferredWidth: 110; font.bold: true }
                        Label { text: "Họ tên"; Layout.preferredWidth: 140; font.bold: true }
                        Label { text: "Vai trò"; Layout.preferredWidth: 80; font.bold: true }
                        Label { text: "Nhóm"; Layout.preferredWidth: 60; font.bold: true }
                        Label { text: "Đổi pass?"; Layout.preferredWidth: 70; font.bold: true }
                        Label { text: "Hành động"; Layout.fillWidth: true; font.bold: true }
                    }
                }

                delegate: Rectangle {
                    width: ListView.view.width
                    height: 44
                    color: index % 2 === 0 ? "#ffffff" : "#f7f7f7"
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8
                        Label { text: modelData.id; Layout.preferredWidth: 30 }
                        Rectangle {                                                          // <-- THÊM toàn bộ block này
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            radius: 16
                            color: "#e8e8e8"
                            clip: true
                            Image {
                                anchors.fill: parent
                                fillMode: Image.PreserveAspectCrop
                                source: modelData.avatarPath || ""
                                visible: source.toString() !== ""
                                asynchronous: true
                            }
                            Label {
                                anchors.centerIn: parent
                                text: modelData.username.charAt(0).toUpperCase()
                                font.bold: true
                                color: "#666"
                                visible: !modelData.avatarPath
                            }
                        }
                        Label { text: modelData.username; Layout.preferredWidth: 110 }
                        Label { text: modelData.fullName; Layout.preferredWidth: 140 }
                        Label {
                            text: modelData.role === "admin" ? "👑 admin" : "member"
                            Layout.preferredWidth: 80
                        }
                        Label {
                            text: modelData.groupId === -1 ? "—" : ("Nhóm " + modelData.groupId)
                            Layout.preferredWidth: 60
                        }
                        Label {
                            text: modelData.mustChange ? "⚠️" : "✓"
                            Layout.preferredWidth: 70
                        }
                        RowLayout {
                            spacing: 4
                            Layout.fillWidth: true
                            Button {
                                text: "✏️"; implicitWidth: 36
                                onClicked: { editDialog.targetUser = modelData; editDialog.open() }
                            }
                            Button {
                                text: "🔑"; implicitWidth: 36
                                onClicked: {
                                    confirmDialog.title = "Reset mật khẩu?"
                                    confirmDialog.message = "Sinh mật khẩu mới ngẫu nhiên cho '" + modelData.username + "'?"
                                    confirmDialog.action = "reset"
                                    confirmDialog.targetId = modelData.id
                                    confirmDialog.open()
                                }
                            }
                            Button {
                                text: "🗑️"; implicitWidth: 36
                                enabled: modelData.id !== 1
                                onClicked: {
                                    confirmDialog.title = "Xoá user?"
                                    confirmDialog.message = "Xoá user '" + modelData.username + "'?"
                                    confirmDialog.action = "delete"
                                    confirmDialog.targetId = modelData.id
                                    confirmDialog.open()
                                }
                            }
                            Item { Layout.fillWidth: true }
                        }
                    }
                }
            }
        }
    }

    // ===== Dialogs =====
    Dialog {
        id: createDialog
        title: "➕ Tạo người dùng mới"
        modal: true; anchors.centerIn: parent; width: 420
        standardButtons: Dialog.NoButton
        onOpened: {
            usernameField.text = ""; fullNameField.text = ""
            roleCombo.currentIndex = 0; groupSpin.value = -1
            createAvatar.currentPath = ""
            createError.text = ""; usernameField.forceActiveFocus()
        }
        ColumnLayout {
            anchors.fill: parent
            spacing: 10
            Label { text: "Ảnh đại diện:" }
            AvatarUploader { id: createAvatar; Layout.fillWidth: true }
            Label { text: "Tên đăng nhập (≥ 3 ký tự):" }
            TextField { id: usernameField; Layout.fillWidth: true }
            Label { text: "Họ tên đầy đủ:" }
            TextField { id: fullNameField; Layout.fillWidth: true }
            Label { text: "Vai trò:" }
            ComboBox { id: roleCombo; Layout.fillWidth: true; model: ["member", "admin"] }
            Label { text: "Nhóm (-1 = chưa gán):" }
            SpinBox { id: groupSpin; Layout.fillWidth: true; from: -1; to: 99; value: -1 }
            Label { id: createError; color: "red"; wrapMode: Text.Wrap; Layout.fillWidth: true; visible: text.length > 0 }
            RowLayout {
                Layout.fillWidth: true; Layout.alignment: Qt.AlignRight
                Button { text: "Huỷ"; onClicked: createDialog.close() }
                Button {
                    text: "Tạo"; highlighted: true
                    onClicked: {
                        createError.text = ""
                        adminUser.createUser(usernameField.text, fullNameField.text, roleCombo.currentText, groupSpin.value, createAvatar.currentPath)
                    }
                }
            }
        }
    }

    Dialog {
        id: editDialog
        title: "✏️ Sửa người dùng"
        modal: true; anchors.centerIn: parent; width: 420
        standardButtons: Dialog.NoButton
        property var targetUser: null
        onOpened: {
            if (targetUser) {
                editFullName.text = targetUser.fullName
                editRoleCombo.currentIndex = targetUser.role === "admin" ? 1 : 0
                editGroupSpin.value = targetUser.groupId
                editAvatar.currentPath = targetUser.avatarPath
            }
            editError.text = ""
        }
        ColumnLayout {
            anchors.fill: parent
            spacing: 10
            Label {
                text: "Username: " + (editDialog.targetUser ? editDialog.targetUser.username : "")
                color: "#666"; font.italic: true
            }
            Label { text: "Ảnh đại diện:" }
            AvatarUploader { id: editAvatar; Layout.fillWidth: true }
            Label { text: "Họ tên đầy đủ:" }
            TextField { id: editFullName; Layout.fillWidth: true }
            Label { text: "Vai trò:" }
            ComboBox { id: editRoleCombo; Layout.fillWidth: true; model: ["member", "admin"] }
            Label { text: "Nhóm (-1 = chưa gán):" }
            SpinBox { id: editGroupSpin; Layout.fillWidth: true; from: -1; to: 99 }
            Label { id: editError; color: "red"; wrapMode: Text.Wrap; Layout.fillWidth: true; visible: text.length > 0 }
            RowLayout {
                Layout.fillWidth: true; Layout.alignment: Qt.AlignRight
                Button { text: "Huỷ"; onClicked: editDialog.close() }
                Button {
                    text: "Lưu"; highlighted: true
                    onClicked: {
                        adminUser.updateUser(editDialog.targetUser.id, editFullName.text, editRoleCombo.currentText, editGroupSpin.value, editAvatar.currentPath  )
                        editDialog.close()
                    }
                }
            }
        }
    }

    Dialog {
        id: confirmDialog
        modal: true; anchors.centerIn: parent; width: 380
        standardButtons: Dialog.NoButton
        property string message: ""
        property string action: ""
        property int targetId: -1
        ColumnLayout {
            anchors.fill: parent
            spacing: 14
            Label { text: confirmDialog.message; wrapMode: Text.Wrap; Layout.fillWidth: true }
            RowLayout {
                Layout.fillWidth: true; Layout.alignment: Qt.AlignRight
                Button { text: "Huỷ"; onClicked: confirmDialog.close() }
                Button {
                    text: confirmDialog.action === "delete" ? "Xoá" : "Reset"
                    highlighted: true
                    onClicked: {
                        if (confirmDialog.action === "delete") adminUser.deleteUser(confirmDialog.targetId)
                        else if (confirmDialog.action === "reset") adminUser.resetPassword(confirmDialog.targetId)
                        confirmDialog.close()
                    }
                }
            }
        }
    }

    Dialog {
        id: passResultDialog
        title: "🔐 Mật khẩu mới"
        modal: true; anchors.centerIn: parent; width: 400
        standardButtons: Dialog.Ok
        property string username: ""
        property string newPassword: ""
        ColumnLayout {
            anchors.fill: parent
            spacing: 10
            Label { text: "User: " + passResultDialog.username; font.pixelSize: 14 }
            Label { text: "Mật khẩu mới (lưu ngay):" }
            Rectangle {
                Layout.fillWidth: true; Layout.preferredHeight: 50
                color: "#fff8dc"; border.color: "#daa520"
                Label {
                    anchors.centerIn: parent
                    text: passResultDialog.newPassword
                    font.family: "Consolas"; font.pixelSize: 20; font.bold: true
                }
            }
            Label {
                text: "💡 User này sẽ bị bắt đổi pass khi đăng nhập tới."
                color: "#666"; font.italic: true; wrapMode: Text.Wrap; Layout.fillWidth: true
            }
        }
    }

    Connections {
        target: root.adminUser
        function onUserCreated(id, username, generatedPassword) {
            createDialog.close()
            passResultDialog.username = username
            passResultDialog.newPassword = generatedPassword
            passResultDialog.open()
        }
        function onPasswordReset(id, username, newPassword) {
            passResultDialog.username = username
            passResultDialog.newPassword = newPassword
            passResultDialog.open()
        }
        function onCreateFailed(reason) { createError.text = reason }
        function onUpdateFailed(reason) { editError.text = reason }
    }
}