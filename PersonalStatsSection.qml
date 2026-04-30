import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Item {
    id: root
    property var personal: null
    property int userId: -1

    readonly property var skillData: personal && userId > 0
                                     ? personal.getMySkillBreakdown(userId)
                                     : { listening: 0, speaking: 0, reading: 0, writing: 0, vocabulary: 0 }
    readonly property real totalAll: skillData.listening + skillData.speaking
                                    + skillData.reading + skillData.writing + skillData.vocabulary

    readonly property var mySeries: personal && userId > 0 ? personal.getDailySeries(userId) : []
    readonly property var avgSeries: personal && userId > 0 ? personal.getGroupAvgSeries(userId) : []

    implicitHeight: contentCol.implicitHeight

    onMySeriesChanged: chartCanvas.requestPaint()
    onAvgSeriesChanged: chartCanvas.requestPaint()

    ColumnLayout {
        id: contentCol
        width: parent.width
        spacing: 14

        Label {
            text: "📊 Thống kê theo kỹ năng"
            font.pixelSize: 18; font.bold: true
            color: "#0f172a"
        }

        // ===== 6 thẻ kỹ năng =====
        GridLayout {
            Layout.fillWidth: true
            columns: 6
            columnSpacing: 10
            rowSpacing: 10

            Repeater {
                model: [
                    { icon: "🎧", name: "Nghe",      key: "listening",  bg: "#dbeafe", fg: "#1d4ed8" },
                    { icon: "🗣️", name: "Nói",       key: "speaking",   bg: "#fef3c7", fg: "#b45309" },
                    { icon: "📖", name: "Đọc",       key: "reading",    bg: "#dcfce7", fg: "#15803d" },
                    { icon: "✍️", name: "Viết",      key: "writing",    bg: "#fce7f3", fg: "#be185d" },
                    { icon: "📝", name: "Từ vựng",   key: "vocabulary", bg: "#ede9fe", fg: "#6d28d9" },
                    { icon: "⭐", name: "Tổng cộng", key: "_total",     bg: "#fef9c3", fg: "#a16207" }
                ]
                delegate: Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.preferredHeight: 110
                    radius: 10
                    color: modelData.bg
                    border.color: "#e2e8f0"; border.width: 1

                    readonly property real myHours: modelData.key === "_total"
                                                    ? totalAll
                                                    : (skillData[modelData.key] || 0)
                    readonly property real ratio: totalAll > 0 && modelData.key !== "_total"
                                                  ? (myHours / totalAll) : 0

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 4

                        Label { text: modelData.icon + " " + modelData.name; color: modelData.fg; font.pixelSize: 13; font.bold: true }
                        Label { text: myHours.toFixed(1) + "h"; color: "#0f172a"; font.pixelSize: 22; font.bold: true; Layout.topMargin: 4 }
                        Item { Layout.fillHeight: true }

                        Rectangle {
                            visible: modelData.key !== "_total"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 6
                            radius: 3
                            color: "#ffffff"
                            Rectangle {
                                anchors.left: parent.left
                                anchors.top: parent.top; anchors.bottom: parent.bottom
                                width: parent.width * ratio
                                radius: 3
                                color: modelData.fg
                            }
                        }
                        Label {
                            visible: modelData.key !== "_total"
                            text: Math.round(ratio * 100) + "% của tổng"
                            color: modelData.fg
                            font.pixelSize: 10
                        }
                    }
                }
            }
        }

        // ===== Biểu đồ 25 ngày (Canvas thuần) =====
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 320
            radius: 10
            color: "#f8fafc"
            border.color: "#e2e8f0"; border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16
                    Label { text: "📈 Giờ học theo ngày (25 ngày challenge)"; font.pixelSize: 14; font.bold: true; color: "#0f172a" }
                    Item { Layout.fillWidth: true }
                    Row {
                        spacing: 6
                        Rectangle { width: 14; height: 14; radius: 3; color: "#0ea5e9"; anchors.verticalCenter: parent.verticalCenter }
                        Label { text: "Tôi"; color: "#0f172a"; anchors.verticalCenter: parent.verticalCenter }
                    }
                    Row {
                        spacing: 6
                        Rectangle { width: 14; height: 14; radius: 3; color: "#94a3b8"; anchors.verticalCenter: parent.verticalCenter }
                        Label { text: "TB nhóm"; color: "#0f172a"; anchors.verticalCenter: parent.verticalCenter }
                    }
                }

                Canvas {
                    id: chartCanvas
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    antialiasing: true

                    onWidthChanged: requestPaint()
                    onHeightChanged: requestPaint()

                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()

                        var W = width, H = height
                        var padL = 40, padR = 12, padT = 12, padB = 28
                        var cw = W - padL - padR
                        var ch = H - padT - padB
                        if (cw <= 0 || ch <= 0) return

                        // Tính maxY
                        var maxY = 4
                        for (var i = 0; i < mySeries.length; i++) {
                            if (mySeries[i].hours > maxY) maxY = mySeries[i].hours
                        }
                        for (var j = 0; j < avgSeries.length; j++) {
                            if (avgSeries[j].avg > maxY) maxY = avgSeries[j].avg
                        }
                        maxY = Math.ceil(maxY + 1)
                        var TOTAL_DAYS = 25

                        // Helper toạ độ
                        function px(day) { return padL + ((day - 1) / (TOTAL_DAYS - 1)) * cw }
                        function py(val) { return padT + ch - (val / maxY) * ch }

                        // Vẽ grid + trục Y
                        ctx.strokeStyle = "#e2e8f0"
                        ctx.lineWidth = 1
                        ctx.fillStyle = "#64748b"
                        ctx.font = "10px sans-serif"
                        ctx.textAlign = "right"
                        ctx.textBaseline = "middle"
                        var yTicks = 6
                        for (var t = 0; t <= yTicks; t++) {
                            var v = (maxY * t) / yTicks
                            var y = py(v)
                            ctx.beginPath()
                            ctx.moveTo(padL, y); ctx.lineTo(padL + cw, y)
                            ctx.stroke()
                            ctx.fillText(v.toFixed(0) + "h", padL - 4, y)
                        }

                        // Vẽ trục X (mốc ngày 1, 5, 10, 15, 20, 25)
                        ctx.textAlign = "center"
                        ctx.textBaseline = "top"
                        var xTicks = [1, 5, 10, 15, 20, 25]
                        for (var k = 0; k < xTicks.length; k++) {
                            var x = px(xTicks[k])
                            ctx.beginPath()
                            ctx.moveTo(x, padT + ch); ctx.lineTo(x, padT + ch + 4)
                            ctx.strokeStyle = "#94a3b8"
                            ctx.stroke()
                            ctx.fillText("Ngày " + xTicks[k], x, padT + ch + 6)
                        }

                        // Vẽ avg line (xám)
                        if (avgSeries.length > 0) {
                            ctx.strokeStyle = "#94a3b8"
                            ctx.lineWidth = 2
                            ctx.beginPath()
                            for (var a = 0; a < avgSeries.length; a++) {
                                var ax = px(avgSeries[a].day)
                                var ay = py(avgSeries[a].avg || 0)
                                if (a === 0) ctx.moveTo(ax, ay); else ctx.lineTo(ax, ay)
                            }
                            ctx.stroke()
                        }

                        // Vẽ my line (xanh đậm)
                        if (mySeries.length > 0) {
                            ctx.strokeStyle = "#0ea5e9"
                            ctx.lineWidth = 3
                            ctx.beginPath()
                            for (var m = 0; m < mySeries.length; m++) {
                                var mx = px(mySeries[m].day)
                                var my = py(mySeries[m].hours || 0)
                                if (m === 0) ctx.moveTo(mx, my); else ctx.lineTo(mx, my)
                            }
                            ctx.stroke()

                            // Vẽ chấm tròn ở các ngày có data
                            ctx.fillStyle = "#0ea5e9"
                            for (var n = 0; n < mySeries.length; n++) {
                                if ((mySeries[n].hours || 0) > 0) {
                                    var nx = px(mySeries[n].day)
                                    var ny = py(mySeries[n].hours)
                                    ctx.beginPath()
                                    ctx.arc(nx, ny, 4, 0, 2 * Math.PI)
                                    ctx.fill()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}