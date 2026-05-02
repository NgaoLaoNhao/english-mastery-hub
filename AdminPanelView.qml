import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Item {
    id: root
    property var auth: null
    property var adminUser: null
    property var adminGroup: null
    property var pdfExporter: null              // ← MỚI
    signal backToWelcome()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 12

        // Header
        RowLayout {
            Layout.fillWidth: true
            Label {
                text: "🛠 Quản trị"
                font.pixelSize: 22
                font.bold: true
                Layout.fillWidth: true
            }
            Button {
                text: "📄 Xuất Top Board"
                enabled: !!root.pdfExporter
                onClicked: {
                    if (root.pdfExporter) {
                        pdfPreviewTopBoardDialog.report = root.pdfExporter.buildTopBoardReport()
                        pdfPreviewTopBoardDialog.open()
                    }
                }
            }
            Button {
                text: "← Trở về"
                onClicked: root.backToWelcome()
            }
        }

        // Tab bar
        TabBar {
            id: tabBar
            Layout.fillWidth: true
            TabButton { text: "👥 Người dùng" }
            TabButton { text: "👨‍👩‍👧 Nhóm" }
        }

        // Page stack
        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: tabBar.currentIndex

            UserManagementPage {
                adminUser: root.adminUser
            }
            GroupManagementPage {
                adminUser: root.adminUser
                adminGroup: root.adminGroup
            }
        }
    }

    // ===== F.3 Dialog =====
    PdfPreviewTopBoardDialog {
        id: pdfPreviewTopBoardDialog
        pdfExporter: root.pdfExporter
    }
}