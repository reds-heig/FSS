#ifndef QTEMUREPTAR_H
#define QTEMUREPTAR_H

#include <QMainWindow>
#include <QList>
#include <QThread>
#include <QTcpServer>

#include "sp6Packet.h"

#include "config.h"
#include "ledWidget.h"

namespace Ui {
class QtemuReptar;
}

class QtemuReptar : public QMainWindow
{
    Q_OBJECT
    
public:
    explicit QtemuReptar(QWidget *parent = 0);
    ~QtemuReptar();


public slots:
    void clcdCmdProcess(Sp6Packet * p);
    void ledCmdProcess(Sp6Packet * p);
    void sevenSegCmdProcess(Sp6Packet * p);

private slots:
    void buttonPressed(int button_nr);
    void buttonReleased(int button_nr);

    void removeWorkers();
    void startWorkers();

signals:
    void eventPost(Sp6Packet *p);


private:
    Ui::QtemuReptar *ui;
    QTcpServer *server;
    QList<QThread*> threadList;

    void updateClcd(const char *str);
    void updateLeds(uint8_t val);
    void updateButtons(int button_nr, bool state);
    uint16_t buttons_state;

    int serverThreadsRunning;
    bool qemuProcRunning;
};

#endif // QTEMUREPTAR_H
