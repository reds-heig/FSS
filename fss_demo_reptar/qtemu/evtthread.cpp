#include "evtthread.h"
#include "config.h"
#include "sp6Packet.h"

EvtThread::EvtThread(QTcpSocket *client, QObject *parent)
    : QThread(parent)
{
    eventQueue  = new QQueue<Sp6Packet*>;
    eventSem    = new QSemaphore();

    socket      = client;
    isRunning   = true;

    connect(client, SIGNAL(disconnected()),this, SLOT(shouldStop()));
}

EvtThread::~EvtThread()
{
    delete eventQueue;
    delete eventSem;
    delete socket;
}

void EvtThread::shouldStop()
{
    /*
     * If still connected, disconnect. This slot will be called again.
     */
    if(socket->state() != QAbstractSocket::UnconnectedState)
    {
        socket->disconnectFromHost();
        return;
    }

    isRunning = false;

    eventSem->release();
}

void EvtThread::run()
{
        Sp6Packet *event;

        while(isRunning)
        {
            while(eventQueue->isEmpty() && isRunning)
                eventSem->acquire();

            if(!isRunning)
                break;

            qDebug() << "[EvtThread] run. Dequeuing.";

            event = eventQueue->dequeue();

            socket->write(event->getJSON().append("\n"));
            socket->flush();

            qDebug() << "[EvtThread] Wrote " << event->getJSON();

            delete event;
        }

    qDebug() << "[EvtThread] finished";
}

void EvtThread::eventPostProcess(Sp6Packet *p) {

    eventQueue->enqueue(p);
    qDebug() << "[EvtThread] eventPostProcess enqueed ";

    eventSem->release();
}
