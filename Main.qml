import QtQuick
import QtQuick.Window
import QtQuick.Controls

ApplicationWindow {
    id: root
    width: 1200
    height: 800
    visible: true
    title: qsTr("English Mastery Hub")

    // ============================================================
    // FLAG SWITCH MOCK/REAL — đổi 1 dòng để chuyển toàn app
    // ============================================================
    readonly property bool useMocks: false

    // Mock instance (luôn được tạo, chỉ dùng nếu useMocks=true)
    MockAuthController { id: mockAuth }

    // realAuthController được expose từ main.cpp qua setContextProperty
    // -> tham chiếu trực tiếp tên đó.

    readonly property var auth: useMocks ? mockAuth : realAuthController

    // ============================================================
    // Router — dùng StackView + Component
    // ============================================================
    StackView {
        id: stack
        anchors.fill: parent
        initialItem: loginPage
    }

    Component {
        id: loginPage
        LoginView {
            auth: root.auth
            onLoginOk: {
                if (root.auth.mustChangePassword) {
                    stack.replace(changePassPage)
                } else {
                    stack.replace(welcomePage)
                }
            }
        }
    }

    Component {
        id: changePassPage
        ChangePasswordView {
            auth: root.auth
            onChangeOk: stack.replace(welcomePage)
        }
    }

    Component {
        id: welcomePage
        WelcomeView {
            auth: root.auth
            onLogoutRequested: {
                root.auth.logout()
                stack.replace(loginPage)
            }
        }
    }
}