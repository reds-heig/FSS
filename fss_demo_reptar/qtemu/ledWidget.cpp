#include "ledWidget.h"

Led::Led(QWidget *parent)
        : QWidget(parent)
{
    on = false;
}

void Led::set() {
    on = true;
    this->update();
}

void Led::clear() {
    on = false;
    this->update();
}

void Led::paintEvent(QPaintEvent *)
{
    QPainter painter(this);
    painter.setPen(Qt::NoPen);

    if (on) {
        painter.setBrush(QBrush(Qt::green, Qt::SolidPattern));
        painter.drawRect(0, 0, 16, 16);
    } else {
        painter.setBrush(QBrush(Qt::darkGreen, Qt::SolidPattern));
        painter.drawRect(0, 0, 16, 16);
    }
}
