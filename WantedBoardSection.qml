import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

ColumnLayout {
    id: root
    property var auth: null
    property var checkin: null
    property var gemini: null
    Layout.fillWidth: true
    spacing: 6

    BannerHero {
        Layout.fillWidth: true
        emoji: "🚨"
        title: "BẢNG TRUY NÃ"
        subtitle: "Thành viên chưa check-in hôm nay"
        colorStart: "#7f1d1d"; colorMid: "#dc2626"; colorEnd: "#f59e0b"
    }

    Rectangle {
        Layout.fillWidth: true
        color: "#fff5f5"; border.color: "#fadbd8"; border.width: 1; radius: 6
        implicitHeight: wantedCol.implicitHeight + 24

        ColumnLayout {
            id: wantedCol
            anchors.fill: parent
            anchors.margins: 12
            spacing: 6

            Label {
                text: "🚨 " + (checkin && checkin.wantedList ? checkin.wantedList.length : 0) + " thành viên đang \"trốn check-in\""
                font.bold: true; color: "#c0392b"
            }

            Repeater {
                model: checkin ? checkin.wantedList : []
                delegate: Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    color: "white"; border.color: "#fadbd8"; radius: 4
                    RowLayout {
                        anchors.fill: parent; anchors.margins: 8; spacing: 10
                        Rectangle {
                            Layout.preferredWidth: 34; Layout.preferredHeight: 34
                            radius: 17; color: "#e74c3c"; clip: true
                            Image {
                                anchors.fill: parent; fillMode: Image.PreserveAspectCrop
                                source: modelData.avatarPath || ""
                                visible: source.toString() !== ""
                            }
                            Label {
                                anchors.centerIn: parent
                                text: modelData.username.charAt(0).toUpperCase()
                                color: "white"; font.bold: true
                                visible: !modelData.avatarPath
                            }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true; spacing: 0
                            Label {
                                text: modelData.fullName || modelData.username
                                font.bold: true; elide: Text.ElideRight; Layout.fillWidth: true
                            }
                            Label { text: "@" + modelData.username; color: "#888"; font.pixelSize: 11 }
                        }
                        Label { text: "⏳"; font.pixelSize: 20 }
                        Button {
                            text: "🤖 Nhắc"
                            font.pixelSize: 11
                            onClicked: {
                                if (root.gemini) {
                                    root.gemini.generateWarning(modelData.fullName || modelData.username, 1)
                                }
                            }
                        }
                    }
                }
            }

            Label {
                text: "🎉 Tất cả đã check-in!"
                color: "#27ae60"; font.pixelSize: 14
                Layout.fillWidth: true; horizontalAlignment: Text.AlignHCenter
                visible: !checkin || !checkin.wantedList || checkin.wantedList.length === 0
            }
        }
    }
}