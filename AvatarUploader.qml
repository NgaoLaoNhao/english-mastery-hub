import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Dialogs

Item {
    id: root
    property string currentPath: ""
    signal pathChanged(string newPath)

    implicitWidth: 280
    implicitHeight: 100

    RowLayout {
        anchors.fill: parent
        spacing: 12

        // Preview circle
        Rectangle {
            Layout.preferredWidth: 84
            Layout.preferredHeight: 84
            radius: 42
            color: "#eeeeee"
            border.color: "#bbb"
            border.width: 1
            clip: true

            Image {
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                source: root.currentPath
                visible: root.currentPath !== ""
                asynchronous: true
            }

            Label {
                anchors.centerIn: parent
                text: "👤"
                font.pixelSize: 40
                visible: root.currentPath === ""
            }
        }

        // Buttons + hint
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Button {
                text: "📁 Chọn ảnh"
                Layout.fillWidth: true
                onClicked: fileDialog.open()
            }
            Button {
                text: "🗑️ Xoá ảnh"
                Layout.fillWidth: true
                enabled: root.currentPath !== ""
                onClicked: {
                    root.currentPath = ""
                    root.pathChanged("")
                }
            }
            Label {
                text: "PNG/JPG, ≤ 2MB.\n(Mock: chưa resize/validate)"
                color: "#888"
                font.pixelSize: 10
            }
        }
    }

    FileDialog {
        id: fileDialog
        title: "Chọn ảnh đại diện"
        nameFilters: ["Hình ảnh (*.png *.jpg *.jpeg)"]
        fileMode: FileDialog.OpenFile
        onAccepted: {
            const path = selectedFile.toString()  // file:///C:/...
            root.currentPath = path
            root.pathChanged(path)
        }
    }
}