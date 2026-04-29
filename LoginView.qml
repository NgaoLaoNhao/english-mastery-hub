import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Item {
    id: root

    ColumnLayout {
        anchors.centerIn: parent
        width: 320
        spacing: 16

        Label {
            text: "🎓 English Mastery Hub"
            font.pixelSize: 24
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }

        Label {
            text: "Đăng nhập"
            font.pixelSize: 16
            color: "#666"
            Layout.alignment: Qt.AlignHCenter
        }

        TextField {
            id: usernameField
            Layout.fillWidth: true
            placeholderText: "Tên đăng nhập"
            text: "admin"  // Pre-fill cho tiện test, sau M1 có thể xoá
        }

        TextField {
            id: passwordField
            Layout.fillWidth: true
            placeholderText: "Mật khẩu"
            echoMode: TextInput.Password
            onAccepted: loginButton.clicked()  // Enter = bấm nút
        }

        Button {
            id: loginButton
            text: "Đăng nhập"
            Layout.fillWidth: true
            onClicked: {
                errorLabel.text = ""
                auth.login(usernameField.text, passwordField.text)
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

    // Lắng nghe signal loginFailed từ C++
    Connections {
        target: auth
        function onLoginFailed(reason) {
            errorLabel.text = reason
        }
    }
}