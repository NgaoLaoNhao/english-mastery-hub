import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Item {
    id: root

    property var auth: null
    property var personal: null      // tái dùng MockPersonalController cho C.2
    property var adminUser: null
    property var adminGroup: null
    property int userId: -1

    signal backRequested()
    signal openGroupDetail(int groupId)

    // Lookup user object
    readonly property var userObj: {
        if (!adminUser || !adminUser.users || userId <= 0) return null
        for (var i = 0; i < adminUser.users.length; i++) {
            if (adminUser.users[i].id === userId) return adminUser.users[i]
        }
        return null
    }

    // Lookup group của user
    readonly property var userGroup: {
        if (!userObj || !adminGroup || !adminGroup.groups) return null
        if (!userObj.groupId || userObj.groupId <= 0) return null
        for (var i = 0; i < adminGroup.groups.length; i++) {
            if (adminGroup.groups[i].id === userObj.groupId) return adminGroup.groups[i]
        }
        return null
    }

    readonly property string roleLabel: {
        if (!userObj) return ""
        if (userObj.role === "admin") return "👑 Quản trị viên"
        if (userGroup) {
            var leaderId = userGroup.leaderId !== undefined
                           ? userGroup.leaderId : userGroup.leaderUserId
            if (leaderId === userObj.id) return "🥇 Leader nhóm"
        }
        return "👤 Thành viên"
    }

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
                    text: "🏆 Hồ sơ thành viên"
                    color: "white"; font.pixelSize: 16; font.bold: true
                    Layout.leftMargin: 12
                }

                Item { Layout.fillWidth: true }

                Label {
                    text: userObj ? (userObj.fullName || userObj.username) : ""
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
                    visible: !userObj
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
                            text: "❌ Không tìm thấy người dùng"
                            color: "#dc2626"
                            font.pixelSize: 18; font.bold: true
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Label {
                            text: "Tài khoản có thể đã bị xoá hoặc ID không hợp lệ."
                            color: "#7f1d1d"
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }

                // ===== Banner thành viên =====
                Rectangle {
                    visible: !!userObj
                    Layout.fillWidth: true
                    Layout.preferredHeight: 140
                    Layout.topMargin: 16
                    Layout.leftMargin: 20; Layout.rightMargin: 20
                    radius: 10
                    border.color: "#222"; border.width: 2
                    clip: true

                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "#0891b2" }
                        GradientStop { position: 0.5; color: "#06b6d4" }
                        GradientStop { position: 1.0; color: "#67e8f9" }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 14

                        // Avatar
                        Rectangle {
                            Layout.preferredWidth: 96
                            Layout.preferredHeight: 96
                            radius: 48
                            color: "white"
                            border.color: "#fff"; border.width: 3
                            clip: true

                            Image {
                                anchors.fill: parent
                                anchors.margins: 3
                                source: (userObj && userObj.avatarPath)
                                        ? userObj.avatarPath : ""
                                fillMode: Image.PreserveAspectCrop
                                sourceSize.width: 96; sourceSize.height: 96
                                asynchronous: true; cache: true
                                visible: userObj && userObj.avatarPath !== ""
                            }
                            Label {
                                anchors.centerIn: parent
                                text: "👤"; font.pixelSize: 56
                                visible: !userObj || userObj.avatarPath === ""
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Label {
                                text: userObj ? (userObj.fullName || userObj.username) : ""
                                color: "white"
                                font.pixelSize: 26; font.bold: true
                                style: Text.Outline; styleColor: "#000"
                            }
                            Label {
                                text: userObj
                                      ? "@" + userObj.username + "  ·  " + roleLabel
                                      : ""
                                color: "white"
                                font.pixelSize: 13
                                style: Text.Outline; styleColor: "#000"
                            }
                            // Group chip (clickable, sẽ wire ở C.3)
                            Rectangle {
                                visible: !!userGroup
                                Layout.preferredHeight: 28
                                Layout.preferredWidth: groupChipLabel.implicitWidth + 24
                                radius: 14
                                color: groupChipMa.containsMouse ? "#ffffff" : "#ffffff80"
                                border.color: "#ffffff"; border.width: 1

                                Label {
                                    id: groupChipLabel
                                    anchors.centerIn: parent
                                    text: userGroup
                                          ? "👥 " + userGroup.name + " ›"
                                          : ""
                                    color: groupChipMa.containsMouse ? "#0891b2" : "#075985"
                                    font.pixelSize: 12; font.bold: true
                                }

                                MouseArea {
                                    id: groupChipMa
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (userGroup)
                                            root.openGroupDetail(userGroup.id)
                                    }
                                }
                            }
                        }
                    }
                }

                // ===== Placeholder C.2 (body) =====
                // ===== C.2.1: 4 KPI cards =====
                RowLayout {
                    visible: !!userObj
                    Layout.fillWidth: true
                    Layout.leftMargin: 20; Layout.rightMargin: 20
                    spacing: 12

                    // Lookup data từ MockPersonalController
                    readonly property var skillData: (personal && userId > 0)
                                                     ? personal.getMySkillBreakdown(userId)
                                                     : { listening: 0, speaking: 0, reading: 0, writing: 0, vocabulary: 0 }
                    readonly property var history: (personal && userId > 0)
                                                   ? personal.getMyHistory(userId) : []

                    readonly property real totalAll: skillData.listening + skillData.speaking
                                                     + skillData.reading + skillData.writing + skillData.vocabulary
                    readonly property int daysCheckedIn: history.length
                    readonly property real avgPerDay: daysCheckedIn > 0 ? totalAll / daysCheckedIn : 0
                    readonly property int currentChallengeDay: 16   // ngày 16/25 (today)
                    readonly property real attendanceRate: currentChallengeDay > 0
                                                           ? (daysCheckedIn / currentChallengeDay) * 100 : 0

                    // Inline KpiCard component
                    component KpiCard: Rectangle {
                        property string emoji: ""
                        property string title: ""
                        property string value: ""
                        property string subtitle: ""
                        property color accent: "#0891b2"
                        property color bg: "#ecfeff"
                        property color border_: "#a5f3fc"

                        Layout.fillWidth: true
                        Layout.preferredHeight: 110
                        radius: 10
                        color: bg
                        border.color: border_; border.width: 1

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 4

                            RowLayout {
                                spacing: 6
                                Label { text: emoji; font.pixelSize: 22 }
                                Label { text: title; color: accent; font.pixelSize: 12; font.bold: true }
                            }
                            Label {
                                text: value
                                color: "#0f172a"
                                font.pixelSize: 26; font.bold: true
                            }
                            Label {
                                text: subtitle
                                color: "#64748b"
                                font.pixelSize: 11
                            }
                        }
                    }

                    KpiCard {
                        emoji: "⏱"; title: "TỔNG GIỜ HỌC"
                        value: parent.totalAll.toFixed(2) + "h"
                        subtitle: "Tích luỹ từ ngày 1"
                        accent: "#0891b2"; bg: "#ecfeff"; border_: "#a5f3fc"
                    }
                    KpiCard {
                        emoji: "📊"; title: "TB MỖI NGÀY"
                        value: parent.avgPerDay.toFixed(2) + "h"
                        subtitle: "Trên các ngày có check-in"
                        accent: "#dc2626"; bg: "#fef2f2"; border_: "#fecaca"
                    }
                    KpiCard {
                        emoji: "📅"; title: "SỐ NGÀY CHECK-IN"
                        value: parent.daysCheckedIn + " / " + parent.currentChallengeDay
                        subtitle: "Trong " + parent.currentChallengeDay + " ngày challenge"
                        accent: "#7c3aed"; bg: "#f5f3ff"; border_: "#ddd6fe"
                    }
                    KpiCard {
                        emoji: "✅"; title: "TỶ LỆ CHUYÊN CẦN"
                        value: parent.attendanceRate.toFixed(0) + "%"
                        subtitle: parent.attendanceRate >= 80 ? "🔥 Xuất sắc"
                                : parent.attendanceRate >= 50 ? "👍 Khá"
                                : "💪 Cần cố gắng"
                        accent: "#16a34a"; bg: "#f0fdf4"; border_: "#bbf7d0"
                    }
                }

                // ===== C.2.2: Stats kỹ năng + chart 25 ngày =====
                PersonalStatsSection {
                    visible: !!userObj
                    Layout.fillWidth: true
                    Layout.leftMargin: 20; Layout.rightMargin: 20
                    Layout.topMargin: 8
                    personal: root.personal
                    userId: root.userId
                }

                // ===== C.2.3: Lịch sử check-in =====
                PersonalHistorySection {
                    visible: !!userObj
                    Layout.fillWidth: true
                    Layout.leftMargin: 20; Layout.rightMargin: 20
                    Layout.topMargin: 8
                    personal: root.personal
                    userId: root.userId
                }

                Item { Layout.preferredHeight: 24 }
            }
        }
    }
}