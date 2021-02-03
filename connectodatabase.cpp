#include <QDebug>
#include <QSettings>
#include <QGuiApplication>

#include "connectodatabase.h"

void Database::init(QGuiApplication* app){
    QSettings settings(QString("config.ini"), QSettings::IniFormat);
    QString driver = settings.value("mysql/driver").toString();
    QString hostname = settings.value("mysql/hostname").toString();
    QString username = settings.value("mysql/username").toString();
    QString password = settings.value("mysql/password").toString();
    QString databaseName = settings.value("mysql/databaseName").toString();

    QSqlDatabase db = QSqlDatabase::addDatabase(driver);
    db.setHostName(hostname);
    db.setUserName(username);
    db.setPassword(password);
    db.setDatabaseName(databaseName);
    db.setConnectOptions("SSL_KEY=client-key.pem;SSL_CERT=client-cert.pem;SSL_CA=server-ca.pem;CLIENT_IGNORE_SPACE=1");

    qDebug() << app->applicationDirPath();
}

QSqlDatabase Database::connect()
{
    return QSqlDatabase::database();
}
