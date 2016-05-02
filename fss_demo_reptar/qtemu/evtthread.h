#ifndef EVTTHREAD_H
#define EVTTHREAD_H

#include <QThread>
#include <QTcpSocket>
#include <QQueue>
#include <QSemaphore>

#include "sp6Packet.h"
#include <qglobal.h>
#include <stdint.h>

class EvtThread : public QThread
{
    Q_OBJECT

public:
    EvtThread(QTcpSocket *client, QObject *parent);
    ~EvtThread();
    void run();

public slots:
    void eventPostProcess(Sp6Packet *p);
    void shouldStop();

signals:
    void error(QTcpSocket::SocketError socketError);

private:
    QTcpSocket *socket;
    QQueue<Sp6Packet*> *eventQueue;
    QSemaphore *eventSem;

    bool isRunning;
};


#endif // EVTTHREAD_H
