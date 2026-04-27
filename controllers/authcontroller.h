#ifndef AUTHCONTROLLER_H
#define AUTHCONTROLLER_H

#include <QObject>

class AuthController : public QObject
{
    Q_OBJECT
public:
    explicit AuthController(QObject *parent = nullptr);

signals:
};

#endif // AUTHCONTROLLER_H
