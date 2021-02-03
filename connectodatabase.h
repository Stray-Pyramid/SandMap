#ifndef CONNECTTODATABASE_H
#define CONNECTTODATABASE_H
#include <QtSql/QSqlDatabase>
#include <QGuiApplication>

class Database
{
public:
    static void init(QGuiApplication* app);
    static QSqlDatabase connect();
};

#endif // CONNECTTODATABASE_H
