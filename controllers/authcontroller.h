#ifndef AUTHCONTROLLER_H
#define AUTHCONTROLLER_H

#include <QObject>
#include <QString>

class AuthController : public QObject
{
    Q_OBJECT

    // ─── Properties expose ra QML ────────────────────────────
    // QML có thể đọc: authController.isLoggedIn, authController.currentUsername, ...
    Q_PROPERTY(bool    isLoggedIn          READ isLoggedIn          NOTIFY currentUserChanged)
    Q_PROPERTY(bool    mustChangePassword  READ mustChangePassword  NOTIFY currentUserChanged)
    Q_PROPERTY(int     currentUserId       READ currentUserId       NOTIFY currentUserChanged)
    Q_PROPERTY(QString currentUsername     READ currentUsername     NOTIFY currentUserChanged)
    Q_PROPERTY(QString currentDisplayName  READ currentDisplayName  NOTIFY currentUserChanged)
    Q_PROPERTY(QString currentRole         READ currentRole         NOTIFY currentUserChanged)

public:
    explicit AuthController(QObject *parent = nullptr);

    // ─── Getter cho Q_PROPERTY ──────────────────────────────
    bool    isLoggedIn()         const { return m_userId > 0; }
    bool    mustChangePassword() const { return m_mustChangePassword; }
    int     currentUserId()      const { return m_userId; }
    QString currentUsername()    const { return m_username; }
    QString currentDisplayName() const { return m_displayName; }
    QString currentRole()        const { return m_role; }

    // ─── Method QML gọi được ────────────────────────────────
    // Đăng nhập với username + password (plain).
    // Thành công → emit currentUserChanged.
    // Thất bại  → emit loginFailed(lý do).
    Q_INVOKABLE void login(const QString &username,
                           const QString &password);

    // Đổi mật khẩu cho user đang đăng nhập.
    // Thành công → emit passwordChanged + currentUserChanged
    //              (vì must_change_password đổi false).
    // Thất bại  → emit passwordChangeFailed(lý do).
    Q_INVOKABLE void changePassword(const QString &oldPassword,
                                    const QString &newPassword);

    // Đăng xuất.
    Q_INVOKABLE void logout();

signals:
    // Phát khi state user thay đổi: login / logout / đổi pass.
    void currentUserChanged();

    // Phát khi login fail (sai pass, không tìm thấy user).
    void loginFailed(const QString &reason);

    // Phát khi đổi pass thành công.
    void passwordChanged();

    // Phát khi đổi pass fail (sai pass cũ, pass mới quá ngắn, ...).
    void passwordChangeFailed(const QString &reason);

private:
    // Helper internal — set hoặc clear state user hiện tại.
    void setCurrentUser(int id,
                        const QString &username,
                        const QString &displayName,
                        const QString &role,
                        bool mustChange);
    void clearCurrentUser();

    // ─── State user đang đăng nhập ──────────────────────────
    int     m_userId             = -1;     // -1 = chưa đăng nhập
    QString m_username;
    QString m_displayName;
    QString m_role;
    bool    m_mustChangePassword = false;
};

#endif // AUTHCONTROLLER_H