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
        isLoading = true
        _timer.mode = "warn"; _timer.prompt = name + " lười " + lazyDays + " ngày"; _timer.start()
    }

    function analyzeProgress(dataJson) {
        isLoading = true
        _timer.mode = "analyze"; _timer.prompt = dataJson; _timer.start()
    }

    function summarizeResource(content) {
        isLoading = true
        _timer.mode = "summarize"; _timer.prompt = content; _timer.start()
    }

    property Timer _timer: Timer {
        property string mode: ""
        property string prompt: ""
        interval: 1500; repeat: false
        onTriggered: {
            mockGemini.isLoading = false
            var responses = {
                "chat": "🤖 [Mock] Xin chào! Tôi là AI trợ lý English Mastery Hub.",
                "warn": "⚠️ [Mock] Bạn ơi, " + prompt + "! Hãy quay lại học ngay nào! 📚",
                "analyze": "📊 [Mock] Tiến độ tốt! Ngày mai nên tập trung Listening 1h + Reading 1h.",
                "summarize": "📝 [Mock] Tóm tắt: Nội dung chính về ngữ pháp và từ vựng cần ghi nhớ..."
            }
            mockGemini.lastResponse = responses[mode] || responses["chat"]
            mockGemini.responseReceived(mockGemini.lastResponse)
        }
    }
}
