import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

ColumnLayout {
    id: root
    property var checkin: null
    property var theme: null
    spacing: 8
    Layout.fillWidth: true

    function getUserCheckin(userId) {
        return checkin ? checkin.getTodayCheckin(userId) : null
    }

    BannerHero {
        Layout.fillWidth: true
        emoji: "✅"
        title: "ĐIỂM DANH HÔM NAY"
        subtitle: "Danh sách thành viên đã check-in trong ngày · cập nhật realtime"
        colorStart: "#16a085"; colorMid: "#27ae60"; colorEnd: "#2ecc71"
    }

    Rectangle {
        Layout.fillWidth: true
        color: theme && theme.isDark ? "#1e293b" : "#f8f8f8"
        border.color: theme && theme.isDark ? "#334155" : "#ddd"
        border.width: 1
        radius: 6
        implicitHeight: contentCol.implicitHeight + 24

        ColumnLayout {
            id: contentCol
            anchors.fill: parent
            anchors.margins: 12
            spacing: 6

            Label {
                text: checkin ? ("Tổng cộng " + (checkin.checkedInList ? checkin.checkedInList.length : 0)
                              + " thành viên đã check-in") : ""
                font.bold: true
                color: "#27ae60"
            }

            Repeater {
                model: checkin ? checkin.checkedInList : []
                delegate: Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    color: theme && theme.isDark ? "#1a2e3b" : "white"
                    border.color: theme && theme.isDark ? "#2d4a3f" : "#d4edda"
                    radius: 4

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 12

                        Rectangle {
                            Layout.preferredWidth: 38; Layout.preferredHeight: 38
                            radius: 19; color: "#27ae60"; clip: true
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
                            Layout.fillWidth: true; spacing: 1
                            Label {
                                text: modelData.fullName || modelData.username
                                font.bold: true; elide: Text.ElideRight; Layout.fillWidth: true
                                color: theme ? theme.colors.text : "#0f172a"
                            }
                            Label {
                                property var c: root.getUserCheckin(modelData.id)
                                text: c ? ("⏱ " + checkin.totalHours(c).toFixed(2) + "h"
                                       + "  ·  🎧" + c.listening.toFixed(1)
                                       + " 🗣" + c.speaking.toFixed(1)
                                       + " 📖" + c.reading.toFixed(1)
                                       + " ✍" + c.writing.toFixed(1)
                                       + " 🔤" + c.vocabulary.toFixed(1)
                                       + (c.note ? "  ·  💬 " + c.note : "")) : ""
                                color: theme ? theme.colors.textMuted : "#555"; font.pixelSize: 11
                                elide: Text.ElideRight; Layout.fillWidth: true
                            }
                        }
                    }
                }
            }

            Label {
                text: "Chưa ai check-in 😢"
                color: "#888"; Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                visible: !checkin || !checkin.checkedInList || checkin.checkedInList.length === 0
            }
        }
    }
}