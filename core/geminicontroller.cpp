#include "geminicontroller.h"
#include <QProcess>
#include <QJsonDocument>
#include <QJsonObject>
#include <QCoreApplication>
#include <QDebug>

GeminiController::GeminiController(QObject *parent) : QObject(parent) {
    m_apiKey = qEnvironmentVariable("GEMINI_API_KEY");
    if (m_apiKey.isEmpty())
        qWarning() << "GEMINI_API_KEY not set!";
}

void GeminiController::runPythonBridge(const QString &mode, const QString &data) {
    m_isLoading = true;
    emit loadingChanged();

    auto *proc = new QProcess(this);
    QString scriptPath = QCoreApplication::applicationDirPath() + "/scripts/gemini_bridge.py";

    connect(proc, &QProcess::finished, this, [this, proc](int exitCode) {
        m_isLoading = false;
        emit loadingChanged();

        auto output = proc->readAllStandardOutput();
        auto doc = QJsonDocument::fromJson(output).object();

        if (exitCode == 0 && doc["ok"].toBool()) {
            m_lastResponse = doc["text"].toString();
            emit responseReceived(m_lastResponse);
        } else {
            QString err = doc["error"].toString();
            if (err.isEmpty()) err = proc->readAllStandardError();
            emit errorOccurred(err);
        }
        proc->deleteLater();
    });

    proc->start("python", {scriptPath, "--mode", mode, "--data", data, "--api-key", m_apiKey});
}

void GeminiController::askGemini(const QString &prompt) {
    runPythonBridge("chat", prompt);
}

void GeminiController::generateWarning(const QString &name, int lazyDays) {
    runPythonBridge("warn", QString("%1 đã lười biếng %2 ngày").arg(name).arg(lazyDays));
}

void GeminiController::analyzeProgress(const QString &dataJson) {
    runPythonBridge("analyze", dataJson);
}

void GeminiController::summarizeResource(const QString &content) {
    runPythonBridge("summarize", content);
}
