import QtQuick

QtObject {
    id: root

    property var checkin: null
    property var auth: null
    property var adminUser: null
    property var adminGroup: null
    property var personal: null
    property var groupDetail: null

    signal exportStarted(string fileName)
    signal exportCompleted(string fileName, string fakePath)
    signal exportFailed(string reason)

    // ============================================================
    // F.1 — Personal report
    // ============================================================
    function buildPersonalReport(userId) {
        if (!checkin || !adminUser || userId <= 0) return null
        var user = null
        var us = adminUser.users || []
        for (var i = 0; i < us.length; i++)
            if (us[i].id === userId) { user = us[i]; break }
        if (!user) return null

        var groupName = "—"
        if (adminGroup && user.groupId > 0) {
            var gs = adminGroup.groups || []
            for (var j = 0; j < gs.length; j++)
                if (gs[j].id === user.groupId) { groupName = gs[j].name; break }
        }

        var history = checkin.getMyHistory(userId) || []
        var sumL=0, sumS=0, sumR=0, sumW=0, sumV=0, sumTotal=0
        var rows = []
        for (var k = 0; k < history.length; k++) {
            var c = history[k]
            var t = checkin.totalHours(c)
            sumL += c.listening||0; sumS += c.speaking||0; sumR += c.reading||0
            sumW += c.writing||0;   sumV += c.vocabulary||0; sumTotal += t
            rows.push({
                date: c.date, listening: c.listening||0, speaking: c.speaking||0,
                reading: c.reading||0, writing: c.writing||0, vocabulary: c.vocabulary||0,
                total: t, note: c.note||""
            })
        }
        var stats = (personal && personal.getMyStats) ? personal.getMyStats(userId)
            : { totalHours: sumTotal, daysCheckedIn: rows.length, attendanceRate: 0, avgPerDay: 0 }

        var streak = 0, dt = new Date()
        for (var s = 0; s < 365; s++) {
            var ds = _formatDate(dt)
            if (checkin.hasCheckinOnDate(userId, ds)) { streak++; dt.setDate(dt.getDate()-1) }
            else break
        }
        return {
            user: user, groupName: groupName,
            generatedAt: new Date().toISOString(),
            challengeStart: checkin.challengeStartDate,
            challengeTotal: checkin.challengeTotalDays,
            rows: rows,
            sumByskill: { listening: sumL, speaking: sumS, reading: sumR,
                          writing: sumW, vocabulary: sumV, total: sumTotal },
            stats: stats, currentStreak: streak
        }
    }
    function exportPersonal(userId) {
        var data = buildPersonalReport(userId)
        if (!data) { exportFailed("Không tìm thấy dữ liệu user."); return "" }
        var fileName = "checkin_" + data.user.username + "_"
                     + Qt.formatDateTime(new Date(), "yyyyMMdd_hhmmss") + ".pdf"
        var fakePath = "C:/Users/" + data.user.username + "/Documents/" + fileName
        _doExport(fileName, fakePath)
        return fileName
    }

    // ============================================================
    // F.2 — Group report
    // ============================================================
    function buildGroupReport(groupId) {
        if (!groupDetail || !adminGroup || !adminUser || groupId <= 0) return null
        var info = groupDetail.getGroupInfo(groupId)
        if (!info) return null
        var kpi  = groupDetail.getGroupKpi(groupId)
        var grow = adminGroup.getGroup(groupId)
        var leaderUserId = grow ? grow.leaderUserId : -1

        var members = []
        var totalH = 0
        var us = adminUser.users || []
        for (var i = 0; i < us.length; i++) {
            if (us[i].groupId !== groupId) continue
            var uid = us[i].id
            var hrs = (checkin && checkin.getMyTotalHours) ? checkin.getMyTotalHours(uid) : 0
            var dys = (checkin && checkin.getMyCheckinCount) ? checkin.getMyCheckinCount(uid) : 0
            var totalDays = checkin ? checkin.challengeTotalDays : 25
            var rate = totalDays > 0 ? Math.round(dys / totalDays * 100) : 0
            totalH += hrs
            members.push({
                id: uid, username: us[i].username,
                fullName: us[i].fullName || us[i].username,
                isLeader: uid === leaderUserId,
                totalHours: hrs, daysCheckedIn: dys, attendanceRate: rate
            })
        }
        members.sort(function(a, b) { return b.totalHours - a.totalHours })

        return {
            info: info, kpi: kpi, leaderUserId: leaderUserId,
            members: members, memberCount: members.length,
            totalHours: totalH,
            avgPerMember: members.length > 0 ? (totalH / members.length) : 0,
            topContributor: members.length > 0 ? members[0] : null,
            generatedAt: new Date().toISOString(),
            challengeStart: checkin ? checkin.challengeStartDate : "",
            challengeTotal: checkin ? checkin.challengeTotalDays : 25
        }
    }
    function exportGroup(groupId) {
        var data = buildGroupReport(groupId)
        if (!data) { exportFailed("Không tìm thấy dữ liệu nhóm."); return "" }
        var safeName = (data.info.name || ("group_" + groupId)).replace(/[^a-zA-Z0-9]/g, "_")
        var fileName = "group_" + safeName + "_"
                     + Qt.formatDateTime(new Date(), "yyyyMMdd_hhmmss") + ".pdf"
        var fakePath = "C:/Reports/" + fileName
        _doExport(fileName, fakePath)
        return fileName
    }

    // ============================================================
    // F.3 — Top Board (workspace overview)
    // ============================================================
    function buildTopBoardReport() {
        if (!adminUser || !adminGroup || !checkin) return null

        var us = adminUser.users || []
        var gs = adminGroup.groups || []
        var totalDays = checkin.challengeTotalDays || 25

        // Build user list with hours
        var allUsers = []
        var grandTotal = 0
        for (var i = 0; i < us.length; i++) {
            var u = us[i]
            var hrs = checkin.getMyTotalHours(u.id)
            var dys = checkin.getMyCheckinCount(u.id)
            var rate = totalDays > 0 ? Math.round(dys / totalDays * 100) : 0
            grandTotal += hrs

            var gname = "—"
            if (u.groupId > 0) {
                for (var j = 0; j < gs.length; j++)
                    if (gs[j].id === u.groupId) { gname = gs[j].name; break }
            }
            allUsers.push({
                id: u.id, username: u.username,
                fullName: u.fullName || u.username,
                groupName: gname, totalHours: hrs,
                daysCheckedIn: dys, attendanceRate: rate
            })
        }
        allUsers.sort(function(a, b) { return b.totalHours - a.totalHours })
        var top10 = allUsers.slice(0, 10)

        // Group ranking
        var groupRanking = []
        for (var k = 0; k < gs.length; k++) {
            var g = gs[k]
            var members = us.filter(function(uu) { return uu.groupId === g.id })
            var gHours = 0, gDaysSum = 0
            for (var m = 0; m < members.length; m++) {
                gHours += checkin.getMyTotalHours(members[m].id)
                gDaysSum += checkin.getMyCheckinCount(members[m].id)
            }
            var leaderName = "Chưa có"
            if (g.leaderUserId > 0) {
                for (var n = 0; n < us.length; n++)
                    if (us[n].id === g.leaderUserId) {
                        leaderName = us[n].fullName || us[n].username
                        break
                    }
            }
            var avgHrs = members.length > 0 ? gHours / members.length : 0
            var avgRate = (members.length > 0 && totalDays > 0)
                ? Math.round((gDaysSum / members.length) / totalDays * 100) : 0

            groupRanking.push({
                id: g.id, name: g.name, leaderName: leaderName,
                memberCount: members.length, totalHours: gHours,
                avgPerMember: avgHrs, attendanceRate: avgRate
            })
        }
        groupRanking.sort(function(a, b) { return b.totalHours - a.totalHours })

        // Challenge progress
        var startStr = checkin.challengeStartDate
        var startDate = new Date(startStr.substring(0,4) + "-" + startStr.substring(5,7) + "-" + startStr.substring(8,10))
        var today = new Date()
        var daysPassed = Math.floor((today - startDate) / 86400000) + 1
        daysPassed = Math.min(Math.max(daysPassed, 0), totalDays)
        var progressPct = Math.round(daysPassed / totalDays * 100)

        return {
            generatedAt: new Date().toISOString(),
            totalUsers: us.length,
            totalGroups: gs.length,
            totalHours: grandTotal,
            avgPerUser: us.length > 0 ? grandTotal / us.length : 0,
            challengeStart: startStr,
            challengeTotal: totalDays,
            currentDay: daysPassed,
            progressPct: progressPct,
            top10: top10,
            groupRanking: groupRanking
        }
    }
    function exportTopBoard() {
        var data = buildTopBoardReport()
        if (!data) { exportFailed("Không tìm thấy dữ liệu workspace."); return "" }
        var fileName = "topboard_"
                     + Qt.formatDateTime(new Date(), "yyyyMMdd_hhmmss") + ".pdf"
        var fakePath = "C:/Reports/" + fileName
        _doExport(fileName, fakePath)
        return fileName
    }

    // ============================================================
    // Helpers
    // ============================================================
    function _doExport(fileName, fakePath) {
        exportStarted(fileName)
        _delayTimer.fakePath = fakePath
        _delayTimer.fileName = fileName
        _delayTimer.restart()
    }
    function _formatDate(d) {
        return d.getFullYear() + "-"
             + String(d.getMonth() + 1).padStart(2, "0") + "-"
             + String(d.getDate()).padStart(2, "0")
    }
    property Timer _delayTimer: Timer {
        property string fakePath: ""
        property string fileName: ""
        interval: 600
        repeat: false
        onTriggered: root.exportCompleted(fileName, fakePath)
    }
}