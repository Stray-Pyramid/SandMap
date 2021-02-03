import QtQuick 2.0
import QtLocation 5.6
import QtPositioning 5.12
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.3


import Vial 1.0

MapQuickItem {
    id: vial_marker_container

    property Vial vial;
    property var infobox_container: null

    function editVial(){
        if (infobox_container !== null) infobox_container.destroy()
        vial_properties_forum.editVial(vial_marker_container)
        //hideInfobox()
    }

    function promptDeleteVial(){
        confirm_delete.visible = true
    }

    function deleteVial(){
        vial.deleteVial()
        destroy()
    }

    function createInfobox(){
        if(infobox_container !== null) return;

        var infobox_cmp = Qt.createComponent("VialMarker_Infobox.qml");
        var infobox_obj = infobox_cmp.createObject();

        infobox_obj.vial = vial
        infobox_obj.marker_container = vial_marker_container;

        infobox_container = infobox_obj
        map.addMapItem(infobox_obj);
    }


    MessageDialog {
        id: confirm_delete
        title: qsTr("Confirm")
        text: qsTr("Are you sure you want to delete this vial?")
        standardButtons: StandardButton.Cancel | StandardButton.Ok
        onAccepted: {
            vial_marker_container.deleteVial()
            visible = false
        }
    }

    sourceItem:
        Rectangle {
            id: vial_marker
            width: 20
            height: 20
            radius: 10
            border.width: 2
            border.color: "black"

            property color collectedColour: "lime"
            property color activeColour: "blue"
            property color inactiveColour: "yellow"
            property color skippedColour: "grey"
            property color invalidColour: "red"
            property color borderHoverColour: "dimgrey"

            function updateStatusColour(){
                switch(vial.status){
                case Vial.COLLECTED:
                    vial_marker.color = collectedColour;
                    break;
                case Vial.ACTIVE:
                    vial_marker.color = activeColour;
                    break;
                case Vial.INACTIVE:
                    vial_marker.color = inactiveColour;
                    break;
                case Vial.SKIPPED:
                    vial_marker.color = skippedColour;
                    break;
                case Vial.INVALID:
                default:
                    vial_marker.color = invalidColour;
                }
            }

            MouseArea {
                hoverEnabled: true
                anchors.fill: parent

                onClicked: createInfobox()
                cursorShape: Qt.PointingHandCursor
                onEntered: parent.border.color = parent.borderHoverColour
                onExited: parent.border.color = "black"
            }
        }
    // sourceItem

    anchorPoint.x: vial_marker.width / 2
    anchorPoint.y: vial_marker.height / 2

    onVialChanged: {
        vial_marker_container.coordinate = vial.location
        vial_marker.updateStatusColour()
        //infobox_contents.updateInfo()
        vial.onStatusChanged.connect( function() {
            vial_marker.updateStatusColour()
            //infobox_contents.updateInfo()
        }
    )}

}
