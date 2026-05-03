import QtQuick
import QtQuick.Window
import QtQuick.Controls

ApplicationWindow {
    id: root
    width: 1200
    height: 800
    visible: true
    title: qsTr("English Mastery Hub")
    color: theme ? theme.colors.pageBg : "#f8fafc"

    readonly property bool useMocks: true

    // ============================================================
    // Mock instances
    // ============================================================
    MockAuthController        { id: mockAuth }
    MockAdminUserController   { id: mockAdminUser }
    MockAppSettingsController { id: mockAppSettings }
    MockAdminGroupController  { id: mockAdminGroup }
    MockCheckinController {
        id: mockCheckin
        adminUserRef: mockAdminUser
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
    MockGeminiController         { id: mockGemini }
    MockNotificationController   { id: mockNotification }
    MockPdfExporter {
        id: mockPdfExporter
        checkin: mockCheckin
        auth: mockAuth
        adminUser: mockAdminUser
        adminGroup: mockAdminGroup
        personal: mockPersonal
        groupDetail: mockGroupDetail
    }
    MockThemeController          { id: mockTheme }
    // ============================================================
    // Property aliases
    // ============================================================
    readonly property var auth:           useMocks ? mockAuth          : realAuthController
    readonly property var adminUser:      useMocks ? mockAdminUser     : null
    readonly property var adminGroup:     useMocks ? mockAdminGroup    : null
    readonly property var checkin:        useMocks ? mockCheckin       : null
    readonly property var appSettings:    useMocks ? mockAppSettings   : null
    readonly property var topController:  useMocks ? mockTop           : null
    readonly property var resource:       useMocks ? mockResource      : null
    readonly property var personal:       useMocks ? mockPersonal      : null
    readonly property var groupDetail:    useMocks ? mockGroupDetail   : null
    readonly property var gemini:         useMocks ? mockGemini        : realGeminiController
    readonly property var notification:   useMocks ? mockNotification  : null
    readonly property var pdfExporter: useMocks ? mockPdfExporter : null
    readonly property var theme:        mockTheme
    // ============================================================
    // State điều hướng
    // ============================================================
    property int currentGroupDetailId: -1
    property int currentTopDetailUserId: -1
    property int currentResourceDetailId: -1

    // ============================================================
    // Helpers (notif routing + user lookup)
    // ============================================================
    function _routeNotifLink(link, refId) {
        if (!link) return
        var parts = link.split(":")
        if (parts.length < 2) return
        var kind = parts[0]
        var id = parseInt(parts[1])
        if (isNaN(id)) return
        if (kind === "resource") {
            root.currentResourceDetailId = id
            stack.replace(resourceDetailPage)
        } else if (kind === "group") {
            root.currentGroupDetailId = id
            stack.replace(groupDetailPage)
        }
    }

    function _userIdFromUsername(uname) {
        if (!adminUser || !uname) return -1
        var us = adminUser.users || []
        for (var i = 0; i < us.length; i++)
            if (us[i].username === uname) return us[i].id
        return -1
    }

    function _userDisplayById(uid) {
        if (!adminUser || uid < 0) return "ai đó"
        var us = adminUser.users || []
        for (var i = 0; i < us.length; i++)
            if (us[i].id === uid)
                return us[i].fullName || ("@" + us[i].username)
        return "ai đó"
    }

    // ============================================================
    // M8 E.5: Wire resource events → tự sinh notif
    // ============================================================
    Connections {
        target: root.resource
        enabled: !!root.resource && !!root.notification

        // Comment mới → notify uploader
        function onCommentAdded(commentId, resourceId) {
            var res = root.resource.getResourceById(resourceId)
            if (!res) return

            var uploaderId = root._userIdFromUsername(res.uploadedBy)
            if (uploaderId <= 0) return

            // Tìm comment vừa thêm để lấy userId người comment
            var allCmts = root.resource.getComments(resourceId)
            var commenterId = -1
            for (var i = 0; i < allCmts.length; i++) {
                if (allCmts[i].id === commentId) {
                    commenterId = allCmts[i].userId
                    break
                }
            }
            // Skip self-notify
            if (commenterId === uploaderId) return

            var commenterName = root._userDisplayById(commenterId)
            root.notification.addNotif(
                uploaderId,
                "comment",
                "💬 Bình luận mới",
                commenterName + " đã bình luận tài liệu \"" + res.title + "\"",
                "resource:" + resourceId,
                resourceId
            )
        }

        // Like → notify uploader (chỉ khi liked=true)
        function onLikeToggled(resourceId, userId, liked) {
            if (!liked) return  // chỉ notify khi like, bỏ qua unlike

            var res = root.resource.getResourceById(resourceId)
            if (!res) return

            var uploaderId = root._userIdFromUsername(res.uploadedBy)
            if (uploaderId <= 0) return
            // Skip self-notify
            if (userId === uploaderId) return

            var likerName = root._userDisplayById(userId)
            root.notification.addNotif(
                uploaderId,
                "like",
                "❤️ Có lượt thích mới",
                likerName + " đã thích tài liệu \"" + res.title + "\"",
                "resource:" + resourceId,
                resourceId
            )
        }
    }

    // ============================================================
    // Router
    // ============================================================
    StackView {
        id: stack
        anchors.fill: parent
        initialItem: loginPage
    }

    // ===== M8 E.2: Phím tắt test toast =====
    Shortcut {
        sequence: "Ctrl+T"
        onActivated: {
            var uid = -1
            if (root.adminUser && root.auth) {
                var us = root.adminUser.users || []
                for (var i = 0; i < us.length; i++)
                    if (us[i].username === root.auth.currentUsername) {
                        uid = us[i].id; break
                    }
            }
            if (uid <= 0) { console.log("Chưa login"); return }

            root.notification.addNotif(
                uid,
                "comment",
                "💬 Test toast",
                "Đây là thông báo test bấm Ctrl+T",
                "resource:1",
                1
            )
        }
    }

    // ===== M8 E.2: Toast overlay =====
    NotificationToastHost {
        anchors.fill: parent
        auth: root.auth
        notification: root.notification
        adminUser: root.adminUser
        onToastClicked: function(link, refId) { root._routeNotifLink(link, refId) }
    }

    // ============================================================
    // Pages
    // ============================================================
    Component {
        id: loginPage
        LoginView {
            auth: root.auth
            theme: root.theme
            onLoginOk: {
                if (root.auth.mustChangePassword) stack.replace(changePassPage)
                else stack.replace(welcomePage)
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
            checkin: root.checkin
            adminUser: root.adminUser
            adminGroup: root.adminGroup
            appSettings: root.appSettings
            topController: root.topController
            resource: root.resource
            gemini: root.gemini
            notification: root.notification
            theme: root.theme

            onLogoutRequested: { root.auth.logout(); stack.replace(loginPage) }
            onOpenAdminPanel: stack.replace(adminPanelPage)
            onOpenPersonal: stack.replace(personalPage)
            onOpenGroupDetail: function(gid) {
                root.currentGroupDetailId = gid
                stack.replace(groupDetailPage)
            }
            onOpenTopDetail: function(uid) {
                root.currentTopDetailUserId = uid
                stack.replace(topDetailPage)
            }
            onOpenResourceDetail: function(rid) {
                root.currentResourceDetailId = rid
                stack.replace(resourceDetailPage)
            }
            onNotifNavigateRequested: function(link, refId) { root._routeNotifLink(link, refId) }
        }
    }

    Component {
        id: adminPanelPage
        AdminPanelView {
            auth: root.auth
            adminUser: root.adminUser
            adminGroup: root.adminGroup
            pdfExporter: root.pdfExporter
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
            gemini: root.gemini
            pdfExporter: root.pdfExporter
            theme: root.theme
            onBackRequested: stack.replace(welcomePage)
        }
    }

    Component {
        id: groupDetailPage
        GroupDetailView {
            auth: root.auth
            groupDetail: root.groupDetail
            adminGroup: root.adminGroup
            adminUser: root.adminUser
            groupId: root.currentGroupDetailId
            pdfExporter: root.pdfExporter
            onBackRequested: stack.replace(welcomePage)
        }
    }

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

    Component {
        id: resourceDetailPage
        ResourceDetailView {
            auth: root.auth
            resource: root.resource
            adminUser: root.adminUser
            adminGroup: root.adminGroup
            resourceId: root.currentResourceDetailId
            onBackRequested: stack.replace(welcomePage)
        }
    }
}