import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Item {
    id: root
    property var auth: null
    signal logoutRequested()                       // <-- THÊM
    signal openAdminPanel()
    ColumnLayout {
        anchors.centerIn: parent
        width: 360
        spacing: 14

        Label {
            text: "👋 Xin chào,"
            font.pixelSize: 22
            Layout.alignment: Qt.AlignHCenter
        }

        Label {
            text: auth && auth.currentDisplayName && auth.currentDisplayName.length > 0
                  ? auth.currentDisplayName
                  : (auth ? auth.currentUsername : "")
            font.pixelSize: 28
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }

        Label {
            text: "Vai trò: " + (auth && auth.currentRole === "admin"
                                ? "Quản trị viên 👑"
                                : "Thành viên")
            color: "#666"
            Layout.alignment: Qt.AlignHCenter
        }

        Item { Layout.preferredHeight: 20 }

        Label {
            text: "🚧 Các tính năng khác sẽ được phát triển ở Milestone 2 trở đi."
            color: "#888"
            font.italic: true
            wrapMode: Text.Wrap
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }

        Item { Layout.preferredHeight: 20 }

        Button {
            visible: auth && auth.currentRole === "admin"          // <-- chỉ admin thấy
            text: "🛠 Quản trị"
            Layout.fillWidth: true
            onClicked: root.openAdminPanel()
        }

        Button {
            text: "Đăng xuất"
            Layout.fillWidth: true
            onClicked: root.logoutRequested()
        }
    }
}