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
}