import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Item {
    id: root
    property var auth: null
    signal changeOk()

    ColumnLayout {
        anchors.centerIn: parent
        width: 360
        spacing: 14

        Label {
            text: "🔐 Đổi mật khẩu"
            font.pixelSize: 22
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }

        Label {
            text: "Đây là lần đầu đăng nhập. Vui lòng đặt mật khẩu mới (≥ 6 ký tự)."
            wrapMode: Text.Wrap
            color: "#666"
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }

        TextField {
            id: oldField
            Layout.fillWidth: true
            placeholderText: "Mật khẩu hiện tại"
            echoMode: TextInput.Password
        }

        TextField {
            id: newField
            Layout.fillWidth: true
            placeholderText: "Mật khẩu mới (≥ 6 ký tự)"
            echoMode: TextInput.Password
        }

        TextField {
            id: confirmField
            Layout.fillWidth: true
            placeholderText: "Nhập lại mật khẩu mới"
            echoMode: TextInput.Password
            onAccepted: changeButton.clicked()
        }

        Button {
            id: changeButton
            text: "Đổi mật khẩu"
            Layout.fillWidth: true
            onClicked: {
                errorLabel.text = ""
                if (newField.text !== confirmField.text) {
                    errorLabel.text = "Mật khẩu xác nhận không khớp."
                    return
                }
                auth.changePassword(oldField.text, newField.text)
                // Đợi signal passwordChanged hoặc passwordChangeFailed
            }
        }

        Label {
            id: errorLabel
            color: "red"
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Connections {
        target: root.auth
        function onPasswordChanged() {
            root.changeOk()
        }
        function onPasswordChangeFailed(reason) {
            errorLabel.text = reason
        }
    }
}