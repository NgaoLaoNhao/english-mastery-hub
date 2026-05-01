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
    MockAdminUserController { id: mockAdminUser }
    MockAppSettingsController { id: mockAppSettings }
    MockAdminGroupController { id: mockAdminGroup }
    MockCheckinController {
        id: mockCheckin
        adminUserRef: mockAdminUser    // pass reference để biết user list
    }
    MockTopController {
        id: mockTop
        checkin: mockCheckin
        adminUser: mockAdminUser
        adminGroup: mockAdminGroup
    }
    MockResourceController { id: mockResource }
    MockPersonalController {
        id: mockPersonal
        checkin: mockCheckin
        auth: mockAuth
        adminUser: mockAdminUser
        adminGroup: mockAdminGroup
    }
    MockGroupDetailController {
        id: mockGroupDetail
        auth: mockAuth
        adminUser: mockAdminUser
        adminGroup: mockAdminGroup
        checkin: mockCheckin
    }
    MockGeminiController { id: mockGemini }                       // ← Người C thêm
    // realAuthController được expose từ main.cpp qua setContextProperty
    // -> tham chiếu trực tiếp tên đó.

    readonly property var auth: useMocks ? mockAuth : realAuthController
    // Admin user controller (TODO: realAdminUserController sẽ có ở DB track)
    readonly property var adminUser: useMocks ? mockAdminUser : null
    readonly property var adminGroup: useMocks ? mockAdminGroup : null
    readonly property var checkin: useMocks ? mockCheckin : null
    readonly property var appSettings: useMocks ? mockAppSettings : null
    readonly property var topController: useMocks ? mockTop : null    // ============================================================
    readonly property var resource: useMocks ? mockResource : null
    readonly property var personal: useMocks ? mockPersonal : null
    readonly property var groupDetail: useMocks ? mockGroupDetail : null
    readonly property var gemini: useMocks ? mockGemini : realGeminiController
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
            checkin: root.checkin            // <-- THÊM
            adminUser: root.adminUser        // <-- THÊM
            adminGroup: root.adminGroup      // <-- THÊM
            appSettings: root.appSettings
            topController: root.topController
            onLogoutRequested: {
                root.auth.logout()
                stack.replace(loginPage)
            }
            onOpenAdminPanel: stack.replace(adminPanelPage)    // <-- THÊM'
            onOpenPersonal: stack.replace(personalPage)
            onOpenGroupDetail: function(gid) {
                root.currentGroupDetailId = gid
                stack.replace(groupDetailPage)
            }
            onOpenTopDetail: function(uid) {
                root.currentTopDetailUserId = uid
                stack.replace(topDetailPage)
            }
            resource: root.resource
            gemini: root.gemini                                  // ← Người C thêm
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
    Component {
        id: personalPage
        PersonalView {
            auth: root.auth
            personal: root.personal
            checkin: root.checkin
            adminUser: root.adminUser
            adminGroup: root.adminGroup
            gemini: root.gemini                              // ← Người C thêm
            onBackRequested: stack.replace(welcomePage)
        }
    }
    property int currentGroupDetailId: -1

    Component {
        id: groupDetailPage
        GroupDetailView {
            auth: root.auth
            groupDetail: root.groupDetail
            adminGroup: root.adminGroup
            adminUser: root.adminUser
            groupId: root.currentGroupDetailId
            onBackRequested: stack.replace(welcomePage)
        }
    }
    property int currentTopDetailUserId: -1

    Component {
        id: topDetailPage
        TopDetailView {
            auth: root.auth
            personal: root.personal
            adminUser: root.adminUser
            adminGroup: root.adminGroup
            userId: root.currentTopDetailUserId
            onBackRequested: stack.replace(welcomePage)
            onOpenGroupDetail: function(gid) {
                root.currentGroupDetailId = gid
                stack.replace(groupDetailPage)
            }
        }
    }

}