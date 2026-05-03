import QtQuick

QtObject {
    id: mockGemini

    property bool isLoading: false
    property string lastResponse: ""

    signal responseReceived(string text)
    signal errorOccurred(string error)

    function askGemini(prompt) {
        isLoading = true; lastResponse = ""
        _timer.mode = "chat"; _timer.prompt = prompt; _timer.start()
    }

    function generateWarning(name, lazyDays) {
        isLoading = true; lastResponse = ""
        _timer.mode = "warn"; _timer.prompt = name; _timer.start()
    }

    function analyzeProgress(dataJson) {
        isLoading = true; lastResponse = ""
        _timer.mode = "analyze"; _timer.prompt = dataJson; _timer.start()
    }

    function summarizeResource(content) {
        isLoading = true; lastResponse = ""
        _timer.mode = "summarize"; _timer.prompt = content; _timer.start()
    }

    property Timer _timer: Timer {
        property string mode: ""
        property string prompt: ""
        interval: 800; repeat: false
        onTriggered: {
            mockGemini.isLoading = false

            var warnMessages = [
                "⚠️ Ê " + prompt + " ơi! Sách tiếng Anh đang khóc vì nhớ bạn rồi đó! 📚😢\nHãy quay lại check-in ngay trước khi bị đưa lên Bảng Truy Nã vĩnh viễn nhé!",
                "🚨 " + prompt + " à, " + "bạn nghĩ trốn check-in là vui sao? AI này theo dõi 24/7 đó nha! 👀\nMở sách lên, học 30 phút rồi check-in — không khó lắm đâu!",
                "😤 " + prompt + "! Lười biếng quá rồi! Streak sắp mất hết!\n📖 Mở Bookworm ngay, đọc 1 chương thôi cũng được. Đừng để AI phải nhắc lần nữa nha!"
            ]

            var analyzeMessages = [
                "📊 **Phân tích tiến độ học tập:**\n\n"
                + "✅ Điểm mạnh: Bạn duy trì check-in khá đều đặn, thể hiện sự kiên trì tốt.\n"
                + "⚠️ Cần cải thiện: Thời gian học Ministory còn thấp so với Bookworm.\n\n"
                + "📋 **Lộ trình đề xuất cho ngày mai:**\n"
                + "• Bookworm: 1.5 giờ (đọc chương mới + ghi chú từ vựng)\n"
                + "• Ministory: 1 giờ (nghe 2 episode + shadowing)\n"
                + "• Mục tiêu: Tăng tỷ lệ chuyên cần lên 85%",

                "📈 **Báo cáo AI — Tiến độ học tiếng Anh:**\n\n"
                + "🔥 Streak hiện tại: Tốt! Hãy giữ vững phong độ.\n"
                + "📖 Bookworm: Ổn định, trung bình 1.2h/ngày.\n"
                + "🎧 Ministory: Cần tăng lên ít nhất 0.8h/ngày.\n\n"
                + "💡 **Gợi ý:** Thử phương pháp Pomodoro — học 25 phút, nghỉ 5 phút.\n"
                + "Kết hợp nghe Ministory trong khi di chuyển để tận dụng thời gian."
            ]

            var summarizeMessages = [
                "📝 **Tóm tắt tài liệu:**\n\n"
                + "📌 Nội dung chính:\n"
                + "• Tài liệu trình bày các cấu trúc ngữ pháp quan trọng cho trình độ B1-B2\n"
                + "• Bao gồm bài tập thực hành với đáp án chi tiết\n\n"
                + "📚 Từ vựng khó cần ghi nhớ:\n"
                + "• \"Proficiency\" (n.) — Sự thành thạo\n"
                + "• \"Comprehension\" (n.) — Sự hiểu biết, đọc hiểu\n"
                + "• \"Consolidate\" (v.) — Củng cố kiến thức\n\n"
                + "💡 Ngữ pháp quan trọng: Present Perfect Continuous, Conditional Type 2-3",

                "📝 **AI Tóm tắt nhanh:**\n\n"
                + "Tài liệu tập trung vào kỹ năng Listening và Reading.\n"
                + "• Phần 1: Chiến lược nghe hiểu — keyword spotting, note-taking\n"
                + "• Phần 2: Đọc hiểu nâng cao — skimming vs scanning\n\n"
                + "🔑 Từ vựng trọng tâm:\n"
                + "• \"Infer\" (v.) — Suy luận\n"
                + "• \"Elaborate\" (v./adj.) — Giải thích chi tiết / Phức tạp\n"
                + "• \"Coherent\" (adj.) — Mạch lạc, logic"
            ]

            var chatMessages = [
                "🤖 Xin chào! Tôi là AI trợ lý của English Mastery Hub.\n\n"
                + "Tôi có thể giúp bạn:\n"
                + "• 📊 Phân tích tiến độ học tập\n"
                + "• ⚠️ Nhắc nhở check-in\n"
                + "• 📝 Tóm tắt tài liệu tiếng Anh\n\n"
                + "Hãy sử dụng các nút AI trên dashboard để bắt đầu nhé! 💪"
            ]

            var responses = {
                "chat": chatMessages[Math.floor(Math.random() * chatMessages.length)],
                "warn": warnMessages[Math.floor(Math.random() * warnMessages.length)],
                "analyze": analyzeMessages[Math.floor(Math.random() * analyzeMessages.length)],
                "summarize": summarizeMessages[Math.floor(Math.random() * summarizeMessages.length)]
            }

            mockGemini.lastResponse = responses[mode] || responses["chat"]
            mockGemini.responseReceived(mockGemini.lastResponse)
        }
    }
}
