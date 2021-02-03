import QtQuick 2.0
import QtLocation 5.6
import QtPositioning 5.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.3

Rectangle {
        Rectangle {
            id: rect
            width: 20
            height: 20
            radius: 10
            border.width: 2
            border.color: "black"
        }

        Image {
            id: infobox_arrow
            source: "qrc:/VialInfoboxArrow.png"
            horizontalAlignment: Image.AlignHCenter
            x: -infobox_arrow.width/2 + rect.width/2
            y: rect.height - 2
        }

        Rectangle {
            id: infobox_contents
            width: 220
            height: 150
            x: -infobox_contents.width/2 + rect.width/2
            y: rect.height + infobox_arrow.height - 4
            border.color: "black"
            border.width: 1

            RowLayout {
                id: rowLayout
                anchors.fill: parent

                ColumnLayout {
                    id: columnLayout
                    Layout.margins: 5

                    Text {
                        id: vial_id
                        text: qsTr("{vial_id}")
                        font.pointSize: 8
                        Layout.fillWidth: true
                    }

                    Text {
                        id: vial_location_name
                        text: "{vial_name}"
                        font.pointSize: 12
                        font.bold: true
                        Layout.fillWidth: true
                    }

                    Text {
                        id: vial_status
                        text: "{vial_status}"
                        Layout.fillWidth: true
                    }

                    Text {
                        id: vial_created_on
                        text: "{vial_created_on}"
                        Layout.fillWidth: true
                    }

                    Text {
                        id: vial_collected_on
                        text: qsTr("{vial_collected_on}")
                        Layout.fillWidth: true
                    }

                    Text {
                        id: vial_latitude
                        text: "{vial_latitude}"
                        Layout.fillWidth: true
                    }

                    Text {
                        id: vial_longitude
                        text: "{vial_longitude}"
                        Layout.fillWidth: true
                    }



                }

                ColumnLayout {
                    id: columnLayout1
                    width: 100
                    height: 100
                    Layout.margins: 5
                    Layout.maximumWidth: 50
                    spacing: 0

                    Button {
                        id: edit_vial_btn
                        width: 50
                        height: 50
                        text: qsTr("Edit")
                        Layout.rightMargin: 1
                        Layout.margins: 0
                        Layout.maximumWidth: 50
                    }

                    Button {
                        id: delete_vial_btn
                        width: 50
                        height: 50
                        text: qsTr("Delete")
                        Layout.margins: 0
                        Layout.maximumWidth: 50
                    }

                    Button {
                        id: close_btn
                        width: 50
                        height: 50
                        text: qsTr("Close")
                        Layout.margins: 0
                        Layout.maximumWidth: 50
                    }
                }

            }
        }

        MouseArea {
            hoverEnabled: true
            anchors.fill: rect
            onClicked: console.log(vial.name)
            cursorShape: Qt.PointingHandCursor
            onEntered: rect.border.color = vial_marker.borderHoverColour
            onExited: rect.border.color = "black"
        }

    }


/*##^##
Designer {
    D{i:0;autoSize:true;formeditorZoom:1.5;height:480;width:640}D{i:4}
}
##^##*/
