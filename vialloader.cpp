#include <QSqlQuery>
#include <QDebug>
#include <Qt>

#include "vialloader.h"
#include "connectodatabase.h"

VialLoader::VialLoader(QObject *parent) : QObject(parent){}

QList<QObject*> VialLoader::getVials(){
    QList<QObject *> vials;

    QSqlDatabase db = Database::connect();

    QSqlQuery query(db);
    query.prepare("SELECT `id`,`name`,`latitude`,`longitude`,`dateCreated`,`dateCollected`,`status` FROM `sand_storage`;");
    query.exec();

    while(query.next()){


        unsigned int id = query.value("id").toUInt();
        QString name = query.value("name").toString();
        double longitude = query.value("latitude").toDouble();
        double latitude = query.value("longitude").toDouble();
        QGeoCoordinate location(longitude, latitude);
        QDateTime dateCreated = query.value("dateCreated").toDateTime();
        dateCreated.setTimeSpec(Qt::UTC);
        QDateTime dateCollected = query.value("dateCollected").toDateTime();
        dateCollected.setTimeSpec(Qt::UTC);
        QString status = query.value("status").toString();

        Vial * vial = new Vial(id, name, location, dateCreated, dateCollected, status);

        vials.append(vial);
    }

    db.close();

    return vials;
}

Vial* VialLoader::createVial(QString name, QGeoCoordinate location, QDateTime dateCreated, QDateTime dateCollected)
{
    // Connect to database
    QSqlDatabase db = Database::connect();

    QDateTime now = QDateTime();

    // Prepare query
    QSqlQuery query(db);
    query.prepare("INSERT INTO `sand_storage`\
                  (`name`, `latitude`, `longitude`, `dateCreated`, `dateCollected`, `status`)\
                  VALUES\
                  (:name,:latitude,:longitude,:dateCreated,:dateCollected,:status);");
    query.bindValue(":name", name);
    query.bindValue(":latitude", location.latitude());
    query.bindValue(":longitude", location.longitude());
    query.bindValue(":dateCreated", dateCreated.toUTC());
    query.bindValue(":dateCollected", dateCollected.toUTC());
    query.bindValue(":status", Vial::status2string(Vial::Status::INVALID));

    // Save new vial to database
    if(query.exec()){
        qDebug() << "New vial created";
    } else {
        qCritical() << "Error creating new vial";
        qCritical() << query.lastQuery();
    }
    unsigned int id = query.lastInsertId().toUInt();
    qDebug() << "New row id:" << id;

    // Disconnect from database
    db.close();

    // Initalize basic properties
    Vial* vial = new Vial(id, name, location, dateCreated, dateCollected, Vial::status2string(Vial::Status::INVALID));

    return vial;
}
