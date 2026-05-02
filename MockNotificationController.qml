import QtQuick

QtObject {
    id: root

    // ===== Store =====
    // { id, userId (recipient), type, title, body, link?, refId?, isRead, createdAt }
    property var notifications: [
        // Seed cho admin (userId 1)
        {
            id: 1, userId: 1, type: "comment",
            title: "💬 Bình luận mới",
            body: "@tien đã bình luận về tài liệu \"Cambridge B1 — Chương 2\"",
            link: "resource:1", refId: 1,
            isRead: false,
            createdAt: "2026-04-22T08:30:00"
        },
        {
            id: 2, userId: 1, type: "like",
            title: "❤️ Có lượt thích mới",
            body: "@duy đã thích tài liệu \"Cambridge B1 — Chương 2\"",
            link: "resource:1", refId: 1,
            isRead: false,
            createdAt: "2026-04-23T10:00:00"
        },
        {
            id: 3, userId: 1, type: "streak",
            title: "🔥 Streak 7 ngày!",
            body: "Chúc mừng bạn đã check-in liên tiếp 7 ngày.",
            link: "", refId: 0,
            isRead: true,
            createdAt: "2026-04-21T18:00:00"
        },

        // Seed cho user id=2 (tien)
        {
            id: 4, userId: 2, type: "group_added",
            title: "👥 Bạn đã được thêm vào nhóm",
            body: "Admin đã thêm bạn vào \"Nhóm Alpha\"",
            link: "group:1", refId: 1,
            isRead: false,
            createdAt: "2026-04-15T09:00:00"
        },
        {
            id: 5, userId: 2, type: "comment",
            title: "💬 Bình luận mới",
            body: "@admin đã trả lời bình luận của bạn",
            link: "resource:2", refId: 2,
            isRead: true,
            createdAt: "2026-04-22T14:00:00"
        }
    ]
    property int _nextId: 6
    property int _maxPerUser: 100  // FIFO prune

    // ===== Signals =====
    signal notifAdded(int id, int userId)
    signal notifRead(int id)
    signal allMarkedRead(int userId)
    signal notifDeleted(int id)

    // ===== Queries =====
    function getForUser(uid) {
        if (uid <= 0) return []
        var out = []
        for (var i = 0; i < notifications.length; i++) {
            if (notifications[i].userId === uid) out.push(notifications[i])
        }
        // Mới nhất ở trên
        out.sort(function(a, b) { return a.createdAt < b.createdAt ? 1 : -1 })
        return out
    }

    function getUnreadCount(uid) {
        if (uid <= 0) return 0
        var n = 0
        for (var i = 0; i < notifications.length; i++) {
            if (notifications[i].userId === uid && !notifications[i].isRead) n++
        }
        return n
    }

    function getById(id) {
        for (var i = 0; i < notifications.length; i++) {
            if (notifications[i].id === id) return notifications[i]
        }
        return null
    }

    // ===== Mutations =====
    function addNotif(userId, type, title, body, link, refId) {
        if (!userId || userId <= 0) return -1
        var item = {
            id: _nextId++,
            userId: userId,
            type: type || "info",
            title: title || "",
            body: body || "",
            link: link || "",
            refId: refId || 0,
            isRead: false,
            createdAt: new Date().toISOString()
        }
        var arr = notifications.slice()
        arr.push(item)

        // Prune: giữ tối đa _maxPerUser per user
        var byUser = {}
        for (var i = arr.length - 1; i >= 0; i--) {
            var u = arr[i].userId
            byUser[u] = (byUser[u] || 0) + 1
            if (byUser[u] > _maxPerUser) arr.splice(i, 1)
        }

        notifications = arr
        notifAdded(item.id, item.userId)
        return item.id
    }

    function markRead(id) {
        var arr = notifications.slice()
        for (var i = 0; i < arr.length; i++) {
            if (arr[i].id === id && !arr[i].isRead) {
                arr[i] = Object.assign({}, arr[i], { isRead: true })
                notifications = arr
                notifRead(id)
                return
            }
        }
    }

    function markAllRead(uid) {
        if (uid <= 0) return
        var arr = notifications.slice()
        var changed = false
        for (var i = 0; i < arr.length; i++) {
            if (arr[i].userId === uid && !arr[i].isRead) {
                arr[i] = Object.assign({}, arr[i], { isRead: true })
                changed = true
            }
        }
        if (changed) {
            notifications = arr
            allMarkedRead(uid)
        }
    }

    function deleteNotif(id) {
        notifications = notifications.filter(function(n) { return n.id !== id })
        notifDeleted(id)
    }

    function clearForUser(uid) {
        if (uid <= 0) return
        notifications = notifications.filter(function(n) { return n.userId !== uid })
    }

    // ===== Helpers UI =====
    function typeIcon(t) {
        if (t === "comment")      return "💬"
        if (t === "like")         return "❤️"
        if (t === "group_added")  return "👥"
        if (t === "wanted_offer") return "🤝"
        if (t === "streak")       return "🔥"
        return "🔔"
    }

    function typeColor(t) {
        if (t === "comment")      return "#3b82f6"  // blue
        if (t === "like")         return "#ec4899"  // pink
        if (t === "group_added")  return "#a855f7"  // purple
        if (t === "wanted_offer") return "#10b981"  // green
        if (t === "streak")       return "#f97316"  // orange
        return "#64748b"
    }

    // Format thời gian relative đơn giản
    function relativeTime(iso) {
        if (!iso) return ""
        var d = new Date(iso)
        if (isNaN(d.getTime())) return iso
        var diff = (Date.now() - d.getTime()) / 1000  // seconds

        if (diff < 60)        return "Vừa xong"
        if (diff < 3600)      return Math.floor(diff / 60) + " phút trước"
        if (diff < 86400)     return Math.floor(diff / 3600) + " giờ trước"
        if (diff < 86400 * 7) return Math.floor(diff / 86400) + " ngày trước"

        var dd = ("0" + d.getDate()).slice(-2)
        var mo = ("0" + (d.getMonth() + 1)).slice(-2)
        return dd + "/" + mo + "/" + d.getFullYear()
    }
}