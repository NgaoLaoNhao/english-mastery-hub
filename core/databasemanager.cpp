#include "databasemanager.h"

#include <QCoreApplication>
#include <QCryptographicHash>
#include <QDebug>
#include <QDir>
#include <QRandomGenerator>
#include <QSqlError>
#include <QSqlQuery>
#include <QStandardPaths>

namespace {
// Tên connection nội bộ (Qt cho phép nhiều connection, ta chỉ cần 1).
const QString kConnectionName = "english_mastery_hub_main";
const QString kDbFileName     = "database.db";
}

// ─── Singleton ─────────────────────────────────────────────────
DatabaseManager &DatabaseManager::instance()
{
    static DatabaseManager s_instance;  // C++11: tạo 1 lần, thread-safe.
    return s_instance;
}

DatabaseManager::DatabaseManager(QObject *parent) : QObject(parent) {}

DatabaseManager::~DatabaseManager()
{
    if (m_db.isOpen())
        m_db.close();
}

// ─── Khởi tạo DB ───────────────────────────────────────────────
bool DatabaseManager::initialize()
{
    // 1. Xác định folder lưu DB (vd C:\Users\Admin\AppData\Roaming\EnglishMasteryHub\)
    const QString dataDir = QStandardPaths::writableLocation(
        QStandardPaths::AppDataLocation);
    QDir().mkpath(dataDir);  // Tạo folder nếu chưa có.

    const QString dbPath = dataDir + "/" + kDbFileName;
    qDebug() << "[DB] Path:" << dbPath;

    // 2. Tạo connection SQLite
    m_db = QSqlDatabase::addDatabase("QSQLITE", kConnectionName);
    m_db.setDatabaseName(dbPath);

    if (!m_db.open()) {
        qCritical() << "[DB] Cannot open:" << m_db.lastError().text();
        return false;
    }

    // 3. Bật foreign keys + WAL mode (an toàn + nhanh hơn).
    QSqlQuery pragma(m_db);
    pragma.exec("PRAGMA foreign_keys = ON");
    pragma.exec("PRAGMA journal_mode = WAL");

    // 4. Tạo schema.
    if (!createSchema())
        return false;

    // 5. Seed admin nếu chưa có.
    if (!seedAdminIfMissing())
        return false;

    qDebug() << "[DB] Initialized OK";
    return true;
}

// ─── Tạo schema (6 bảng) ───────────────────────────────────────
bool DatabaseManager::createSchema()
{
    QSqlQuery q(m_db);

    const QStringList stmts = {
        // groups
        R"(CREATE TABLE IF NOT EXISTS groups (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            name        TEXT NOT NULL UNIQUE,
            cover_path  TEXT,
            leader_id   INTEGER,
            created_at  TEXT NOT NULL DEFAULT (datetime('now'))
        ))",

        // users
        R"(CREATE TABLE IF NOT EXISTS users (
            id                    INTEGER PRIMARY KEY AUTOINCREMENT,
            username              TEXT NOT NULL UNIQUE,
            password_hash         TEXT NOT NULL,
            password_salt         TEXT NOT NULL,
            display_name          TEXT NOT NULL,
            avatar_path           TEXT,
            role                  TEXT NOT NULL DEFAULT 'member',
            group_id              INTEGER REFERENCES groups(id) ON DELETE SET NULL,
            must_change_password  INTEGER NOT NULL DEFAULT 1,
            created_at            TEXT NOT NULL DEFAULT (datetime('now'))
        ))",

        // checkins
        R"(CREATE TABLE IF NOT EXISTS checkins (
            id              INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id         INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
            checkin_date    TEXT NOT NULL,
            bookworm_hours  REAL NOT NULL DEFAULT 0
                            CHECK (bookworm_hours >= 0 AND bookworm_hours <= 12),
            ministory_hours REAL NOT NULL DEFAULT 0
                            CHECK (ministory_hours >= 0 AND ministory_hours <= 12),
            created_at      TEXT NOT NULL DEFAULT (datetime('now')),
            UNIQUE (user_id, checkin_date)
        ))",
        "CREATE INDEX IF NOT EXISTS idx_checkins_user_date ON checkins(user_id, checkin_date)",

        // resources
        R"(CREATE TABLE IF NOT EXISTS resources (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            title       TEXT NOT NULL,
            category    TEXT,
            kind        TEXT NOT NULL CHECK (kind IN ('link','file')),
            target      TEXT NOT NULL,
            description TEXT,
            created_at  TEXT NOT NULL DEFAULT (datetime('now'))
        ))",

        // app_settings
        R"(CREATE TABLE IF NOT EXISTS app_settings (
            key   TEXT PRIMARY KEY,
            value TEXT
        ))",

        // activity_log
        R"(CREATE TABLE IF NOT EXISTS activity_log (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            actor_id    INTEGER REFERENCES users(id) ON DELETE SET NULL,
            action_type TEXT NOT NULL,
            target_type TEXT,
            target_id   INTEGER,
            description TEXT,
            created_at  TEXT NOT NULL DEFAULT (datetime('now'))
        ))"
    };

    for (const QString &sql : stmts) {
        if (!q.exec(sql)) {
            qCritical() << "[DB] createSchema fail:" << q.lastError().text()
            << "\nSQL:" << sql;
            return false;
        }
    }
    return true;
}

// ─── Seed admin mặc định ───────────────────────────────────────
bool DatabaseManager::seedAdminIfMissing()
{
    QSqlQuery q(m_db);
    q.prepare("SELECT COUNT(*) FROM users WHERE role = 'admin'");
    if (!q.exec() || !q.next()) {
        qCritical() << "[DB] count admin fail:" << q.lastError().text();
        return false;
    }
    if (q.value(0).toInt() > 0)
        return true;  // Đã có admin, không cần seed.

    const QString salt = generateSalt();
    const QString hash = hashPassword("admin123", salt);

    QSqlQuery ins(m_db);
    ins.prepare(R"(
        INSERT INTO users
            (username, password_hash, password_salt, display_name,
             role, must_change_password)
        VALUES
            (:u, :h, :s, :d, 'admin', 1)
    )");
    ins.bindValue(":u", "admin");
    ins.bindValue(":h", hash);
    ins.bindValue(":s", salt);
    ins.bindValue(":d", "Administrator");

    if (!ins.exec()) {
        qCritical() << "[DB] seed admin fail:" << ins.lastError().text();
        return false;
    }
    qDebug() << "[DB] Seeded default admin (admin / admin123)";
    return true;
}

// ─── Tìm user theo username ────────────────────────────────────
bool DatabaseManager::findUserByUsername(const QString &username,
                                         UserRecord &outUser)
{
    QSqlQuery q(m_db);
    q.prepare(R"(
        SELECT id, username, password_hash, password_salt, display_name,
               avatar_path, role, group_id, must_change_password
        FROM users
        WHERE username = :u
        LIMIT 1
    )");
    q.bindValue(":u", username);

    if (!q.exec()) {
        qCritical() << "[DB] findUserByUsername fail:" << q.lastError().text();
        return false;
    }
    if (!q.next())
        return false;  // Không tìm thấy.

    outUser.id                 = q.value(0).toInt();
    outUser.username           = q.value(1).toString();
    outUser.passwordHash       = q.value(2).toString();
    outUser.passwordSalt       = q.value(3).toString();
    outUser.displayName        = q.value(4).toString();
    outUser.avatarPath         = q.value(5).toString();
    outUser.role               = q.value(6).toString();
    outUser.groupId            = q.value(7).isNull() ? -1 : q.value(7).toInt();
    outUser.mustChangePassword = q.value(8).toInt() != 0;
    return true;
}

// ─── Đổi mật khẩu (đồng thời clear cờ must_change) ────────────
bool DatabaseManager::updateUserPassword(int userId,
                                         const QString &newPlainPassword)
{
    const QString salt = generateSalt();
    const QString hash = hashPassword(newPlainPassword, salt);

    QSqlQuery q(m_db);
    q.prepare(R"(
        UPDATE users
        SET password_hash = :h,
            password_salt = :s,
            must_change_password = 0
        WHERE id = :id
    )");
    q.bindValue(":h", hash);
    q.bindValue(":s", salt);
    q.bindValue(":id", userId);

    if (!q.exec()) {
        qCritical() << "[DB] updateUserPassword fail:" << q.lastError().text();
        return false;
    }
    return q.numRowsAffected() > 0;
}

// ─── Helper: hash + salt ───────────────────────────────────────
QString DatabaseManager::hashPassword(const QString &plainPassword,
                                      const QString &salt)
{
    const QByteArray combined = (salt + plainPassword).toUtf8();
    const QByteArray digest   = QCryptographicHash::hash(
        combined, QCryptographicHash::Sha256);
    return QString::fromLatin1(digest.toHex());
}

QString DatabaseManager::generateSalt()
{
    QByteArray salt(16, '\0');  // 16 byte (128 bit)
    for (int i = 0; i < salt.size(); ++i) {
        salt[i] = static_cast<char>(
            QRandomGenerator::system()->bounded(256));
    }
    return QString::fromLatin1(salt.toHex());
}