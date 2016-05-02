#ifndef CMDTHREAD_H
#define CMDTHREAD_H

#include <QThread>
#include <QTcpSocket>
#include <QTcpServer>
#include <QSemaphore>

#include "sp6Packet.h"

class CmdThread : public QThread
{
    Q_OBJECT

public:
    CmdThread(QTcpSocket *client, QObject *parent);
    ~CmdThread();
    void run();

public slots:
    void shouldStop();

signals:
    void clcdCmd(Sp6Packet * p);
    void ledCmd(Sp6Packet * p);
    void sevenSegCmd(Sp6Packet * p);

private:
    QTcpSocket *socket;
    QSemaphore *cmdSem;

    bool isRunning;

private slots:
    void dataAvailable();

};


#endif // CMDTHREAD_H
