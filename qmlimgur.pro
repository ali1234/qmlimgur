TEMPLATE = app

QT += quick qml xml xmlpatterns
SOURCES = main.cpp
RESOURCES += qmlimgur.qrc

OTHER_FILES = *.qml

target.path = /usr/bin
INSTALLS += target
