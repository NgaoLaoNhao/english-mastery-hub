import QtQuick
import QtQuick.Controls.Basic

Window {
    id: mainWindow
    width: 480
    height: 560
    visible: true
    title: qsTr("English Mastery Hub")

    // ─── Loader chính: hiển thị view tuỳ trạng thái ─────────────
    Loader {
        anchors.fill: parent
        sourceComponent: {
            if (!authController.isLoggedIn)
                return loginComponent
            if (authController.mustChangePassword)
                return changePasswordComponent
            return welcomeComponent
        }
    }

    // ─── 3 Component pre-defined ────────────────────────────────
    Component {
        id: loginComponent
        LoginView {}
    }

    Component {
        id: changePasswordComponent
        ChangePasswordView {}
    }

    Component {
        id: welcomeComponent
        WelcomeView {}
    }
}