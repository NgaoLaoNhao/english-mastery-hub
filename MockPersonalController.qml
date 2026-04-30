import QtQuick

QtObject {
    id: mock

    property var auth: null
    property var adminUser: null
    property var adminGroup: null
    property var checkin: null

    // ===== Lấy stats tổng (dùng ở banner 4 thẻ) =====
    function _sumSkills(c) {
        return (c.listening || 0) + (c.speaking || 0) + (c.reading || 0)
             + (c.writing   || 0) + (c.vocabulary || 0)
    }
    function getMyStats(userId) {
        var totalHours = 0, daysCheckedIn = 0
        var TOTAL_DAYS = 25
        if (checkin && checkin.checkins) {
            var seen = {}
            for (var i = 0; i < checkin.checkins.length; i++) {
                var c = checkin.checkins[i]
                if (c.userId !== userId) continue
                totalHours += _sumSkills(c)
                if (!seen[c.date]) { seen[c.date] = true; daysCheckedIn++ }
            }
        }
        var attendanceRate = Math.round(daysCheckedIn * 100 / TOTAL_DAYS)
        var avgPerDay = daysCheckedIn > 0 ? totalHours / daysCheckedIn : 0
        return {
            totalHours: totalHours,
            daysCheckedIn: daysCheckedIn,
            attendanceRate: attendanceRate,
            avgPerDay: avgPerDay
        }
    }

    // ===== Stats theo 5 kỹ năng (sẽ dùng ở A.4) =====
    function getMySkillBreakdown(userId) {
        var sk = { listening: 0, speaking: 0, reading: 0, writing: 0, vocabulary: 0 }
        if (checkin && checkin.checkins) {
            for (var i = 0; i < checkin.checkins.length; i++) {
                var c = checkin.checkins[i]
                if (c.userId !== userId) continue
                sk.listening  += (c.listening  || 0)
                sk.speaking   += (c.speaking   || 0)
                sk.reading    += (c.reading    || 0)
                sk.writing    += (c.writing    || 0)
                sk.vocabulary += (c.vocabulary || 0)
            }
        }
        return sk
    }

    // ===== Lịch sử của tôi =====
    function getMyHistory(userId) {
        var rows = []
        if (checkin && checkin.checkins) {
            for (var i = 0; i < checkin.checkins.length; i++) {
                if (checkin.checkins[i].userId === userId) rows.push(checkin.checkins[i])
            }
        }
        rows.sort(function(a, b) { return a.date < b.date ? 1 : -1 })
        return rows
    }

    // ===== Update profile (FIX: mutate trực tiếp + ép String) =====
    // ===== Update profile — gọi adminUser.updateUser (đã clone object) =====
    // ===== Series 25 ngày của tôi =====
    function getDailySeries(userId) {
        var startDate = new Date("2026-04-15")
        var TOTAL_DAYS = 25
        var arr = []
        var sumByDate = {}
        if (checkin && checkin.checkins) {
            for (var i = 0; i < checkin.checkins.length; i++) {
                var c = checkin.checkins[i]
                if (c.userId !== userId) continue
                sumByDate[c.date] = (sumByDate[c.date] || 0) + _sumSkills(c)
            }
        }
        for (var d = 0; d < TOTAL_DAYS; d++) {
            var dt = new Date(startDate)
            dt.setDate(startDate.getDate() + d)
            var ymd = Qt.formatDate(dt, "yyyy-MM-dd")
            arr.push({ day: d + 1, date: ymd, hours: sumByDate[ymd] || 0 })
        }
        return arr
    }

    // ===== Series 25 ngày — trung bình nhóm =====
    function getGroupAvgSeries(userId) {
        if (!adminUser || !adminUser.users) return []
        var groupId = -1
        for (var i = 0; i < adminUser.users.length; i++) {
            if (adminUser.users[i].id === userId) { groupId = adminUser.users[i].groupId; break }
        }
        var memberIds = []
        if (groupId > 0) {
            for (var j = 0; j < adminUser.users.length; j++) {
                if (adminUser.users[j].groupId === groupId) memberIds.push(adminUser.users[j].id)
            }
        }
        var memberCount = memberIds.length
        if (memberCount === 0) return []

        var startDate = new Date("2026-04-15")
        var TOTAL_DAYS = 25
        var sumByDate = {}
        if (checkin && checkin.checkins) {
            for (var k = 0; k < checkin.checkins.length; k++) {
                var c = checkin.checkins[k]
                if (memberIds.indexOf(c.userId) < 0) continue
                sumByDate[c.date] = (sumByDate[c.date] || 0) + _sumSkills(c)
            }
        }
        var arr = []
        for (var d = 0; d < TOTAL_DAYS; d++) {
            var dt = new Date(startDate)
            dt.setDate(startDate.getDate() + d)
            var ymd = Qt.formatDate(dt, "yyyy-MM-dd")
            arr.push({ day: d + 1, date: ymd, avg: (sumByDate[ymd] || 0) / memberCount })
        }
        return arr
    }
    function updateMyProfile(userId, patch) {
        if (!adminUser || !adminUser.users) return

        // Tìm user hiện tại để giữ nguyên các field không sửa
        var u = null
        for (var i = 0; i < adminUser.users.length; i++) {
            if (adminUser.users[i].id === userId) { u = adminUser.users[i]; break }
        }
        if (!u) return

        var newFullName   = patch.fullName   !== undefined ? String(patch.fullName)   : (u.fullName || "")
        var newAvatarPath = patch.avatarPath !== undefined ? String(patch.avatarPath) : (u.avatarPath || "")

        // Gọi method có sẵn — nó dùng Object.assign nên tạo object mới → binding re-evaluate
        adminUser.updateUser(userId, newFullName, u.role, u.groupId, newAvatarPath)

        // Sync sang auth nếu đổi fullName của chính mình
        if (auth && patch.fullName !== undefined && auth.currentUserId === userId) {
            if (typeof auth.updateUserFullName === "function") {
                auth.updateUserFullName(userId, newFullName)
            }
        }
    }
}