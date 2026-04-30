import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

ColumnLayout {
    id: root
    property var auth: null
    property var checkin: null
    Layout.fillWidth: true
    spacing: 8

    BannerHero {
        Layout.fillWidth: true
        emoji: "🏆"
        title: "25-DAY ENGLISH CHALLENGE"
        subtitle: "Tổng quan tiến độ thử thách 25 ngày của bạn"
        colorStart: "#1e3a8a"; colorMid: "#7c3aed"; colorEnd: "#db2777"
    }

    Rectangle {
        Layout.fillWidth: true
        color: "#fafafa"; border.color: "#ddd"; radius: 8
        implicitHeight: progressCol.implicitHeight + 28

        ColumnLayout {
            id: progressCol
            anchors.fill: parent
            anchors.margins: 14
            spacing: 12

            // ===== Big progress bar =====
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                RowLayout {
                    Layout.fillWidth: true
                    Label {
                        property var p: checkin ? checkin.getChallengeProgress() : null
                        text: p ? ("Ngày " + p.currentDay + " / " + p.totalDays) : ""
                        font.pixelSize: 22; font.bold: true
                    }
                    Item { Layout.fillWidth: true }
                    Label {
                        property var p: checkin ? checkin.getChallengeProgress() : null
                        text: p ? (p.isFinished
                            ? "✅ Hoàn thành"
                            : ("Còn " + p.remainingDays + " ngày")) : ""
                        font.pixelSize: 14; color: "#7c3aed"; font.bold: true
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 18
                    color: "#e9ecef"; radius: 9
                    Rectangle {
                        property var p: checkin ? checkin.getChallengeProgress() : null
                        height: parent.height; radius: parent.radius
                        width: parent.width * (p ? p.currentDay / p.totalDays : 0)
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "#7c3aed" }
                            GradientStop { position: 1.0; color: "#db2777" }
                        }
                    }
                }

                Label {
                    property var p: checkin ? checkin.getChallengeProgress() : null
                    text: p ? ("Bắt đầu: " + p.startDate
                        + "  ·  Đã trôi qua " + Math.round(p.currentDay / p.totalDays * 100) + "%") : ""
                    color: "#777"; font.pixelSize: 11
                }
            }

            // ===== 3 stat cards =====
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 80
                    color: "#eef2ff"; border.color: "#a5b4fc"; radius: 8
                    ColumnLayout {
                        anchors.centerIn: parent; spacing: 2
                        Label {
                            text: auth && checkin
                                ? checkin.getMyTotalHours(auth.currentUserId).toFixed(2)
                                : "0.00"
                            font.pixelSize: 24; font.bold: true; color: "#4338ca"
                            horizontalAlignment: Text.AlignHCenter; Layout.alignment: Qt.AlignHCenter
                        }
                        Label { text: "⏱ Tổng giờ học của bạn"
                            font.pixelSize: 11; color: "#555"; Layout.alignment: Qt.AlignHCenter }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 80
                    color: "#fef3c7"; border.color: "#fbbf24"; radius: 8
                    ColumnLayout {
                        anchors.centerIn: parent; spacing: 2
                        Label {
                            text: auth && checkin
                                ? (checkin.getMyCheckinCount(auth.currentUserId)
                                   + " / " + checkin.challengeTotalDays)
                                : "0 / 25"
                            font.pixelSize: 24; font.bold: true; color: "#b45309"
                            horizontalAlignment: Text.AlignHCenter; Layout.alignment: Qt.AlignHCenter
                        }
                        Label { text: "📅 Số ngày bạn đã check-in"
                            font.pixelSize: 11; color: "#555"; Layout.alignment: Qt.AlignHCenter }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 80
                    color: "#dcfce7"; border.color: "#4ade80"; radius: 8
                    ColumnLayout {
                        anchors.centerIn: parent; spacing: 2
                        Label {
                            text: {
                                if (!auth || !checkin) return "0%"
                                var done = checkin.getMyCheckinCount(auth.currentUserId)
                                var p = checkin.getChallengeProgress()
                                if (!p || p.currentDay === 0) return "0%"
                                return Math.round(done / p.currentDay * 100) + "%"
                            }
                            font.pixelSize: 24; font.bold: true; color: "#15803d"
                            horizontalAlignment: Text.AlignHCenter; Layout.alignment: Qt.AlignHCenter
                        }
                        Label { text: "🎯 Tỷ lệ chuyên cần"
                            font.pixelSize: 11; color: "#555"; Layout.alignment: Qt.AlignHCenter }
                    }
                }
            }
        }
    }
}