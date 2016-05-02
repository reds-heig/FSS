/****************************************************************************
** Meta object code from reading C++ file 'cmdthread.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.2.1)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "cmdthread.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'cmdthread.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.2.1. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
struct qt_meta_stringdata_CmdThread_t {
    QByteArrayData data[9];
    char stringdata[77];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    offsetof(qt_meta_stringdata_CmdThread_t, stringdata) + ofs \
        - idx * sizeof(QByteArrayData) \
    )
static const qt_meta_stringdata_CmdThread_t qt_meta_stringdata_CmdThread = {
    {
QT_MOC_LITERAL(0, 0, 9),
QT_MOC_LITERAL(1, 10, 7),
QT_MOC_LITERAL(2, 18, 0),
QT_MOC_LITERAL(3, 19, 10),
QT_MOC_LITERAL(4, 30, 1),
QT_MOC_LITERAL(5, 32, 6),
QT_MOC_LITERAL(6, 39, 11),
QT_MOC_LITERAL(7, 51, 10),
QT_MOC_LITERAL(8, 62, 13)
    },
    "CmdThread\0clcdCmd\0\0Sp6Packet*\0p\0ledCmd\0"
    "sevenSegCmd\0shouldStop\0dataAvailable\0"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_CmdThread[] = {

 // content:
       7,       // revision
       0,       // classname
       0,    0, // classinfo
       5,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       3,       // signalCount

 // signals: name, argc, parameters, tag, flags
       1,    1,   39,    2, 0x06,
       5,    1,   42,    2, 0x06,
       6,    1,   45,    2, 0x06,

 // slots: name, argc, parameters, tag, flags
       7,    0,   48,    2, 0x0a,
       8,    0,   49,    2, 0x08,

 // signals: parameters
    QMetaType::Void, 0x80000000 | 3,    4,
    QMetaType::Void, 0x80000000 | 3,    4,
    QMetaType::Void, 0x80000000 | 3,    4,

 // slots: parameters
    QMetaType::Void,
    QMetaType::Void,

       0        // eod
};

void CmdThread::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        CmdThread *_t = static_cast<CmdThread *>(_o);
        switch (_id) {
        case 0: _t->clcdCmd((*reinterpret_cast< Sp6Packet*(*)>(_a[1]))); break;
        case 1: _t->ledCmd((*reinterpret_cast< Sp6Packet*(*)>(_a[1]))); break;
        case 2: _t->sevenSegCmd((*reinterpret_cast< Sp6Packet*(*)>(_a[1]))); break;
        case 3: _t->shouldStop(); break;
        case 4: _t->dataAvailable(); break;
        default: ;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        void **func = reinterpret_cast<void **>(_a[1]);
        {
            typedef void (CmdThread::*_t)(Sp6Packet * );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&CmdThread::clcdCmd)) {
                *result = 0;
            }
        }
        {
            typedef void (CmdThread::*_t)(Sp6Packet * );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&CmdThread::ledCmd)) {
                *result = 1;
            }
        }
        {
            typedef void (CmdThread::*_t)(Sp6Packet * );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&CmdThread::sevenSegCmd)) {
                *result = 2;
            }
        }
    }
}

const QMetaObject CmdThread::staticMetaObject = {
    { &QThread::staticMetaObject, qt_meta_stringdata_CmdThread.data,
      qt_meta_data_CmdThread,  qt_static_metacall, 0, 0}
};


const QMetaObject *CmdThread::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *CmdThread::qt_metacast(const char *_clname)
{
    if (!_clname) return 0;
    if (!strcmp(_clname, qt_meta_stringdata_CmdThread.stringdata))
        return static_cast<void*>(const_cast< CmdThread*>(this));
    return QThread::qt_metacast(_clname);
}

int CmdThread::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QThread::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 5)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 5;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 5)
            *reinterpret_cast<int*>(_a[0]) = -1;
        _id -= 5;
    }
    return _id;
}

// SIGNAL 0
void CmdThread::clcdCmd(Sp6Packet * _t1)
{
    void *_a[] = { 0, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 0, _a);
}

// SIGNAL 1
void CmdThread::ledCmd(Sp6Packet * _t1)
{
    void *_a[] = { 0, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 1, _a);
}

// SIGNAL 2
void CmdThread::sevenSegCmd(Sp6Packet * _t1)
{
    void *_a[] = { 0, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 2, _a);
}
QT_END_MOC_NAMESPACE
