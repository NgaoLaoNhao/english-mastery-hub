import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Item {
    id: root

    property var groupDetail: null
    property int groupId: -1

    readonly property var info: groupDetail && groupId > 0
                                ? groupDetail.getGroupInfo(groupId) : null

    readonly property var groupSeries: groupDetail && groupId > 0
                                       ? groupDetail.getGroupDailySeries(groupId) : []
    readonly property var leaderSeries: (groupDetail && info && info.leaderId > 0)
                                        ? groupDetail.getUserDailySeries(info.leaderId) : []

    readonly property string leaderName: info ? info.leaderName : ""
    readonly property bool hasLeader: info && info.leaderId > 0

    // Tính maxY chung (gộp cả 2 series, làm tròn lên 2/4/6/8/10)
    readonly property real maxY: {
        var m = 0
        for (var i = 0; i < groupSeries.length; i++) {
            if (groupSeries[i].avg > m) m = groupSeries[i].avg
        }
        for (var j = 0; j < leaderSeries.length; j++) {
            if (leaderSeries[j].hours > m) m = leaderSeries[j].hours
        }
        if (m === 0) return 4
        if (m <= 2) return 2
        if (m <= 4) return 4
        if (m <= 6) return 6
        if (m <= 8) return 8
        if (m <= 10) return 10
        return Math.ceil(m / 2) * 2
    }

    onGroupSeriesChanged:  chartCanvas.requestPaint()
    onLeaderSeriesChanged: chartCanvas.requestPaint()
    onMaxYChanged:         chartCanvas.requestPaint()
    onWidthChanged:        chartCanvas.requestPaint()
    onHeightChanged:       chartCanvas.requestPaint()

    implicitHeight: contentCol.implicitHeight

    ColumnLayout {
        id: contentCol
        width: parent.width
        spacing: 10

        // Tiêu đề + chú thích
        RowLayout {
            Layout.fillWidth: true
            spacing: 12
            Label {
                text: "📈 Tiến độ 25 ngày challenge"
                font.pixelSize: 18; font.bold: true
                color: "#0f172a"
            }
            Item { Layout.fillWidth: true }

            // Legend group avg
            Rectangle {
                Layout.preferredWidth: 12; Layout.preferredHeight: 12
                radius: 2; color: "#a855f7"
            }
            Label {
                text: "TB nhóm"
                color: "#475569"; font.pixelSize: 12
            }

            // Legend leader
            Rectangle {
                Layout.preferredWidth: 12; Layout.preferredHeight: 12
                radius: 2; color: "#f59e0b"
                visible: root.hasLeader
            }
            Label {
                visible: root.hasLeader
                text: "👑 " + root.leaderName
                color: "#475569"; font.pixelSize: 12
            }
        }

        // Chart canvas wrapper
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 320
            color: "white"
            border.color: "#e2e8f0"; border.width: 1
            radius: 8

            Canvas {
                id: chartCanvas
                anchors.fill: parent
                anchors.margins: 8

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()

                    var W = width, H = height
                    var padL = 50, padR = 16, padT = 12, padB = 30
                    var cw = W - padL - padR
                    var ch = H - padT - padB

                    // ===== Background grid + Y axis labels =====
                    var ticks = 6
                    ctx.fillStyle = "#94a3b8"
                    ctx.font = "11px sans-serif"
                    ctx.textAlign = "right"
                    ctx.textBaseline = "middle"
                    for (var t = 0; t <= ticks - 1; t++) {
                        var v = (root.maxY * t) / (ticks - 1)
                        var y = padT + ch - (ch * t) / (ticks - 1)
                        ctx.strokeStyle = "#f1f5f9"
                        ctx.lineWidth = 1
                        ctx.beginPath()
                        ctx.moveTo(padL, y); ctx.lineTo(padL + cw, y); ctx.stroke()
                        ctx.fillText(v.toFixed(0) + "h", padL - 6, y)
                    }

                    // ===== X axis labels (Ngày 1, 5, 10, 15, 20, 25) =====
                    ctx.textAlign = "center"
                    ctx.textBaseline = "top"
                    var xTicks = [1, 5, 10, 15, 20, 25]
                    function px(day) { return padL + ((day - 1) / 24) * cw }
                    function py(val) { return padT + ch - (val / root.maxY) * ch }
                    for (var k = 0; k < xTicks.length; k++) {
                        var d = xTicks[k]
                        var xx = px(d)
                        ctx.fillStyle = "#94a3b8"
                        ctx.fillText("Ngày " + d, xx, padT + ch + 6)
                    }

                    // ===== Vẽ đường TB nhóm =====
                    if (root.groupSeries.length > 0) {
                        ctx.strokeStyle = "#a855f7"
                        ctx.lineWidth = 2
                        ctx.beginPath()
                        for (var g = 0; g < root.groupSeries.length; g++) {
                            var gv = root.groupSeries[g]
                            var gx = px(gv.day), gy = py(gv.avg)
                            if (g === 0) ctx.moveTo(gx, gy)
                            else ctx.lineTo(gx, gy)
                        }
                        ctx.stroke()
                    }

                    // ===== Vẽ đường leader (nếu có) =====
                    if (root.hasLeader && root.leaderSeries.length > 0) {
                        ctx.strokeStyle = "#f59e0b"
                        ctx.lineWidth = 3
                        ctx.beginPath()
                        for (var l = 0; l < root.leaderSeries.length; l++) {
                            var lv = root.leaderSeries[l]
                            var lx = px(lv.day), ly = py(lv.hours)
                            if (l === 0) ctx.moveTo(lx, ly)
                            else ctx.lineTo(lx, ly)
                        }
                        ctx.stroke()

                        // Dots tại các ngày leader có check-in
                        ctx.fillStyle = "#f59e0b"
                        for (var m = 0; m < root.leaderSeries.length; m++) {
                            var mv = root.leaderSeries[m]
                            if (mv.hours > 0) {
                                ctx.beginPath()
                                ctx.arc(px(mv.day), py(mv.hours), 4, 0, Math.PI * 2)
                                ctx.fill()
                            }
                        }
                    }
                }
            }
        }
    }
}