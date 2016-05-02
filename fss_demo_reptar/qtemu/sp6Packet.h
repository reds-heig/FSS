#ifndef SP6EVENT_H
#define SP6EVENT_H

#include <QJsonDocument>
#include <QJsonObject>
#include <QString>

#include <stdint.h>
#include <qglobal.h>

class Sp6Packet
{

public:
    QString perId;

    Sp6Packet(QByteArray json);
    Sp6Packet(const char *perId);

    Sp6Packet* add(const char *s1,const char *s2);

    Sp6Packet* add(const char *s1,int value);

    ~Sp6Packet();

    int getInt(const char *s);

    QString getString(const char *s);

    bool hasKey(const char *s);

    QByteArray getJSON();

private:
    QJsonObject jsonPacket;
    QJsonDocument doc;
};

#endif // SP6EVENT_H
