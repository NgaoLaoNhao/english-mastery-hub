import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

ColumnLayout {
    id: root
    property var auth: null
    property var checkin: null
    Layout.fillWidth: true
    spacing: 8

    property var selectedDay: null

    function _formatDate(dateStr) {
        var parts = dateStr.split("-")
        return parts[2] + "/" + parts[1] + "/" + parts[0]
    }

    BannerHero {
        Layout.fillWidth: true
        emoji: "📅"
        title: "LỊCH SỬ CHECK-IN CỦA BẠN"
        subtitle: "25 ngày của thử thách · click vào ngày để xem chi tiết"
        colorStart: "#0891b2"; colorMid: "#0ea5e9"; colorEnd: "#22d3ee"
    }

    Rectangle {
        Layout.fillWidth: true
        color: "#fafafa"; border.color: "#ddd"; radius: 8
        implicitHeight: gridCol.implicitHeight + 28

        ColumnLayout {
            id: gridCol
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            // Legend
            RowLayout {
                spacing: 14
                Layout.fillWidth: true
                Rectangle { width: 16; height: 16; radius: 4; color: "#22c55e" }
                Label { text: "Đã check-in"; font.pixelSize: 11 }
                Rectangle { width: 16; height: 16; radius: 4; color: "#fde047" }
                Label { text: "Hôm nay"; font.pixelSize: 11 }
                Rectangle { width: 16; height: 16; radius: 4; color: "#e5e7eb" }
                Label { text: "Chưa tới / chưa check-in"; font.pixelSize: 11 }
                Item { Layout.fillWidth: true }
            }

            // 5x5 grid of days
            GridLayout {
                Layout.fillWidth: true
                columns: 5
                rowSpacing: 8
                columnSpacing: 8

                Repeater {
                    model: checkin ? checkin.challengeTotalDays : 25
                    delegate: Rectangle {
                        property int dayIdx: index + 1
                        property string dateStr: checkin ? checkin.getDateStrForDayIndex(dayIdx) : ""
                        property var dayCheckin: (checkin && auth) ? checkin.hasCheckinOnDate(auth.currentUserId, dateStr) : null
                        property bool isToday: {
                            var d = new Date()
                            var t = d.getFullYear() + "-"
                                  + String(d.getMonth() + 1).padStart(2, '0') + "-"
                                  + String(d.getDate()).padStart(2, '0')
                            return dateStr === t
                        }
                        property bool isPast: {
                            if (!dateStr) return false
                            return new Date(dateStr) < new Date(new Date().toDateString())
                        }

                        Layout.fillWidth: true
                        Layout.preferredHeight: 80

                        color: dayCheckin ? "#22c55e"
                             : isToday    ? "#fde047"
                             : isPast     ? "#fee2e2"
                             :              "#e5e7eb"
                        border.color: isToday ? "#ca8a04" : "#9ca3af"
                        border.width: isToday ? 2 : 1
                        radius: 8

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 2
                            Label {
                                text: "Ngày " + dayIdx
                                font.pixelSize: 11
                                color: dayCheckin ? "white" : "#444"
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Label {
                                text: dateStr ? root._formatDate(dateStr).substring(0, 5) : ""
                                font.pixelSize: 10
                                color: dayCheckin ? "white" : "#666"
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Label {
                                text: dayCheckin ? "✅" : (isToday ? "⭐" : (isPast ? "❌" : "⏳"))
                                font.pixelSize: 16
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Label {
                                text: dayCheckin ? (checkin.totalHours(dayCheckin).toFixed(1) + "h") : ""
                                font.pixelSize: 10
                                color: "white"; font.bold: true
                                visible: !!dayCheckin
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: dayCheckin ? Qt.PointingHandCursor : Qt.ArrowCursor
                            enabled: !!dayCheckin
                            onClicked: {
                                root.selectedDay = {
                                    idx: dayIdx,
                                    dateStr: dateStr,
                                    checkin: dayCheckin
                                }
                                detailDialog.open()
                            }
                        }
                    }
                }
            }
        }
    }

    Dialog {
        id: detailDialog
        modal: true
        anchors.centerIn: Overlay.overlay
        width: 420
        title: root.selectedDay
            ? ("📋 Check-in ngày " + root.selectedDay.idx + " — " + root._formatDate(root.selectedDay.dateStr))
            : ""
        standardButtons: Dialog.Close

        ColumnLayout {
            anchors.fill: parent
            spacing: 8
            visible: !!root.selectedDay && !!root.selectedDay.checkin

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 12
                rowSpacing: 6
                Label { text: "🎧 Listening:"; font.bold: true }
                Label { text: root.selectedDay && root.selectedDay.checkin
                    ? root.selectedDay.checkin.listening.toFixed(2) + " giờ" : "" }

                Label { text: "🗣 Speaking:"; font.bold: true }
                Label { text: root.selectedDay && root.selectedDay.checkin
                    ? root.selectedDay.checkin.speaking.toFixed(2) + " giờ" : "" }

                Label { text: "📖 Reading:"; font.bold: true }
                Label { text: root.selectedDay && root.selectedDay.checkin
                    ? root.selectedDay.checkin.reading.toFixed(2) + " giờ" : "" }

                Label { text: "✍ Writing:"; font.bold: true }
                Label { text: root.selectedDay && root.selectedDay.checkin
                    ? root.selectedDay.checkin.writing.toFixed(2) + " giờ" : "" }

                Label { text: "🔤 Vocabulary:"; font.bold: true }
                Label { text: root.selectedDay && root.selectedDay.checkin
                    ? root.selectedDay.checkin.vocabulary.toFixed(2) + " giờ" : "" }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#ddd"
            }

            Label {
                text: root.selectedDay && root.selectedDay.checkin
                    ? "⏱ Tổng: " + checkin.totalHours(root.selectedDay.checkin).toFixed(2) + " giờ"
                    : ""
                font.pixelSize: 16; font.bold: true; color: "#15803d"
            }

            Label {
                text: root.selectedDay && root.selectedDay.checkin && root.selectedDay.checkin.note
                    ? "💬 Ghi chú: " + root.selectedDay.checkin.note
                    : ""
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                visible: text.length > 0
            }
        }
    }
}