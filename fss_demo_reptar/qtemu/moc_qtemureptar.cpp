/****************************************************************************
** Meta object code from reading C++ file 'qtemureptar.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.2.1)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "qtemureptar.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'qtemureptar.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.2.1. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
struct qt_meta_stringdata_QtemuReptar_t {
    QByteArrayData data[13];
    char stringdata[151];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    offsetof(qt_meta_stringdata_QtemuReptar_t, stringdata) + ofs \
        - idx * sizeof(QByteArrayData) \
    )
static const qt_meta_stringdata_QtemuReptar_t qt_meta_stringdata_QtemuReptar = {
    {
QT_MOC_LITERAL(0, 0, 11),
QT_MOC_LITERAL(1, 12, 9),
QT_MOC_LITERAL(2, 22, 0),
QT_MOC_LITERAL(3, 23, 10),
QT_MOC_LITERAL(4, 34, 1),
QT_MOC_LITERAL(5, 36, 14),
QT_MOC_LITERAL(6, 51, 13),
QT_MOC_LITERAL(7, 65, 18),
QT_MOC_LITERAL(8, 84, 13),
QT_MOC_LITERAL(9, 98, 9),
QT_MOC_LITERAL(10, 108, 14),
QT_MOC_LITERAL(11, 123, 13),
QT_MOC_LITERAL(12, 137, 12)
    },
    "QtemuReptar\0eventPost\0\0Sp6Packet*\0p\0"
    "clcdCmdProcess\0ledCmdProcess\0"
    "sevenSegCmdProcess\0buttonPressed\0"
    "button_nr\0buttonReleased\0removeWorkers\0"
    "startWorkers\0"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_QtemuReptar[] = {

 // content:
       7,       // revision
       0,       // classname
       0,    0, // classinfo
       8,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       1,       // signalCount

 // signals: name, argc, parameters, tag, flags
       1,    1,   54,    2, 0x06,

 // slots: name, argc, parameters, tag, flags
       5,    1,   57,    2, 0x0a,
       6,    1,   60,    2, 0x0a,
       7,    1,   63,    2, 0x0a,
       8,    1,   66,    2, 0x08,
      10,    1,   69,    2, 0x08,
      11,    0,   72,    2, 0x08,
      12,    0,   73,    2, 0x08,

 // signals: parameters
    QMetaType::Void, 0x80000000 | 3,    4,

 // slots: parameters
    QMetaType::Void, 0x80000000 | 3,    4,
    QMetaType::Void, 0x80000000 | 3,    4,
    QMetaType::Void, 0x80000000 | 3,    4,
    QMetaType::Void, QMetaType::Int,    9,
    QMetaType::Void, QMetaType::Int,    9,
    QMetaType::Void,
    QMetaType::Void,

       0        // eod
};

void QtemuReptar::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        QtemuReptar *_t = static_cast<QtemuReptar *>(_o);
        switch (_id) {
        case 0: _t->eventPost((*reinterpret_cast< Sp6Packet*(*)>(_a[1]))); break;
        case 1: _t->clcdCmdProcess((*reinterpret_cast< Sp6Packet*(*)>(_a[1]))); break;
        case 2: _t->ledCmdProcess((*reinterpret_cast< Sp6Packet*(*)>(_a[1]))); break;
        case 3: _t->sevenSegCmdProcess((*reinterpret_cast< Sp6Packet*(*)>(_a[1]))); break;
        case 4: _t->buttonPressed((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 5: _t->buttonReleased((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 6: _t->removeWorkers(); break;
        case 7: _t->startWorkers(); break;
        default: ;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        void **func = reinterpret_cast<void **>(_a[1]);
        {
            typedef void (QtemuReptar::*_t)(Sp6Packet * );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&QtemuReptar::eventPost)) {
                *result = 0;
            }
        }
    }
}

const QMetaObject QtemuReptar::staticMetaObject = {
    { &QMainWindow::staticMetaObject, qt_meta_stringdata_QtemuReptar.data,
      qt_meta_data_QtemuReptar,  qt_static_metacall, 0, 0}
};


const QMetaObject *QtemuReptar::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *QtemuReptar::qt_metacast(const char *_clname)
{
    if (!_clname) return 0;
    if (!strcmp(_clname, qt_meta_stringdata_QtemuReptar.stringdata))
        return static_cast<void*>(const_cast< QtemuReptar*>(this));
    return QMainWindow::qt_metacast(_clname);
}

int QtemuReptar::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QMainWindow::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 8)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 8;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 8)
            *reinterpret_cast<int*>(_a[0]) = -1;
        _id -= 8;
    }
    return _id;
}

// SIGNAL 0
void QtemuReptar::eventPost(Sp6Packet * _t1)
{
    void *_a[] = { 0, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 0, _a);
}
QT_END_MOC_NAMESPACE
