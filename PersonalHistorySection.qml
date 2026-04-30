import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Item {
    id: root
    property var personal: null
    property int userId: -1

    // "date_desc" | "date_asc" | "total_desc" | "total_asc"
    property string sortMode: "date_desc"

    readonly property var rawHistory: personal && userId > 0
                                      ? personal.getMyHistory(userId) : []

    readonly property var sortedHistory: {
        var rows = rawHistory.slice()
        for (var i = 0; i < rows.length; i++) {
            var c = rows[i]
            rows[i] = Object.assign({}, c, {
                _total: (c.listening || 0) + (c.speaking || 0) + (c.reading || 0)
                      + (c.writing   || 0) + (c.vocabulary || 0)
            })
        }
        if (sortMode === "date_desc")  rows.sort(function(a,b){ return a.date < b.date ? 1 : -1 })
        if (sortMode === "date_asc")   rows.sort(function(a,b){ return a.date < b.date ? -1 : 1 })
        if (sortMode === "total_desc") rows.sort(function(a,b){ return b._total - a._total })
        if (sortMode === "total_asc")  rows.sort(function(a,b){ return a._total - b._total })
        return rows
    }

    function _weekday(ymd) {
        var dt = new Date(ymd)
        var names = ["CN", "T2", "T3", "T4", "T5", "T6", "T7"]
        return names[dt.getDay()]
    }

    function _toggle(modeBase) {
        if (sortMode === modeBase + "_desc") sortMode = modeBase + "_asc"
        else sortMode = modeBase + "_desc"
    }
    function _arrow(modeBase) {
        if (sortMode === modeBase + "_desc") return " ▼"
        if (sortMode === modeBase + "_asc")  return " ▲"
        return ""
    }

    implicitHeight: contentCol.implicitHeight

    ColumnLayout {
        id: contentCol
        width: parent.width
        spacing: 10

        // Tiêu đề + count
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Label {
                text: "📋 Lịch sử check-in"
                font.pixelSize: 18; font.bold: true
                color: "#0f172a"
            }
            Item { Layout.fillWidth: true }
            Label {
                text: sortedHistory.length + " ngày"
                color: "#64748b"; font.pixelSize: 12
            }
        }

        // Khung bảng
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: contentInner.implicitHeight + 2
            radius: 8
            color: "white"
            border.color: "#e2e8f0"; border.width: 1
            clip: true

            Column {
                id: contentInner
                width: parent.width
                spacing: 0

                // ===== HEADER ROW =====
                Rectangle {
                    width: parent.width
                    height: 38
                    color: "#f1f5f9"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12; anchors.rightMargin: 12
                        spacing: 0

                        Item {
                            Layout.preferredWidth: 130
                            Layout.fillHeight: true
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root._toggle("date")
                            }
                            Label {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                text: "Ngày" + root._arrow("date")
                                font.bold: true; color: "#334155"
                            }
                        }

                        Label { Layout.preferredWidth: 50; text: "Thứ"; font.bold: true; color: "#334155" }
                        Label { Layout.fillWidth: true; text: "🎧 Nghe";    font.bold: true; color: "#334155"; horizontalAlignment: Text.AlignRight }
                        Label { Layout.fillWidth: true; text: "🗣️ Nói";     font.bold: true; color: "#334155"; horizontalAlignment: Text.AlignRight }
                        Label { Layout.fillWidth: true; text: "📖 Đọc";     font.bold: true; color: "#334155"; horizontalAlignment: Text.AlignRight }
                        Label { Layout.fillWidth: true; text: "✍️ Viết";    font.bold: true; color: "#334155"; horizontalAlignment: Text.AlignRight }
                        Label { Layout.fillWidth: true; text: "📝 Từ vựng"; font.bold: true; color: "#334155"; horizontalAlignment: Text.AlignRight }

                        Item {
                            Layout.preferredWidth: 90
                            Layout.fillHeight: true
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root._toggle("total")
                            }
                            Label {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                text: "Tổng" + root._arrow("total")
                                font.bold: true; color: "#0f172a"
                            }
                        }
                    }
                }

                // ===== EMPTY STATE =====
                Rectangle {
                    width: parent.width
                    height: 80
                    visible: sortedHistory.length === 0
                    color: "transparent"
                    Label {
                        anchors.centerIn: parent
                        text: "Chưa có ngày check-in nào."
                        color: "#94a3b8"; font.italic: true
                    }
                }

                // ===== DATA ROWS (Repeater thay vì ListView) =====
                Repeater {
                    model: sortedHistory
                    delegate: Rectangle {
                        required property var modelData
                        required property int index
                        width: contentInner.width
                        height: 36
                        color: index % 2 === 0 ? "white" : "#f8fafc"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12; anchors.rightMargin: 12
                            spacing: 0

                            Label { Layout.preferredWidth: 130; text: modelData.date; color: "#0f172a" }
                            Label {
                                Layout.preferredWidth: 50
                                text: root._weekday(modelData.date)
                                color: {
                                    var d = new Date(modelData.date).getDay()
                                    return (d === 0 || d === 6) ? "#dc2626" : "#475569"
                                }
                            }
                            Label { Layout.fillWidth: true; text: (modelData.listening  || 0).toFixed(1); color: "#1d4ed8"; horizontalAlignment: Text.AlignRight }
                            Label { Layout.fillWidth: true; text: (modelData.speaking   || 0).toFixed(1); color: "#b45309"; horizontalAlignment: Text.AlignRight }
                            Label { Layout.fillWidth: true; text: (modelData.reading    || 0).toFixed(1); color: "#15803d"; horizontalAlignment: Text.AlignRight }
                            Label { Layout.fillWidth: true; text: (modelData.writing    || 0).toFixed(1); color: "#be185d"; horizontalAlignment: Text.AlignRight }
                            Label { Layout.fillWidth: true; text: (modelData.vocabulary || 0).toFixed(1); color: "#6d28d9"; horizontalAlignment: Text.AlignRight }
                            Label {
                                Layout.preferredWidth: 90
                                text: ((modelData.listening||0)+(modelData.speaking||0)+(modelData.reading||0)+(modelData.writing||0)+(modelData.vocabulary||0)).toFixed(1) + "h"
                                color: "#0f172a"; font.bold: true
                                horizontalAlignment: Text.AlignRight
                            }
                        }
                    }
                }
            }
        }

        // Hint
        Label {
            text: "💡 Click vào tiêu đề \"Ngày\" hoặc \"Tổng\" để sắp xếp"
            color: "#94a3b8"; font.pixelSize: 11; font.italic: true
        }
    }
}