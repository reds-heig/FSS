#include <QMutex>
#include <QDebug>

#include "cmdthread.h"
#include "config.h"
#include "sp6Packet.h"

CmdThread::CmdThread(QTcpSocket *client, QObject *parent)
    : QThread(parent)
{
    cmdSem    = new QSemaphore();

    socket = client;
    isRunning = true;

    connect(client, SIGNAL(disconnected()),this, SLOT(shouldStop()));
    connect(client, SIGNAL(readyRead()),this,SLOT(dataAvailable()));
}
CmdThread::~CmdThread()
{
    delete cmdSem;
}

void CmdThread::shouldStop()
{
    /*
     * If still connected, disconnect. This slot will be called again.
     */
    qDebug() << "[CmdThread::shouldStop]";

    if(socket->state() != QAbstractSocket::UnconnectedState)
    {
        qDebug() << "[CmdThread::shouldStop] socket was connected, disconnect it";

        socket->disconnectFromHost();
        return;
    }

    isRunning = false;

    cmdSem->release();
}

void CmdThread::dataAvailable()
{
    qDebug() << "[CmdThread::dataAvailable]";
    cmdSem->release();
}

void CmdThread::run()
{
    QByteArray inBuffer;
    int newLineIndex;
    Sp6Packet *packet = NULL;

    while (isRunning)
    {
        /* Wait if there is nothing to read from socket */
        while(!socket->bytesAvailable() && isRunning)
            cmdSem->acquire();

        /* If we were waken up, was it to ask us to quit? */
        if(!isRunning)
            break;

        /* Else, maybe some bits are available? (should always be the case) */
        if(socket->bytesAvailable())
            inBuffer.append(socket->readAll());

        qDebug() << "[CmdThread::run] " << inBuffer.size() << " bytes available";

        /* Foreach newline-delimited JSON packet */
        while((newLineIndex = inBuffer.indexOf("\n")) >= 0)
        {
            try
            {
                qDebug() << "[CmdThread::run] parsing packet, CR at " << newLineIndex;

                QByteArray jsonPacket = QByteArray(inBuffer);

                jsonPacket.truncate(newLineIndex);
                inBuffer.remove(0,newLineIndex+1);

                packet = new Sp6Packet(jsonPacket);
            }
            catch(int i)
            {
                qDebug() << "[CmdThread::run] invalid JSON";
                continue;
            }

            if (packet)
            {
                QString perId = packet->perId;

                qDebug() << "[CmdThread::run] we have a packet for perif " << perId;

                if(perId == PERID_LED){
                        qDebug() << "[CmdThread::run] LED ";
                        emit ledCmd(packet);
                }
                else if(perId == PERID_LCD){
                        qDebug() << "[CmdThread::run] SP6_LCD ";
                        emit clcdCmd(packet);
                }
                else if(perId == PERID_SEVEN_SEG){
                        qDebug() << "[CmdThread::run] SP6_SEVEN_SEG ";
                        emit sevenSegCmd(packet);
                }
            }
            qDebug() << "[CmdThread::run] inBuffer.length() " << inBuffer.length();

        }

        if(inBuffer.length() > 1024)
        {
            qDebug() << "[CmdThread] buffer has become full of garbage. Clearing it.";
            inBuffer.clear();
        }
    }

    qDebug() << "[cmdthread] finished ";
}

