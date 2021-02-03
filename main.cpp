#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtSql>
#include <QFileInfo>
#include <QSettings>


#include "vial.h"
#include "vialloader.h"

bool fileExists(QString path);

int main(int argc, char *argv[])
{
    qDebug() << "Sandmap started";

    qmlRegisterType<Vial>("Vial", 1, 0, "Vial");
    qmlRegisterType<VialLoader>("VialLoader", 1, 0, "VialLoader");

    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    // generates a 'None'/Invalid date. Used in vial collectedOn datetime.
    engine.rootContext()->setContextProperty("invalidDate", QDateTime());
    engine.rootContext()->setContextProperty("homeDir", qApp->applicationDirPath());

    Database::init(qApp);

    QSettings settings(QString("config.ini"), QSettings::IniFormat);
    QString mb_access_token = settings.value("mapbox/access_token").toString();
    engine.rootContext()->setContextProperty("mapbox_access_token", mb_access_token);

    engine.load(url);

    return app.exec();
}
