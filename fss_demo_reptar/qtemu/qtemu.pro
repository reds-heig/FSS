# -------------------------------------------------
# Project created by QtCreator 2012-12-04T11:41:05
# -------------------------------------------------
QT += core \
    gui \
    network
greaterThan(QT_MAJOR_VERSION, 4):QT += widgets
TARGET = qtemu
TEMPLATE = app
QMAKE_CXXFLAGS += -fpermissive
SOURCES += main.cpp \
    qtemureptar.cpp \
    cmdthread.cpp \
    ledWidget.cpp \
    evtthread.cpp \
    sp6Packet.cpp
HEADERS += qtemureptar.h \
    config.h \
    cmdthread.h \
    ledWidget.h \
    evtthread.h \
    sp6Packet.h
FORMS += qtemureptar.ui
RESOURCES += qtemu.qrc

DEFINES += QT_NO_DEBUG_OUTPUT
