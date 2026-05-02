import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Dialog {
    id: root
    modal: true
    anchors.centerIn: Overlay.overlay
    width: 720
    height: 760
    title: "📄 Xem trước PDF — Báo cáo nhóm"

    property var report: null
    property var pdfExporter: null

    standardButtons: Dialog.Close

    contentItem: ColumnLayout {
        spacing: 0

        // Toolbar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            color: "#f1f5f9"
            border.color: "#cbd5e1"
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12; anchors.rightMargin: 12
                spacing: 8
                Button {
                    text: "💾 Lưu PDF nhóm"
                    enabled: !!report && !!pdfExporter
                    onClicked: {
                        if (pdfExporter && report)
                            pdfExporter.exportGroup(report.info.id || report.info.groupId)
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

                // Header banner
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 24; Layout.rightMargin: 24; Layout.topMargin: 20
                    Layout.preferredHeight: 110
                    radius: 8
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "#7c3aed" }
                        GradientStop { position: 1.0; color: "#a855f7" }
                    }
                    ColumnLayout {
                        anchors.fill: parent; anchors.margins: 16
                        spacing: 4
                        Label {
                            text: "👥 BÁO CÁO NHÓM"
                            color: "white"; font.pixelSize: 20; font.bold: true
                        }
                        Label {
                            text: "English Mastery Hub  ·  25-day Challenge"
                            color: "#ede9fe"; font.pixelSize: 12
                        }
                        Item { Layout.fillHeight: true }
                        Label {
                            text: report ? ("Nhóm: " + report.info.name
                                          + "  ·  👑 " + (report.info.leaderName || "Chưa có leader")
                                          + "  ·  " + report.memberCount + " thành viên")
                                         : ""
                            color: "white"; font.pixelSize: 13
                        }
                    }
                }

                // KPI cards
                GridLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 24; Layout.rightMargin: 24
                    columns: 4
                    rowSpacing: 8; columnSpacing: 8
                    Repeater {
                        model: report ? [
                            { lbl: "⏱ Tổng giờ", val: report.totalHours.toFixed(2) + "h" },
                            { lbl: "📊 TB/người", val: report.avgPerMember.toFixed(2) + "h" },
                            { lbl: "👥 Thành viên", val: String(report.memberCount) },
                            { lbl: "✅ Chuyên cần", val: report.kpi ? (report.kpi.attendanceRate + "%") : "—" }
                        ] : []
                        delegate: Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: 64
                            radius: 6
                            color: "#f5f3ff"; border.color: "#ddd6fe"
                            ColumnLayout {
                                anchors.fill: parent; anchors.margins: 8; spacing: 2
                                Label { text: modelData.lbl; color: "#6d28d9"; font.pixelSize: 11 }
                                Label { text: modelData.val; color: "#0f172a"; font.pixelSize: 18; font.bold: true }
                            }
                        }
                    }
                }

                // Top contributor card
                Rectangle {
                    visible: report && !!report.topContributor
                    Layout.fillWidth: true
                    Layout.leftMargin: 24; Layout.rightMargin: 24
                    Layout.preferredHeight: 80
                    radius: 8
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "#fef3c7" }
                        GradientStop { position: 1.0; color: "#fde68a" }
                    }
                    border.color: "#fbbf24"; border.width: 1
                    RowLayout {
                        anchors.fill: parent; anchors.margins: 12
                        spacing: 12
                        Label { text: "🏆"; font.pixelSize: 36 }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Label {
                                text: "Top Contributor"
                                color: "#78350f"; font.pixelSize: 11; font.bold: true
                            }
                            Label {
                                text: report && report.topContributor
                                    ? (report.topContributor.fullName + "  ·  @" + report.topContributor.username)
                                    : ""
                                color: "#0f172a"; font.pixelSize: 16; font.bold: true
                            }
                            Label {
                                text: report && report.topContributor
                                    ? (report.topContributor.totalHours.toFixed(2) + "h  ·  "
                                      + report.topContributor.daysCheckedIn + " ngày  ·  "
                                      + report.topContributor.attendanceRate + "% chuyên cần")
                                    : ""
                                color: "#92400e"; font.pixelSize: 12
                            }
                        }
                    }
                }

                // Ranking table
                Label {
                    text: "🏅 Ranking thành viên"
                    Layout.leftMargin: 24
                    Layout.topMargin: 8
                    font.pixelSize: 14; font.bold: true
                    color: "#1e293b"
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 24; Layout.rightMargin: 24
                    Layout.preferredHeight: tblCol.implicitHeight + 4
                    color: "white"
                    border.color: "#cbd5e1"; border.width: 1
                    radius: 4
                    ColumnLayout {
                        id: tblCol
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
                                Label { text: "Thành viên"; Layout.fillWidth: true; font.bold: true; font.pixelSize: 12 }
                                Label { text: "Tổng giờ"; Layout.preferredWidth: 80; font.bold: true; font.pixelSize: 12; horizontalAlignment: Text.AlignRight }
                                Label { text: "Ngày";     Layout.preferredWidth: 50; font.bold: true; font.pixelSize: 12; horizontalAlignment: Text.AlignRight }
                                Label { text: "Chuyên cần"; Layout.preferredWidth: 90; font.bold: true; font.pixelSize: 12; horizontalAlignment: Text.AlignRight }
                            }
                        }

                        Repeater {
                            model: report ? report.members : []
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
                                        text: index === 0 ? "🥇" : (index === 1 ? "🥈" : (index === 2 ? "🥉" : (index+1).toString()))
                                        Layout.preferredWidth: 30
                                        font.pixelSize: index < 3 ? 16 : 12
                                        font.bold: true
                                    }
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 4
                                        Label {
                                            text: (modelData.fullName || ("@" + modelData.username))
                                                + (modelData.isLeader ? " 👑" : "")
                                            font.pixelSize: 12
                                            font.bold: modelData.isLeader
                                            color: modelData.isLeader ? "#7c3aed" : "#0f172a"
                                            elide: Label.ElideRight
                                            Layout.fillWidth: true
                                        }
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
                                        Layout.preferredWidth: 90
                                        font.pixelSize: 12
                                        horizontalAlignment: Text.AlignRight
                                        color: modelData.attendanceRate >= 80 ? "#16a34a"
                                             : modelData.attendanceRate >= 50 ? "#f59e0b" : "#dc2626"
                                    }
                                }
                            }
                        }

                        Label {
                            visible: report && report.members.length === 0
                            text: "Nhóm chưa có thành viên."
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