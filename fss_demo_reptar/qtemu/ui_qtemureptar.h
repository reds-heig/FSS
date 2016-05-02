/********************************************************************************
** Form generated from reading UI file 'qtemureptar.ui'
**
** Created by: Qt User Interface Compiler version 5.2.1
**
** WARNING! All changes made in this file will be lost when recompiling UI file!
********************************************************************************/

#ifndef UI_QTEMUREPTAR_H
#define UI_QTEMUREPTAR_H

#include <QtCore/QVariant>
#include <QtWidgets/QAction>
#include <QtWidgets/QApplication>
#include <QtWidgets/QButtonGroup>
#include <QtWidgets/QHBoxLayout>
#include <QtWidgets/QHeaderView>
#include <QtWidgets/QLCDNumber>
#include <QtWidgets/QLabel>
#include <QtWidgets/QMainWindow>
#include <QtWidgets/QMenu>
#include <QtWidgets/QMenuBar>
#include <QtWidgets/QPushButton>
#include <QtWidgets/QStatusBar>
#include <QtWidgets/QWidget>
#include <ledWidget.h>

QT_BEGIN_NAMESPACE

class Ui_QtemuReptar
{
public:
    QAction *actionQuit;
    QAction *actionConfigure;
    QAction *actionAbout;
    QWidget *centralWidget;
    QLabel *bbLabel;
    QPushButton *btnStop;
    QLabel *lblClcd;
    QLCDNumber *lcdSevenSeg2;
    QLCDNumber *lcdSevenSeg1;
    QLCDNumber *lcdSevenSeg3;
    QPushButton *btn1;
    QPushButton *btn2;
    QPushButton *btn3;
    QPushButton *btn4;
    QPushButton *btn5;
    QPushButton *btn6;
    QPushButton *btn7;
    QPushButton *btn8;
    QWidget *layoutWidget;
    QHBoxLayout *ledsArray;
    Led *led7;
    Led *led6;
    Led *led5;
    Led *led4;
    Led *led3;
    Led *led2;
    Led *led1;
    Led *led0;
    QStatusBar *statusBar;
    QMenuBar *menuBar;
    QMenu *menuAbout;
    QMenu *menuQtemu_REPTAR;
    QButtonGroup *pushButtons;

    void setupUi(QMainWindow *QtemuReptar)
    {
        if (QtemuReptar->objectName().isEmpty())
            QtemuReptar->setObjectName(QStringLiteral("QtemuReptar"));
        QtemuReptar->resize(580, 620);
        QSizePolicy sizePolicy(QSizePolicy::Expanding, QSizePolicy::Expanding);
        sizePolicy.setHorizontalStretch(0);
        sizePolicy.setVerticalStretch(0);
        sizePolicy.setHeightForWidth(QtemuReptar->sizePolicy().hasHeightForWidth());
        QtemuReptar->setSizePolicy(sizePolicy);
        QtemuReptar->setMinimumSize(QSize(580, 620));
        QtemuReptar->setMaximumSize(QSize(580, 620));
        QtemuReptar->setContextMenuPolicy(Qt::ActionsContextMenu);
        QtemuReptar->setAutoFillBackground(false);
        QtemuReptar->setToolButtonStyle(Qt::ToolButtonIconOnly);
        QtemuReptar->setTabShape(QTabWidget::Rounded);
        actionQuit = new QAction(QtemuReptar);
        actionQuit->setObjectName(QStringLiteral("actionQuit"));
        actionConfigure = new QAction(QtemuReptar);
        actionConfigure->setObjectName(QStringLiteral("actionConfigure"));
        actionAbout = new QAction(QtemuReptar);
        actionAbout->setObjectName(QStringLiteral("actionAbout"));
        centralWidget = new QWidget(QtemuReptar);
        centralWidget->setObjectName(QStringLiteral("centralWidget"));
        sizePolicy.setHeightForWidth(centralWidget->sizePolicy().hasHeightForWidth());
        centralWidget->setSizePolicy(sizePolicy);
        bbLabel = new QLabel(centralWidget);
        bbLabel->setObjectName(QStringLiteral("bbLabel"));
        bbLabel->setGeometry(QRect(0, 10, 581, 531));
        bbLabel->setLineWidth(0);
        bbLabel->setPixmap(QPixmap(QString::fromUtf8(":/img/fpga_board.png")));
        bbLabel->setScaledContents(false);
        bbLabel->setAlignment(Qt::AlignBottom|Qt::AlignLeading|Qt::AlignLeft);
        bbLabel->setOpenExternalLinks(false);
        btnStop = new QPushButton(centralWidget);
        btnStop->setObjectName(QStringLiteral("btnStop"));
        btnStop->setEnabled(true);
        btnStop->setGeometry(QRect(0, 540, 111, 27));
        lblClcd = new QLabel(centralWidget);
        lblClcd->setObjectName(QStringLiteral("lblClcd"));
        lblClcd->setGeometry(QRect(143, 122, 261, 91));
        QFont font;
        font.setFamily(QStringLiteral("Courier New"));
        font.setPointSize(16);
        font.setBold(true);
        font.setWeight(75);
        lblClcd->setFont(font);
        lblClcd->setCursor(QCursor(Qt::BlankCursor));
        lblClcd->setTextFormat(Qt::PlainText);
        lblClcd->setWordWrap(false);
        lcdSevenSeg2 = new QLCDNumber(centralWidget);
        lcdSevenSeg2->setObjectName(QStringLiteral("lcdSevenSeg2"));
        lcdSevenSeg2->setGeometry(QRect(364, 285, 28, 51));
        lcdSevenSeg2->setFrameShape(QFrame::NoFrame);
        lcdSevenSeg2->setFrameShadow(QFrame::Plain);
        lcdSevenSeg2->setLineWidth(0);
        lcdSevenSeg2->setDigitCount(1);
        lcdSevenSeg2->setSegmentStyle(QLCDNumber::Flat);
        lcdSevenSeg1 = new QLCDNumber(centralWidget);
        lcdSevenSeg1->setObjectName(QStringLiteral("lcdSevenSeg1"));
        lcdSevenSeg1->setGeometry(QRect(326, 285, 28, 51));
        lcdSevenSeg1->setFrameShape(QFrame::NoFrame);
        lcdSevenSeg1->setFrameShadow(QFrame::Plain);
        lcdSevenSeg1->setLineWidth(0);
        lcdSevenSeg1->setDigitCount(1);
        lcdSevenSeg1->setSegmentStyle(QLCDNumber::Flat);
        lcdSevenSeg3 = new QLCDNumber(centralWidget);
        lcdSevenSeg3->setObjectName(QStringLiteral("lcdSevenSeg3"));
        lcdSevenSeg3->setGeometry(QRect(403, 285, 28, 51));
        lcdSevenSeg3->setFrameShape(QFrame::NoFrame);
        lcdSevenSeg3->setFrameShadow(QFrame::Plain);
        lcdSevenSeg3->setLineWidth(0);
        lcdSevenSeg3->setDigitCount(1);
        lcdSevenSeg3->setSegmentStyle(QLCDNumber::Flat);
        btn1 = new QPushButton(centralWidget);
        pushButtons = new QButtonGroup(QtemuReptar);
        pushButtons->setObjectName(QStringLiteral("pushButtons"));
        pushButtons->setExclusive(false);
        pushButtons->addButton(btn1);
        btn1->setObjectName(QStringLiteral("btn1"));
        btn1->setGeometry(QRect(204, 391, 32, 32));
        btn1->setCursor(QCursor(Qt::PointingHandCursor));
        btn1->setFlat(true);
        btn2 = new QPushButton(centralWidget);
        pushButtons->addButton(btn2);
        btn2->setObjectName(QStringLiteral("btn2"));
        btn2->setGeometry(QRect(138, 435, 32, 32));
        btn2->setCursor(QCursor(Qt::PointingHandCursor));
        btn2->setFlat(true);
        btn3 = new QPushButton(centralWidget);
        pushButtons->addButton(btn3);
        btn3->setObjectName(QStringLiteral("btn3"));
        btn3->setGeometry(QRect(204, 478, 32, 32));
        btn3->setCursor(QCursor(Qt::PointingHandCursor));
        btn3->setFlat(true);
        btn4 = new QPushButton(centralWidget);
        pushButtons->addButton(btn4);
        btn4->setObjectName(QStringLiteral("btn4"));
        btn4->setGeometry(QRect(270, 435, 32, 32));
        btn4->setCursor(QCursor(Qt::PointingHandCursor));
        btn4->setFlat(true);
        btn5 = new QPushButton(centralWidget);
        pushButtons->addButton(btn5);
        btn5->setObjectName(QStringLiteral("btn5"));
        btn5->setGeometry(QRect(203, 435, 32, 32));
        btn5->setCursor(QCursor(Qt::PointingHandCursor));
        btn5->setFlat(true);
        btn6 = new QPushButton(centralWidget);
        pushButtons->addButton(btn6);
        btn6->setObjectName(QStringLiteral("btn6"));
        btn6->setGeometry(QRect(138, 349, 32, 32));
        btn6->setCursor(QCursor(Qt::PointingHandCursor));
        btn6->setFlat(true);
        btn7 = new QPushButton(centralWidget);
        pushButtons->addButton(btn7);
        btn7->setObjectName(QStringLiteral("btn7"));
        btn7->setGeometry(QRect(204, 349, 32, 32));
        btn7->setCursor(QCursor(Qt::PointingHandCursor));
        btn7->setFlat(true);
        btn8 = new QPushButton(centralWidget);
        pushButtons->addButton(btn8);
        btn8->setObjectName(QStringLiteral("btn8"));
        btn8->setGeometry(QRect(269, 348, 32, 32));
        btn8->setCursor(QCursor(Qt::PointingHandCursor));
        btn8->setFlat(true);
        layoutWidget = new QWidget(centralWidget);
        layoutWidget->setObjectName(QStringLiteral("layoutWidget"));
        layoutWidget->setGeometry(QRect(132, 516, 161, 21));
        ledsArray = new QHBoxLayout(layoutWidget);
        ledsArray->setSpacing(0);
        ledsArray->setContentsMargins(11, 11, 11, 11);
        ledsArray->setObjectName(QStringLiteral("ledsArray"));
        ledsArray->setSizeConstraint(QLayout::SetDefaultConstraint);
        ledsArray->setContentsMargins(0, 0, 0, 0);
        led7 = new Led(layoutWidget);
        led7->setObjectName(QStringLiteral("led7"));

        ledsArray->addWidget(led7);

        led6 = new Led(layoutWidget);
        led6->setObjectName(QStringLiteral("led6"));

        ledsArray->addWidget(led6);

        led5 = new Led(layoutWidget);
        led5->setObjectName(QStringLiteral("led5"));

        ledsArray->addWidget(led5);

        led4 = new Led(layoutWidget);
        led4->setObjectName(QStringLiteral("led4"));

        ledsArray->addWidget(led4);

        led3 = new Led(layoutWidget);
        led3->setObjectName(QStringLiteral("led3"));

        ledsArray->addWidget(led3);

        led2 = new Led(layoutWidget);
        led2->setObjectName(QStringLiteral("led2"));

        ledsArray->addWidget(led2);

        led1 = new Led(layoutWidget);
        led1->setObjectName(QStringLiteral("led1"));

        ledsArray->addWidget(led1);

        led0 = new Led(layoutWidget);
        led0->setObjectName(QStringLiteral("led0"));

        ledsArray->addWidget(led0);

        QtemuReptar->setCentralWidget(centralWidget);
        statusBar = new QStatusBar(QtemuReptar);
        statusBar->setObjectName(QStringLiteral("statusBar"));
        statusBar->setBaseSize(QSize(100, 20));
        statusBar->setCursor(QCursor(Qt::PointingHandCursor));
        QtemuReptar->setStatusBar(statusBar);
        menuBar = new QMenuBar(QtemuReptar);
        menuBar->setObjectName(QStringLiteral("menuBar"));
        menuBar->setEnabled(false);
        menuBar->setGeometry(QRect(0, 0, 580, 27));
        menuAbout = new QMenu(menuBar);
        menuAbout->setObjectName(QStringLiteral("menuAbout"));
        menuQtemu_REPTAR = new QMenu(menuBar);
        menuQtemu_REPTAR->setObjectName(QStringLiteral("menuQtemu_REPTAR"));
        QtemuReptar->setMenuBar(menuBar);

        menuBar->addAction(menuQtemu_REPTAR->menuAction());
        menuBar->addAction(menuAbout->menuAction());
        menuAbout->addAction(actionAbout);
        menuQtemu_REPTAR->addAction(actionConfigure);
        menuQtemu_REPTAR->addAction(actionQuit);

        retranslateUi(QtemuReptar);

        QMetaObject::connectSlotsByName(QtemuReptar);
    } // setupUi

    void retranslateUi(QMainWindow *QtemuReptar)
    {
        QtemuReptar->setWindowTitle(QApplication::translate("QtemuReptar", "QtemuReptar", 0));
        actionQuit->setText(QApplication::translate("QtemuReptar", "Quit", 0));
        actionConfigure->setText(QApplication::translate("QtemuReptar", "Configure", 0));
        actionAbout->setText(QApplication::translate("QtemuReptar", "About", 0));
        bbLabel->setText(QString());
        btnStop->setText(QApplication::translate("QtemuReptar", "Quit", 0));
        lblClcd->setText(QString());
        btn1->setText(QString());
        btn2->setText(QString());
        btn3->setText(QString());
        btn4->setText(QString());
        btn5->setText(QString());
        btn6->setText(QString());
        btn7->setText(QString());
        btn8->setText(QString());
        menuAbout->setTitle(QApplication::translate("QtemuReptar", "Help", 0));
        menuQtemu_REPTAR->setTitle(QApplication::translate("QtemuReptar", "File", 0));
    } // retranslateUi

};

namespace Ui {
    class QtemuReptar: public Ui_QtemuReptar {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_QTEMUREPTAR_H
