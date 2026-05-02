import QtQuick

QtObject {
    id: root

    // ============================================================
    // RESOURCES
    // ============================================================
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

    // ============================================================
    // LIKES (M7 D.1)
    // ============================================================
    property var likes: [
        { resourceId: 1, userId: 2 },
        { resourceId: 1, userId: 3 },
        { resourceId: 2, userId: 4 },
        { resourceId: 5, userId: 1 },
        { resourceId: 5, userId: 2 },
        { resourceId: 5, userId: 3 }
    ]

    signal likeToggled(int resourceId, int userId, bool liked)

    // ============================================================
    // COMMENTS (M7 D.1)
    // ============================================================
    property var comments: [
        { id: 1, resourceId: 1, userId: 2, body: "Tài liệu rất hay, mình đã làm xong chương 2 rồi nhe! 👍",  createdAt: "2026-04-22T10:30:00" },
        { id: 2, resourceId: 1, userId: 3, body: "Cảm ơn admin đã chia sẻ. Bài tập 5 hơi khó.",              createdAt: "2026-04-23T15:45:00" },
        { id: 3, resourceId: 2, userId: 4, body: "Video phát âm rõ quá, mình tập được ngay 🎉",              createdAt: "2026-04-19T09:15:00" },
        { id: 4, resourceId: 5, userId: 4, body: "500 phrases rất bổ ích cho speaking!",                     createdAt: "2026-04-26T18:00:00" }
    ]
    property int _nextCommentId: 5

    signal commentAdded(int id, int resourceId)
    signal commentDeleted(int id)

    // ============================================================
    // GETTERS
    // ============================================================
    function getAll() { return resources.slice() }

    function getByType(t) {
        if (!t || t === "all") return resources.slice()
        return resources.filter(function(r) { return r.type === t })
    }

    function getByGroup(gid) {
        return resources.filter(function(r) { return r.groupId === gid })
    }

    function getResourceById(id) {
        for (var i = 0; i < resources.length; i++)
            if (resources[i].id === id) return resources[i]
        return null
    }
    // Alias cho code cũ
    function getById(id) { return getResourceById(id) }

    // ============================================================
    // CRUD RESOURCES
    // ============================================================
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
        resources = resources.filter(function(r) { return r.id !== id })
        // Dọn likes & comments của resource bị xóa
        likes    = likes.filter(function(l)    { return l.resourceId !== id })
        comments = comments.filter(function(c) { return c.resourceId !== id })
        resourceDeleted(id)
    }

    // ============================================================
    // LIKES API
    // ============================================================
    function getLikeCount(resourceId) {
        var n = 0
        for (var i = 0; i < likes.length; i++)
            if (likes[i].resourceId === resourceId) n++
        return n
    }

    function hasLiked(resourceId, userId) {
        for (var i = 0; i < likes.length; i++)
            if (likes[i].resourceId === resourceId && likes[i].userId === userId) return true
        return false
    }

    function toggleLike(resourceId, userId) {
        if (resourceId <= 0 || userId <= 0) return false
        var arr = likes.slice()
        var idx = -1
        for (var i = 0; i < arr.length; i++)
            if (arr[i].resourceId === resourceId && arr[i].userId === userId) { idx = i; break }

        var liked
        if (idx >= 0) {
            arr.splice(idx, 1)
            liked = false
        } else {
            arr.push({ resourceId: resourceId, userId: userId })
            liked = true
        }
        likes = arr
        likeToggled(resourceId, userId, liked)
        return liked
    }

    // ============================================================
    // COMMENTS API
    // ============================================================
    function getComments(resourceId) {
        var arr = comments.filter(function(c) { return c.resourceId === resourceId })
        // Sắp xếp mới nhất trước
        arr.sort(function(a, b) {
            if (a.createdAt < b.createdAt) return 1
            if (a.createdAt > b.createdAt) return -1
            return 0
        })
        return arr
    }

    function addComment(resourceId, userId, body) {
        if (!body || !body.trim()) return -1
        var item = {
            id: _nextCommentId++,
            resourceId: resourceId,
            userId: userId,
            body: body.trim(),
            createdAt: new Date().toISOString()
        }
        var arr = comments.slice()
        arr.push(item)
        comments = arr
        commentAdded(item.id, resourceId)
        return item.id
    }

    function deleteComment(id) {
        comments = comments.filter(function(c) { return c.id !== id })
        commentDeleted(id)
    }

    // ============================================================
    // HELPERS
    // ============================================================
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
}