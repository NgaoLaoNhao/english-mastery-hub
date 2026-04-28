# 🛠️ Hướng Dẫn Triển Khai Từng Phần Trên Qt Design

Tài liệu hướng dẫn **thực hành từng bước** — từ setup project đến hoàn thành tất cả 5 khu vực giao diện.

---

## Bước 0: Setup Project Trong Qt Creator

### 0.1 Mở Qt Creator → chọn project đã tạo

Dự án đã có scaffold tại `F:\Project_BTL\english-mastery-hub\`. Mở bằng CMakeLists.txt.

### 0.2 Cập nhật [CMakeLists.txt](file:///F:/Project_BTL/english-mastery-hub/CMakeLists.txt)

Thêm các Qt module cần thiết:

```cmake
find_package(Qt6 REQUIRED COMPONENTS Quick Sql Charts Network)
# ...
target_link_libraries(appEnglishMasteryHub
    PRIVATE Qt6::Quick Qt6::Sql Qt6::Charts Qt6::Network
)
```

| Module | Dùng cho |
|---|---|
| `Qt6::Quick` | QML engine, cơ bản |
| `Qt6::Sql` | SQLite database |
| `Qt6::Charts` | Biểu đồ Line/Bar |
| `Qt6::Network` | HTTP call tới Gemini API |

### 0.3 Tạo cây thư mục

Tạo sẵn các folder trong Qt Creator (Right click → Add New → QML File):

```
components/       ← Các file QML component
controllers/      ← Đã có
core/             ← Đã có
models/           ← Tạo mới
assets/images/    ← Ảnh avatar, cover, icon
```

---

## Bước 1: LoginView.qml — Màn Hình Đăng Nhập

### Trong Qt Design Mode:
1. Mở [LoginView.qml](file:///F:/Project_BTL/english-mastery-hub/LoginView.qml) → chuyển sang tab **Design**
2. Đặt root Item → đổi thành `Rectangle`, fill toàn màn hình
3. Thêm `ColumnLayout` centered

### Code hoàn chỉnh:

```qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: loginRoot
    color: "#1a1a2e"  // Dark theme

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 20
        width: 350

        // Logo / Title
        Text {
            text: "🔥 English Mastery Hub"
            font { pixelSize: 28; bold: true }
            color: "#e94560"
            Layout.alignment: Qt.AlignHCenter
        }

        // Username
        TextField {
            id: usernameField
            placeholderText: "Tên đăng nhập"
            Layout.fillWidth: true
            color: "white"
            background: Rectangle { color: "#16213e"; radius: 8; border.color: "#0f3460" }
        }

        // Password
        TextField {
            id: passwordField
            placeholderText: "Mật khẩu"
            echoMode: TextInput.Password
            Layout.fillWidth: true
            color: "white"
            background: Rectangle { color: "#16213e"; radius: 8; border.color: "#0f3460" }
        }

        // Error message
        Text {
            id: errorText
            color: "#e94560"
            visible: text.length > 0
            Layout.alignment: Qt.AlignHCenter
        }

        // Login button
        Button {
            text: "Đăng Nhập"
            Layout.fillWidth: true
            flat: true
            background: Rectangle { color: "#e94560"; radius: 8 }
            contentItem: Text { text: parent.text; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter }
            onClicked: {
                var ok = authController.login(usernameField.text, passwordField.text)
                if (!ok) errorText.text = "Sai tên đăng nhập hoặc mật khẩu"
            }
        }
    }
}
```

### Kết nối C++:
- `authController.login()` là `Q_INVOKABLE` trong [AuthController](file:///F:/Project_BTL/english-mastery-hub/controllers/authcontroller.cpp#3-6)
- Khi thành công → emit signal `loginSuccess()` → [Main.qml](file:///F:/Project_BTL/english-mastery-hub/Main.qml) chuyển sang Dashboard

---

## Bước 2: Main.qml — Điều Hướng (StackView)

### Cách hoạt động:
- Dùng `StackView` để push/pop giữa Login ↔ Dashboard
- Lắng nghe signal `loginSuccess` từ C++

```qml
import QtQuick
import QtQuick.Controls

ApplicationWindow {
    id: root
    width: 1280; height: 800
    visible: true
    title: "English Mastery Hub"
    color: "#0f0f23"

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: loginPage
    }

    Component { id: loginPage; LoginView {} }
    Component { id: dashboardPage; DashboardView {} }

    Connections {
        target: authController
        function onLoginSuccess() { stackView.replace(dashboardPage) }
        function onLogout() { stackView.replace(loginPage) }
    }
}
```

> [!TIP]
> Trong Qt Design, bạn có thể kéo `StackView` từ panel **Components** → **Qt Quick Controls**.

---

## Bước 3: DashboardView.qml — Layout 5 Khu Vực

### Cấu trúc chính: `SwipeView` hoặc `ScrollView` + `ColumnLayout`

**Phương án 1 — SwipeView (tab-based):**
```qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    ColumnLayout {
        anchors.fill: parent

        // Tab Bar
        TabBar {
            id: tabBar; Layout.fillWidth: true
            TabButton { text: "📋 Check-in" }
            TabButton { text: "👤 Cá nhân" }
            TabButton { text: "👥 Nhóm" }
            TabButton { text: "🏆 Vinh danh" }
            TabButton { text: "📚 Tài nguyên" }
        }

        // Content
        SwipeView {
            id: swipeView; Layout.fillWidth: true; Layout.fillHeight: true
            currentIndex: tabBar.currentIndex

            CheckInZone {}      // KV1
            PersonalZone {}     // KV2
            GroupZone {}        // KV3
            TopPerformerZone {} // KV4
            ResourceZone {}    // KV5
        }
    }
}
```

**Phương án 2 — ScrollView (cuộn dọc liền mạch):**
```qml
ScrollView {
    anchors.fill: parent
    ColumnLayout {
        width: parent.width
        CheckInZone { Layout.fillWidth: true; Layout.preferredHeight: 500 }
        PersonalZone { Layout.fillWidth: true; Layout.preferredHeight: 600 }
        GroupZone { Layout.fillWidth: true; Layout.preferredHeight: 500 }
        TopPerformerZone { Layout.fillWidth: true; Layout.preferredHeight: 400 }
        ResourceZone { Layout.fillWidth: true; Layout.preferredHeight: 500 }
    }
}
```

---

## Bước 4: Khu Vực 1 — Check-in & Bảng Truy Nã

### Trong Qt Design:
1. Tạo file `components/CheckInZone.qml`
2. Kéo thả: `Item` root → `ColumnLayout` → `Button` (Check-in) + `GridView` (Wanted Board)

### Popup Check-in:
Tạo file `components/CheckInPopup.qml`:

```qml
Popup {
    id: checkInPopup
    modal: true; dim: true
    anchors.centerIn: Overlay.overlay
    width: 400; height: 300
    background: Rectangle { color: "#1a1a2e"; radius: 16; border.color: "#e94560" }

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 24; spacing: 16

        Text { text: "📝 Điểm danh hôm nay"; color: "white"; font { pixelSize: 20; bold: true } }

        // Bookworm hours
        RowLayout {
            Text { text: "Giờ Bookworm:"; color: "#ccc"; Layout.preferredWidth: 120 }
            SpinBox { id: bwHours; from: 0; to: 240; stepSize: 5; editable: true
                      property real realValue: value / 10.0  // cho phép 0.5h
            }
        }

        // Ministory hours
        RowLayout {
            Text { text: "Giờ Ministory:"; color: "#ccc"; Layout.preferredWidth: 120 }
            SpinBox { id: msHours; from: 0; to: 240; stepSize: 5; editable: true
                      property real realValue: value / 10.0
            }
        }

        // Actions
        RowLayout {
            Layout.alignment: Qt.AlignRight
            Button { text: "Hủy"; onClicked: checkInPopup.close() }
            Button {
                text: "✅ Xác nhận"
                onClicked: {
                    checkInController.submit(bwHours.realValue, msHours.realValue)
                    checkInPopup.close()
                }
            }
        }
    }
}
```

### Wanted Board (GridView):

```qml
// components/WantedBoard.qml
GridView {
    id: wantedGrid
    clip: true; cellWidth: 220; cellHeight: 180
    model: wantedModel  // QAbstractListModel từ C++

    delegate: Rectangle {
        width: 200; height: 160; radius: 12
        color: "#16213e"
        border.color: "#e94560"; border.width: 1

        // DropShadow
        layer.enabled: true
        layer.effect: MultiEffect { shadowEnabled: true; shadowColor: "#40e94560" }

        ColumnLayout {
            anchors.fill: parent; anchors.margins: 12; spacing: 8

            // Avatar (bo tròn)
            Image {
                source: model.avatarPath
                Layout.preferredWidth: 60; Layout.preferredHeight: 60
                Layout.alignment: Qt.AlignHCenter
                layer.enabled: true
                layer.effect: MultiEffect { maskEnabled: true; maskSource: Rectangle { width: 60; height: 60; radius: 30 } }
            }

            Text { text: model.displayName; color: "white"; font.bold: true; Layout.alignment: Qt.AlignHCenter }
            Text { text: "⚠️ Chưa check-in"; color: "#e94560"; font.pixelSize: 11; Layout.alignment: Qt.AlignHCenter }
            Text { text: "🔥 Streak: " + model.streak; color: "#ffa500"; font.pixelSize: 11; Layout.alignment: Qt.AlignHCenter }
        }
    }
}
```

---

## Bước 5: Khu Vực 2 — Không Gian Cá Nhân

### Trong Qt Design:
Tạo `components/PersonalZone.qml` → Kéo `RowLayout` chia 2 vùng.

```qml
RowLayout {
    spacing: 16

    // ═══ NỬA TRÁI: Profile + Calendar ═══
    Rectangle {
        Layout.fillWidth: true; Layout.preferredWidth: 1
        Layout.fillHeight: true; color: "#16213e"; radius: 12

        ColumnLayout {
            anchors.fill: parent; anchors.margins: 16

            // Avatar bo tròn
            Image { source: currentUser.avatar; Layout.preferredWidth: 80; Layout.preferredHeight: 80; Layout.alignment: Qt.AlignHCenter
                layer.enabled: true; layer.effect: MultiEffect { maskEnabled: true; maskSource: Rectangle { width: 80; height: 80; radius: 40 } }
            }
            Text { text: currentUser.name; color: "white"; font { pixelSize: 18; bold: true }; Layout.alignment: Qt.AlignHCenter }
            Text { text: "🔥 Streak: " + currentUser.streak + " ngày"; color: "#ffa500"; Layout.alignment: Qt.AlignHCenter }

            // Progress Bar 25 ngày
            ProgressBar { id: dayProgress; value: currentUser.completedDays / 25.0; Layout.fillWidth: true
                background: Rectangle { color: "#0f3460"; radius: 4; implicitHeight: 10 }
                contentItem: Rectangle { width: dayProgress.visualPosition * parent.width; height: 10; radius: 4
                    gradient: Gradient { orientation: Gradient.Horizontal
                        GradientStop { position: 0; color: "#00f5a0" }
                        GradientStop { position: 1; color: "#00d9f5" }
                    }
                }
            }
            Text { text: currentUser.completedDays + " / 25 ngày"; color: "#aaa"; Layout.alignment: Qt.AlignHCenter }

            // Calendar Grid (7 cột = T2→CN)
            GridLayout { columns: 7; Layout.fillWidth: true
                // Header (tên ngày)
                Repeater { model: ["T2","T3","T4","T5","T6","T7","CN"]
                    Text { text: modelData; color: "#888"; font.pixelSize: 10; Layout.alignment: Qt.AlignHCenter }
                }
                // 1 ô trống (offset: ngày 1 = T3) + 25 ô ngày
                Item { Layout.preferredWidth: 30; Layout.preferredHeight: 30 }  // offset
                Repeater { model: 25
                    Rectangle { width: 30; height: 30; radius: 4
                        color: dayStatusArray[index] === "done" ? "#4CAF50"
                             : dayStatusArray[index] === "missed" ? "#F44336"
                             : "#333"
                        Text { text: index + 1; anchors.centerIn: parent; color: "white"; font.pixelSize: 10 }
                    }
                }
            }
        }
    }

    // ═══ NỬA PHẢI: 2 Line Charts ═══
    ColumnLayout {
        Layout.fillWidth: true; Layout.preferredWidth: 1; spacing: 8

        import QtCharts  // Thêm import này

        ChartView { title: "📘 Giờ Học Bookworm"; Layout.fillWidth: true; Layout.fillHeight: true
            backgroundColor: "transparent"; titleColor: "white"; antialiasing: true
            ValuesAxis { id: xAxis1; min: 1; max: 25; labelsColor: "#aaa"; titleText: "Ngày" }
            ValuesAxis { id: yAxis1; min: 0; max: 5; labelsColor: "#aaa"; titleText: "Giờ" }
            LineSeries { name: "Bookworm"; axisX: xAxis1; axisY: yAxis1; color: "#00d9f5"; width: 2
                // Dữ liệu được append từ C++ model
            }
        }
        ChartView { title: "🎧 Giờ Học Ministory"; Layout.fillWidth: true; Layout.fillHeight: true
            backgroundColor: "transparent"; titleColor: "white"; antialiasing: true
            ValuesAxis { id: xAxis2; min: 1; max: 25; labelsColor: "#aaa" }
            ValuesAxis { id: yAxis2; min: 0; max: 5; labelsColor: "#aaa" }
            LineSeries { name: "Ministory"; axisX: xAxis2; axisY: yAxis2; color: "#ffa500"; width: 2 }
        }
    }
}
```

---

## Bước 6: Khu Vực 3 — Nhóm & Biểu Đồ

### Horizontal ListView (Danh sách nhóm):

```qml
// components/GroupCarousel.qml
ListView {
    orientation: ListView.Horizontal; spacing: 16; clip: true
    height: 200; model: groupModel

    delegate: Rectangle {
        width: 200; height: 180; radius: 12; color: "#16213e"

        ColumnLayout { anchors.fill: parent; spacing: 0
            Image { source: model.coverImage; Layout.fillWidth: true; Layout.preferredHeight: 100
                fillMode: Image.PreserveAspectCrop
                layer.enabled: true
                layer.effect: MultiEffect { maskEnabled: true; maskSource: Rectangle { width: 200; height: 100; radius: 12 } }
            }
            ColumnLayout { Layout.margins: 8
                Text { text: model.name; color: "white"; font.bold: true }
                Text { text: "👑 " + model.leaderName; color: "#aaa"; font.pixelSize: 11 }
                Text { text: "👥 " + model.memberCount + " thành viên"; color: "#888"; font.pixelSize: 11 }
            }
        }
    }
}
```

### Bar + Line Charts:

```qml
RowLayout {
    ChartView { title: "📊 Bookworm (theo nhóm)"; Layout.fillWidth: true; Layout.fillHeight: true
        backgroundColor: "transparent"; antialiasing: true
        BarCategoryAxis { id: catAxis; categories: groupNames }  // ["KFC","Ếch Ộp"...]
        ValueAxis { id: barYAxis; min: 0 }
        BarSeries { axisX: catAxis; axisY: barYAxis
            BarSet { label: "Bookworm"; values: groupBookwormTotals; color: "#00d9f5" }
        }
    }
    ChartView { title: "📈 Ministory (theo nhóm)"; Layout.fillWidth: true; Layout.fillHeight: true
        backgroundColor: "transparent"; antialiasing: true
        LineSeries { name: "Ministory"; color: "#ffa500"; width: 3 }
    }
}
```

---

## Bước 7: Khu Vực 4 — Bục Vinh Danh (6:4)

```qml
RowLayout {
    spacing: 16

    // 60% — Top 3 Bookworm
    Rectangle { Layout.fillWidth: true; Layout.preferredWidth: 6; Layout.fillHeight: true; color: "#16213e"; radius: 12
        ColumnLayout { anchors.fill: parent; anchors.margins: 16
            Text { text: "👑 TOP 3 BOOKWORM"; color: "#ffd700"; font { pixelSize: 22; bold: true } }
            ListView { Layout.fillWidth: true; Layout.fillHeight: true; model: top3BookwormModel; spacing: 8
                delegate: Rectangle { width: parent.width; height: index === 0 ? 80 : 60; radius: 8
                    color: index === 0 ? "#2d1b69" : "#1a1a2e"
                    border.color: index === 0 ? "#ffd700" : index === 1 ? "#c0c0c0" : "#cd7f32"
                    RowLayout { anchors.fill: parent; anchors.margins: 8
                        Rectangle { width: 36; height: 36; radius: 18; color: index === 0 ? "#ffd700" : index === 1 ? "#c0c0c0" : "#cd7f32"
                            Text { text: (index+1); anchors.centerIn: parent; font.bold: true } }
                        Image { source: model.avatar; Layout.preferredWidth: 40; Layout.preferredHeight: 40 }
                        ColumnLayout { Layout.fillWidth: true
                            Text { text: model.name; color: "white"; font.bold: true }
                            Text { text: model.totalHours + " giờ"; color: "#aaa" }
                        }
                    }
                }
            }
        }
    }

    // 40% — Top 3 Ministory (cấu trúc tương tự, đổi title/model)
    Rectangle { Layout.fillWidth: true; Layout.preferredWidth: 4; Layout.fillHeight: true; color: "#16213e"; radius: 12
        ColumnLayout { anchors.fill: parent; anchors.margins: 16
            Text { text: "🔥 TOP 3 MINISTORY"; color: "#ff6b35"; font { pixelSize: 22; bold: true } }
            ListView { /* tương tự, dùng top3MinistoryModel */ }
        }
    }
}
```

---

## Bước 8: Khu Vực 5 — Kho Tài Nguyên

```qml
ScrollView { anchors.fill: parent
    ColumnLayout { width: parent.width; spacing: 24

        // Section header
        Repeater {
            model: ["📚 Bookworms & Audiobooks", "📋 Quy định 25 ngày", "🎧 Ministory"]
            ColumnLayout { Layout.fillWidth: true
                Text { text: modelData; color: "white"; font { pixelSize: 18; bold: true }; Layout.bottomMargin: 8 }
                // Resource cards cho section này
                Repeater { model: resourceModel.filterByCategory(index)
                    Rectangle { Layout.fillWidth: true; height: 50; radius: 8
                        color: hovered ? "#1e3a5f" : "#16213e"
                        property bool hovered: false
                        MouseArea { anchors.fill: parent; hoverEnabled: true
                            onEntered: parent.hovered = true; onExited: parent.hovered = false
                            onClicked: resourceController.open(model.sourcePath, model.sourceType)
                        }
                        RowLayout { anchors.fill: parent; anchors.margins: 8
                            Text { text: model.sourceType === "link" ? "🌐" : "📎"; font.pixelSize: 20 }
                            Text { text: model.title; color: "white"; Layout.fillWidth: true }
                            Button { text: model.sourceType === "link" ? "Mở" : "Tải về"; flat: true }
                        }
                    }
                }
            }
        }
    }
}
```

---

## Bước 9: Gemini AI Side Panel

Xem chi tiết tại [project_overview.md — Mục 8.5](file:///C:/Users/Admin/.gemini/antigravity/brain/02443a67-72e6-4fbb-8a21-5eddd3974f3e/project_overview.md).

Thêm vào `DashboardView.qml`:

```qml
// Floating AI Button + Drawer
Rectangle { id: aiFab; width: 56; height: 56; radius: 28; color: "#4285F4"; z: 100
    anchors { right: parent.right; bottom: parent.bottom; margins: 20 }
    Text { text: "🤖"; anchors.centerIn: parent; font.pixelSize: 24 }
    MouseArea { anchors.fill: parent; onClicked: aiDrawer.open() }
}

Drawer { id: aiDrawer; edge: Qt.RightEdge; width: 380
    // Nội dung xem project_overview.md mục 8.5
}
```

---

## Checklist Tổng Hợp

| # | Bước | File QML | Trạng thái |
|---|---|---|---|
| 0 | Setup CMake + modules | [CMakeLists.txt](file:///F:/Project_BTL/english-mastery-hub/CMakeLists.txt) | [ ] |
| 1 | Login | [LoginView.qml](file:///F:/Project_BTL/english-mastery-hub/LoginView.qml) | [ ] |
| 2 | Navigation | [Main.qml](file:///F:/Project_BTL/english-mastery-hub/Main.qml) | [ ] |
| 3 | Dashboard layout | `DashboardView.qml` | [ ] |
| 4 | KV1: Check-in + Wanted | `CheckInPopup.qml`, `WantedBoard.qml` | [ ] |
| 5 | KV2: Personal | `PersonalZone.qml` | [ ] |
| 6 | KV3: Group | `GroupCarousel.qml`, `GroupCharts.qml` | [ ] |
| 7 | KV4: Top Performer | `TopPerformerBoard.qml` | [ ] |
| 8 | KV5: Resource | `ResourceLibrary.qml` | [ ] |
| 9 | AI Panel | Floating Button + Drawer | [ ] |
