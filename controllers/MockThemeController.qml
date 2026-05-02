import QtQuick
import Qt.labs.settings

QtObject {
    id: root

    // ===== Persisted state =====
    property string currentTheme: "light"   // "light" | "dark"

    property Settings _persist: Settings {
        category: "theme"
        property alias themeName: root.currentTheme
    }

    signal themeChanged(string newTheme)

    onCurrentThemeChanged: themeChanged(currentTheme)

    // ===== Color palette =====
    readonly property bool isDark: currentTheme === "dark"

    readonly property var colors: isDark ? _darkColors : _lightColors

    readonly property var _lightColors: ({
        // Page
        pageBg:         "#f8fafc",
        pageBgAlt:      "#ffffff",

        // Header (top bar) — vẫn dark cho nổi bật
        headerBg:       "#1f1f2e",
        headerText:     "#ffffff",
        headerSubText:  "#dddddd",

        // Surface (cards)
        surface:        "#ffffff",
        surfaceAlt:     "#f1f5f9",
        surfaceHover:   "#e2e8f0",
        border:         "#e2e8f0",
        borderStrong:   "#cbd5e1",

        // Text
        text:           "#0f172a",
        textMuted:      "#64748b",
        textSubtle:     "#94a3b8",

        // Accent (giữ nguyên — đã đẹp ở light)
        primary:        "#0ea5e9",
        success:        "#16a34a",
        warning:        "#f59e0b",
        danger:         "#dc2626",

        // Toggle
        toggleIcon:     "🌙",
        toggleTooltip:  "Chuyển dark mode"
    })

    readonly property var _darkColors: ({
        // Page
        pageBg:         "#0f172a",
        pageBgAlt:      "#1e293b",

        // Header — đậm hơn nữa cho contrast với page
        headerBg:       "#020617",
        headerText:     "#f8fafc",
        headerSubText:  "#cbd5e1",

        // Surface
        surface:        "#1e293b",
        surfaceAlt:     "#334155",
        surfaceHover:   "#475569",
        border:         "#334155",
        borderStrong:   "#475569",

        // Text
        text:           "#f1f5f9",
        textMuted:      "#cbd5e1",
        textSubtle:     "#94a3b8",

        // Accent
        primary:        "#38bdf8",
        success:        "#4ade80",
        warning:        "#fbbf24",
        danger:         "#f87171",

        // Toggle
        toggleIcon:     "☀️",
        toggleTooltip:  "Chuyển light mode"
    })

    // ===== Methods =====
    function toggle() {
        currentTheme = (currentTheme === "dark") ? "light" : "dark"
    }

    function setTheme(name) {
        if (name === "light" || name === "dark") {
            currentTheme = name
        }
    }
}