import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

ColumnLayout {
    id: root
    signal userClicked(int userId)
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

            property var topList: {
                if (!topController || !topController.checkin) return []
                topController.checkin.checkins  // dep
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
                    id: card
                    required property var modelData
                    required property int index
                    property bool _hovered: false

                    Layout.fillWidth: true
                    Layout.preferredHeight: 64
                    color: card._hovered ? "#fef3c7"
                                         : (card.index < 3 ? "#fffbeb" : "white")
                    border.color: card._hovered ? "#0891b2"
                                                : (card.index < 3 ? "#fbbf24" : "#e5e7eb")
                    border.width: card._hovered ? 2
                                                : (card.index < 3 ? 2 : 1)
                    radius: 6

                    RowLayout {
                        anchors.fill: parent; anchors.margins: 10; spacing: 12

                        Label {
                            text: card.index === 0 ? "🥇"
                                : card.index === 1 ? "🥈"
                                : card.index === 2 ? "🥉"
                                : ("#" + (card.index + 1))
                            font.pixelSize: 22; font.bold: true
                            Layout.preferredWidth: 50
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Rectangle {
                            Layout.preferredWidth: 42; Layout.preferredHeight: 42
                            radius: 21; color: "#7c3aed"; clip: true
                            Image {
                                anchors.fill: parent; fillMode: Image.PreserveAspectCrop
                                source: card.modelData.avatarPath || ""
                                visible: source.toString() !== ""
                                sourceSize.width: 42; sourceSize.height: 42
                                asynchronous: true; cache: true
                            }
                            Label {
                                anchors.centerIn: parent
                                text: card.modelData.username.charAt(0).toUpperCase()
                                color: "white"; font.bold: true; font.pixelSize: 16
                                visible: !card.modelData.avatarPath
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true; spacing: 1
                            Label {
                                text: card.modelData.fullName || card.modelData.username
                                font.bold: true; font.pixelSize: 14
                            }
                            Label {
                                text: "@" + card.modelData.username
                                      + (card.modelData.role === "admin" ? "  ·  🛠 Admin" : "")
                                color: "#888"; font.pixelSize: 11
                            }
                        }

                        ColumnLayout {
                            spacing: 1
                            Label {
                                text: card.modelData.totalHours.toFixed(2) + "h"
                                font.bold: true; font.pixelSize: 16; color: "#dc2626"
                                Layout.alignment: Qt.AlignRight
                            }
                            Label {
                                text: card.modelData.days + " ngày"
                                color: "#888"; font.pixelSize: 11
                                Layout.alignment: Qt.AlignRight
                            }
                        }
                    }

                    // ===== MouseArea phủ toàn card → emit userClicked =====
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onEntered: card._hovered = true
                        onExited:  card._hovered = false
                        onClicked: {
                            console.log("Top card clicked:", JSON.stringify(card.modelData))
                            if (!card.modelData) return
                            var uid = card.modelData.userId !== undefined
                                      ? card.modelData.userId
                                      : (card.modelData.id !== undefined ? card.modelData.id : -1)
                            if (uid > 0) root.userClicked(uid)
                            else console.warn("⚠️ Top card không có userId/id!")
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