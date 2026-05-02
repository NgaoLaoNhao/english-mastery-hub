import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Dialog {
    id: root
    modal: true
    anchors.centerIn: Overlay.overlay
    width: 720
    height: 760
    title: "📄 Xem trước PDF"

    property var report: null         // do MockPdfExporter.buildPersonalReport(...) trả về
    property var pdfExporter: null    // tham chiếu MockPdfExporter

    standardButtons: Dialog.Close

    contentItem: ColumnLayout {
        spacing: 0

        // ===== Toolbar =====
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            color: "#f1f5f9"
            border.color: "#cbd5e1"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 8

                Button {
                    text: "💾 Lưu PDF"
                    enabled: !!report && !!pdfExporter
                    onClicked: {
                        if (pdfExporter && report)
                            pdfExporter.exportPersonal(report.user.id)
                    }
                }
                Button {
                    text: "🖨 In"
                    onClicked: {
                        // Phase A: chỉ thông báo
                        savedDialog.title = "🖨 In ấn"
                        savedLabel.text = "Phase A chưa hỗ trợ in trực tiếp.\nVui lòng dùng nút 💾 Lưu PDF."
                        savedDialog.open()
                    }
                }
                Item { Layout.fillWidth: true }
                Label {
                    text: report ? ("Tạo lúc: " + report.generatedAt.substring(0, 16).replace("T", " "))
                                 : ""
                    color: "#64748b"; font.pixelSize: 11
                }
            }
        }

        // ===== Preview body =====
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentWidth: availableWidth

            ColumnLayout {
                width: parent.width
                spacing: 12

                // ===== Header (giống PDF cover) =====
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 24; Layout.rightMargin: 24
                    Layout.topMargin: 20
                    Layout.preferredHeight: 110
                    radius: 8
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "#0ea5e9" }
                        GradientStop { position: 1.0; color: "#22d3ee" }
                    }
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 4
                        Label {
                            text: "📋 BÁO CÁO LỊCH SỬ CHECK-IN"
                            color: "white"; font.pixelSize: 20; font.bold: true
                        }
                        Label {
                            text: "English Mastery Hub  ·  25-day Challenge"
                            color: "#e0f7fa"; font.pixelSize: 12
                        }
                        Item { Layout.fillHeight: true }
                        Label {
                            text: report ? ("Học viên: " + (report.user.fullName || report.user.username)
                                          + "  ·  @" + report.user.username
                                          + "  ·  Nhóm: " + report.groupName)
                                         : ""
                            color: "white"; font.pixelSize: 13
                        }
                    }
                }

                // ===== Stats summary =====
                GridLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 24; Layout.rightMargin: 24
                    columns: 4
                    rowSpacing: 8; columnSpacing: 8

                    Repeater {
                        model: report ? [
                            { lbl: "⏱ Tổng giờ", val: (report.sumByskill.total).toFixed(2) + "h" },
                            { lbl: "📅 Số ngày", val: report.rows.length + "/" + report.challengeTotal },
                            { lbl: "📈 TB/ngày", val: report.stats.avgPerDay.toFixed(2) + "h" },
                            { lbl: "🔥 Streak", val: report.currentStreak + " ngày" }
                        ] : []
                        delegate: Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: 64
                            radius: 6
                            color: "#fef3c7"
                            border.color: "#fbbf24"
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 2
                                Label { text: modelData.lbl; color: "#78350f"; font.pixelSize: 11 }
                                Label { text: modelData.val; color: "#0f172a"; font.pixelSize: 18; font.bold: true }
                            }
                        }
                    }
                }

                // ===== Skill breakdown =====
                Label {
                    text: "🎯 Phân bổ kỹ năng (tổng giờ)"
                    Layout.leftMargin: 24
                    font.pixelSize: 14; font.bold: true
                    color: "#1e293b"
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 24; Layout.rightMargin: 24
                    spacing: 4

                    Repeater {
                        model: report ? [
                            { name: "👂 Listening",  val: report.sumByskill.listening,  color: "#3b82f6" },
                            { name: "🗣 Speaking",   val: report.sumByskill.speaking,   color: "#10b981" },
                            { name: "📖 Reading",    val: report.sumByskill.reading,    color: "#f59e0b" },
                            { name: "✍ Writing",    val: report.sumByskill.writing,    color: "#ef4444" },
                            { name: "🔤 Vocabulary", val: report.sumByskill.vocabulary, color: "#8b5cf6" }
                        ] : []
                        delegate: RowLayout {
                            required property var modelData
                            Layout.fillWidth: true
                            spacing: 8
                            Label {
                                text: modelData.name
                                Layout.preferredWidth: 130
                                font.pixelSize: 12
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 14
                                radius: 6
                                color: "#e2e8f0"
                                Rectangle {
                                    width: {
                                        var maxV = report ? Math.max(1, report.sumByskill.total) : 1
                                        return parent.width * (modelData.val / maxV)
                                    }
                                    height: parent.height
                                    radius: parent.radius
                                    color: modelData.color
                                }
                            }
                            Label {
                                text: modelData.val.toFixed(2) + "h"
                                Layout.preferredWidth: 60
                                font.pixelSize: 12; font.bold: true
                                horizontalAlignment: Text.AlignRight
                            }
                        }
                    }
                }

                // ===== Bảng chi tiết =====
                Label {
                    text: "📅 Chi tiết theo ngày"
                    Layout.leftMargin: 24
                    Layout.topMargin: 8
                    font.pixelSize: 14; font.bold: true
                    color: "#1e293b"
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 24; Layout.rightMargin: 24
                    Layout.preferredHeight: tableCol.implicitHeight + 4
                    color: "white"
                    border.color: "#cbd5e1"; border.width: 1
                    radius: 4

                    ColumnLayout {
                        id: tableCol
                        anchors.fill: parent
                        spacing: 0

                        // Header row
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 32
                            color: "#f1f5f9"
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8; anchors.rightMargin: 8
                                spacing: 4
                                Label { text: "Ngày";    Layout.preferredWidth: 90; font.bold: true; font.pixelSize: 12 }
                                Label { text: "L";       Layout.preferredWidth: 36; font.bold: true; font.pixelSize: 12; horizontalAlignment: Text.AlignRight }
                                Label { text: "S";       Layout.preferredWidth: 36; font.bold: true; font.pixelSize: 12; horizontalAlignment: Text.AlignRight }
                                Label { text: "R";       Layout.preferredWidth: 36; font.bold: true; font.pixelSize: 12; horizontalAlignment: Text.AlignRight }
                                Label { text: "W";       Layout.preferredWidth: 36; font.bold: true; font.pixelSize: 12; horizontalAlignment: Text.AlignRight }
                                Label { text: "V";       Layout.preferredWidth: 36; font.bold: true; font.pixelSize: 12; horizontalAlignment: Text.AlignRight }
                                Label { text: "Tổng";    Layout.preferredWidth: 50; font.bold: true; font.pixelSize: 12; horizontalAlignment: Text.AlignRight }
                                Label { text: "Ghi chú"; Layout.fillWidth: true; font.bold: true; font.pixelSize: 12 }
                            }
                        }

                        Repeater {
                            model: report ? report.rows : []
                            delegate: Rectangle {
                                required property var modelData
                                required property int index
                                Layout.fillWidth: true
                                Layout.preferredHeight: 28
                                color: index % 2 === 0 ? "white" : "#fafafa"
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 8; anchors.rightMargin: 8
                                    spacing: 4
                                    Label { text: modelData.date;                Layout.preferredWidth: 90;  font.pixelSize: 11 }
                                    Label { text: modelData.listening.toFixed(1);Layout.preferredWidth: 36;  font.pixelSize: 11; horizontalAlignment: Text.AlignRight }
                                    Label { text: modelData.speaking.toFixed(1); Layout.preferredWidth: 36;  font.pixelSize: 11; horizontalAlignment: Text.AlignRight }
                                    Label { text: modelData.reading.toFixed(1);  Layout.preferredWidth: 36;  font.pixelSize: 11; horizontalAlignment: Text.AlignRight }
                                    Label { text: modelData.writing.toFixed(1);  Layout.preferredWidth: 36;  font.pixelSize: 11; horizontalAlignment: Text.AlignRight }
                                    Label { text: modelData.vocabulary.toFixed(1);Layout.preferredWidth: 36; font.pixelSize: 11; horizontalAlignment: Text.AlignRight }
                                    Label { text: modelData.total.toFixed(1) + "h"; Layout.preferredWidth: 50; font.pixelSize: 11; font.bold: true; horizontalAlignment: Text.AlignRight; color: "#0f172a" }
                                    Label {
                                        text: modelData.note
                                        Layout.fillWidth: true
                                        font.pixelSize: 11
                                        color: "#64748b"
                                        elide: Label.ElideRight
                                    }
                                }
                            }
                        }

                        // Empty state
                        Label {
                            visible: report && report.rows.length === 0
                            text: "Chưa có check-in nào trong giai đoạn này."
                            Layout.fillWidth: true
                            Layout.topMargin: 12; Layout.bottomMargin: 12
                            horizontalAlignment: Text.AlignHCenter
                            color: "#94a3b8"
                        }
                    }
                }

                // ===== Footer =====
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

    // ===== Lắng nghe export events =====
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
        Label {
            id: savedLabel
            anchors.fill: parent
            wrapMode: Label.WordWrap
        }
    }
}