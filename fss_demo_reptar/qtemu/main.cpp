#include <QApplication>

#include <signal.h>
#include <stdlib.h>
#include <stdio.h>

#include "qtemureptar.h"

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    QtemuReptar w;

    w.show();

    if(argc == 2)
    {
	kill(atoi(argv[1]),SIGUSR1);
    }

    return a.exec();
}
