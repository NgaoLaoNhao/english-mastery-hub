import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

ColumnLayout {
    id: root
    property var topController: null
    Layout.fillWidth: true
    spacing: 8

    BannerHero {
        Layout.fillWidth: true
        emoji: "🏆"
        title: "BẢNG XẾP HẠNG THÀNH VIÊN"
        subtitle: "Top thành viên tích cực nhất theo số giờ học"
        colorStart: "#7c2d12"; colorMid: "#ea580c"; colorEnd: "#fbbf24"
    }

    Rectangle {
        Layout.fillWidth: true
        color: "#fafafa"; border.color: "#ddd"; radius: 8
        implicitHeight: contentCol.implicitHeight + 28

        ColumnLayout {
            id: contentCol
            anchors.fill: parent
            anchors.margins: 14
            spacing: 8

            // Re-eval on tab change & on checkin updates
            property var topList: {
                if (!topController || !topController.checkin) return []
                topController.checkin.checkins  // dependency tracker
                return topController.getTopUsers(tabBar.currentIndex === 0 ? "today" : "all")
            }

            TabBar {
                id: tabBar
                Layout.fillWidth: true
                TabButton { text: "🌟 Hôm nay" }
                TabButton { text: "🏆 Toàn challenge" }
            }

            Repeater {
                model: contentCol.topList
                delegate: Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 64
                    color: index < 3 ? "#fffbeb" : "white"
                    border.color: index < 3 ? "#fbbf24" : "#e5e7eb"
                    border.width: index < 3 ? 2 : 1
                    radius: 6

                    RowLayout {
                        anchors.fill: parent; anchors.margins: 10; spacing: 12

                        Label {
                            text: index === 0 ? "🥇" : index === 1 ? "🥈" : index === 2 ? "🥉" : ("#" + (index + 1))
                            font.pixelSize: 22; font.bold: true
                            Layout.preferredWidth: 50
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Rectangle {
                            Layout.preferredWidth: 42; Layout.preferredHeight: 42
                            radius: 21; color: "#7c3aed"; clip: true
                            Image {
                                anchors.fill: parent; fillMode: Image.PreserveAspectCrop
                                source: modelData.avatarPath || ""
                                visible: source.toString() !== ""
                            }
                            Label {
                                anchors.centerIn: parent
                                text: modelData.username.charAt(0).toUpperCase()
                                color: "white"; font.bold: true; font.pixelSize: 16
                                visible: !modelData.avatarPath
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true; spacing: 1
                            Label {
                                text: modelData.fullName || modelData.username
                                font.bold: true; font.pixelSize: 14
                            }
                            Label {
                                text: "@" + modelData.username
                                    + (modelData.role === "admin" ? "  ·  🛠 Admin" : "")
                                color: "#888"; font.pixelSize: 11
                            }
                        }

                        ColumnLayout {
                            spacing: 1
                            Label {
                                text: modelData.totalHours.toFixed(2) + "h"
                                font.bold: true; font.pixelSize: 16; color: "#dc2626"
                                Layout.alignment: Qt.AlignRight
                            }
                            Label {
                                text: modelData.days + " ngày"
                                color: "#888"; font.pixelSize: 11
                                Layout.alignment: Qt.AlignRight
                            }
                        }
                    }
                }
            }

            Label {
                text: tabBar.currentIndex === 0
                    ? "Chưa có thành viên nào check-in hôm nay 😢"
                    : "Chưa có dữ liệu check-in"
                color: "#888"
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                visible: contentCol.topList.length === 0
            }
        }
    }
}