import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Item {
    id: root

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
            // Hiện display name nếu có, fallback về username
            text: auth.currentDisplayName.length > 0
                  ? auth.currentDisplayName
                  : auth.currentUsername
            font.pixelSize: 28
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }

        Label {
            text: "Vai trò: " + (auth.currentRole === "admin"
                                 ? "Quản trị viên 👑"
                                 : "Thành viên")
            color: "#666"
            Layout.alignment: Qt.AlignHCenter
        }

        Item { Layout.preferredHeight: 20 }  // Spacer

        Label {
            text: "🚧 Các tính năng khác sẽ được phát triển ở Milestone 2 trở đi."
            color: "#888"
            font.italic: true
            wrapMode: Text.Wrap
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }

        Item { Layout.preferredHeight: 20 }  // Spacer

        Button {
            text: "Đăng xuất"
            Layout.fillWidth: true
            onClicked: auth.logout()
        }
    }
}