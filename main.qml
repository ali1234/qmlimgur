// * Copyright 2016 Alistair Buxton <a.j.buxton@gmail.com>
// *
// * License: This program is free software; you can redistribute it and/or
// * modify it under the terms of the GNU General Public License as published
// * by the Free Software Foundation; either version 3 of the License, or (at
// * your option) any later version. This program is distributed in the hope
// * that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
// * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// * GNU General Public License for more details.

import QtQuick 2.2
import QtQuick.XmlListModel 2.0

Rectangle {
    id: window
    color: "black"
    width: 800
    height: 480
    
    PathView {
        id: pv
        anchors.fill: parent
        model: XmlListModel {

            query: "/data/images/item";
            XmlRole { name: "title"; query: "title/string()" }
            XmlRole { name: "description"; query: "description/string()" }
            XmlRole { name: "image"; query: "link/string()"; isKey: true }

            // Override the reload method so that we can insert the auth header.
            // For public API we would just set the source property instead.
            function reload() {
                var req = new XMLHttpRequest();
                var location = 'https://api.imgur.com/3/album/' + Qt.application.arguments[2] + '.xml';
                req.open("GET", location, true);
                req.setRequestHeader('Authorization', 'Client-ID ' + Qt.application.arguments[1]);
                req.send(null);
                req.onreadystatechange = function()
                {
                    if (req.readyState == 4)
                    {
                        xml = req.responseText;
                    }
                };
            }

            // Call custom reload function once at startup.
            Component.onCompleted: {
                reload();
            }
        }

        highlightRangeMode: PathView.StrictlyEnforceRange
        preferredHighlightBegin: 0.5
        preferredHighlightEnd: 0.5
        highlightMoveDuration: 600
        snapMode: PathView.SnapOneItem

        // Delegate tells QtQuick how to display each item from the list model
        delegate: Image {

            // make the image fill the view
            source: image
            width: PathView.view.width
            height: PathView.view.height
            fillMode: Image.PreserveAspectCrop

            // This Rectangle shows the title and description
            Rectangle {
                color: "#6F000000"

                height:90
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                Column {
                    anchors.fill: parent
                    anchors.rightMargin: 15
                    anchors.leftMargin: 15
                    anchors.topMargin: 12
                    spacing: 8

                    Text {
                        id: titleText
                        text: title
                        color: "white"
                        width: parent.width
                        wrapMode: Text.WordWrap
                        font.pixelSize: 18
                        font.bold: true
                    }

                    Text {
                        id: descriptionText
                        text: description
                        color: "white"
                        width: parent.width
                        wrapMode: Text.WordWrap
                        font.pixelSize: 14
                        textFormat: Text.StyledText
                        horizontalAlignment: Qt.AlignLeft
                    }
                }
            }
        }


        pathItemCount: 3 // Only previous, current, next

        // Set up the path so that previous and next are completely off screen.
        path: Path { // horizontal
            startX: -width; startY: height/2
            PathLine{x: width*2; y: height/2}
        }

        // Timer to reload the album after 10 minutes.
        Timer {
            interval: 600000; running: true; repeat: true;
            onTriggered: parent.model.reload()
        }

        // Timer to advance the slideshow after 10 seconds.
        Timer {
            id: autotimer
            interval: 10000; running: true; repeat: true;
            onTriggered: {
                parent.incrementCurrentIndex()
            }
        }

        // Restart automatic advance after 20 seconds delay.
        Timer {
            id: manualtimer
            interval: 20000; running: false; repeat: false;
            onTriggered: autotimer.restart()
        }

        // When user is interacting don't auto advance slideshow.
        onMovementStarted: {
            autotimer.stop()
            manualtimer.stop()
        }

        // When user stops interacting, wait a bit before restarting auto advance.
        onMovementEnded: {
            manualtimer.restart()
        } 
    }

    // Keyboard input. You can also swipe to go forwards/backwards.

    focus: true

    Keys.onLeftPressed: {
        pv.incrementCurrentIndex();
        pv.onMovementStarted();
        pv.onMovementEnded();
    }

    Keys.onRightPressed: {
        pv.decrementCurrentIndex();
        pv.onMovementStarted();
        pv.onMovementEnded();
    }
}


