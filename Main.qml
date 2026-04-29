// file: Main.qml  (FULL FILE — thay thế nội dung cũ)
//
// =============================================================
//  Root window + Router của app.
//  Chứa "công tắc" useMocks để switch giữa Mock (QML) và Real (C++).
// =============================================================

import QtQuick
import QtQuick.Controls.Basic

// Import folder mocks/ với alias "Mocks" để tránh đụng namespace.
import "mocks" as Mocks

Window {
    id: mainWindow
    width: 480
    height: 560
    visible: true
    title: qsTr("English Mastery Hub")

    // ─── Công tắc Mock-first ──────────────────────────────────
    //  true  = chạy bằng MockAuthController (QML thuần, không cần DB)
    //  false = chạy bằng AuthController C++ (context property "authController")
    //
    //  ⚠️ QUY ƯỚC TEAM: trước khi merge vào main, mặc định FALSE.
    //  Khi dev UI cục bộ thì tự bật TRUE rồi tắt lại trước khi commit.
    property bool useMocks: false

    // ─── Mock instance (luôn tồn tại, chỉ được dùng khi useMocks === true) ──
    Mocks.MockAuthController {
        id: mockAuthController
    }

    // ─── Biến `auth` trung gian — tất cả View con dùng cái này ──
    //  Mọi View đọc property / gọi function / Connections target tới `auth`,
    //  KHÔNG còn đụng trực tiếp `authController` hay `mockAuthController`.
    //  Nhờ vậy đổi useMocks là 1 dòng, View không phải sửa gì.
    property var auth: useMocks ? mockAuthController : authController

    // ─── Component templates (Lazy load, chỉ instantiate khi cần) ──
    Component { id: loginComponent;       LoginView          {} }
    Component { id: changePassComponent;  ChangePasswordView {} }
    Component { id: welcomeComponent;     WelcomeView        {} }

    // ─── Router: chọn View dựa trên state auth ─────────────────
    Loader {
        id: rootLoader
        anchors.fill: parent
        sourceComponent: {
            // Binding này tự re-evaluate khi auth.isLoggedIn hoặc
            // auth.mustChangePassword đổi (vì truy cập property của auth).
            if (!mainWindow.auth.isLoggedIn)
                return loginComponent
            if (mainWindow.auth.mustChangePassword)
                return changePassComponent
            return welcomeComponent
        }
    }
}