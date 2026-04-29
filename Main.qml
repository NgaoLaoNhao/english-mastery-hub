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
    readonly property bool useMocks: true

    // Mock instance (luôn được tạo, chỉ dùng nếu useMocks=true)
    MockAuthController { id: mockAuth }
    MockAdminUserController { id: mockAdminUser }
    MockAdminGroupController { id: mockAdminGroup }

    // realAuthController được expose từ main.cpp qua setContextProperty
    // -> tham chiếu trực tiếp tên đó.

    readonly property var auth: useMocks ? mockAuth : realAuthController
    // Admin user controller (TODO: realAdminUserController sẽ có ở DB track)
    readonly property var adminUser: useMocks ? mockAdminUser : null
    readonly property var adminGroup: useMocks ? mockAdminGroup : null
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
            onOpenAdminPanel: stack.replace(adminPanelPage)    // <-- THÊM
        }
    }

    Component {                                                // <-- THÊM CẢ COMPONENT MỚI
        id: adminPanelPage
        AdminPanelView {
            auth: root.auth
            adminUser: root.adminUser
            adminGroup: root.adminGroup
            onBackToWelcome: stack.replace(welcomePage)
        }
    }
}