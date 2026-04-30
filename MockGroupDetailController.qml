import QtQuick

QtObject {
    id: mock

    property var auth: null
    property var adminUser: null
    property var adminGroup: null
    property var checkin: null

    // ===== Helper: tổng giờ của 1 check-in =====
    function _sumSkills(c) {
        return (c.listening || 0) + (c.speaking || 0) + (c.reading || 0)
             + (c.writing   || 0) + (c.vocabulary || 0)
    }

    // ===== Tìm group theo id =====
    function _findGroup(groupId) {
        if (!adminGroup || !adminGroup.groups) return null
        for (var i = 0; i < adminGroup.groups.length; i++) {
            if (adminGroup.groups[i].id === groupId) return adminGroup.groups[i]
        }
        return null
    }

    // ===== Tìm user theo id =====
    function _findUser(userId) {
        if (!adminUser || !adminUser.users) return null
        for (var i = 0; i < adminUser.users.length; i++) {
            if (adminUser.users[i].id === userId) return adminUser.users[i]
        }
        return null
    }

    // ===== Lấy danh sách userId thuộc group =====
    function _memberIdsOf(groupId) {
        var ids = []
        if (!adminUser || !adminUser.users) return ids
        for (var i = 0; i < adminUser.users.length; i++) {
            if (adminUser.users[i].groupId === groupId) ids.push(adminUser.users[i].id)
        }
        return ids
    }

    // ===== Info chung của group =====
    function getGroupInfo(groupId) {
        var g = _findGroup(groupId)
        if (!g) return null
        // Hỗ trợ cả id và leaderId/leaderUserId
        var leaderIdRaw = (g.leaderId !== undefined) ? g.leaderId
                        : (g.leaderUserId !== undefined ? g.leaderUserId : -1)
        var leader = leaderIdRaw > 0 ? _findUser(leaderIdRaw) : null
        var memberIds = _memberIdsOf(groupId)
        return {
            id: g.id,
            name: g.name || "",
            description: g.description || "",
            leaderId: leaderIdRaw,
            leaderName: leader ? (leader.fullName || leader.username) : "(chưa có)",
            leaderUsername: leader ? leader.username : "",
            leaderAvatar: leader ? (leader.avatarPath || "") : "",
            memberCount: memberIds.length,
            createdAt: g.createdAt || ""
        }
    }

    // ===== KPI tổng của group =====
    function getGroupKpi(groupId) {
        var memberIds = _memberIdsOf(groupId)
        var memberCount = memberIds.length
        var totalHours = 0
        var distinctDays = {}

        if (checkin && checkin.checkins && memberCount > 0) {
            for (var i = 0; i < checkin.checkins.length; i++) {
                var c = checkin.checkins[i]
                if (memberIds.indexOf(c.userId) < 0) continue
                totalHours += _sumSkills(c)
                distinctDays[c.date] = true
            }
        }
        var daysCovered = Object.keys(distinctDays).length
        var avgPerMember = memberCount > 0 ? totalHours / memberCount : 0
        var TOTAL_DAYS = 25
        var attendanceRate = memberCount > 0
            ? Math.round((daysCovered * 100) / TOTAL_DAYS)
            : 0

        return {
            totalHours: totalHours,
            avgPerMember: avgPerMember,
            memberCount: memberCount,
            daysCovered: daysCovered,
            attendanceRate: attendanceRate
        }
    }

    // ===== Danh sách thành viên + stats từng người (cho bảng ranking) =====
    function getGroupMembers(groupId) {
        var g = _findGroup(groupId)
        if (!g) return []
        var memberIds = _memberIdsOf(groupId)
        var rows = []

        for (var i = 0; i < memberIds.length; i++) {
            var uid = memberIds[i]
            var u = _findUser(uid)
            if (!u) continue

            var totalHours = 0
            var daysSet = {}
            var sk = { listening: 0, speaking: 0, reading: 0, writing: 0, vocabulary: 0 }

            if (checkin && checkin.checkins) {
                for (var j = 0; j < checkin.checkins.length; j++) {
                    var c = checkin.checkins[j]
                    if (c.userId !== uid) continue
                    totalHours += _sumSkills(c)
                    daysSet[c.date] = true
                    sk.listening  += (c.listening  || 0)
                    sk.speaking   += (c.speaking   || 0)
                    sk.reading    += (c.reading    || 0)
                    sk.writing    += (c.writing    || 0)
                    sk.vocabulary += (c.vocabulary || 0)
                }
            }
            var daysCount = Object.keys(daysSet).length
            var TOTAL_DAYS = 25

            rows.push({
                id: u.id,
                username: u.username,
                fullName: u.fullName || u.username,
                avatarPath: u.avatarPath || "",
                role: u.role || "member",
                isLeader: ((g.leaderId !== undefined ? g.leaderId : g.leaderUserId) === u.id),
                totalHours: totalHours,
                daysCheckedIn: daysCount,
                attendanceRate: Math.round(daysCount * 100 / TOTAL_DAYS),
                avgPerDay: daysCount > 0 ? totalHours / daysCount : 0,
                listening: sk.listening,
                speaking: sk.speaking,
                reading: sk.reading,
                writing: sk.writing,
                vocabulary: sk.vocabulary
            })
        }
        // Mặc định sort theo tổng giờ giảm dần
        rows.sort(function(a, b) { return b.totalHours - a.totalHours })
        // Đánh số rank sau khi sort
        for (var k = 0; k < rows.length; k++) rows[k].rank = k + 1
        return rows
    }

    // ===== Series 25 ngày của nhóm (tổng giờ + TB/người) =====
    function getGroupDailySeries(groupId) {
        var memberIds = _memberIdsOf(groupId)
        var memberCount = memberIds.length
        var startDate = new Date("2026-04-15")
        var TOTAL_DAYS = 25
        var sumByDate = {}

        if (checkin && checkin.checkins) {
            for (var i = 0; i < checkin.checkins.length; i++) {
                var c = checkin.checkins[i]
                if (memberIds.indexOf(c.userId) < 0) continue
                sumByDate[c.date] = (sumByDate[c.date] || 0) + _sumSkills(c)
            }
        }

        var arr = []
        for (var d = 0; d < TOTAL_DAYS; d++) {
            var dt = new Date(startDate)
            dt.setDate(startDate.getDate() + d)
            var ymd = Qt.formatDate(dt, "yyyy-MM-dd")
            var total = sumByDate[ymd] || 0
            arr.push({
                day: d + 1,
                date: ymd,
                total: total,
                avg: memberCount > 0 ? total / memberCount : 0
            })
        }
        return arr
    }

    // ===== Series 25 ngày của 1 user (dùng cho đường leader trong chart) =====
    function getUserDailySeries(userId) {
        var startDate = new Date("2026-04-15")
        var TOTAL_DAYS = 25
        var sumByDate = {}

        if (checkin && checkin.checkins) {
            for (var i = 0; i < checkin.checkins.length; i++) {
                var c = checkin.checkins[i]
                if (c.userId !== userId) continue
                sumByDate[c.date] = (sumByDate[c.date] || 0) + _sumSkills(c)
            }
        }
        var arr = []
        for (var d = 0; d < TOTAL_DAYS; d++) {
            var dt = new Date(startDate)
            dt.setDate(startDate.getDate() + d)
            var ymd = Qt.formatDate(dt, "yyyy-MM-dd")
            arr.push({ day: d + 1, date: ymd, hours: sumByDate[ymd] || 0 })
        }
        return arr
    }
}