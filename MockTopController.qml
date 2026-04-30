import QtQuick

QtObject {
    property var checkin: null
    property var adminUser: null
    property var adminGroup: null

    function _today() {
        var d = new Date()
        return d.getFullYear() + "-"
            + String(d.getMonth() + 1).padStart(2, '0') + "-"
            + String(d.getDate()).padStart(2, '0')
    }

    function getTopUsers(period) {  // "today" | "all"
        if (!checkin || !adminUser) return []
        var userMap = {}
        var todayStr = _today()
        for (var i = 0; i < checkin.checkins.length; i++) {
            var c = checkin.checkins[i]
            if (period === "today" && c.date !== todayStr) continue
            var uid = c.userId
            if (!userMap[uid]) userMap[uid] = { totalHours: 0, days: 0 }
            userMap[uid].totalHours += checkin.totalHours(c)
            userMap[uid].days += 1
        }
        var arr = []
        for (var k in userMap) {
            var u = null
            for (var j = 0; j < adminUser.users.length; j++) {
                if (adminUser.users[j].id === parseInt(k)) { u = adminUser.users[j]; break }
            }
            if (u) {
                arr.push({
                    rank: 0,
                    userId: u.id,
                    username: u.username,
                    fullName: u.fullName,
                    avatarPath: u.avatarPath,
                    role: u.role,
                    totalHours: userMap[k].totalHours,
                    days: userMap[k].days
                })
            }
        }
        arr.sort(function(a, b) { return b.totalHours - a.totalHours })
        for (var n = 0; n < arr.length; n++) arr[n].rank = n + 1
        return arr
    }

    function getTopGroups() {
        if (!adminGroup || !adminUser || !checkin) return []
        var result = []
        for (var i = 0; i < adminGroup.groups.length; i++) {
            var g = adminGroup.groups[i]
            var members = []
            for (var j = 0; j < adminUser.users.length; j++) {
                if (adminUser.users[j].groupId === g.id) members.push(adminUser.users[j])
            }
            var totalHours = 0, totalCheckins = 0
            for (var k = 0; k < checkin.checkins.length; k++) {
                var c = checkin.checkins[k]
                var inGroup = false
                for (var m = 0; m < members.length; m++) {
                    if (members[m].id === c.userId) { inGroup = true; break }
                }
                if (inGroup) {
                    totalHours += checkin.totalHours(c)
                    totalCheckins++
                }
            }
            var avg = members.length > 0 ? totalHours / members.length : 0
            var leader = null
            for (var l = 0; l < adminUser.users.length; l++) {
                if (adminUser.users[l].id === g.leaderUserId) { leader = adminUser.users[l]; break }
            }
            result.push({
                groupId: g.id,
                name: g.name,
                leaderName: leader ? (leader.fullName || leader.username) : "Chưa có",
                memberCount: members.length,
                totalHours: totalHours,
                avgHours: avg,
                totalCheckins: totalCheckins
            })
        }
        result.sort(function(a, b) { return b.avgHours - a.avgHours })
        return result
    }
}