import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

ColumnLayout {
    id: root
    property var auth: null
    property var checkin: null
    Layout.fillWidth: true
    spacing: 6

    property var existingCheckin: null

    function _todayDisplay() {
        const d = new Date()
        return String(d.getDate()).padStart(2, '0') + "/"
            + String(d.getMonth() + 1).padStart(2, '0') + "/" + d.getFullYear()
    }
    function refreshExisting() {
        if (!auth || !checkin) return
        existingCheckin = checkin.getTodayCheckin(auth.currentUserId)
    }
    Component.onCompleted: refreshExisting()

    // Banner — clickable
    Item {
        Layout.fillWidth: true
        implicitHeight: banner.implicitHeight

        BannerHero {
            id: banner
            anchors.fill: parent
            emoji: "📋"
            title: "DAILY CHECK-IN"
            subtitle: "Điểm danh học mỗi ngày · ấn để khai báo  ·  " + root._todayDisplay()
            colorStart: "#c0392b"; colorMid: "#e67e22"; colorEnd: "#f1c40f"
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: { root.refreshExisting(); checkinDialog.open() }
        }
    }

    // Status row + button
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 50
        color: "#f8f8f8"
        border.color: "#ddd"; radius: 6
        RowLayout {
            anchors.fill: parent; anchors.margins: 8; spacing: 8

            Rectangle {
                Layout.preferredHeight: 32
                Layout.preferredWidth: statusLabel.implicitWidth + 18
                color: root.existingCheckin ? "#27ae60" : "#7f8c8d"
                radius: 16
                Label {
                    id: statusLabel
                    anchors.centerIn: parent
                    color: "white"; font.pixelSize: 12; font.bold: true
                    text: root.existingCheckin
                        ? "✅ Đã check-in: " + checkin.totalHours(root.existingCheckin).toFixed(2) + "h"
                        : "⏳ Chưa check-in"
                }
            }
            Item { Layout.fillWidth: true }
            Button {
                text: root.existingCheckin ? "✏️ Cập nhật" : "✅ CHECK-IN NGAY"
                highlighted: true
                onClicked: { root.refreshExisting(); checkinDialog.open() }
            }
        }
    }

    // ===== POPUP DIALOG =====
    Dialog {
        id: checkinDialog
        modal: true
        anchors.centerIn: Overlay.overlay
        width: 520
        title: root.existingCheckin
            ? "✏️ Cập nhật check-in — " + root._todayDisplay()
            : "📝 Check-in hôm nay — " + root._todayDisplay()
        standardButtons: Dialog.NoButton

        onOpened: {
            if (root.existingCheckin) {
                listeningField.text = root.existingCheckin.listening.toFixed(2)
                speakingField.text  = root.existingCheckin.speaking.toFixed(2)
                readingField.text   = root.existingCheckin.reading.toFixed(2)
                writingField.text   = root.existingCheckin.writing.toFixed(2)
                vocabField.text     = root.existingCheckin.vocabulary.toFixed(2)
                noteField.text      = root.existingCheckin.note || ""
            } else {
                listeningField.text = "0.00"; speakingField.text = "0.00"
                readingField.text   = "0.00"; writingField.text  = "0.00"
                vocabField.text     = "0.00"; noteField.text     = ""
            }
            errorLabel.text = ""
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 10

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                color: "#fff5d7"; border.color: "#daa520"; radius: 6
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 8; spacing: 2
                    Label {
                        property var p: checkin ? checkin.getChallengeProgress() : null
                        text: p ? ("🏆 Ngày " + p.currentDay + "/" + p.totalDays
                            + (p.remainingDays > 0 ? "  (còn " + p.remainingDays + " ngày)" : "  ✅ Hoàn thành")) : ""
                        font.pixelSize: 13; font.bold: true
                    }
                    ProgressBar {
                        Layout.fillWidth: true
                        property var p: checkin ? checkin.getChallengeProgress() : null
                        from: 0; to: p ? p.totalDays : 25; value: p ? p.currentDay : 0
                    }
                }
            }

            Label { text: "Khai báo số giờ học (max 12/skill):"; color: "#555" }

            GridLayout {
                Layout.fillWidth: true; columns: 4; columnSpacing: 8; rowSpacing: 8

                Label { text: "🎧 Listening:" }
                TextField { id: listeningField; Layout.fillWidth: true; text: "0.00"
                    validator: DoubleValidator { bottom: 0; top: 12; decimals: 2 } }
                Label { text: "🗣 Speaking:" }
                TextField { id: speakingField; Layout.fillWidth: true; text: "0.00"
                    validator: DoubleValidator { bottom: 0; top: 12; decimals: 2 } }

                Label { text: "📖 Reading:" }
                TextField { id: readingField; Layout.fillWidth: true; text: "0.00"
                    validator: DoubleValidator { bottom: 0; top: 12; decimals: 2 } }
                Label { text: "✍ Writing:" }
                TextField { id: writingField; Layout.fillWidth: true; text: "0.00"
                    validator: DoubleValidator { bottom: 0; top: 12; decimals: 2 } }

                Label { text: "🔤 Vocab:" }
                TextField { id: vocabField; Layout.fillWidth: true; text: "0.00"
                    validator: DoubleValidator { bottom: 0; top: 12; decimals: 2 } }
                Item { Layout.fillWidth: true; Layout.columnSpan: 2 }
            }

            Label {
                text: "Tổng: " + (
                    (parseFloat(listeningField.text) || 0) +
                    (parseFloat(speakingField.text)  || 0) +
                    (parseFloat(readingField.text)   || 0) +
                    (parseFloat(writingField.text)   || 0) +
                    (parseFloat(vocabField.text)     || 0)
                ).toFixed(2) + " giờ"
                font.pixelSize: 16; font.bold: true; color: "#2a6"
            }

            Label { text: "Ghi chú (tuỳ chọn):" }
            TextArea {
                id: noteField; Layout.fillWidth: true; Layout.preferredHeight: 60
                placeholderText: "Hôm nay học gì..."; wrapMode: TextArea.Wrap
            }

            Label {
                id: errorLabel; color: "red"; visible: text.length > 0
                wrapMode: Text.Wrap; Layout.fillWidth: true
            }

            RowLayout {
                Layout.fillWidth: true
                Button { text: "Hủy"; onClicked: checkinDialog.close() }
                Item { Layout.fillWidth: true }
                Button {
                    text: root.existingCheckin ? "💾 Cập nhật" : "✅ Lưu check-in"
                    highlighted: true
                    onClicked: {
                        errorLabel.text = ""
                        if (!auth || !checkin) { errorLabel.text = "Lỗi: chưa đăng nhập"; return }
                        checkin.submitCheckin(auth.currentUserId,
                            parseFloat(listeningField.text) || 0,
                            parseFloat(speakingField.text)  || 0,
                            parseFloat(readingField.text)   || 0,
                            parseFloat(writingField.text)   || 0,
                            parseFloat(vocabField.text)     || 0,
                            noteField.text)
                    }
                }
            }
        }
    }

    Connections {
        target: root.checkin
        function onCheckinSubmitted(id, date) { root.refreshExisting(); checkinDialog.close() }
        function onSubmitFailed(reason) { errorLabel.text = reason }
    }
}