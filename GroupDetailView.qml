import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Item {
    id: root

    property var auth: null
    property var groupDetail: null
    property var adminGroup: null
    property var adminUser: null
    property int groupId: -1

    signal backRequested()

    readonly property var info: groupDetail && groupId > 0
                                ? groupDetail.getGroupInfo(groupId) : null

    readonly property var kpi: groupDetail && groupId > 0
                               ? groupDetail.getGroupKpi(groupId) : null

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ===== HEADER =====
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            color: "#1f1f2e"; z: 10

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20; anchors.rightMargin: 20
                spacing: 12

                Button {
                    text: "← Trở về"
                    onClicked: root.backRequested()
                }

                Label {
                    text: "👥 Chi tiết nhóm"
                    color: "white"; font.pixelSize: 16; font.bold: true
                    Layout.leftMargin: 12
                }

                Item { Layout.fillWidth: true }

                Label {
                    text: info ? info.name : ""
                    color: "#ddd"; font.pixelSize: 13
                }
            }
        }

        // ===== SCROLLABLE BODY =====
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: availableWidth
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 16

                // ===== Empty state =====
                Rectangle {
                    visible: !info
                    Layout.fillWidth: true
                    Layout.preferredHeight: 200
                    Layout.topMargin: 16
                    Layout.leftMargin: 20; Layout.rightMargin: 20
                    color: "#fef2f2"
                    border.color: "#fca5a5"; border.width: 1
                    radius: 10

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 8
                        Label {
                            text: "❌ Không tìm thấy nhóm"
                            color: "#dc2626"
                            font.pixelSize: 18; font.bold: true
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Label {
                            text: "Nhóm có thể đã bị xoá hoặc ID không hợp lệ."
                            color: "#7f1d1d"
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }

                // ===== Banner nhóm =====
                Rectangle {
                    visible: !!info
                    Layout.fillWidth: true
                    Layout.preferredHeight: 130
                    Layout.topMargin: 16
                    Layout.leftMargin: 20; Layout.rightMargin: 20
                    radius: 10
                    border.color: "#222"; border.width: 2
                    clip: true

                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "#7c3aed" }
                        GradientStop { position: 0.5; color: "#a855f7" }
                        GradientStop { position: 1.0; color: "#f0abfc" }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 14

                        Rectangle {
                            Layout.preferredWidth: 88
                            Layout.preferredHeight: 88
                            radius: 16
                            color: "white"
                            border.color: "#fff"; border.width: 3
                            Label {
                                anchors.centerIn: parent
                                text: "👥"; font.pixelSize: 48
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Label {
                                text: info ? info.name : ""
                                color: "white"
                                font.pixelSize: 24; font.bold: true
                                style: Text.Outline; styleColor: "#000"
                            }
                            Label {
                                text: info
                                      ? "👑 Leader: " + info.leaderName
                                        + " · " + info.memberCount + " thành viên"
                                      : ""
                                color: "white"
                                font.pixelSize: 13
                                style: Text.Outline; styleColor: "#000"
                            }
                            Label {
                                visible: info && info.description !== ""
                                text: info ? info.description : ""
                                color: "white"
                                font.pixelSize: 12; font.italic: true
                                style: Text.Outline; styleColor: "#000"
                                Layout.fillWidth: true
                                wrapMode: Label.WordWrap
                            }
                        }
                    }
                }

                // ===== 4 KPI CARDS =====
                RowLayout {
                    visible: !!info
                    Layout.fillWidth: true
                    Layout.leftMargin: 20; Layout.rightMargin: 20
                    spacing: 12

                    component KpiCard: Rectangle {
                        property string emoji: ""
                        property string title: ""
                        property string value: ""
                        property string subtitle: ""
                        property color accent: "#0f172a"
                        property color bg: "#ffffff"
                        property color border_: "#e2e8f0"

                        Layout.fillWidth: true
                        Layout.preferredHeight: 96
                        radius: 10
                        color: bg
                        border.color: border_; border.width: 1

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 14
                            spacing: 4

                            RowLayout {
                                spacing: 6
                                Label { text: emoji; font.pixelSize: 14 }
                                Label {
                                    text: title
                                    color: "#64748b"
                                    font.pixelSize: 12; font.bold: true
                                }
                            }
                            Label {
                                text: value
                                color: accent
                                font.pixelSize: 24; font.bold: true
                            }
                            Label {
                                visible: subtitle !== ""
                                text: subtitle
                                color: "#94a3b8"
                                font.pixelSize: 11
                            }
                        }
                    }

                    KpiCard {
                        emoji: "⏱"
                        title: "Tổng giờ nhóm"
                        value: root.kpi ? root.kpi.totalHours.toFixed(2) + "h" : "0h"
                        subtitle: "Cộng dồn từ tất cả thành viên"
                        accent: "#0891b2"
                        bg: "#ecfeff"; border_: "#a5f3fc"
                    }

                    KpiCard {
                        emoji: "📊"
                        title: "TB / người"
                        value: root.kpi ? root.kpi.avgPerMember.toFixed(2) + "h" : "0h"
                        subtitle: root.kpi ? "Cho " + root.kpi.memberCount + " thành viên" : ""
                        accent: "#dc2626"
                        bg: "#fef2f2"; border_: "#fecaca"
                    }

                    KpiCard {
                        emoji: "👥"
                        title: "Số thành viên"
                        value: root.kpi ? String(root.kpi.memberCount) : "0"
                        subtitle: "Active trong nhóm"
                        accent: "#7c3aed"
                        bg: "#f5f3ff"; border_: "#ddd6fe"
                    }

                    KpiCard {
                        emoji: "✅"
                        title: "Chuyên cần"
                        value: root.kpi ? root.kpi.attendanceRate + "%" : "0%"
                        subtitle: root.kpi
                                  ? root.kpi.daysCovered + "/25 ngày có check-in"
                                  : ""
                        accent: "#16a34a"
                        bg: "#f0fdf4"; border_: "#bbf7d0"
                    }
                }

                // ===== B.4: Ranking thành viên =====
                GroupMemberRankingSection {
                    visible: !!info
                    Layout.fillWidth: true
                    Layout.leftMargin: 20; Layout.rightMargin: 20
                    groupDetail: root.groupDetail
                    groupId: root.groupId
                }

                // ===== Placeholder B.5 =====
                // ===== B.5: Chart 25 ngày =====
                GroupDailyChart {
                    visible: !!info
                    Layout.fillWidth: true
                    Layout.leftMargin: 20; Layout.rightMargin: 20
                    groupDetail: root.groupDetail
                    groupId: root.groupId
                }

                Item { Layout.preferredHeight: 24 }
            }
        }
    }
}