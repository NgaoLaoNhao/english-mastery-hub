import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Dialog {
    id: root
    modal: true
    anchors.centerIn: Overlay.overlay
    width: 760
    height: 800
    title: "📄 Xem trước PDF — Top Board Workspace"

    property var report: null
    property var pdfExporter: null

    standardButtons: Dialog.Close

    contentItem: ColumnLayout {
        spacing: 0

        // Toolbar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            color: "#f1f5f9"; border.color: "#cbd5e1"
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12; anchors.rightMargin: 12
                spacing: 8
                Button {
                    text: "💾 Lưu PDF Top Board"
                    enabled: !!report && !!pdfExporter
                    onClicked: {
                        if (pdfExporter) pdfExporter.exportTopBoard()
                    }
                }
                Item { Layout.fillWidth: true }
                Label {
                    text: report ? ("Tạo lúc: " + report.generatedAt.substring(0,16).replace("T"," "))
                                 : ""
                    color: "#64748b"; font.pixelSize: 11
                }
            }
        }

        // Body preview
        ScrollView {
            Layout.fillWidth: true; Layout.fillHeight: true
            clip: true
            contentWidth: availableWidth

            ColumnLayout {
                width: parent.width
                spacing: 12

                // Header banner — vàng/cam
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 24; Layout.rightMargin: 24; Layout.topMargin: 20
                    Layout.preferredHeight: 110
                    radius: 8
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "#f59e0b" }
                        GradientStop { position: 1.0; color: "#fbbf24" }
                    }
                    ColumnLayout {
                        anchors.fill: parent; anchors.margins: 16
                        spacing: 4
                        Label {
                            text: "🏆 TOP BOARD WORKSPACE"
                            color: "white"; font.pixelSize: 20; font.bold: true
                            style: Text.Outline; styleColor: "#78350f"
                        }
                        Label {
                            text: "English Mastery Hub  ·  Báo cáo tổng hợp 25-day Challenge"
                            color: "white"; font.pixelSize: 12
                            style: Text.Outline; styleColor: "#78350f"
                        }
                        Item { Layout.fillHeight: true }
                        Label {
                            text: report ? ("Ngày báo cáo: "
                                          + report.generatedAt.substring(0,10)
                                          + "  ·  Đã qua: " + report.currentDay + "/" + report.challengeTotal + " ngày")
                                         : ""
                            color: "white"; font.pixelSize: 13
                            style: Text.Outline; styleColor: "#78350f"
                        }
                    }
                }

                // KPI Workspace (4 cards)
                GridLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 24; Layout.rightMargin: 24
                    columns: 4
                    rowSpacing: 8; columnSpacing: 8
                    Repeater {
                        model: report ? [
                            { lbl: "👥 Tổng users", val: String(report.totalUsers), bg: "#dbeafe", c: "#1e40af" },
                            { lbl: "👨‍👩‍👧 Số nhóm", val: String(report.totalGroups), bg: "#f5f3ff", c: "#6d28d9" },
                            { lbl: "⏱ Tổng giờ", val: report.totalHours.toFixed(1) + "h", bg: "#ecfeff", c: "#0891b2" },
                            { lbl: "📊 TB/user", val: report.avgPerUser.toFixed(2) + "h", bg: "#fef3c7", c: "#b45309" }
                        ] : []
                        delegate: Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: 70
                            radius: 6
                            color: modelData.bg
                            border.color: "#e2e8f0"
                            ColumnLayout {
                                anchors.fill: parent; anchors.margins: 10; spacing: 2
                                Label { text: modelData.lbl; color: "#64748b"; font.pixelSize: 11 }
                                Label { text: modelData.val; color: modelData.c; font.pixelSize: 22; font.bold: true }
                            }
                        }
                    }
                }

                // Challenge progress bar
                Rectangle {
                    visible: !!report
                    Layout.fillWidth: true
                    Layout.leftMargin: 24; Layout.rightMargin: 24
                    Layout.preferredHeight: 56
                    radius: 8
                    color: "#fafafa"
                    border.color: "#e2e8f0"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 4
                        RowLayout {
                            Layout.fillWidth: true
                            Label {
                                text: "🎯 Tiến độ challenge"
                                font.pixelSize: 12; font.bold: true
                                color: "#1e293b"
                            }
                            Item { Layout.fillWidth: true }
                            Label {
                                text: report ? ("Ngày " + report.currentDay + "/" + report.challengeTotal
                                              + "  ·  " + report.progressPct + "%")
                                             : ""
                                font.pixelSize: 12; font.bold: true
                                color: "#16a34a"
                            }
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 14
                            radius: 7
                            color: "#e2e8f0"
                            Rectangle {
                                width: parent.width * (report ? (report.progressPct / 100) : 0)
                                height: parent.height
                                radius: parent.radius
                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop { position: 0.0; color: "#10b981" }
                                    GradientStop { position: 1.0; color: "#34d399" }
                                }
                            }
                        }
                    }
                }

                // Top 10 users
                Label {
                    text: "🏆 Top 10 học viên"
                    Layout.leftMargin: 24
                    Layout.topMargin: 8
                    font.pixelSize: 14; font.bold: true
                    color: "#1e293b"
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 24; Layout.rightMargin: 24
                    Layout.preferredHeight: topTblCol.implicitHeight + 4
                    color: "white"
                    border.color: "#cbd5e1"; border.width: 1
                    radius: 4

                    ColumnLayout {
                        id: topTblCol
                        anchors.fill: parent
                        spacing: 0

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 32
                            color: "#f1f5f9"
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8; anchors.rightMargin: 8
                                spacing: 4
                                Label { text: "#";          Layout.preferredWidth: 36; font.bold: true; font.pixelSize: 12 }
                                Label { text: "Học viên";   Layout.fillWidth: true;     font.bold: true; font.pixelSize: 12 }
                                Label { text: "Nhóm";       Layout.preferredWidth: 110; font.bold: true; font.pixelSize: 12 }
                                Label { text: "Tổng giờ";   Layout.preferredWidth: 80;  font.bold: true; font.pixelSize: 12; horizontalAlignment: Text.AlignRight }
                                Label { text: "Ngày";       Layout.preferredWidth: 50;  font.bold: true; font.pixelSize: 12; horizontalAlignment: Text.AlignRight }
                                Label { text: "%CC";        Layout.preferredWidth: 60;  font.bold: true; font.pixelSize: 12; horizontalAlignment: Text.AlignRight }
                            }
                        }

                        Repeater {
                            model: report ? report.top10 : []
                            delegate: Rectangle {
                                required property var modelData
                                required property int index
                                Layout.fillWidth: true
                                Layout.preferredHeight: 32
                                color: index === 0 ? "#fef9c3"
                                     : index === 1 ? "#f1f5f9"
                                     : index === 2 ? "#fed7aa"
                                     : (index % 2 === 0 ? "white" : "#fafafa")
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 8; anchors.rightMargin: 8
                                    spacing: 4
                                    Label {
                                        text: index === 0 ? "🥇"
                                            : index === 1 ? "🥈"
                                            : index === 2 ? "🥉"
                                            : (index+1).toString()
                                        Layout.preferredWidth: 36
                                        font.pixelSize: index < 3 ? 18 : 13
                                        font.bold: true
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                    Label {
                                        text: modelData.fullName + " · @" + modelData.username
                                        Layout.fillWidth: true
                                        font.pixelSize: 12
                                        font.bold: index < 3
                                        elide: Label.ElideRight
                                        color: "#0f172a"
                                    }
                                    Label {
                                        text: modelData.groupName
                                        Layout.preferredWidth: 110
                                        font.pixelSize: 11
                                        color: "#64748b"
                                        elide: Label.ElideRight
                                    }
                                    Label {
                                        text: modelData.totalHours.toFixed(2) + "h"
                                        Layout.preferredWidth: 80
                                        font.pixelSize: 12; font.bold: true
                                        horizontalAlignment: Text.AlignRight
                                        color: "#0891b2"
                                    }
                                    Label {
                                        text: String(modelData.daysCheckedIn)
                                        Layout.preferredWidth: 50
                                        font.pixelSize: 12
                                        horizontalAlignment: Text.AlignRight
                                    }
                                    Label {
                                        text: modelData.attendanceRate + "%"
                                        Layout.preferredWidth: 60
                                        font.pixelSize: 12
                                        horizontalAlignment: Text.AlignRight
                                        color: modelData.attendanceRate >= 80 ? "#16a34a"
                                             : modelData.attendanceRate >= 50 ? "#f59e0b" : "#dc2626"
                                    }
                                }
                            }
                        }

                        Label {
                            visible: report && report.top10.length === 0
                            text: "Chưa có dữ liệu học viên."
                            Layout.fillWidth: true
                            Layout.topMargin: 12; Layout.bottomMargin: 12
                            horizontalAlignment: Text.AlignHCenter
                            color: "#94a3b8"
                        }
                    }
                }

                // Group ranking
                Label {
                    text: "👨‍👩‍👧 Bảng xếp hạng nhóm"
                    Layout.leftMargin: 24
                    Layout.topMargin: 8
                    font.pixelSize: 14; font.bold: true
                    color: "#1e293b"
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 24; Layout.rightMargin: 24
                    Layout.preferredHeight: groupTblCol.implicitHeight + 4
                    color: "white"
                    border.color: "#cbd5e1"; border.width: 1
                    radius: 4

                    ColumnLayout {
                        id: groupTblCol
                        anchors.fill: parent
                        spacing: 0

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 32
                            color: "#f1f5f9"
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8; anchors.rightMargin: 8
                                spacing: 4
                                Label { text: "#";        Layout.preferredWidth: 30; font.bold: true; font.pixelSize: 12 }
                                Label { text: "Nhóm";     Layout.fillWidth: true;     font.bold: true; font.pixelSize: 12 }
                                Label { text: "Leader";   Layout.preferredWidth: 110; font.bold: true; font.pixelSize: 12 }
                                Label { text: "Sĩ số";    Layout.preferredWidth: 50;  font.bold: true; font.pixelSize: 12; horizontalAlignment: Text.AlignRight }
                                Label { text: "Tổng giờ"; Layout.preferredWidth: 80;  font.bold: true; font.pixelSize: 12; horizontalAlignment: Text.AlignRight }
                                Label { text: "TB/người"; Layout.preferredWidth: 80;  font.bold: true; font.pixelSize: 12; horizontalAlignment: Text.AlignRight }
                                Label { text: "%CC";      Layout.preferredWidth: 60;  font.bold: true; font.pixelSize: 12; horizontalAlignment: Text.AlignRight }
                            }
                        }

                        Repeater {
                            model: report ? report.groupRanking : []
                            delegate: Rectangle {
                                required property var modelData
                                required property int index
                                Layout.fillWidth: true
                                Layout.preferredHeight: 32
                                color: index % 2 === 0 ? "white" : "#fafafa"
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 8; anchors.rightMargin: 8
                                    spacing: 4
                                    Label {
                                        text: (index+1).toString()
                                        Layout.preferredWidth: 30
                                        font.pixelSize: 13; font.bold: true
                                    }
                                    Label {
                                        text: modelData.name
                                        Layout.fillWidth: true
                                        font.pixelSize: 12; font.bold: true
                                        elide: Label.ElideRight
                                        color: "#7c3aed"
                                    }
                                    Label {
                                        text: modelData.leaderName
                                        Layout.preferredWidth: 110
                                        font.pixelSize: 11
                                        color: "#64748b"
                                        elide: Label.ElideRight
                                    }
                                    Label {
                                        text: String(modelData.memberCount)
                                        Layout.preferredWidth: 50
                                        font.pixelSize: 12
                                        horizontalAlignment: Text.AlignRight
                                    }
                                    Label {
                                        text: modelData.totalHours.toFixed(2) + "h"
                                        Layout.preferredWidth: 80
                                        font.pixelSize: 12; font.bold: true
                                        horizontalAlignment: Text.AlignRight
                                        color: "#0891b2"
                                    }
                                    Label {
                                        text: modelData.avgPerMember.toFixed(2) + "h"
                                        Layout.preferredWidth: 80
                                        font.pixelSize: 12
                                        horizontalAlignment: Text.AlignRight
                                    }
                                    Label {
                                        text: modelData.attendanceRate + "%"
                                        Layout.preferredWidth: 60
                                        font.pixelSize: 12
                                        horizontalAlignment: Text.AlignRight
                                        color: modelData.attendanceRate >= 80 ? "#16a34a"
                                             : modelData.attendanceRate >= 50 ? "#f59e0b" : "#dc2626"
                                    }
                                }
                            }
                        }

                        Label {
                            visible: report && report.groupRanking.length === 0
                            text: "Chưa có nhóm nào."
                            Layout.fillWidth: true
                            Layout.topMargin: 12; Layout.bottomMargin: 12
                            horizontalAlignment: Text.AlignHCenter
                            color: "#94a3b8"
                        }
                    }
                }

                Label {
                    text: "Báo cáo được tạo tự động bởi English Mastery Hub  ·  Phase A (mock)"
                    Layout.fillWidth: true
                    Layout.topMargin: 12; Layout.bottomMargin: 16
                    Layout.leftMargin: 24; Layout.rightMargin: 24
                    horizontalAlignment: Text.AlignHCenter
                    color: "#94a3b8"; font.pixelSize: 10
                }
            }
        }
    }

    Connections {
        target: pdfExporter
        function onExportCompleted(fileName, fakePath) {
            savedDialog.title = "✅ Đã xuất PDF"
            savedLabel.text = "📁 File giả lập:\n" + fakePath
                            + "\n\n(Phase A: dữ liệu giả — Phase B/C sẽ ghi file thật)"
            savedDialog.open()
        }
        function onExportFailed(reason) {
            savedDialog.title = "❌ Lỗi"
            savedLabel.text = reason
            savedDialog.open()
        }
    }

    Dialog {
        id: savedDialog
        modal: true
        anchors.centerIn: Overlay.overlay
        width: 420
        standardButtons: Dialog.Ok
        Label { id: savedLabel; anchors.fill: parent; wrapMode: Label.WordWrap }
    }
}