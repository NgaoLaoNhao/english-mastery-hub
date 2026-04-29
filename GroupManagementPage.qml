import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Item {
    id: root
    property var adminGroup: null
    property var adminUser: null   // dùng để hiển thị tên trưởng nhóm + chọn leader

    function leaderName(leaderId) {
        if (leaderId === -1 || !adminUser) return "—"
        const u = adminUser.getUser(leaderId)
        return u ? (u.fullName || u.username) : "(đã xoá)"
    }

    function buildLeaderModel() {
        var list = [{ id: -1, label: "(chưa gán)" }]
        if (!adminUser) return list
        for (var i = 0; i < adminUser.users.length; i++) {
            var u = adminUser.users[i]
            list.push({ id: u.id, label: (u.fullName || u.username) + " (" + u.username + ")" })
        }
        return list
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        // Toolbar
        RowLayout {
            Layout.fillWidth: true
            Button {
                text: "➕ Tạo nhóm"
                highlighted: true
                onClicked: createGroupDialog.open()
            }
            Item { Layout.fillWidth: true }
            Label {
                text: "Tổng: " + (adminGroup ? adminGroup.groups.length : 0) + " nhóm"
                color: "#666"
            }
        }

        // Table
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#fafafa"
            border.color: "#ddd"
            border.width: 1

            ListView {
                anchors.fill: parent
                anchors.margins: 1
                clip: true
                model: adminGroup ? adminGroup.groups : []

                header: Rectangle {
                    width: ListView.view.width
                    height: 38
                    color: "#e8e8e8"
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8
                        Label { text: "ID"; Layout.preferredWidth: 40; font.bold: true }
                        Label { text: "Tên nhóm"; Layout.preferredWidth: 200; font.bold: true }
                        Label { text: "Trưởng nhóm"; Layout.preferredWidth: 220; font.bold: true }
                        Label { text: "Hành động"; Layout.fillWidth: true; font.bold: true }
                    }
                }

                delegate: Rectangle {
                    width: ListView.view.width
                    height: 44
                    color: index % 2 === 0 ? "#fff" : "#f7f7f7"
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8
                        Label { text: modelData.id; Layout.preferredWidth: 40 }
                        Label { text: modelData.name; Layout.preferredWidth: 200 }
                        Label { text: root.leaderName(modelData.leaderUserId); Layout.preferredWidth: 220 }
                        RowLayout {
                            spacing: 4
                            Layout.fillWidth: true
                            Button {
                                text: "✏️"; implicitWidth: 36
                                onClicked: {
                                    editGroupDialog.targetGroup = modelData
                                    editGroupDialog.open()
                                }
                            }
                            Button {
                                text: "🗑️"; implicitWidth: 36
                                onClicked: {
                                    confirmGroupDelete.targetId = modelData.id
                                    confirmGroupDelete.message = "Xoá nhóm '" + modelData.name + "'?"
                                    confirmGroupDelete.open()
                                }
                            }
                            Item { Layout.fillWidth: true }
                        }
                    }
                }
            }
        }
    }

    // ===== Dialogs =====
    Dialog {
        id: createGroupDialog
        title: "➕ Tạo nhóm mới"
        modal: true; anchors.centerIn: parent; width: 420
        standardButtons: Dialog.NoButton
        onOpened: {
            groupNameField.text = ""
            leaderCombo.model = root.buildLeaderModel()
            leaderCombo.currentIndex = 0
            createGroupError.text = ""
            groupNameField.forceActiveFocus()
        }
        ColumnLayout {
            anchors.fill: parent
            spacing: 10
            Label { text: "Tên nhóm:" }
            TextField { id: groupNameField; Layout.fillWidth: true; placeholderText: "vd: Nhóm Gamma" }
            Label { text: "Trưởng nhóm:" }
            ComboBox {
                id: leaderCombo
                Layout.fillWidth: true
                textRole: "label"
                valueRole: "id"
            }
            Label { id: createGroupError; color: "red"; wrapMode: Text.Wrap; Layout.fillWidth: true; visible: text.length > 0 }
            RowLayout {
                Layout.fillWidth: true; Layout.alignment: Qt.AlignRight
                Button { text: "Huỷ"; onClicked: createGroupDialog.close() }
                Button {
                    text: "Tạo"; highlighted: true
                    onClicked: {
                        createGroupError.text = ""
                        adminGroup.createGroup(groupNameField.text, leaderCombo.currentValue)
                    }
                }
            }
        }
    }

    Dialog {
        id: editGroupDialog
        title: "✏️ Sửa nhóm"
        modal: true; anchors.centerIn: parent; width: 420
        standardButtons: Dialog.NoButton
        property var targetGroup: null
        onOpened: {
            if (targetGroup) {
                editGroupName.text = targetGroup.name
                editLeaderCombo.model = root.buildLeaderModel()
                var idx = 0
                for (var i = 0; i < editLeaderCombo.count; i++) {
                    if (editLeaderCombo.valueAt(i) === targetGroup.leaderUserId) { idx = i; break }
                }
                editLeaderCombo.currentIndex = idx
            }
        }
        ColumnLayout {
            anchors.fill: parent
            spacing: 10
            Label { text: "Tên nhóm:" }
            TextField { id: editGroupName; Layout.fillWidth: true }
            Label { text: "Trưởng nhóm:" }
            ComboBox {
                id: editLeaderCombo
                Layout.fillWidth: true
                textRole: "label"
                valueRole: "id"
            }
            RowLayout {
                Layout.fillWidth: true; Layout.alignment: Qt.AlignRight
                Button { text: "Huỷ"; onClicked: editGroupDialog.close() }
                Button {
                    text: "Lưu"; highlighted: true
                    onClicked: {
                        adminGroup.updateGroup(
                            editGroupDialog.targetGroup.id,
                            editGroupName.text,
                            editLeaderCombo.currentValue
                        )
                        editGroupDialog.close()
                    }
                }
            }
        }
    }

    Dialog {
        id: confirmGroupDelete
        title: "Xoá nhóm?"
        modal: true; anchors.centerIn: parent; width: 380
        standardButtons: Dialog.NoButton
        property string message: ""
        property int targetId: -1
        ColumnLayout {
            anchors.fill: parent
            spacing: 14
            Label { text: confirmGroupDelete.message; wrapMode: Text.Wrap; Layout.fillWidth: true }
            RowLayout {
                Layout.fillWidth: true; Layout.alignment: Qt.AlignRight
                Button { text: "Huỷ"; onClicked: confirmGroupDelete.close() }
                Button {
                    text: "Xoá"; highlighted: true
                    onClicked: {
                        adminGroup.deleteGroup(confirmGroupDelete.targetId)
                        confirmGroupDelete.close()
                    }
                }
            }
        }
    }

    Connections {
        target: root.adminGroup
        function onGroupCreated(id, name) { createGroupDialog.close() }
        function onCreateFailed(reason) { createGroupError.text = reason }
    }
}