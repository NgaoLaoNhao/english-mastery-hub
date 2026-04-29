import QtQuick

// ============================================================
// MockAdminUserController — phiên bản giả AdminUserController
// CRUD user trong RAM. Cùng interface (signal, method) với
// real C++ controller sẽ build ở DB track.
// ============================================================
QtObject {
    id: mockAdmin

    // ===== Properties =====
    // List user. Mỗi user là object: { id, username, fullName, role, groupId, mustChange, avatarPath }
    property var users: [
        { id: 1, username: "admin", fullName: "Admin", role: "admin",  groupId: -1, mustChange: false, avatarPath: "" },
        { id: 2, username: "tien",  fullName: "Tiền",  role: "member", groupId: 1,  mustChange: false, avatarPath: "" },
        { id: 3, username: "duy",   fullName: "Duy",   role: "member", groupId: 1,  mustChange: true,  avatarPath: "" }
    ]
    property int _nextId: 4

    // ===== Signals =====
    signal userCreated(int id, string username, string generatedPassword)
    signal passwordReset(int id, string username, string newPassword)
    signal createFailed(string reason)
    signal updateFailed(string reason)
    signal deleteFailed(string reason)

    // ===== Methods =====
    function getUser(id) {
        for (var i = 0; i < users.length; i++) {
            if (users[i].id === id) return users[i]
        }
        return null
    }

    function createUser(username, fullName, role, groupId, avatarPath) {
        if (!username || username.length < 3) {
            createFailed("Tên đăng nhập phải ≥ 3 ký tự")
            return
        }
        for (var i = 0; i < users.length; i++) {
            if (users[i].username === username) {
                createFailed("Tên đăng nhập đã tồn tại")
                return
            }
        }
        const id = _nextId++
        const generated = _generatePassword()
        users = users.concat([{
            id: id,
            username: username,
            fullName: fullName || "",
            role: role || "member",
            groupId: groupId !== undefined ? groupId : -1,
            mustChange: true,
            avatarPath: avatarPath || ""        // <-- THÊM
        }])
        userCreated(id, username, generated)
    }

    function updateUser(id, fullName, role, groupId, avatarPath) {
        users = users.map(function(u) {
            if (u.id === id) {
                return Object.assign({}, u, {
                    fullName: fullName,
                    role: role,
                    groupId: groupId,
                    avatarPath: avatarPath !== undefined ? avatarPath : u.avatarPath  // <-- THÊM
                })
            }
            return u
        })
    }

    function deleteUser(id) {
        if (id === 1) {
            deleteFailed("Không thể xoá admin gốc")
            return
        }
        users = users.filter(function(u) { return u.id !== id })
    }

    function resetPassword(id) {
        const u = getUser(id)
        if (!u) return
        const newPass = _generatePassword()
        users = users.map(function(x) {
            if (x.id === id) return Object.assign({}, x, { mustChange: true })
            return x
        })
        passwordReset(id, u.username, newPass)
    }

    // Helper: random pass 8 ký tự dễ đọc
    function _generatePassword() {
        const chars = "abcdefghijkmnpqrstuvwxyz23456789"
        let result = ""
        for (let i = 0; i < 8; i++) {
            result += chars[Math.floor(Math.random() * chars.length)]
        }
        return result
    }
}