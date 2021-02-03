#ifndef VIAL_H
#define VIAL_H

#include <QObject>
#include <QStringList>
#include <QQmlContext>
#include <QDateTime>
#include <QGeoCoordinate>

#include "connectodatabase.h"

class Vial : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int id READ id)

    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QGeoCoordinate location READ location WRITE setLocation NOTIFY locationChanged)
    Q_PROPERTY(QDateTime dateCreated READ dateCreated WRITE setDateCreated NOTIFY dateCreatedChanged)
    Q_PROPERTY(QDateTime dateCollected READ dateCollected WRITE setDateCollected NOTIFY dateCollectedChanged)
    Q_PROPERTY(Vial::Status status READ status WRITE setStatus NOTIFY statusChanged)

public:
    enum Status
    {
        COLLECTED,
        ACTIVE,
        INACTIVE,
        SKIPPED,
        INVALID
    };
    Q_ENUM(Status)

    explicit Vial(QObject *parent = nullptr);
    Vial(unsigned int id, QString name, QGeoCoordinate location, QDateTime dateCreated, QDateTime dateCollected, QString status);

    unsigned int id() const;

    QString name() const;
    void setName(QString name);

    QGeoCoordinate location() const;
    void setLocation(QGeoCoordinate location);

    QDateTime dateCreated() const;
    void setDateCreated(QDateTime dateCreated);

    QDateTime dateCollected() const;
    void setDateCollected(QDateTime dateCollected);

    Vial::Status status() const;
    void setStatus(Vial::Status status);

    Q_INVOKABLE void deleteVial();

    Q_INVOKABLE QString getStatusString();

    static QString status2string(Vial::Status status);
    static Vial::Status string2status(QString status);

signals:
    void nameChanged();
    void locationChanged();
    void dateCreatedChanged();
    void dateCollectedChanged();
    void statusChanged();

private:
    int _id;
    QString _name;
    QGeoCoordinate _location;
    QDateTime _dateCreated; // Set in initalizer
    QDateTime _dateCollected; // Set when _status changed to "COMPLETED"
    Vial::Status _status;
};

#endif // VIALSERVICES_H
