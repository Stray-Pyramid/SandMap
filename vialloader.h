#ifndef VIALLOADER_H
#define VIALLOADER_H


#include "vial.h"

class VialLoader : public QObject
{
    Q_OBJECT
public:
    explicit VialLoader(QObject *parent = nullptr);
    Q_INVOKABLE static QList<QObject*> getVials();
    Q_INVOKABLE static Vial* createVial(QString name, QGeoCoordinate location, QDateTime dateCreated, QDateTime dateCollected);

};

#endif // VIALLOADER_H
