#include "authcontroller.h"

#include "core/databasemanager.h"

#include <QDebug>

AuthController::AuthController(QObject *parent) : QObject(parent) {}

// ─── login ────────────────────────────────────────────────────
void AuthController::login(const QString &username, const QString &password)
{
    if (username.trimmed().isEmpty() || password.isEmpty()) {
        emit loginFailed(QStringLiteral("Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu."));
        return;
    }

    DatabaseManager::UserRecord user;
    if (!DatabaseManager::instance().findUserByUsername(username.trimmed(), user)) {
        emit loginFailed(QStringLiteral("Tên đăng nhập không tồn tại."));
        return;
    }

    // So hash: hash(salt + password_user_gõ) vs password_hash trong DB.
    const QString candidateHash = DatabaseManager::hashPassword(password, user.passwordSalt);
    if (candidateHash != user.passwordHash) {
        emit loginFailed(QStringLiteral("Sai mật khẩu."));
        return;
    }

    // Đúng pass → set state + bắn signal cho QML.
    setCurrentUser(user.id, user.username, user.displayName,
                   user.role, user.mustChangePassword);
    qDebug() << "[Auth] Login OK:" << user.username
             << "(must change pass:" << user.mustChangePassword << ")";
}

// ─── changePassword ───────────────────────────────────────────
void AuthController::changePassword(const QString &oldPassword,
                                    const QString &newPassword)
{
    if (m_userId <= 0) {
        emit passwordChangeFailed(QStringLiteral("Bạn chưa đăng nhập."));
        return;
    }

    // 1. Validate độ dài pass mới (yêu cầu ≥ 6 ký tự).
    if (newPassword.length() < 6) {
        emit passwordChangeFailed(QStringLiteral("Mật khẩu mới phải có ít nhất 6 ký tự."));
        return;
    }

    // 2. Verify pass cũ — re-fetch user từ DB để lấy salt hiện tại.
    DatabaseManager::UserRecord user;
    if (!DatabaseManager::instance().findUserByUsername(m_username, user)) {
        emit passwordChangeFailed(QStringLiteral("Không tìm thấy tài khoản."));
        return;
    }
    const QString oldHash = DatabaseManager::hashPassword(oldPassword, user.passwordSalt);
    if (oldHash != user.passwordHash) {
        emit passwordChangeFailed(QStringLiteral("Mật khẩu cũ không đúng."));
        return;
    }

    // 3. Cấm đặt pass mới giống pass cũ.
    if (oldPassword == newPassword) {
        emit passwordChangeFailed(QStringLiteral("Mật khẩu mới phải khác mật khẩu cũ."));
        return;
    }

    // 4. Update DB.
    if (!DatabaseManager::instance().updateUserPassword(m_userId, newPassword)) {
        emit passwordChangeFailed(QStringLiteral("Lỗi khi cập nhật mật khẩu."));
        return;
    }

    // 5. Cập nhật state local: must_change_password đổi false.
    m_mustChangePassword = false;
    emit currentUserChanged();
    emit passwordChanged();
    qDebug() << "[Auth] Password changed OK for user:" << m_username;
}

// ─── logout ───────────────────────────────────────────────────
void AuthController::logout()
{
    clearCurrentUser();
    qDebug() << "[Auth] Logout OK";
}

// ─── Helper internal ──────────────────────────────────────────
void AuthController::setCurrentUser(int id,
                                    const QString &username,
                                    const QString &displayName,
                                    const QString &role,
                                    bool mustChange)
{
    m_userId             = id;
    m_username           = username;
    m_displayName        = displayName;
    m_role               = role;
    m_mustChangePassword = mustChange;
    emit currentUserChanged();
}

void AuthController::clearCurrentUser()
{
    m_userId             = -1;
    m_username.clear();
    m_displayName.clear();
    m_role.clear();
    m_mustChangePassword = false;
    emit currentUserChanged();
}