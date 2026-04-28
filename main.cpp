#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QDebug>

#include "core/databasemanager.h"
#include "controllers/authcontroller.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // ─── Metadata app — dùng cho QStandardPaths::AppDataLocation ────
    // Path lưu DB sẽ là: %APPDATA%/EnglishMasteryHub/database.db
    QGuiApplication::setOrganizationName("EnglishMasteryHub");
    QGuiApplication::setOrganizationDomain("englishmasteryhub.local");
    QGuiApplication::setApplicationName("EnglishMasteryHub");
    QGuiApplication::setApplicationVersion("0.1");

    // ─── Style mặc định cho QtQuick.Controls (Basic = clean, gọn) ───
    QQuickStyle::setStyle("Basic");

    // ─── Khởi tạo DB (mở SQLite, tạo schema, seed admin) ────────────
    if (!DatabaseManager::instance().initialize()) {
        qCritical() << "Cannot initialize database. Exiting.";
        return -1;
    }

    // ─── Tạo AuthController + expose ra QML ─────────────────────────
    AuthController authController;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("authController", &authController);

    // ─── Bắt sự kiện engine load lỗi ────────────────────────────────
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    // ─── Load Main.qml từ module EnglishMasteryHub ──────────────────
    engine.loadFromModule("EnglishMasteryHub", "Main");

    return app.exec();
}