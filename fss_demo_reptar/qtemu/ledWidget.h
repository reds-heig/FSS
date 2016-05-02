#ifndef LEDWIDGET_H
#define LEDWIDGET_H

#include <QtGui>
#include <QWidget>

class Led : public QWidget
{
    Q_OBJECT

public:
    Led(QWidget *parent = 0);
    void set();
    void clear();
protected:
    void paintEvent(QPaintEvent *);
private:
    bool on;
};

#endif // LEDWIDGET_H
