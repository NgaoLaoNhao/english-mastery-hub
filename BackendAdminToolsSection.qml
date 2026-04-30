import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: root
    Layout.fillWidth: true
    spacing: 12

    property var auth: null
    property var adminUser: null
    property var adminGroup: null
    property var checkin: null
    property var resource: null

    signal openAdminPanelRequested()

    readonly property bool isAdmin: auth && auth.currentRole === "admin"
    visible: isAdmin
    Layout.preferredHeight: isAdmin ? implicitHeight : 0

    BannerHero {
        Layout.fillWidth: true
        title: "🛠 BACKEND ADMIN TOOLS"
        subtitle: "Khu vực quản trị — chỉ admin nhìn thấy"
        emoji: "🛠"
        colorStart: "#0f172a"
        colorMid:   "#1e3a8a"
        colorEnd:   "#0891b2"
        height: 100
    }

    // Stats grid 4 cards
    GridLayout {
        Layout.fillWidth: true
        columns: 4
        columnSpacing: 12
        rowSpacing: 12

        Repeater {
            model: [
                { icon: "👤", label: "Người dùng", value: (adminUser && adminUser.users)        ? adminUser.users.length        : 0, color: "#3b82f6" },
                { icon: "👥", label: "Nhóm",       value: (adminGroup && adminGroup.groups)     ? adminGroup.groups.length      : 0, color: "#10b981" },
                { icon: "✅", label: "Check-in",   value: (checkin && checkin.checkins)         ? checkin.checkins.length        : 0, color: "#f59e0b" },
                { icon: "📚", label: "Tài liệu",   value: (resource && resource.resources)      ? resource.resources.length      : 0, color: "#a855f7" }
            ]
            delegate: Rectangle {
                required property var modelData
                Layout.fillWidth: true
                Layout.preferredHeight: 88
                radius: 10
                color: "white"
                border.color: "#e2e8f0"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    Rectangle {
                        Layout.preferredWidth: 56
                        Layout.preferredHeight: 56
                        radius: 28
                        color: Qt.lighter(modelData.color, 1.85)
                        Label {
                            anchors.centerIn: parent
                            text: modelData.icon
                            font.pixelSize: 26
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        Label {
                            text: modelData.value
                            font.pixelSize: 24
                            font.bold: true
                            color: "#0f172a"
                        }
                        Label {
                            text: modelData.label
                            color: "#64748b"
                            font.pixelSize: 12
                        }
                    }
                }
            }
        }
    }

    // Quick action buttons
    RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: 4
        spacing: 10

        Button {
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            text: "🧑‍💼  Quản lý người dùng"
            onClicked: root.openAdminPanelRequested()
        }
        Button {
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            text: "👥  Quản lý nhóm"
            onClicked: root.openAdminPanelRequested()
        }
        Button {
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            text: "⚙️  Cài đặt ứng dụng"
            onClicked: root.openAdminPanelRequested()
        }
    }

    // Activity log placeholder
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 80
        Layout.topMargin: 4
        radius: 10
        color: "#f8fafc"
        border.color: "#cbd5e1"
        border.width: 1

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 4
            Label {
                text: "📋  Nhật ký hoạt động"
                font.pixelSize: 14
                font.bold: true
                color: "#475569"
                Layout.alignment: Qt.AlignHCenter
            }
            Label {
                text: "Sẽ ra mắt ở M11 — ActivityLogger"
                color: "#94a3b8"
                font.pixelSize: 11
                font.italic: true
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}