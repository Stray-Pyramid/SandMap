import QtQuick 2.12
import QtQuick.Window 2.12
import QtLocation 5.12
import QtPositioning 5.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.0

import VialLoader 1.0


Window {
    width: 1280
    height: 720
    visible: true
    title: qsTr("Sand Map")

    property var home: QtPositioning.coordinate(-36.8483, 174.7626)
    property list<VialMarker> markers;

    Plugin {
        id: mapboxglPlugin
        name: "osm"
        //name: "mapboxgl"
        //name: "mapbox"
        //PluginParameter { name: "mapbox.access_token"; value: mapbox_access_token }
    }

    // Responsible for loading vials from DB, storing new vials
    VialLoader {
        id: loader
    }

    Map {
        id: map
        anchors.fill: parent
        anchors.rightMargin: 0
        anchors.bottomMargin: 0
        anchors.leftMargin: 0
        anchors.topMargin: 0
        plugin: mapboxglPlugin
        center: home
        zoomLevel: 15

        property MapQuickItem infoBox
        property bool disable_panning: false
        property int no_panning: (MapGestureArea.PinchGesture | MapGestureArea.FlickGesture |MapGestureArea.RotationGesture | MapGestureArea.TiltGesture)
        property int panning: (MapGestureArea.PanGesture | MapGestureArea.PinchGesture | MapGestureArea.FlickGesture |MapGestureArea.RotationGesture | MapGestureArea.TiltGesture)

        gesture.acceptedGestures: disable_panning ? no_panning : panning

        function stringToDateTime(string){
            if (string === "") return invalidDate;

            var parts = string.split(' ');
            var date = parts[0];
            var time = parts[1];

            var date_parts = date.split('-');
            var year = date_parts[0];
            var month = date_parts[1]-1; // Why javascript why
            var day = date_parts[2];

            var time_parts = time.split(':');
            var hour = time_parts[0];
            var minute = time_parts[1];
            var second = time_parts[2];

            return new Date(year, month, day, hour, minute, second);
        }

        function loadVialMarkers(){
            refresh_vials_busyIndicator.running = true
            refresh_vials_btn_txt.visible = false
            console.log("Refreshing vials...");

            // Get vials
            var vialList = loader.getVials();
            console.log("Got", vialList.length, "Results");

            // Clear map of existing vials
            var i;
            for(i = 0; i < markers.length; i++){
                // The confirm delete message dialog that is a part of VialMarker will cause errors for an unknown reason
                // when the new set of vials are created (TypeError: Type error)
                // Clearing the map via each's items destroy method seems to prevent this error.
                markers[i].destroy()
            }
            map.clearMapItems() // Remove any infobox containers

            // Populate map with new vials
            createVialMarkers(vialList);

            console.log("Vials Refreshed");
            refresh_vials_busyIndicator.running = false
            refresh_vials_btn_txt.visible = true
        }

        function createVialMarkers(vials){
            var i;
            for(i = 0; i < vials.length; i++){
                addVial(vials[i]);
            }
        }

        function addVial(vial){
            var vial_cmp = Qt.createComponent("VialMarker.qml");
            var vial_obj = vial_cmp.createObject();

            vial_obj.vial = vial;

            markers.push(vial_obj);
            map.addMapItem(vial_obj);
        }

        function selectLocation(){
            dummy_marker.enabled = true
            dummy_marker.visible = true
            dummy_click_area.enabled = true
        }

        // Ignore this error. (Invalid property name "Component")
        Component.onCompleted: {
            map.loadVialMarkers()
        }

        VialForm{
            id: vial_properties_forum
        }

        MapQuickItem {
            id: dummy_marker
            visible: false
            anchorPoint.x: sourceItem.width / 2
            anchorPoint.y: sourceItem.height
            sourceItem: Image {
                source: "qrc:marker.png"
                width: 50
                height: 50
            }

        }

        MouseArea {
            id: dummy_click_area
            enabled: false
            anchors.fill: parent
            anchors.rightMargin: 0
            anchors.bottomMargin: 0
            anchors.leftMargin: 0
            anchors.topMargin: 0
            hoverEnabled: true
            onClicked: {
                dummy_marker.enabled = false
                dummy_marker.visible = false
                dummy_click_area.enabled = false
                vial_properties_forum.visible = true

                var marker_loc = map.toCoordinate(Qt.point(mouse.x,mouse.y));

                vial_properties_forum.latitude = marker_loc.latitude;
                vial_properties_forum.longitude = marker_loc.longitude;

                vial_properties_forum.update_latitude_dms();
                vial_properties_forum.update_longitude_dms();
            }
            onPositionChanged: {
                if(dummy_marker.enabled){
                    dummy_marker.coordinate = map.toCoordinate(Qt.point(mouse.x,mouse.y));
                }
            }
        }


        RowLayout {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: 10
            anchors.bottomMargin: 10
            z: 10

            Rectangle {
                id: refresh_vials_btn
                radius: 10
                border.width: 2
                Layout.preferredHeight: 50
                Layout.preferredWidth: 50

                property color buttonColor: "#d9d9d9"
                property color onHoverColor: "gold"
                property color borderColor: "white"

                Text {
                    id: refresh_vials_btn_txt
                    text: qsTr("Refresh")
                    anchors.centerIn: parent
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                }

                BusyIndicator {
                    id: refresh_vials_busyIndicator
                    width: 50
                    height: 50
                    running: false
                }

                MouseArea {
                    id: refresh_vials_btn_mouseArea
                    anchors.fill: parent
                    onClicked: map.loadVialMarkers()
                    onEntered: parent.border.color = parent.onHoverColor
                    onExited:  parent.border.color = parent.borderColor
                }


                color: refresh_vials_btn_mouseArea.pressed ? Qt.darker(buttonColor, 1.5) : buttonColor
            }

            Rectangle {
                id: new_vial_btn
                radius: 10
                border.width: 2
                Layout.preferredHeight: 50
                Layout.preferredWidth: 50

                property color buttonColor: "#d9d9d9"
                property color onHoverColor: "gold"
                property color borderColor: "white"

                Text {
                    text: qsTr("New\nVial")
                    anchors.centerIn: parent
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                }

                MouseArea {
                    id: new_vial_btn_mouseArea
                    anchors.fill: parent
                    onClicked: vial_properties_forum.newVial()
                    onEntered: parent.border.color = parent.onHoverColor
                    onExited:  parent.border.color = parent.borderColor
                }

                color: new_vial_btn_mouseArea.pressed ? Qt.darker(buttonColor, 1.5) : buttonColor
            }
        }
    } // Map
    Text {
        text: homeDir
    }
}

/*##^##
Designer {
    D{i:0;formeditorZoom:1.5}
}
##^##*/
