import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Rectangle {
    id: root
    property string title: ""
    property string subtitle: ""
    property string emoji: ""
    property color colorStart: "#c0392b"
    property color colorMid:   "#e67e22"
    property color colorEnd:   "#f1c40f"
    property string imageSource: ""    // Phase A: rỗng → dùng gradient. Sau này set ảnh thật.

    radius: 10
    border.color: "#222"
    border.width: 2
    clip: true
    implicitHeight: 100

    // Gradient background
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        visible: !root.imageSource
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: root.colorStart }
            GradientStop { position: 0.5; color: root.colorMid }
            GradientStop { position: 1.0; color: root.colorEnd }
        }
    }
    Image {
        anchors.fill: parent
        source: root.imageSource
        visible: !!root.imageSource
        fillMode: Image.PreserveAspectCrop
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 14
        Label { text: root.emoji; font.pixelSize: 40 }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            Label {
                text: root.title; color: "white"; font.pixelSize: 20; font.bold: true
                style: Text.Outline; styleColor: "#000"; Layout.fillWidth: true
                elide: Text.ElideRight
            }
            Label {
                text: root.subtitle; color: "#fff"; font.pixelSize: 11; font.italic: true
                Layout.fillWidth: true; wrapMode: Text.Wrap; visible: text.length > 0
            }
        }
    }
}