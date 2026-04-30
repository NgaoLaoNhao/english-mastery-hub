import QtQuick

// ============================================================
// MockCheckinController — quản lý daily checkin (mock data RAM).
// Tham chiếu adminUser để biết danh sách user đăng ký.
// ============================================================
QtObject {
    id: mockCheckin

    // ===== Properties =====
    property var adminUserRef: null    // sẽ set từ Main.qml để biết user list

    // 25-day challenge config
    readonly property string challengeStartDate: "2026-04-15"
    readonly property int challengeTotalDays: 25

    // Mock data: list các checkin đã có
    // Mỗi checkin: { id, userId, date (YYYY-MM-DD), listening, speaking, reading, writing, vocabulary, note }
    property var checkins: [
        // 2 ngày trước: admin
        { id: 1, userId: 1, date: _addDays(_today(), -2), listening: 1.0, speaking: 0.5, reading: 1.5, writing: 0.5, vocabulary: 1.0, note: "Học IELTS Listening Test 1" },
        { id: 2, userId: 2, date: _addDays(_today(), -2), listening: 0.5, speaking: 1.0, reading: 1.0, writing: 0.0, vocabulary: 0.5, note: "Luyện speaking part 2" },
        // Hôm qua: admin + tien
        { id: 3, userId: 1, date: _addDays(_today(), -1), listening: 2.0, speaking: 0.5, reading: 1.0, writing: 1.0, vocabulary: 1.5, note: "" },
        { id: 4, userId: 2, date: _addDays(_today(), -1), listening: 1.0, speaking: 0.5, reading: 0.5, writing: 0.5, vocabulary: 1.0, note: "Đọc báo BBC" },
        // Hôm nay: chỉ admin (tien & duy chưa → vào wanted board)
        { id: 5, userId: 1, date: _today(),                listening: 1.5, speaking: 1.0, reading: 1.0, writing: 0.5, vocabulary: 0.5, note: "Bắt đầu chương 2 sách Cambridge" }
    ]
    property int _nextId: 6
    // ===== Computed reactive properties =====
    readonly property var _todayUserIds: {
        var today = _today()
        var ids = []
        for (var i = 0; i < checkins.length; i++) {
            if (checkins[i].date === today) ids.push(checkins[i].userId)
        }
        return ids
    }

    readonly property var wantedList: {
        if (!adminUserRef) return []
        return adminUserRef.users.filter(function(u) {
            return _todayUserIds.indexOf(u.id) === -1
        })
    }

    readonly property var checkedInList: {
        if (!adminUserRef) return []
        return adminUserRef.users.filter(function(u) {
            return _todayUserIds.indexOf(u.id) !== -1
        })
    }
    // ===== Signals =====
    signal checkinSubmitted(int id, string date)
    signal submitFailed(string reason)

    // ===== Methods =====

    // Trả về checkin của userId trong 1 ngày, hoặc null
    function getCheckin(userId, date) {
        for (var i = 0; i < checkins.length; i++) {
            const c = checkins[i]
            if (c.userId === userId && c.date === date) return c
        }
        return null
    }

    function getTodayCheckin(userId) {
        return getCheckin(userId, _today())
    }

    // Submit hoặc update checkin hôm nay
    function submitCheckin(userId, listening, speaking, reading, writing, vocabulary, note) {
        const skills = [listening, speaking, reading, writing, vocabulary]
        for (var i = 0; i < skills.length; i++) {
            if (skills[i] < 0 || skills[i] > 12) {
                submitFailed("Mỗi kỹ năng phải từ 0 đến 12 giờ")
                return
            }
        }
        const today = _today()
        const existing = getCheckin(userId, today)
        if (existing) {
            // Update
            checkins = checkins.map(function(c) {
                if (c.id === existing.id) {
                    return Object.assign({}, c, {
                        listening: listening, speaking: speaking, reading: reading,
                        writing: writing, vocabulary: vocabulary, note: note
                    })
                }
                return c
            })
            checkinSubmitted(existing.id, today)
        } else {
            // Tạo mới
            const id = _nextId++
            checkins = checkins.concat([{
                id: id, userId: userId, date: today,
                listening: listening, speaking: speaking, reading: reading,
                writing: writing, vocabulary: vocabulary, note: note
            }])
            checkinSubmitted(id, today)
        }
    }

    // Lịch sử checkin của 1 user (sort mới → cũ)
    function getMyHistory(userId) {
        return checkins
            .filter(function(c) { return c.userId === userId })
            .sort(function(a, b) { return b.date.localeCompare(a.date) })
    }

    // Danh sách userId đã checkin hôm nay
    function getTodayCheckedInUserIds() {
        const today = _today()
        const ids = []
        for (var i = 0; i < checkins.length; i++) {
            if (checkins[i].date === today) ids.push(checkins[i].userId)
        }
        return ids
    }

    // Danh sách user CHƯA checkin hôm nay (wanted board)
    // Trả về list user objects (lấy từ adminUserRef)
    function getWantedList() {
        if (!adminUserRef) return []
        const checkedIn = getTodayCheckedInUserIds()
        return adminUserRef.users.filter(function(u) {
            return checkedIn.indexOf(u.id) === -1
        })
    }

    function getCheckedInList() {
        if (!adminUserRef) return []
        const checkedIn = getTodayCheckedInUserIds()
        return adminUserRef.users.filter(function(u) {
            return checkedIn.indexOf(u.id) !== -1
        })
    }

    // Tiến độ challenge
    function getChallengeProgress() {
        const start = challengeStartDate
        const today = _today()
        const dayIndex = _diffDays(start, today) + 1   // ngày hiện tại trong challenge (1-based)
        const remaining = Math.max(0, challengeTotalDays - dayIndex)
        return {
            startDate: start,
            currentDay: Math.min(dayIndex, challengeTotalDays),
            totalDays: challengeTotalDays,
            remainingDays: remaining,
            isFinished: dayIndex > challengeTotalDays
        }
    }

    // ===== Helpers =====
    function _today() {
        const d = new Date()
        return d.getFullYear() + "-"
            + String(d.getMonth() + 1).padStart(2, '0') + "-"
            + String(d.getDate()).padStart(2, '0')
    }

    function _addDays(dateStr, n) {
        const parts = dateStr.split("-")
        const d = new Date(parseInt(parts[0]), parseInt(parts[1]) - 1, parseInt(parts[2]))
        d.setDate(d.getDate() + n)
        return d.getFullYear() + "-"
            + String(d.getMonth() + 1).padStart(2, '0') + "-"
            + String(d.getDate()).padStart(2, '0')
    }

    function _diffDays(d1, d2) {
        const p1 = d1.split("-"), p2 = d2.split("-")
        const date1 = new Date(parseInt(p1[0]), parseInt(p1[1]) - 1, parseInt(p1[2]))
        const date2 = new Date(parseInt(p2[0]), parseInt(p2[1]) - 1, parseInt(p2[2]))
        return Math.round((date2 - date1) / (1000 * 60 * 60 * 24))
    }

    // Helper public: tổng giờ học của 1 checkin
    function totalHours(checkin) {
        if (!checkin) return 0
        return (checkin.listening || 0) + (checkin.speaking || 0) + (checkin.reading || 0)
            + (checkin.writing || 0) + (checkin.vocabulary || 0)
    }
    function getMyTotalHours(userId) {
        var total = 0
        for (var i = 0; i < checkins.length; i++) {
            if (checkins[i].userId === userId) total += totalHours(checkins[i])
        }
        return total
    }

    function getMyCheckinCount(userId) {
        var count = 0
        for (var i = 0; i < checkins.length; i++) {
            if (checkins[i].userId === userId) count++
        }
        return count
    }

    function hasCheckinOnDate(userId, dateStr) {
        for (var i = 0; i < checkins.length; i++) {
            if (checkins[i].userId === userId && checkins[i].date === dateStr) return checkins[i]
        }
        return null
    }

    function getDateStrForDayIndex(idx) {
        // idx 1-based; returns ISO yyyy-mm-dd from challengeStartDate + (idx-1) days
        var d = new Date(challengeStartDate)
        d.setDate(d.getDate() + (idx - 1))
        return d.getFullYear() + "-"
            + String(d.getMonth() + 1).padStart(2, '0') + "-"
            + String(d.getDate()).padStart(2, '0')
    }
}