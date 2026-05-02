import QtQuick

QtObject {
    property string announcement: "Hôm nay là ngày 16/25 của thử thách. Cố lên các bạn! 💪"
    property string importantDocsLabel: "📚 Tài liệu chương 2 — Cambridge B1"
    property string importantDocsUrl: "https://example.com/docs"

    signal settingsChanged()

    function updateAnnouncement(text) {
        announcement = text
        settingsChanged()
    }
    function updateImportantDocs(label, url) {
        importantDocsLabel = label
        importantDocsUrl = url
        settingsChanged()
    }
}