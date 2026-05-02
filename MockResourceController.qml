import QtQuick

QtObject {
    id: root

    property var resources: [
        { id: 1, title: "Cambridge B1 — Chương 2",      type: "pdf",   url: "https://example.com/b1-ch2.pdf",        uploadedBy: "admin", groupId: 0, addedAt: "2026-04-15" },
        { id: 2, title: "Phát âm /θ/ và /ð/",           type: "video", url: "https://www.youtube.com/watch?v=demo1", uploadedBy: "admin", groupId: 0, addedAt: "2026-04-18" },
        { id: 3, title: "Bài tập Listening A2",         type: "audio", url: "https://example.com/audio.mp3",         uploadedBy: "tien",  groupId: 1, addedAt: "2026-04-20" },
        { id: 4, title: "Cambridge Dictionary",         type: "link",  url: "https://dictionary.cambridge.org",      uploadedBy: "admin", groupId: 0, addedAt: "2026-04-15" },
        { id: 5, title: "500 Common Phrases.pdf",       type: "pdf",   url: "https://example.com/phrases.pdf",       uploadedBy: "duy",   groupId: 1, addedAt: "2026-04-25" },
        { id: 6, title: "Speaking Practice — Ep 1",     type: "video", url: "https://www.youtube.com/watch?v=demo2", uploadedBy: "tien",  groupId: 1, addedAt: "2026-04-28" }
    ]
    property int _nextId: 7

    signal resourceAdded(int id)
    signal resourceDeleted(int id)

    function getAll()             { return resources.slice() }
    function getByType(t) {
        if (!t || t === "all") return resources.slice()
        return resources.filter(function(r){ return r.type === t })
    }
    function getByGroup(gid) {
        return resources.filter(function(r){ return r.groupId === gid })
    }
    function addResource(title, type, url, uploadedBy, groupId) {
        var item = {
            id: _nextId++, title: title, type: type, url: url,
            uploadedBy: uploadedBy, groupId: groupId || 0,
            addedAt: Qt.formatDate(new Date(), "yyyy-MM-dd")
        }
        var arr = resources.slice()
        arr.unshift(item)
        resources = arr
        resourceAdded(item.id)
        return item.id
    }
    function deleteResource(id) {
        resources = resources.filter(function(r){ return r.id !== id })
        resourceDeleted(id)
    }
    function typeIcon(t) {
        if (t === "pdf")   return "📄"
        if (t === "video") return "🎬"
        if (t === "audio") return "🎧"
        if (t === "link")  return "🔗"
        return "📎"
    }
    function typeLabel(t) {
        if (t === "pdf")   return "PDF"
        if (t === "video") return "Video"
        if (t === "audio") return "Audio"
        if (t === "link")  return "Liên kết"
        return "Khác"
    }
    // ===== M7: Properties cho comments & likes =====
    property var comments: [
        { id: 1, resourceId: 1, userId: 2, body: "Tài liệu này hay quá, cảm ơn anh đã chia sẻ!", createdAt: "2026-04-20T10:30:00" },
        { id: 2, resourceId: 1, userId: 3, body: "Mình đã đọc xong, rất bổ ích.", createdAt: "2026-04-21T14:15:00" },
        { id: 3, resourceId: 2, userId: 2, body: "File này download được không nhỉ?", createdAt: "2026-04-22T09:00:00" }
    ]
    property int _nextCommentId: 4

    // likes: array { resourceId, userId } — 1 user có thể like 1 resource 1 lần
    property var likes: [
        { resourceId: 1, userId: 2 },
        { resourceId: 1, userId: 3 },
        { resourceId: 2, userId: 1 }
    ]

    // ===== M7: Signals =====
    signal commentAdded(int id, int resourceId)
    signal commentDeleted(int id)
    signal likeToggled(int resourceId, int userId, bool liked)

    // ===== M7: Methods detail =====
    function getResourceById(resourceId) {
        if (!resources) return null
        for (var i = 0; i < resources.length; i++) {
            if (resources[i].id === resourceId) return resources[i]
        }
        return null
    }

    function getComments(resourceId) {
        var rows = []
        for (var i = 0; i < comments.length; i++) {
            if (comments[i].resourceId === resourceId) rows.push(comments[i])
        }
        // Mới nhất ở dưới (chat-style)
        rows.sort(function(a, b) { return a.createdAt < b.createdAt ? -1 : 1 })
        return rows
    }

    function addComment(resourceId, userId, body) {
        var trimmed = String(body || "").trim()
        if (trimmed.length === 0) return
        var newCmt = {
            id: _nextCommentId++,
            resourceId: resourceId,
            userId: userId,
            body: trimmed,
            createdAt: new Date().toISOString()
        }
        comments = comments.concat([newCmt])
        commentAdded(newCmt.id, resourceId)
    }

    function deleteComment(commentId) {
        comments = comments.filter(function(c) { return c.id !== commentId })
        commentDeleted(commentId)
    }

    function getLikeCount(resourceId) {
        var n = 0
        for (var i = 0; i < likes.length; i++) {
            if (likes[i].resourceId === resourceId) n++
        }
        return n
    }

    function hasLiked(resourceId, userId) {
        for (var i = 0; i < likes.length; i++) {
            if (likes[i].resourceId === resourceId && likes[i].userId === userId) return true
        }
        return false
    }

    function toggleLike(resourceId, userId) {
        var found = -1
        for (var i = 0; i < likes.length; i++) {
            if (likes[i].resourceId === resourceId && likes[i].userId === userId) {
                found = i; break
            }
        }
        if (found >= 0) {
            // Unlike
            var newLikes = likes.slice()
            newLikes.splice(found, 1)
            likes = newLikes
            likeToggled(resourceId, userId, false)
        } else {
            // Like
            likes = likes.concat([{ resourceId: resourceId, userId: userId }])
            likeToggled(resourceId, userId, true)
        }
    }
}