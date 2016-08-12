// * Copyright 2016 Alistair Buxton <a.j.buxton@gmail.com>
// *
// * License: This program is free software; you can redistribute it and/or
// * modify it under the terms of the GNU General Public License as published
// * by the Free Software Foundation; either version 3 of the License, or (at
// * your option) any later version. This program is distributed in the hope
// * that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
// * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// * GNU General Public License for more details.

#include <QGuiApplication>
#include <QNetworkAccessManager>
#include <QNetworkDiskCache>
#include <QQmlEngine>
#include <QQmlNetworkAccessManagerFactory>
#include <QtQuick/QQuickView>


#include <QHash>
#include <QBuffer>
#include <QPair>


// The QML only keeps previous, current, and next images from the slidehsow.
// To prevent it from reloading the images every time the slideshow advances
// we must cache them. This next piece of code installs the built in Qt disk
// cache.

class MyNetworkAccessManagerFactory : public QQmlNetworkAccessManagerFactory
{
public:
    virtual QNetworkAccessManager *create(QObject *parent);
};

QNetworkAccessManager *MyNetworkAccessManagerFactory::create(QObject *parent)
{
    QNetworkAccessManager *nam = new QNetworkAccessManager;
    QNetworkDiskCache *diskCache = new QNetworkDiskCache(parent);
    diskCache->setCacheDirectory("/tmp/qmlimgurcache");

    // *** This must be large enough for the whole album. ***
    diskCache->setMaximumCacheSize(100000000); // 100MB

    nam->setCache(diskCache);
    return nam;
}


// Main function. Install the network access manager factory and run main.qml.

int main(int argc, char **argv)
{
    QGuiApplication app(argc, argv);
    QQuickView view;
    view.engine()->setNetworkAccessManagerFactory(new MyNetworkAccessManagerFactory);
    view.setResizeMode(QQuickView::SizeRootObjectToView);
    view.setSource(QUrl("qrc:///main.qml"));
    view.show();

    return app.exec();
}
