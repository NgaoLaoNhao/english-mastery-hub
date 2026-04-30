import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

ColumnLayout {
    id: root
    signal groupClicked(int groupId)
    property var topController: null
    Layout.fillWidth: true
    spacing: 8

    readonly property var cardPalette: [
        ["#0ea5e9", "#22d3ee"],
        ["#16a34a", "#84cc16"],
        ["#db2777", "#f472b6"],
        ["#7c3aed", "#a855f7"],
        ["#ea580c", "#fbbf24"]
    ]

    BannerHero {
        Layout.fillWidth: true
        emoji: "👥"
        title: "CÁC NHÓM HỌC"
        subtitle: "Xếp hạng theo số giờ trung bình mỗi thành viên"
        colorStart: "#075985"; colorMid: "#0891b2"; colorEnd: "#10b981"
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

            property var groupList: {
                if (!topController || !topController.checkin) return []
                topController.checkin.checkins  // dep
                return topController.getTopGroups()
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                rowSpacing: 12
                columnSpacing: 12

                Repeater {
                    model: gridCol.groupList
                    delegate: Rectangle {
                        id: card
                        required property var modelData
                        required property int index
                        property bool _hovered: false

                        Layout.fillWidth: true
                        Layout.preferredHeight: 160
                        color: "white"
                        border.color: card._hovered ? "#0891b2" : "#d1d5db"
                        border.width: card._hovered ? 2 : 1
                        radius: 8
                        clip: true

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 0

                            // Cover banner (gradient)
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 56
                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop { position: 0.0; color: root.cardPalette[card.index % root.cardPalette.length][0] }
                                    GradientStop { position: 1.0; color: root.cardPalette[card.index % root.cardPalette.length][1] }
                                }
                                RowLayout {
                                    anchors.fill: parent; anchors.margins: 10; spacing: 10
                                    Label {
                                        text: card.index === 0 ? "👑" : card.index === 1 ? "🥈" : card.index === 2 ? "🥉" : "🏅"
                                        font.pixelSize: 22
                                    }
                                    Label {
                                        text: card.modelData.name
                                        color: "white"; font.pixelSize: 16; font.bold: true
                                        style: Text.Outline; styleColor: "#000"
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                    }
                                    Label {
                                        text: "#" + (card.index + 1)
                                        color: "white"; font.pixelSize: 12; font.bold: true
                                    }
                                }
                            }

                            // Stats
                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Layout.margins: 10
                                spacing: 6

                                Label {
                                    text: "👤 Trưởng nhóm: " + card.modelData.leaderName
                                    font.pixelSize: 12
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                Label {
                                    text: "👥 " + card.modelData.memberCount + " thành viên"
                                          + "  ·  ✅ " + card.modelData.totalCheckins + " check-ins"
                                    font.pixelSize: 12; color: "#555"
                                }
                                RowLayout {
                                    Layout.fillWidth: true
                                    Label {
                                        text: "⏱ Tổng: " + card.modelData.totalHours.toFixed(1) + "h"
                                        font.pixelSize: 12; color: "#0891b2"
                                    }
                                    Item { Layout.fillWidth: true }
                                    Label {
                                        text: "📊 TB: " + card.modelData.avgHours.toFixed(2) + "h/người"
                                        font.pixelSize: 13; font.bold: true; color: "#dc2626"
                                    }
                                }
                            }
                        }

                        // ===== MouseArea phủ toàn card → emit groupClicked =====
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onEntered: card._hovered = true
                            onExited:  card._hovered = false
                            onClicked: {
                                console.log("Click card index=" + card.index
                                            + " modelData=" + JSON.stringify(card.modelData))
                                if (!card.modelData) return
                                var gid = card.modelData.id !== undefined
                                          ? card.modelData.id
                                          : card.modelData.groupId
                                if (gid !== undefined) {
                                    root.groupClicked(gid)
                                } else {
                                    console.warn("⚠️ Group card không có field id/groupId!")
                                }
                            }
                        }
                    }
                }
            }

            Label {
                text: "Chưa có nhóm nào"
                color: "#888"; Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                visible: gridCol.groupList.length === 0
            }
        }
    }
}