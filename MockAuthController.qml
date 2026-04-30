import QtQuick

QtObject {
    id: mock

    // Properties (mirror real C++ AuthController)
    property string currentUsername: ""
    property string currentDisplayName: ""
    property string currentRole: ""
    property int    currentUserId: -1
    property bool   isLoggedIn: false
    property bool   mustChangePassword: false

    // Signals (mirror real)
    signal currentUserChanged()
    signal loginFailed(string reason)
    signal passwordChanged()
    signal passwordChangeFailed(string reason)

    property var _users: ({
        "admin": { id: 1, password: "admin123", role: "admin",  mustChange: true,  fullName: "Admin" },
        "tien":  { id: 2, password: "tien1234", role: "member", mustChange: false, fullName: "Tiền"  },
        "duy":   { id: 3, password: "duy12345", role: "member", mustChange: true,  fullName: "Duy"   }
    })

    function login(username, password) {
        const u = _users[username]
        if (!u || u.password !== password) {
            loginFailed("Sai tên đăng nhập hoặc mật khẩu")
            return
        }
        currentUsername     = username
        currentDisplayName  = u.fullName || ""
        currentRole         = u.role
        currentUserId       = u.id
        isLoggedIn          = true
        mustChangePassword  = u.mustChange
        currentUserChanged()
    }

    function logout() {
        currentUsername     = ""
        currentDisplayName  = ""
        currentRole         = ""
        currentUserId       = -1
        isLoggedIn          = false
        mustChangePassword  = false
        currentUserChanged()
    }

    function changePassword(oldPwd, newPwd) {
        if (!isLoggedIn) {
            passwordChangeFailed("Chưa đăng nhập")
            return
        }
        const u = _users[currentUsername]
        if (u.password !== oldPwd) {
            passwordChangeFailed("Mật khẩu cũ không đúng")
            return
        }
        if (newPwd.length < 6) {
            passwordChangeFailed("Mật khẩu mới phải >= 6 ký tự")
            return
        }
        u.password         = newPwd
        u.mustChange       = false
        mustChangePassword = false
        passwordChanged()
        currentUserChanged()
    }
    // Cho phép cập nhật fullName từ ngoài (sync với adminUser khi user sửa hồ sơ)
    function updateUserFullName(userId, newFullName) {
        var s = String(newFullName)
        for (var key in _users) {
            if (_users[key].id === userId) {
                _users[key].fullName = s
                if (currentUserId === userId) {
                    currentDisplayName = s
                    currentUserChanged()
                }
                return
            }
        }
    }
}