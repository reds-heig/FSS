#include "sp6Packet.h"

#include <QDebug>
#include <QStringList>

Sp6Packet::~Sp6Packet() {

}

Sp6Packet::Sp6Packet(QByteArray json)
{
    QJsonParseError err;
    doc = QJsonDocument::fromJson(QString(json).toLatin1(), &err);

    qDebug() << "[Sp6Packet] " << json.length() << ":" << json.data() << " Err: " << err.NoError;

    if(err.NoError)
    {
        qDebug() << "[Sp6Packet] Error: " << err.errorString();
        throw err.NoError;
    }

    jsonPacket = doc.object();

    qDebug() << jsonPacket.keys();

    if(jsonPacket["perif"].isNull())
    {
        qDebug() << "[Sp6Packet] No perif ID in packet";
        throw -1;
    }
    this->perId = jsonPacket["perif"].toString();
}

Sp6Packet::Sp6Packet(const char * perId)
{
    this->perId = perId;

    jsonPacket["perif"] = this->perId;

    qDebug() <<  "[Sp6Packet] Constructed from perif ID ";
}

int Sp6Packet::getInt(const char *key)
{
    if(jsonPacket.contains(key))
        return jsonPacket[key].toInt();
    else
        throw;
}

QString Sp6Packet::getString(const char *key) {
    if(jsonPacket.contains(key))
        return jsonPacket[key].toString();
    else
        throw;
}

Sp6Packet* Sp6Packet::add(const char *key,int value)
{
    jsonPacket.insert(key,QJsonValue(value));
    return this;
}

Sp6Packet* Sp6Packet::add(const char *key, const char *value)
{
    jsonPacket.insert(key,QJsonValue(QString(value)));
    return this;
}

bool Sp6Packet::hasKey(const char *s)
{
    return !(jsonPacket.find(s) == jsonPacket.end());
}

QByteArray Sp6Packet::getJSON()
{
    doc.setObject(jsonPacket);
    return doc.toJson(QJsonDocument::Compact);
}
