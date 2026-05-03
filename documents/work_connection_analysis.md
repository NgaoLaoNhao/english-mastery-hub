# 🔗 Phân Tích Kết Nối Công Việc Giữa 3 Người A, B, C

## 1. Tổng Quan Vai Trò & Ranh Giới Trách Nhiệm

| Người | Vai trò | Sản phẩm chính | Phụ thuộc vào |
|:---:|---|---|---|
| **A** | Backend C++ Engineer | DatabaseManager, Controllers, Models, `main.cpp` | Không ai (A là nền móng) |
| **B** | Frontend QML Designer | Toàn bộ giao diện QML (Login → 5 KV Dashboard) | **A** (data + signals), **C** (AI Drawer) |
| **C** | AI + Integration Specialist | Python bridge, GeminiController, Testing | **A** (models, seed data), **B** (QML files để tích hợp AI) |

> [!IMPORTANT]
> **A là người xây nền móng** — B và C đều phụ thuộc vào sản phẩm của A. Tuy nhiên, B và C có thể làm việc **song song** với A nhờ kỹ thuật mock data và tách module.

---

## 2. Bản Đồ Phụ Thuộc Chéo Theo Ngày

```mermaid
gantt
    title Lịch Trình 6 Ngày — Phụ Thuộc Chéo
    dateFormat  YYYY-MM-DD
    axisFormat  Ngày %d

    section Người A (Backend)
    DatabaseManager + AuthController     :a1, 2026-05-01, 1d
    UserModel + CheckInModel             :a2, after a1, 1d
    CheckInController + Streak           :a3, after a2, 1d
    GroupModel + ResourceModel           :a4, after a3, 1d
    main.cpp + Seed Data                 :a5, after a4, 1d
    Fix Bug + Integration                :a6, after a5, 1d

    section Người B (Frontend)
    LoginView + Main.qml + CMake         :b1, 2026-05-01, 1d
    Dashboard + KV1 (mock data)          :b2, after b1, 1d
    KV2 Personal Zone                    :b3, after b2, 1d
    KV3 Group + KV4 Top Performer        :b4, after b3, 1d
    KV5 Resource + Dark Theme            :b5, after b4, 1d
    Gắn AI Drawer + Polish               :b6, after b5, 1d

    section Người C (AI)
    gemini_bridge.py (Python)            :c1, 2026-05-01, 1d
    GeminiController (C++)               :c2, after c1, 1d
    AiDrawer.qml                         :c3, after c2, 1d
    Tích hợp AI vào KV1,2,5             :c4, after c3, 1d
    Testing End-to-End                   :c5, after c4, 1d
    Fix Bug + Demo                       :c6, after c5, 1d
```

---

## 3. Ma Trận Kết Nối Chi Tiết — Ai Giao Gì Cho Ai, Khi Nào?

### 3.1 Người A → Người B (Luồng chính: Data → UI)

Đây là **luồng phụ thuộc nặng nhất** trong dự án. B cần sản phẩm từ A để bind data vào giao diện.

| Ngày A giao | Sản phẩm A giao | B nhận để làm gì | Giao diện cụ thể |
|:---:|---|---|---|
| **Ngày 1** | `authController.login()` + signals `loginSuccess`, `loginFailed` | B kết nối vào `LoginView.qml` — xử lý đăng nhập | [LoginView.qml](file:///f:/Project_BTL/english-mastery-hub/LoginView.qml) |
| **Ngày 2** | `userModel` (role names: `displayName`, `avatarPath`, `streak`) + `checkInModel` | B bind vào `GridView`/`ListView` trong WantedBoard, PersonalZone | `WantedBoard.qml`, `PersonalZone.qml` |
| **Ngày 3** | `checkInController.submitCheckIn()` + `getDayStatusArray()` | B kết nối vào CheckInPopup (nút Xác nhận) + Calendar Grid | `CheckInPopup.qml`, Calendar trong `PersonalZone.qml` |
| **Ngày 4** | `groupModel`, `resourceModel` (role names) + `groupController.getGroupNames()` | B hoàn thiện KV3, KV4, KV5 | `GroupCarousel.qml`, `TopPerformerBoard.qml`, `ResourceLibrary.qml` |
| **Ngày 5** | `main.cpp` hoàn chỉnh + Seed data | B có data thật để test toàn bộ UI | Tất cả QML files |

### 3.2 Người A → Người C (Luồng phụ: Infrastructure)

| Ngày | A giao/hỗ trợ | C cần để làm gì |
|:---:|---|---|
| **Ngày 2** | Models (UserModel, CheckInModel) đã có role names | C biết cấu trúc data JSON để thiết kế prompt AI phù hợp |
| **Ngày 5** | `main.cpp` — đăng ký `GeminiController` vào QML context | C giao `geminicontroller.h/cpp` cho A, A thêm vào `main.cpp` |
| **Ngày 5** | Seed data mẫu (10-12 users, 5-7 ngày check-in) | C dùng để test end-to-end toàn bộ luồng |

### 3.3 Người C → Người B (Luồng phụ: AI Component → Dashboard)

| Ngày C giao | Sản phẩm | B làm gì |
|:---:|---|---|
| **Ngày 3** | `AiDrawer.qml` (FAB button + Side Drawer) | B gắn vào `DashboardView.qml` ở ngày 6: chỉ cần 1 dòng `AiDrawer { anchors.fill: parent }` |

### 3.4 Người C → Người A (Luồng ngược: AI files → Build system)

| Ngày C giao | Sản phẩm | A làm gì |
|:---:|---|---|
| **Ngày 2** | `geminicontroller.h/cpp` | A thêm vào `CMakeLists.txt` SOURCES + đăng ký vào `main.cpp` ngày 5 |
| **Ngày 1** | `scripts/gemini_bridge.py` | A biết script path để cấu hình deploy cùng executable |

---

## 4. Sơ Đồ Tổng Thể Dòng Chảy Phụ Thuộc

```mermaid
graph TD
    subgraph "Ngày 1"
        A1["A: DatabaseManager<br/>+ AuthController"]
        B1["B: LoginView.qml<br/>+ Main.qml + CMake"]
        C1["C: gemini_bridge.py<br/>(Python, test riêng)"]
    end

    subgraph "Ngày 2"
        A2["A: UserModel<br/>+ CheckInModel"]
        B2["B: DashboardView<br/>+ KV1 (mock data)"]
        C2["C: GeminiController<br/>(C++ QProcess)"]
    end

    subgraph "Ngày 3"
        A3["A: CheckInController<br/>+ Streak Logic"]
        B3["B: KV2 PersonalZone<br/>(Calendar + Charts)"]
        C3["C: AiDrawer.qml"]
    end

    subgraph "Ngày 4"
        A4["A: GroupModel<br/>+ ResourceModel"]
        B4["B: KV3 + KV4"]
        C4["C: Tích hợp AI<br/>vào KV1, KV2, KV5"]
    end

    subgraph "Ngày 5"
        A5["A: main.cpp<br/>+ Seed Data"]
        B5["B: KV5 Resource<br/>+ Dark Theme Polish"]
        C5["C: Test End-to-End"]
    end

    subgraph "Ngày 6"
        A6["A: Fix Bug<br/>+ Support"]
        B6["B: Gắn AI Drawer<br/>+ Polish cuối"]
        C6["C: Fix Bug<br/>+ Chuẩn bị Demo"]
    end

    %% A → B dependencies
    A1 -->|"loginSuccess signal"| B1
    A2 -->|"role names"| B2
    A3 -->|"submitCheckIn<br/>getDayStatusArray"| B3
    A4 -->|"groupModel<br/>resourceModel"| B4
    A5 -->|"seed data thật"| B5

    %% A → C dependencies
    A2 -->|"data structure"| C4
    A5 -->|"đăng ký GeminiController<br/>+ seed data"| C5

    %% C → A dependencies
    C2 -->|"h/cpp files"| A5
    C1 -->|"script path"| A5

    %% C → B dependencies
    C3 -->|"AiDrawer.qml"| B6

    %% B → C dependencies
    B4 -->|"QML files sẵn sàng"| C4

    style A1 fill:#2196F3,color:white
    style A2 fill:#2196F3,color:white
    style A3 fill:#2196F3,color:white
    style A4 fill:#2196F3,color:white
    style A5 fill:#2196F3,color:white
    style A6 fill:#2196F3,color:white
    style B1 fill:#4CAF50,color:white
    style B2 fill:#4CAF50,color:white
    style B3 fill:#4CAF50,color:white
    style B4 fill:#4CAF50,color:white
    style B5 fill:#4CAF50,color:white
    style B6 fill:#4CAF50,color:white
    style C1 fill:#FF9800,color:white
    style C2 fill:#FF9800,color:white
    style C3 fill:#FF9800,color:white
    style C4 fill:#FF9800,color:white
    style C5 fill:#FF9800,color:white
    style C6 fill:#FF9800,color:white
```

---

## 5. Cách Xử Lý Phần Việc Chung — Chiến Lược Song Song

### 5.1 Vấn đề: B phụ thuộc A nhưng cả hai bắt đầu cùng ngày

**Giải pháp: Kỹ thuật Mock Data + Hợp đồng Interface**

```mermaid
sequenceDiagram
    participant A as Người A (Backend)
    participant B as Người B (Frontend)
    participant C as Người C (AI)

    Note over A,C: === NGÀY 1 ===
    par Làm song song
        A->>A: Viết DatabaseManager + AuthController
        B->>B: Viết LoginView.qml (gọi authController placeholder)
        C->>C: Viết gemini_bridge.py + test Python riêng
    end
    A-->>B: Cuối ngày 1: "loginSuccess/loginFailed signals sẵn sàng"

    Note over A,C: === NGÀY 2 ===
    par Làm song song
        A->>A: Viết UserModel + CheckInModel
        B->>B: Viết WantedBoard với ListModel mock
        C->>C: Viết GeminiController (C++)
    end
    A-->>B: Cuối ngày 2: "role names = displayName, streak, avatarPath"
    Note over B: B đổi model: mockUsers → userModel

    Note over A,C: === NGÀY 3 ===
    par Làm song song
        A->>A: Viết CheckInController + Streak
        B->>B: Viết PersonalZone (Calendar + Charts)
        C->>C: Viết AiDrawer.qml
    end
    A-->>B: "submitCheckIn() + getDayStatusArray() sẵn sàng"
    C-->>B: AiDrawer.qml giao cho B (dùng ở ngày 6)

    Note over A,C: === NGÀY 4 (Ngày phức tạp nhất) ===
    par Làm song song
        A->>A: Viết GroupModel + ResourceModel
        B->>B: Viết KV3 GroupCarousel + KV4 TopPerformer
        C->>C: Tích hợp AI vào KV1, KV2, KV5
    end
    Note over C: C cần QML files của B.<br/>Nếu B chưa xong → C tạo file riêng, merge sau

    Note over A,C: === NGÀY 5 ===
    par Làm song song
        A->>A: Hoàn thiện main.cpp + Seed data
        B->>B: KV5 Resource + Polish theme
        C->>C: Test End-to-End 10 kịch bản
    end
    C-->>A: Giao geminicontroller.h/cpp cho main.cpp
    A-->>C: Seed data cho testing

    Note over A,C: === NGÀY 6 ===
    par Cùng fix bug
        A->>A: Fix SQL bugs + hỗ trợ B,C
        B->>B: Gắn AiDrawer + Polish cuối
        C->>C: Fix AI bugs + Chuẩn bị demo
    end
```

### 5.2 Ba Kỹ Thuật Chính Để Làm Việc Song Song

#### Kỹ thuật 1: Mock Data (B dùng khi chờ A)

B **không cần chờ** A hoàn thành model. B tạo `ListModel` giả trực tiếp trong QML:

```qml
// B viết trước với mock data
ListModel {
    id: mockUsers
    ListElement { displayName: "Nguyễn Văn A"; streak: 5; avatarPath: "" }
    ListElement { displayName: "Trần Thị B"; streak: 3; avatarPath: "" }
}

GridView {
    model: mockUsers  // ← Tạm dùng mock
    // Khi A xong → đổi thành: model: userModel
}
```

> [!TIP]
> **Quy tắc đặt tên:** A và B **thống nhất trước** tên role (VD: `displayName`, `streak`, `avatarPath`) để B viết delegate đúng ngay từ đầu. Khi A giao model thật, B chỉ cần đổi 1 dòng `model:`.

#### Kỹ thuật 2: Hợp Đồng Interface (A định nghĩa API trước)

A công bố **signature** của controller ngay ngày 1, dù chưa implement:

```cpp
// A gửi "hợp đồng" cho B ngày 1:
// "CheckInController sẽ có:"
Q_INVOKABLE bool submitCheckIn(double bookwormHours, double ministoryHours);
// → return true/false
// → signals: checkInSuccess(), checkInFailed(reason)

Q_INVOKABLE QVariantList getDayStatusArray(int userId);
// → return ["done", "missed", "future", "future", ...]
```

B dựa vào hợp đồng này để viết UI, không cần chờ implementation.

#### Kỹ thuật 3: Tách Module (C tạo file riêng khi B chưa sẵn sàng)

Ngày 4, C cần sửa QML files của B (thêm nút AI vào KV1, KV2, KV5). Nếu B chưa xong:

```
Cách 1 (ưu tiên): C viết code AI riêng trong file tách biệt
    → Tạo file ai_kv1_additions.qml, ai_kv2_additions.qml
    → Ngày 6 merge vào files chính của B

Cách 2: C và B pair-programming
    → C nói cho B cần thêm gì, B gắn vào
```

---

## 6. Điểm Xung Đột Tiềm Ẩn & Cách Giải Quyết

### 6.1 Xung đột CMakeLists.txt

**Vấn đề:** Cả 3 người đều cần sửa `CMakeLists.txt` để thêm files mới.

| Người | Thêm vào CMakeLists.txt |
|---|---|
| A | `databasemanager.h/cpp`, `authcontroller.h/cpp`, `usermodel.h/cpp`, ... |
| B | `LoginView.qml`, `DashboardView.qml`, `components/*.qml` |
| C | `geminicontroller.h/cpp` |

**Giải pháp:**
- **B quản lý CMakeLists.txt** (ngày 1, nhiệm vụ 1.1)
- A và C **báo B** khi có file mới cần thêm
- Hoặc: sử dụng glob pattern `file(GLOB_RECURSE ...)` để auto-detect files

### 6.2 Xung đột main.cpp

**Vấn đề:** `main.cpp` là file duy nhất mà sản phẩm của cả 3 người hội tụ.

```cpp
// main.cpp — Điểm hội tụ
DatabaseManager dbManager;          // ← A tạo
AuthController authCtrl(&dbManager); // ← A tạo
UserModel userModel(&dbManager);     // ← A tạo
GeminiController geminiCtrl;         // ← C tạo, A đăng ký

ctx->setContextProperty("authController", &authCtrl);  // ← B dùng trong QML
ctx->setContextProperty("geminiController", &geminiCtrl); // ← C dùng trong QML
```

**Giải pháp:**
- **A sở hữu `main.cpp`** — chỉ A sửa file này
- B và C **giao header files** cho A, kèm hướng dẫn:
  - C: "Thêm `#include "core/geminicontroller.h"`, tạo instance, đăng ký `geminiController`"
  - B: "Đăng ký context property tên `authController`, `userModel`, ..."

### 6.3 Xung đột Ngày 4: C cần QML files của B

**Vấn đề:** C cần sửa `WantedBoard.qml`, `PersonalZone.qml`, `ResourceCard.qml` để thêm nút AI — nhưng B có thể chưa hoàn thành.

**Giải pháp theo mức độ:**

| Tình huống | Cách xử lý |
|---|---|
| B **đã xong** KV1, KV2, KV5 | C trực tiếp thêm nút AI vào files của B |
| B **đang làm** nhưng file đã tồn tại | C tạo branch riêng, merge sau |
| B **chưa bắt đầu** | C viết đoạn code AI riêng (snippets), ngày 6 B gắn vào |

---

## 7. Bảng Tổng Hợp: Việc Riêng vs Việc Chung

### Việc hoàn toàn ĐỘC LẬP (không cần ai khác)

| Người | Công việc độc lập | Ngày |
|---|---|---|
| **A** | Viết `DatabaseManager`, tạo schema, seed data, viết SQL queries | Ngày 1-2 |
| **A** | Logic tính streak, `getDayStatusArray()` | Ngày 3 |
| **B** | Thiết kế layout, color palette, hover effects, animations | Ngày 1-5 |
| **B** | Dark theme polish, responsive testing | Ngày 5-6 |
| **C** | Viết + test `gemini_bridge.py` (chạy hoàn toàn riêng bằng Python) | Ngày 1 |
| **C** | Viết `GeminiController` C++ class | Ngày 2 |
| **C** | Thiết kế `AiDrawer.qml` (FAB + Side Panel) | Ngày 3 |

### Việc CẦN PHỐI HỢP (phụ thuộc người khác)

| Việc chung | Ai liên quan | Cách phối hợp |
|---|---|---|
| **Bind model vào QML** | A giao role names → B bind | A gửi danh sách role names chính xác, B đổi `model:` từ mock → thật |
| **Signal/Slot Login** | A phát signal → B lắng nghe | A: `emit loginSuccess()` / B: `Connections { target: authController }` |
| **Đăng ký vào main.cpp** | C giao h/cpp → A đăng ký | C giao file + hướng dẫn 2 dòng code cần thêm |
| **Gắn AI Drawer** | C giao QML → B gắn | B thêm 1 dòng: `AiDrawer { anchors.fill: parent }` |
| **Tích hợp AI vào KV** | C cần QML của B | C thêm Button + Text vào files của B (hoặc tách file) |
| **Testing E2E** | C test → A+B fix bug | C ghi danh sách bug, phân loại Critical/Normal/Minor → A fix SQL, B fix UI |
| **CMakeLists.txt** | Cả 3 thêm files | B quản lý file, A+C báo khi có file mới |

---

## 8. Timeline Giao Tiếp Bắt Buộc

Để tránh blocking, các thành viên **PHẢI** giao tiếp tại các thời điểm sau:

```mermaid
timeline
    title Các Mốc Giao Tiếp Bắt Buộc
    Ngày 1 : A báo B: "loginSuccess/loginFailed signals sẵn sàng"
           : C báo A: "gemini_bridge.py đã test OK"
           : Cả nhóm: Thống nhất role names cho UserModel
    Ngày 2 : A giao B: Danh sách role names chính xác (displayName, streak, avatarPath)
           : C giao A: geminicontroller.h/cpp files
    Ngày 3 : A giao B: submitCheckIn() + getDayStatusArray() API
           : C giao B: AiDrawer.qml component
    Ngày 4 : A giao B: GroupModel + ResourceModel role names
           : C hỏi B: "QML files KV1, KV2, KV5 đã sẵn sàng chưa?"
    Ngày 5 : A báo cả nhóm: "main.cpp + seed data hoàn tất, build OK"
           : C bắt đầu test → báo bug cho A và B
    Ngày 6 : C giao danh sách bug → A fix SQL, B fix UI
           : B gắn AiDrawer vào Dashboard
           : Cả nhóm: Chạy demo thử 1 lượt
```

---

## 9. Kết Luận: Mô Hình Làm Việc Tối Ưu

```
┌─────────────────────────────────────────────────────────────────┐
│                    MÔ HÌNH LÀM VIỆC                             │
│                                                                  │
│  Ngày 1-3: LÀM SONG SONG                                       │
│  ┌──────┐   ┌──────┐   ┌──────┐                                │
│  │  A   │   │  B   │   │  C   │   ← 3 người làm độc lập        │
│  │ Back │   │Front │   │  AI  │   ← Giao tiếp qua "hợp đồng"  │
│  │ end  │   │ end  │   │      │   ← B dùng mock data           │
│  └──┬───┘   └──┬───┘   └──┬───┘                                │
│     │          │          │                                      │
│  Ngày 4-5: HỘI TỤ                                              │
│     │          │          │                                      │
│     └──────────┼──────────┘                                      │
│                ▼                                                  │
│         ┌──────────────┐                                         │
│         │  main.cpp    │  ← Điểm hội tụ duy nhất               │
│         │  + Seed Data │  ← A quản lý, nhận files từ B+C       │
│         └──────┬───────┘                                         │
│                │                                                  │
│  Ngày 5-6: TEST & FIX                                           │
│                │                                                  │
│         ┌──────▼───────┐                                         │
│         │   C: Test    │  ← C test toàn bộ, báo bug            │
│         │   E2E        │                                         │
│         └──┬───────┬───┘                                         │
│            │       │                                              │
│       ┌────▼──┐ ┌──▼────┐                                       │
│       │A: Fix │ │B: Fix │  ← A fix SQL/logic, B fix UI         │
│       │ SQL   │ │ QML   │                                        │
│       └───────┘ └───────┘                                        │
└─────────────────────────────────────────────────────────────────┘
```

> [!IMPORTANT]
> **Nguyên tắc vàng:** Mỗi người hoàn thành **80% việc riêng** một cách độc lập. Chỉ **20% còn lại** là phần kết nối (đổi mock → real, đăng ký context, merge AI buttons). Phần 20% này được giải quyết tại **các mốc giao tiếp bắt buộc** cuối mỗi ngày.
