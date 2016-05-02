#include <QDebug>
#include <QMessageBox>
#include <QTcpSocket>

#include "qtemureptar.h"
#include "ui_qtemureptar.h"

#include "sp6Packet.h"
#include "cmdthread.h"
#include "evtthread.h"
#include "ledWidget.h"


QtemuReptar::QtemuReptar(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::QtemuReptar)
{
    server = new QTcpServer;

    connect(server,SIGNAL(newConnection()),this,SLOT(startWorkers()));

    try  {
        server->listen(QHostAddress::LocalHost, TCP_PORT);
        qDebug() << "[QTEMUREPTAR] server listening on " << TCP_PORT;

    }
    catch(...) {
        qDebug() << "[QTEMUREPTAR] QTcpServer->listen() on " << TCP_PORT << " failed";
        throw;
    }

    ui->setupUi(this);

    ui->lcdSevenSeg1->hide();
    ui->lcdSevenSeg2->hide();
    ui->lcdSevenSeg3->hide();


    connect(ui->btnStop, SIGNAL(clicked()),this, SLOT(removeWorkers()));

    connect(ui->pushButtons,SIGNAL(buttonPressed(int)),this,SLOT(buttonPressed(int)));
    connect(ui->pushButtons,SIGNAL(buttonReleased(int)),this,SLOT(buttonReleased(int)));

    buttons_state = 0;
}
/*
 * Called at every new connection
 */
void QtemuReptar::startWorkers()
{
        qDebug() << "[QTEMUREPTAR] startWorkers ";

        QTcpSocket *tcpSocket;

        tcpSocket = server->nextPendingConnection();

        /*
         * Copy pointer of current tcp session to threads
         */
        CmdThread   *cmd = new CmdThread(tcpSocket,this);
        EvtThread   *evt = new EvtThread(tcpSocket,this);

        /*
         * Connect in/out event from/to workers
         */
        connect( cmd, SIGNAL(clcdCmd(Sp6Packet*)),
                   this, SLOT(clcdCmdProcess(Sp6Packet*)) );
        connect( cmd, SIGNAL(ledCmd(Sp6Packet*)),
                   this, SLOT(ledCmdProcess(Sp6Packet*)) );
        connect( cmd, SIGNAL(sevenSegCmd(Sp6Packet*)),
                   this, SLOT(sevenSegCmdProcess(Sp6Packet*)) );

        connect( this, SIGNAL(eventPost(Sp6Packet*)),
                 evt, SLOT(eventPostProcess(Sp6Packet*)) );

        /*
         * If we want to quit, ask the threads to stop, too
         */
        connect(ui->btnStop, SIGNAL(clicked()),cmd, SLOT(shouldStop()));
        connect(ui->btnStop, SIGNAL(clicked()),evt, SLOT(shouldStop()));

        /*
         * If threads have quit, remove them from our list
         */
        connect(cmd, SIGNAL(finished()),this, SLOT(removeWorkers()));
        connect(evt, SIGNAL(finished()),this, SLOT(removeWorkers()));

        threadList.append((QThread *)cmd);
        threadList.append((QThread *)evt);

        cmd->start();
        evt->start();
}
/*
 * Called when a thread finishes
 */
void QtemuReptar::removeWorkers()
{
    int i;

    for(i=0;i<threadList.length()-1;i+=2)
        if(threadList.at(i)->isFinished() && threadList.at(i+1)->isFinished())
        {
            /*
             * The second is always the evt thread.
             * He is in charge of deleting the shared socket
             */
            delete threadList.at(i);
            delete threadList.at(i+1);
            threadList.removeAt(i);
            threadList.removeAt(i);
            i-=2;

            qDebug() << "[QtemuReptar::removeWorkers] removed 2 workers  ";

        }

    qDebug() << "[QtemuReptar::removeWorkers] active workers: " << threadList.length();

    if(threadList.isEmpty())
    {
        QApplication::quit();
    }
}


QtemuReptar::~QtemuReptar()
{
    server->disconnect();
    delete server;
    delete ui;
}


int sevenSegToVal(uint8_t segval) {

    static uint8_t segs[] = {0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F};
    unsigned int i;

    for (i = 0; i < sizeof(segs); i++) {
        if (segs[i] == segval)
            return i;
    }

    return -1;
}

void QtemuReptar::updateLeds(uint8_t val) {
    int i;

    qDebug() << "[QtemuReptar::updateLeds]";

    for (i=0; i < 8; i++)
        if (val & (1 << i))
            ((Led*)ui->ledsArray->itemAt(7-i)->widget())->set();
        else
            ((Led*)ui->ledsArray->itemAt(7-i)->widget())->clear();
}
void QtemuReptar::ledCmdProcess(Sp6Packet * p)
{
    qDebug() << "[QtemuReptar::ledCmdProcess] ledCmdProcess";

    if(!p->hasKey("value"))
        return;

    updateLeds((uint8_t)p->getInt("value"));

    delete p;
}
void QtemuReptar::clcdCmdProcess(Sp6Packet * p)
{
    qDebug() << "[QTEMUREPTAR] clcdCmdProcess";

    if(!p->hasKey("ddram"))
        return;

    updateClcd(p->getString("ddram").toLocal8Bit().data());

    delete p;
}
void QtemuReptar::sevenSegCmdProcess(Sp6Packet * p)
{
    int i,val;

    const int char2segments[10] = {
        0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F
    };

    if(!p->hasKey("value"))
        return;

    val = p->getInt("value");

    qDebug() << "[QTEMUREPTAR] sevenSegCmdProcess. Val:" << val;

    for(i=0;i<10;i++)
        if(val == char2segments[i])
            break;

    if(i==10)
        return;

    val = i;

    qDebug() << "[QTEMUREPTAR] sevenSegCmdProcess. Val:" << val;

    switch(p->getInt("digit"))
    {
    case 1:
        if (p->getInt("value")==0) {
            ui->lcdSevenSeg1->hide();
        } else {
            ui->lcdSevenSeg1->display(val);
            ui->lcdSevenSeg1->show();
        }
        break;
    case 2:
        if (p->getInt("value")==0) {
            ui->lcdSevenSeg2->hide();
        } else {
            ui->lcdSevenSeg2->display(val);
            ui->lcdSevenSeg2->show();
        }
        break;
    case 3:
        if (p->getInt("value")==0) {
            ui->lcdSevenSeg3->hide();
        } else {
            ui->lcdSevenSeg3->display(val);
            ui->lcdSevenSeg3->show();
        }
        break;
    default:
        break;
    }
    delete p;
}

void QtemuReptar::updateClcd(const char *str)
{
    QString displayString;
    qDebug() << "[QtemuReptar::updateClcd] updateClcd" << str;

    displayString.append(QString::fromLatin1(str,20));
    displayString += '\n';
    displayString.append(QString::fromLatin1(str + 64,20));
    displayString += '\n';
    displayString.append(QString::fromLatin1(str + 20,20));
    displayString += '\n';
    displayString.append(QString::fromLatin1(str + 84,20));

    ui->lblClcd->setText(displayString);
}

void QtemuReptar::buttonPressed(int button_nr)
{
    /* Id is negative and starts at -2 */
    button_nr = -button_nr-1;

    buttons_state |= (1 << (button_nr - 1));

    Sp6Packet *p = new Sp6Packet(PERID_BTN);
    p->add("status",buttons_state);

    emit eventPost(p);
}
void QtemuReptar::buttonReleased(int button_nr)
{
    button_nr = -button_nr-1;

    buttons_state &= ~(1 << (button_nr - 1));

    Sp6Packet *p = new Sp6Packet(PERID_BTN);
    p->add("status",buttons_state);

    emit eventPost(p);
}
