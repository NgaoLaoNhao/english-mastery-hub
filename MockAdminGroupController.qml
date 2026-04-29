import QtQuick

QtObject {
    id: mockGroup

    property var groups: [
        { id: 1, name: "Nhóm Alpha", leaderUserId: 2, coverPath: "" },
        { id: 2, name: "Nhóm Beta",  leaderUserId: -1, coverPath: "" }
    ]
    property int _nextId: 3

    signal groupCreated(int id, string name)
    signal createFailed(string reason)
    signal updateFailed(string reason)
    signal deleteFailed(string reason)

    function getGroup(id) {
        for (var i = 0; i < groups.length; i++) {
            if (groups[i].id === id) return groups[i]
        }
        return null
    }

    function createGroup(name, leaderUserId) {
        if (!name || name.trim().length < 2) {
            createFailed("Tên nhóm phải ≥ 2 ký tự")
            return
        }
        const id = _nextId++
        groups = groups.concat([{
            id: id,
            name: name.trim(),
            leaderUserId: leaderUserId !== undefined ? leaderUserId : -1,
            coverPath: ""
        }])
        groupCreated(id, name)
    }

    function updateGroup(id, name, leaderUserId) {
        groups = groups.map(function(g) {
            if (g.id === id) {
                return Object.assign({}, g, {
                    name: name,
                    leaderUserId: leaderUserId
                })
            }
            return g
        })
    }

    function deleteGroup(id) {
        groups = groups.filter(function(g) { return g.id !== id })
    }
}