// file: mocks/MockAuthController.qml
//
// =============================================================
//  Mock cho AuthController (C++) — chạy thuần QML, không cần DB.
// =============================================================
//  Khi Main.qml đặt useMocks = true, biến `auth` sẽ trỏ vào instance này
//  thay vì controller C++ thật. Mọi View con chỉ gọi auth.xxx nên không
//  cần biết bên dưới là Mock hay Real.
//
//  CONTRACT — phải KHỚP 100% với AuthController.h:
//    Properties: isLoggedIn, mustChangePassword, currentUserId,
//                currentUsername, currentDisplayName, currentRole
//    Signals:    loginFailed(reason), passwordChanged(),
//                passwordChangeFailed(reason)
//                (currentUserChanged tự sinh từ Q_PROPERTY NOTIFY ở C++,
//                 ở QML các property dưới đây cũng tự có xxxChanged.)
//    Methods:    login(username, password),
//                changePassword(oldPassword, newPassword),
//                logout()
//
//  Tài khoản giả lập có sẵn:
//    admin / admin123  -> đúng pass, mustChangePassword = true (lần đầu)
//    user1 / 123456    -> đúng pass, mustChangePassword = false
//    còn lại           -> báo "Tên đăng nhập không tồn tại."
// =============================================================

import QtQuick

QtObject {
    id: mockAuth

    // ─── 1. Properties (khớp Q_PROPERTY bên C++) ─────────────────
    property bool   isLoggedIn:         false
    property bool   mustChangePassword: false
    property int    currentUserId:      -1
    property string currentUsername:    ""
    property string currentDisplayName: ""
    property string currentRole:        ""

    // ─── 2. Signals (khớp `signals:` bên C++) ────────────────────
    signal loginFailed(string reason)
    signal passwordChanged()
    signal passwordChangeFailed(string reason)

    // ─── 3. "DB" giả lập trong RAM ───────────────────────────────
    // Cấu trúc copy phần cần dùng của DatabaseManager::UserRecord.
    // Đây là `var` (object JS) chứ không phải readonly để có thể "ghi"
    // pass mới vào khi changePassword chạy thành công.
    property var m_fakeUsers: ({
        "admin": {
            id: 1,
            password: "admin123",
            displayName: "Administrator",
            role: "admin",
            mustChangePassword: true
        },
        "user1": {
            id: 2,
            password: "123456",
            displayName: "User One",
            role: "member",
            mustChangePassword: false
        }
    })

    // Buffer cho call async giả lập (giữ tham số giữa lúc bấm và lúc Timer fire).
    property string m_pendingUsername: ""
    property string m_pendingPassword: ""
    property string m_pendingOldPassword: ""
    property string m_pendingNewPassword: ""

    // ─── 4. Timer giả lập độ trễ I/O (~200ms) ────────────────────
    // Lý do: ép UI xử lý trạng thái "đang xử lý" để giống Real (xem mục 1.4).
    property Timer m_loginTimer: Timer {
        interval: 200
        repeat: false
        onTriggered: mockAuth._doLogin()
    }
    property Timer m_changePassTimer: Timer {
        interval: 200
        repeat: false
        onTriggered: mockAuth._doChangePassword()
    }

    // ─── 5. Public API (khớp Q_INVOKABLE bên C++) ────────────────
    function login(username, password) {
        // Lưu tham số rồi delay 200ms mới xử lý — y hệt async call.
        m_pendingUsername = (username || "").trim()
        m_pendingPassword = password || ""
        m_loginTimer.restart()
    }

    function changePassword(oldPassword, newPassword) {
        m_pendingOldPassword = oldPassword || ""
        m_pendingNewPassword = newPassword || ""
        m_changePassTimer.restart()
    }

    function logout() {
        _clearCurrentUser()
        console.log("[MockAuth] Logout OK")
    }

    // ─── 6. Internal handlers (chạy sau Timer fire) ──────────────
    function _doLogin() {
        if (m_pendingUsername.length === 0 || m_pendingPassword.length === 0) {
            loginFailed("Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu.")
            return
        }

        const rec = m_fakeUsers[m_pendingUsername]
        if (!rec) {
            loginFailed("Tên đăng nhập không tồn tại.")
            return
        }
        if (rec.password !== m_pendingPassword) {
            loginFailed("Sai mật khẩu.")
            return
        }

        _setCurrentUser(rec.id,
                        m_pendingUsername,
                        rec.displayName,
                        rec.role,
                        rec.mustChangePassword)
        console.log("[MockAuth] Login OK:", m_pendingUsername,
                    "(must change pass:", rec.mustChangePassword, ")")
    }

    function _doChangePassword() {
        if (!isLoggedIn) {
            passwordChangeFailed("Bạn chưa đăng nhập.")
            return
        }
        if (m_pendingNewPassword.length < 6) {
            passwordChangeFailed("Mật khẩu mới phải có ít nhất 6 ký tự.")
            return
        }
        const rec = m_fakeUsers[currentUsername]
        if (!rec) {
            passwordChangeFailed("Không tìm thấy tài khoản.")
            return
        }
        if (m_pendingOldPassword !== rec.password) {
            passwordChangeFailed("Mật khẩu cũ không đúng.")
            return
        }
        if (m_pendingOldPassword === m_pendingNewPassword) {
            passwordChangeFailed("Mật khẩu mới phải khác mật khẩu cũ.")
            return
        }

        // "Ghi" pass mới vào fake DB + clear cờ must_change.
        rec.password = m_pendingNewPassword
        rec.mustChangePassword = false
        mustChangePassword = false

        passwordChanged()
        console.log("[MockAuth] Password changed OK for user:", currentUsername)
    }

    // ─── 7. Helpers nội bộ ───────────────────────────────────────
    function _setCurrentUser(id, username, displayName, role, mustChange) {
        currentUserId      = id
        currentUsername    = username
        currentDisplayName = displayName
        currentRole        = role
        mustChangePassword = mustChange
        isLoggedIn         = true     // Bật cuối cùng để các binding re-eval đúng thứ tự.
    }

    function _clearCurrentUser() {
        isLoggedIn         = false    // Tắt đầu tiên: Loader nhảy về LoginView ngay.
        currentUserId      = -1
        currentUsername    = ""
        currentDisplayName = ""
        currentRole        = ""
        mustChangePassword = false
    }
}