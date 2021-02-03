#include "vial.h"
#include <QSqlQuery>
#include <QVariant>
#include <QDebug>

#include "connectodatabase.h"

Vial::Vial(QObject *parent): QObject(parent){}

Vial::Vial(unsigned int id, QString name, QGeoCoordinate location, QDateTime dateCreated, QDateTime dateCollected, QString status){
    _id = id;
    _name = name;
    _location = location;
    _dateCreated = dateCreated;
    _dateCollected = dateCollected;
    _status = string2status(status);

}

unsigned int Vial::id() const {
    return _id;
}

QString Vial::name() const{
    return _name;
}

void Vial::setName(QString name){
    if (_name == name) return;

    _name = name;

    QSqlDatabase db = Database::connect();

    QSqlQuery query(db);
    query.prepare("UPDATE `sand_storage` SET\
                  `name` = :name,\
                  WHERE `id` = :id;");
    query.bindValue(":name", _name);
    query.bindValue(":id", _id);
    query.exec();

    db.close();

    emit nameChanged();
}

QGeoCoordinate Vial::location() const {
    return _location;
}

void Vial::setLocation(QGeoCoordinate location){
    if (_location == location) return;

    _location = location;

    QSqlDatabase db = Database::connect();

    QSqlQuery query(db);
    query.prepare("UPDATE `sand_storage` SET\
                  `latitude` = :latitude,`longitude` = :longitude,\
                  WHERE `id` = :id;");
    query.bindValue(":latitude", _location.latitude());
    query.bindValue(":longitude", _location.longitude());
    query.bindValue(":id", _id);
    query.exec();

    db.close();

    emit locationChanged();
}

QDateTime Vial::dateCreated() const {
    return _dateCreated;
}

void Vial::setDateCreated(QDateTime dateCreated){
    if (_dateCreated == dateCreated) return;

    _dateCreated = dateCreated;

    QSqlDatabase db = Database::connect();

    QSqlQuery query(db);
    query.prepare("UPDATE `sand_storage` SET\
                  `dateCreated` = :dateCreated\
                  WHERE `id` = :id;");

    query.bindValue(":dateCreated", dateCreated);
    query.bindValue(":id", _id);
    query.exec();

    db.close();

    emit dateCreatedChanged();
}

QDateTime Vial::dateCollected() const {
    return _dateCollected;
}

void Vial::setDateCollected(QDateTime dateCollected){
    if (_dateCollected == dateCollected) return;

    _dateCollected = dateCollected;

    QSqlDatabase db = Database::connect();

    QSqlQuery query(db);
    query.prepare("UPDATE `sand_storage` SET\
                  `dateCompleted` = :dateCollected\
                  WHERE `id` = :id;");

    query.bindValue(":dateCompleted", dateCollected);
    query.bindValue(":id", _id);
    query.exec();

    db.close();

    emit dateCollectedChanged();
}

Vial::Status Vial::status() const {
    return _status;
}

void Vial::setStatus(Vial::Status status){
    if(_status == status) return;

    _status = status;

    QSqlDatabase db = Database::connect();

    QSqlQuery query(db);
    query.prepare("UPDATE `sand_storage` SET\
                  `status` = :status\
                  WHERE `id` = :id;");

    query.bindValue(":status", status2string(_status));
    query.bindValue(":id", _id);
    query.exec();

    db.close();

    emit statusChanged();
}



void Vial::deleteVial(){
    QSqlDatabase db = Database::connect();

    QSqlQuery query(db);
    query.prepare("DELETE FROM `sand_storage`\
                  WHERE `id` = :id;");

    query.bindValue(":id", _id);
    query.exec();

    db.close();
}

QString Vial::getStatusString(){
    return status2string(_status);
}

QString Vial::status2string(Vial::Status status){
    switch(status){
        case Status::ACTIVE:
            return "ACTIVE";
        case Status::COLLECTED:
            return "COLLECTED";
        case Status::INACTIVE:
            return "INACTIVE";
        case Status::SKIPPED:
            return "SKIPPED";
        case Status::INVALID:
        default:
            return "INVALID";
    }
}


Vial::Status Vial::string2status(QString status){
    if (status == "ACTIVE") return Status::ACTIVE;
    if (status == "COLLECTED") return Status::COLLECTED;
    if (status == "INACTIVE") return Status::INACTIVE;
    if (status == "SKIPPED") return Status::SKIPPED;

    return Status::INVALID;
}
