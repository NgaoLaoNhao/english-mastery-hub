#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <QObject>
#include <QSqlDatabase>
#include <QString>

class DatabaseManager : public QObject
{
    Q_OBJECT

public:
    // ─── Singleton ─────────────────────────────────────
    // Truy cập duy nhất qua DatabaseManager::instance()
    static DatabaseManager& instance();

    // ─── Khởi tạo ──────────────────────────────────────
    // Gọi 1 lần lúc app khởi động (trong main.cpp).
    // Mở DB, tạo schema, seed admin nếu cần.
    // Trả về true nếu OK, false nếu fail.
    bool initialize();

    // ─── Cấu trúc đại diện 1 user ─────────────────────
    struct UserRecord {
        int     id = -1;
        QString username;
        QString passwordHash;
        QString passwordSalt;
        QString displayName;
        QString avatarPath;
        QString role;            // "admin" hoặc "member"
        int     groupId = -1;    // -1 nếu chưa thuộc nhóm nào
        bool    mustChangePassword = false;
    };

    // ─── Thao tác liên quan đến user (cần cho M1) ─────

    // Tìm user theo username. Nếu thấy, điền vào outUser & trả true.
    // Nếu không thấy, trả false.
    bool findUserByUsername(const QString &username, UserRecord &outUser);

    // Đổi mật khẩu cho user (đồng thời clear cờ must_change_password).
    bool updateUserPassword(int userId, const QString &newPlainPassword);

    // ─── Helper public ────────────────────────────────

    // Hash mật khẩu = SHA-256( salt + plainPassword ) → hex.
    static QString hashPassword(const QString &plainPassword,
                                const QString &salt);

    // Tạo salt ngẫu nhiên 16 byte (hex).
    static QString generateSalt();

private:
    // Singleton: cấm tạo instance từ bên ngoài, cấm copy.
    explicit DatabaseManager(QObject *parent = nullptr);
    ~DatabaseManager();
    DatabaseManager(const DatabaseManager &) = delete;
    DatabaseManager &operator=(const DatabaseManager &) = delete;

    // Helper internal
    bool createSchema();        // CREATE TABLE IF NOT EXISTS ...
    bool seedAdminIfMissing();  // Tạo admin/admin123 nếu chưa có

    QSqlDatabase m_db;          // connection tới SQLite
};

#endif // DATABASEMANAGER_H