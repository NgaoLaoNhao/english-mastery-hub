#ifndef GEMINICONTROLLER_H
#define GEMINICONTROLLER_H

#include <QObject>
#include <QString>

class GeminiController : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY loadingChanged)
    Q_PROPERTY(QString lastResponse READ lastResponse NOTIFY responseReceived)
public:
    explicit GeminiController(QObject *parent = nullptr);

    Q_INVOKABLE void askGemini(const QString &prompt);
    Q_INVOKABLE void analyzeProgress(const QString &dataJson);
    Q_INVOKABLE void summarizeResource(const QString &content);
    Q_INVOKABLE void generateWarning(const QString &name, int lazyDays);

    bool isLoading() const { return m_isLoading; }
    QString lastResponse() const { return m_lastResponse; }

signals:
    void responseReceived(const QString &text);
    void errorOccurred(const QString &error);
    void loadingChanged();

private:
    void runPythonBridge(const QString &mode, const QString &data);
    QString m_apiKey;
    QString m_lastResponse;
    bool m_isLoading = false;
};
#endif // GEMINICONTROLLER_H
