import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Item {
    id: root
    property var auth: null
    signal loginOk()

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
            text: "admin"
        }

        TextField {
            id: passwordField
            Layout.fillWidth: true
            placeholderText: "Mật khẩu"
            echoMode: TextInput.Password
            onAccepted: loginButton.clicked()
        }

        Button {
            id: loginButton
            text: "Đăng nhập"
            Layout.fillWidth: true
            onClicked: {
                errorLabel.text = ""
                auth.login(usernameField.text, passwordField.text)
                // Không check return — đợi signal currentUserChanged hoặc loginFailed
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
        function onCurrentUserChanged() {
            // Chỉ navigate khi vừa login THÀNH CÔNG (isLoggedIn -> true)
            if (root.auth.isLoggedIn) {
                root.loginOk()
            }
        }
        function onLoginFailed(reason) {
            errorLabel.text = reason
        }
    }
}