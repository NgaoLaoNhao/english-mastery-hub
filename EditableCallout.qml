import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Rectangle {
    id: root
    property string emoji: "📢"
    property string title: ""
    property string body: ""
    property string linkUrl: ""
    property bool canEdit: false
    property color bgColor: "#fff7e6"
    property color borderColor: "#daa520"
    property var theme: null

    signal editClicked()

    color: theme && theme.isDark ? Qt.darker(bgColor, 3.0) : bgColor
    border.color: theme && theme.isDark ? Qt.lighter(borderColor, 1.3) : borderColor
    border.width: 1
    radius: 8
    Layout.fillWidth: true
    implicitHeight: rowL.implicitHeight + 24

    RowLayout {
        id: rowL
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        Label { text: root.emoji; font.pixelSize: 26 }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 3
            Label {
                text: root.title; font.bold: true; font.pixelSize: 14
                visible: text.length > 0; Layout.fillWidth: true; wrapMode: Text.Wrap
                color: theme ? theme.colors.text : "#0f172a"
            }
            Label {
                text: root.body; wrapMode: Text.Wrap; Layout.fillWidth: true
                visible: text.length > 0
                color: theme ? theme.colors.textMuted : "#374151"
            }
            Label {
                text: "🔗 " + root.linkUrl; color: theme && theme.isDark ? "#60a5fa" : "#0066cc"; font.pixelSize: 11
                wrapMode: Text.Wrap; Layout.fillWidth: true
                visible: root.linkUrl.length > 0
            }
        }
        Button {
            text: "✏️"
            visible: root.canEdit
            ToolTip.visible: hovered
            ToolTip.text: "Chỉnh sửa"
            onClicked: root.editClicked()
        }
    }
}