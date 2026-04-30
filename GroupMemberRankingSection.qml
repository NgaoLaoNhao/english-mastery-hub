import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Item {
    id: root

    property var groupDetail: null
    property int groupId: -1

    // sortMode: "rank" | "total_desc" | "total_asc" | "days_desc" | "days_asc"
    //         | "rate_desc" | "rate_asc" | "avg_desc" | "avg_asc"
    property string sortMode: "rank"

    readonly property var rawMembers: groupDetail && groupId > 0
                                      ? groupDetail.getGroupMembers(groupId)
                                      : []

    readonly property var sortedMembers: {
        var rows = rawMembers.slice()
        if (sortMode === "rank")        rows.sort(function(a,b){ return a.rank - b.rank })
        if (sortMode === "total_desc")  rows.sort(function(a,b){ return b.totalHours - a.totalHours })
        if (sortMode === "total_asc")   rows.sort(function(a,b){ return a.totalHours - b.totalHours })
        if (sortMode === "days_desc")   rows.sort(function(a,b){ return b.daysCheckedIn - a.daysCheckedIn })
        if (sortMode === "days_asc")    rows.sort(function(a,b){ return a.daysCheckedIn - b.daysCheckedIn })
        if (sortMode === "rate_desc")   rows.sort(function(a,b){ return b.attendanceRate - a.attendanceRate })
        if (sortMode === "rate_asc")    rows.sort(function(a,b){ return a.attendanceRate - b.attendanceRate })
        if (sortMode === "avg_desc")    rows.sort(function(a,b){ return b.avgPerDay - a.avgPerDay })
        if (sortMode === "avg_asc")     rows.sort(function(a,b){ return a.avgPerDay - b.avgPerDay })
        return rows
    }

    function _toggle(modeBase) {
        if (sortMode === modeBase + "_desc") sortMode = modeBase + "_asc"
        else if (modeBase === "rank") sortMode = "rank"
        else sortMode = modeBase + "_desc"
    }
    function _arrow(modeBase) {
        if (sortMode === modeBase + "_desc") return " ▼"
        if (sortMode === modeBase + "_asc")  return " ▲"
        if (modeBase === "rank" && sortMode === "rank") return " ▼"
        return ""
    }

    implicitHeight: contentCol.implicitHeight

    ColumnLayout {
        id: contentCol
        width: parent.width
        spacing: 10

        // Tiêu đề
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Label {
                text: "🏆 Ranking thành viên"
                font.pixelSize: 18; font.bold: true
                color: "#0f172a"
            }
            Item { Layout.fillWidth: true }
            Label {
                text: sortedMembers.length + " thành viên"
                color: "#64748b"; font.pixelSize: 12
            }
        }

        // Khung bảng
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: tableInner.implicitHeight + 2
            radius: 8
            color: "white"
            border.color: "#e2e8f0"; border.width: 1
            clip: true

            Column {
                id: tableInner
                width: parent.width
                spacing: 0

                // ===== HEADER =====
                Rectangle {
                    width: parent.width
                    height: 38
                    color: "#f1f5f9"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12; anchors.rightMargin: 12
                        spacing: 0

                        // Hạng
                        Item {
                            Layout.preferredWidth: 60
                            Layout.fillHeight: true
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.sortMode = "rank"
                            }
                            Label {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                text: "#" + root._arrow("rank")
                                font.bold: true; color: "#334155"
                            }
                        }

                        // Tên thành viên (không sortable)
                        Label {
                            Layout.fillWidth: true
                            text: "Thành viên"
                            font.bold: true; color: "#334155"
                        }

                        // Tổng giờ (sortable)
                        Item {
                            Layout.preferredWidth: 110
                            Layout.fillHeight: true
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root._toggle("total")
                            }
                            Label {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                text: "Tổng giờ" + root._arrow("total")
                                font.bold: true; color: "#0891b2"
                            }
                        }

                        // Số ngày (sortable)
                        Item {
                            Layout.preferredWidth: 90
                            Layout.fillHeight: true
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root._toggle("days")
                            }
                            Label {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                text: "Số ngày" + root._arrow("days")
                                font.bold: true; color: "#7c3aed"
                            }
                        }

                        // Chuyên cần (sortable)
                        Item {
                            Layout.preferredWidth: 110
                            Layout.fillHeight: true
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root._toggle("rate")
                            }
                            Label {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                text: "Chuyên cần" + root._arrow("rate")
                                font.bold: true; color: "#16a34a"
                            }
                        }

                        // TB/ngày (sortable)
                        Item {
                            Layout.preferredWidth: 100
                            Layout.fillHeight: true
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root._toggle("avg")
                            }
                            Label {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                text: "TB/ngày" + root._arrow("avg")
                                font.bold: true; color: "#dc2626"
                            }
                        }
                    }
                }

                // ===== EMPTY STATE =====
                Rectangle {
                    width: parent.width
                    height: 80
                    visible: sortedMembers.length === 0
                    color: "transparent"
                    Label {
                        anchors.centerIn: parent
                        text: "Nhóm chưa có thành viên nào."
                        color: "#94a3b8"; font.italic: true
                    }
                }

                // ===== DATA ROWS =====
                Repeater {
                    model: sortedMembers
                    delegate: Rectangle {
                        id: row
                        required property var modelData
                        required property int index
                        width: tableInner.width
                        height: 48
                        color: row.index % 2 === 0 ? "white" : "#f8fafc"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12; anchors.rightMargin: 12
                            spacing: 0

                            // Hạng + medal
                            Item {
                                Layout.preferredWidth: 60
                                Layout.fillHeight: true
                                Label {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: {
                                        var r = row.modelData.rank
                                        if (r === 1) return "🥇 1"
                                        if (r === 2) return "🥈 2"
                                        if (r === 3) return "🥉 3"
                                        return "#" + r
                                    }
                                    color: "#0f172a"; font.bold: true
                                }
                            }

                            // Avatar + Tên + leader badge
                            RowLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                spacing: 10

                                Rectangle {
                                    Layout.preferredWidth: 32
                                    Layout.preferredHeight: 32
                                    radius: 16
                                    color: "#e0e7ff"
                                    border.color: "#a5b4fc"; border.width: 1
                                    Image {
                                        anchors.fill: parent
                                        anchors.margins: 1
                                        source: row.modelData.avatarPath !== ""
                                                ? row.modelData.avatarPath
                                                : ""
                                        fillMode: Image.PreserveAspectCrop
                                        sourceSize.width: 32; sourceSize.height: 32
                                        asynchronous: true; cache: true
                                        visible: row.modelData.avatarPath !== ""
                                    }
                                    Label {
                                        anchors.centerIn: parent
                                        text: "👤"; font.pixelSize: 16
                                        visible: row.modelData.avatarPath === ""
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 0
                                    RowLayout {
                                        spacing: 6
                                        Label {
                                            text: row.modelData.fullName
                                            color: "#0f172a"; font.bold: true
                                            elide: Label.ElideRight
                                        }
                                        Rectangle {
                                            visible: row.modelData.isLeader
                                            Layout.preferredHeight: 18
                                            Layout.preferredWidth: leaderBadge.implicitWidth + 12
                                            radius: 4
                                            color: "#fef3c7"
                                            border.color: "#f59e0b"; border.width: 1
                                            Label {
                                                id: leaderBadge
                                                anchors.centerIn: parent
                                                text: "👑 Leader"
                                                color: "#92400e"; font.pixelSize: 10; font.bold: true
                                            }
                                        }
                                    }
                                    Label {
                                        text: "@" + row.modelData.username
                                        color: "#64748b"; font.pixelSize: 11
                                    }
                                }
                            }

                            Label {
                                Layout.preferredWidth: 110
                                text: row.modelData.totalHours.toFixed(2) + "h"
                                color: "#0891b2"; font.bold: true
                                horizontalAlignment: Text.AlignRight
                            }
                            Label {
                                Layout.preferredWidth: 90
                                text: row.modelData.daysCheckedIn + "/25"
                                color: "#7c3aed"
                                horizontalAlignment: Text.AlignRight
                            }
                            Label {
                                Layout.preferredWidth: 110
                                text: row.modelData.attendanceRate + "%"
                                color: "#16a34a"
                                horizontalAlignment: Text.AlignRight
                            }
                            Label {
                                Layout.preferredWidth: 100
                                text: row.modelData.avgPerDay.toFixed(2) + "h"
                                color: "#dc2626"
                                horizontalAlignment: Text.AlignRight
                            }
                        }
                    }
                }
            }
        }

        Label {
            text: "💡 Click vào tiêu đề cột để sắp xếp"
            color: "#94a3b8"; font.pixelSize: 11; font.italic: true
        }
    }
}