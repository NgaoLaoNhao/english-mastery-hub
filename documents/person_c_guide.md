# 🤖 Hướng Dẫn Chi Tiết Cho Người C + Phân Tích Lỗi test.py

## PHẦN 1: Phân Tích Lỗi `test.py`

### File hiện tại có 3 BUG nghiêm trọng

```python
# test.py HIỆN TẠI (có bug)
from google import genai                          # ← BUG 1
client = genai.Client(api_key=os.environ["GEMINI_API_KEY"])  # ← BUG 2
MODEL = "models/gemini-2-"                        # ← BUG 3
```

---

### BUG 1: Biến môi trường KHÔNG TỒN TẠI trong session hiện tại

**Chẩn đoán:**
- `$env:GEMINI_API_KEY` trong session hiện tại → **trống rỗng** ❌
- `[Environment]::GetEnvironmentVariable("GEMINI_API_KEY", "User")` → `AIzaSy...` ✅
- `[Environment]::GetEnvironmentVariable("GEMINI_API_KEY", "Machine")` → **trống** ❌

**Nguyên nhân:** Bạn đã set biến ở level **User** (registry), nhưng **session PowerShell/terminal hiện tại chưa được restart** để nhận giá trị mới. `os.environ["GEMINI_API_KEY"]` đọc từ session hiện tại → `KeyError`.

**Cách fix:**

```powershell
# Cách 1: ĐÓNG và MỞ LẠI terminal PowerShell hoàn toàn
# (bắt buộc để load biến User-level mới)

# Cách 2: Set tạm trong session hiện tại
$env:GEMINI_API_KEY = "AIzaSyCbi5UNzq_JvYiJU4xe4MTmIvQwxNXkGH0"

# Cách 3: Set cả 2 level (User + session) cùng lúc
[Environment]::SetEnvironmentVariable("GEMINI_API_KEY", "AIzaSyCbi5UNzq_JvYiJU4xe4MTmIvQwxNXkGH0", "User")
$env:GEMINI_API_KEY = [Environment]::GetEnvironmentVariable("GEMINI_API_KEY", "User")
```

> [!IMPORTANT]
> **`setx` hoặc `SetEnvironmentVariable("User")` chỉ ảnh hưởng session MỚI.** Session đang mở KHÔNG tự cập nhật. Đây là lý do bạn gặp lỗi dù đã set biến.

---

### BUG 2: Sai SDK — `google.genai` vs `google.generativeai`

Bạn cài **2 package khác nhau**:

| Package | Phiên bản | Import | API style |
|---|---|---|---|
| `google-genai` | 1.73.1 | `from google import genai` | **Mới** — `genai.Client()` |
| `google-generativeai` | 0.8.6 | `import google.generativeai as genai` | **Cũ** — `genai.configure()` + `GenerativeModel()` |

File `test.py` dùng SDK **mới** (`google.genai`), nhưng file `person_c_ai_integration.md` hướng dẫn dùng SDK **cũ** (`google.generativeai`).

**Cả 2 cách đều hoạt động**, nhưng bạn phải chọn **1 cách** và dùng nhất quán.

---

### BUG 3: Tên model sai

```python
MODEL = "models/gemini-2-"  # ← THIẾU tên model đầy đủ!
```

Tên model hợp lệ phải là: `gemini-2.0-flash`, `gemini-1.5-flash`, `gemini-1.5-pro`, v.v.

---

### File `test.py` đã fix hoàn chỉnh

```python
# test.py — ĐÃ FIX
from google import genai
import os, time, random

# Lấy API key từ biến môi trường
api_key = os.environ.get("GEMINI_API_KEY")
if not api_key:
    print("❌ GEMINI_API_KEY chưa được set trong session này!")
    print("   Chạy: $env:GEMINI_API_KEY = 'YOUR_KEY'")
    exit(1)

client = genai.Client(api_key=api_key)
MODEL = "gemini-2.0-flash"  # ← tên model đúng

def generate_with_retry(prompt: str, max_retries=6):
    for attempt in range(max_retries):
        try:
            return client.models.generate_content(model=MODEL, contents=prompt)
        except Exception as e:
            msg = str(e)
            if "503" in msg or "UNAVAILABLE" in msg:
                sleep_s = min(30, (2 ** attempt)) + random.uniform(0, 0.5)
                print(f"Model busy (503). Retry in {sleep_s:.1f}s...")
                time.sleep(sleep_s)
                continue
            raise
    raise RuntimeError("Retry failed: model vẫn quá tải.")

resp = generate_with_retry("Hello, xin chào!")
print(resp.text)
```

---

## PHẦN 2: Hướng Dẫn Thực Hiện Công Việc Người C

### Ngày 1: Viết `scripts/gemini_bridge.py`

#### Bước 1.1 — Tạo thư mục + file

```powershell
# Set API key cho session hiện tại
$env:GEMINI_API_KEY = "AIzaSyCbi5UNzq_JvYiJU4xe4MTmIvQwxNXkGH0"

# Tạo thư mục scripts
mkdir f:\Project_BTL\english-mastery-hub\scripts
```

#### Bước 1.2 — Viết `gemini_bridge.py`

Tạo file `f:\Project_BTL\english-mastery-hub\scripts\gemini_bridge.py`:

```python
import sys, json, argparse
from google import genai

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--mode", choices=["warn", "analyze", "summarize", "chat"], required=True)
    parser.add_argument("--data", required=True)
    parser.add_argument("--api-key", required=True)
    args = parser.parse_args()

    client = genai.Client(api_key=args.api_key)
    MODEL = "gemini-2.0-flash"

    prompts = {
        "warn": (
            "Hãy viết 1 lời nhắc nhở hài hước bằng tiếng Việt, "
            "giọng điệu thân thiện nhưng nghiêm khắc, tối đa 2 câu. "
            f"Thông tin: {args.data}"
        ),
        "analyze": (
            "Phân tích tiến độ học tập tiếng Anh dựa trên dữ liệu sau "
            "và đề xuất lộ trình ngày mai (Bookworm + Ministory). "
            f"Dữ liệu: {args.data}"
        ),
        "summarize": (
            "Tóm tắt tài liệu tiếng Anh sau, trích xuất từ vựng khó "
            "và giải thích ngữ pháp quan trọng. "
            f"Nội dung: {args.data}"
        ),
        "chat": args.data,
    }

    try:
        response = client.models.generate_content(
            model=MODEL, contents=prompts[args.mode]
        )
        print(json.dumps({"ok": True, "text": response.text}, ensure_ascii=False))
    except Exception as e:
        print(json.dumps({"ok": False, "error": str(e)}, ensure_ascii=False))
        sys.exit(1)

if __name__ == "__main__":
    main()
```

> [!IMPORTANT]
> **Khác với `person_c_ai_integration.md`:** File markdown gốc dùng SDK cũ (`google.generativeai`). Code trên dùng SDK mới (`google.genai`) vì bạn đã cài sẵn `google-genai v1.73.1`.

#### Bước 1.3 — Test từng mode

```powershell
# Đảm bảo API key đã set
$env:GEMINI_API_KEY = "AIzaSyCbi5UNzq_JvYiJU4xe4MTmIvQwxNXkGH0"

# Test chat
python f:\Project_BTL\english-mastery-hub\scripts\gemini_bridge.py --mode chat --data "Hello, how are you?" --api-key $env:GEMINI_API_KEY

# Test warn (KV1)
python f:\Project_BTL\english-mastery-hub\scripts\gemini_bridge.py --mode warn --data "Phúc Tiền đã lười biếng 3 ngày" --api-key $env:GEMINI_API_KEY

# Test analyze (KV2)
python f:\Project_BTL\english-mastery-hub\scripts\gemini_bridge.py --mode analyze --data '{"bookworm": [1,2,0,3], "ministory": [0.5,1,0,1.5]}' --api-key $env:GEMINI_API_KEY

# Test summarize (KV5)
python f:\Project_BTL\english-mastery-hub\scripts\gemini_bridge.py --mode summarize --data "The quick brown fox jumps over the lazy dog" --api-key $env:GEMINI_API_KEY
```

**Kết quả mong đợi:** Mỗi lệnh trả JSON `{"ok": true, "text": "..."}`.

---

### Ngày 2: Viết `GeminiController` (C++)

#### Bước 2.1 — Tạo `core/geminicontroller.h`

```cpp
#ifndef GEMINICONTROLLER_H
#define GEMINICONTROLLER_H

#include <QObject>
#include <QString>

class GeminiController : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY loadingChanged)
    Q_PROPERTY(QString lastResponse READ lastResponse NOTIFY responseReceived)
public:
    explicit GeminiController(QObject *parent = nullptr);

    Q_INVOKABLE void askGemini(const QString &prompt);
    Q_INVOKABLE void analyzeProgress(const QString &dataJson);
    Q_INVOKABLE void summarizeResource(const QString &content);
    Q_INVOKABLE void generateWarning(const QString &name, int lazyDays);

    bool isLoading() const { return m_isLoading; }
    QString lastResponse() const { return m_lastResponse; }

signals:
    void responseReceived(const QString &text);
    void errorOccurred(const QString &error);
    void loadingChanged();

private:
    void runPythonBridge(const QString &mode, const QString &data);
    QString m_apiKey;
    QString m_lastResponse;
    bool m_isLoading = false;
};

#endif
```

#### Bước 2.2 — Tạo `core/geminicontroller.cpp`

```cpp
#include "geminicontroller.h"
#include <QProcess>
#include <QJsonDocument>
#include <QJsonObject>
#include <QCoreApplication>
#include <QDebug>

GeminiController::GeminiController(QObject *parent) : QObject(parent) {
    m_apiKey = qEnvironmentVariable("GEMINI_API_KEY");
    if (m_apiKey.isEmpty())
        qWarning() << "GEMINI_API_KEY not set!";
}

void GeminiController::runPythonBridge(const QString &mode, const QString &data) {
    m_isLoading = true;
    emit loadingChanged();

    auto *proc = new QProcess(this);
    QString scriptPath = QCoreApplication::applicationDirPath() + "/scripts/gemini_bridge.py";

    connect(proc, &QProcess::finished, this, [this, proc](int exitCode) {
        m_isLoading = false;
        emit loadingChanged();

        auto output = proc->readAllStandardOutput();
        auto doc = QJsonDocument::fromJson(output).object();

        if (exitCode == 0 && doc["ok"].toBool()) {
            m_lastResponse = doc["text"].toString();
            emit responseReceived(m_lastResponse);
        } else {
            QString err = doc["error"].toString();
            if (err.isEmpty()) err = proc->readAllStandardError();
            emit errorOccurred(err);
        }
        proc->deleteLater();
    });

    proc->start("python", {scriptPath, "--mode", mode, "--data", data, "--api-key", m_apiKey});
}

void GeminiController::askGemini(const QString &prompt) {
    runPythonBridge("chat", prompt);
}
void GeminiController::generateWarning(const QString &name, int lazyDays) {
    runPythonBridge("warn", QString("%1 đã lười biếng %2 ngày").arg(name).arg(lazyDays));
}
void GeminiController::analyzeProgress(const QString &dataJson) {
    runPythonBridge("analyze", dataJson);
}
void GeminiController::summarizeResource(const QString &content) {
    runPythonBridge("summarize", content);
}
```

#### Bước 2.3 — Thêm vào CMakeLists.txt

Thêm 2 dòng vào phần `SOURCES`:
```cmake
SOURCES
    core/databasemanager.h
    core/databasemanager.cpp
    core/geminicontroller.h      # ← THÊM
    core/geminicontroller.cpp    # ← THÊM
    controllers/authcontroller.h
    controllers/authcontroller.cpp
```

---

### Ngày 3: Viết `AiDrawer.qml`

Tạo file `AiDrawer.qml` tại root (theo convention hiện tại của dự án):

```qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    // Floating Action Button (góc phải dưới)
    Rectangle {
        id: aiFab; width: 56; height: 56; radius: 28
        anchors { right: parent.right; bottom: parent.bottom; margins: 20 }
        color: hovered ? "#5a9bf4" : "#4285F4"
        z: 100
        property bool hovered: false

        Text { text: "🤖"; anchors.centerIn: parent; font.pixelSize: 24 }
        MouseArea {
            anchors.fill: parent; hoverEnabled: true
            onEntered: parent.hovered = true
            onExited: parent.hovered = false
            onClicked: aiDrawer.open()
        }

        SequentialAnimation on scale {
            loops: Animation.Infinite
            NumberAnimation { to: 1.05; duration: 1000; easing.type: Easing.InOutSine }
            NumberAnimation { to: 1.0; duration: 1000; easing.type: Easing.InOutSine }
        }
    }

    // Side Drawer
    Drawer {
        id: aiDrawer; edge: Qt.RightEdge; width: 380
        background: Rectangle { color: "#1a1a2e" }

        ColumnLayout {
            anchors.fill: parent; anchors.margins: 16; spacing: 12

            RowLayout {
                Text { text: "🤖 AI Assistant"; color: "white"; font { pixelSize: 20; bold: true }; Layout.fillWidth: true }
                Button { text: "✕"; flat: true; onClicked: aiDrawer.close()
                    contentItem: Text { text: "✕"; color: "#aaa"; font.pixelSize: 16 }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#333" }

            ScrollView {
                Layout.fillWidth: true; Layout.fillHeight: true
                TextArea {
                    text: geminiController.lastResponse
                    readOnly: true; wrapMode: TextArea.WordWrap
                    color: "white"; font.pixelSize: 14
                    background: Rectangle { color: "#16213e"; radius: 8 }
                }
            }

            BusyIndicator {
                running: geminiController.isLoading
                Layout.alignment: Qt.AlignHCenter
                visible: running
            }

            Text { id: errorText; color: "#e94560"; visible: false; Layout.fillWidth: true; wrapMode: Text.WordWrap }

            RowLayout { Layout.fillWidth: true; spacing: 8
                Button { text: "📊 Tiến độ"; Layout.fillWidth: true
                    onClicked: geminiController.analyzeProgress("{}")
                }
                Button { text: "📚 Tóm tắt"; Layout.fillWidth: true
                    onClicked: geminiController.summarizeResource("sample text")
                }
            }

            RowLayout { Layout.fillWidth: true
                TextField {
                    id: promptField; Layout.fillWidth: true
                    placeholderText: "Hỏi AI bất cứ điều gì..."
                    color: "white"
                    background: Rectangle { color: "#16213e"; radius: 8; border.color: "#0f3460" }
                    Keys.onReturnPressed: sendButton.clicked()
                }
                Button {
                    id: sendButton; text: "Gửi"
                    onClicked: {
                        if (promptField.text.length > 0) {
                            geminiController.askGemini(promptField.text)
                            promptField.text = ""
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: geminiController
        function onErrorOccurred(error) { errorText.text = "❌ " + error; errorText.visible = true }
        function onResponseReceived() { errorText.visible = false }
    }
}
```

Thêm vào `CMakeLists.txt` phần `QML_FILES`:
```cmake
QML_FILES
    ...
    AiDrawer.qml    # ← THÊM
```

---

## Tóm Tắt Checklist Người C

| Ngày | Việc | File tạo | Test bằng |
|:---:|---|---|---|
| **1** | Python bridge | `scripts/gemini_bridge.py` | Chạy 4 lệnh PowerShell ở mục 1.3 |
| **2** | C++ controller | `core/geminicontroller.h/cpp` | Build project, kiểm tra compile OK |
| **3** | QML drawer | `AiDrawer.qml` | Gắn vào WelcomeView tạm để xem UI |
| 4-6 | Chờ A+B xong Dashboard | — | — |
