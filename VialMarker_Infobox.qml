import QtQuick 2.0
import QtLocation 5.6
import QtPositioning 5.12
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.3

import Vial 1.0

MapQuickItem {
    id:infobox_container

    property Vial vial;
    property var marker_container

    function close(){
        destroy()
    }

    onVialChanged: {
        coordinate = vial.location
        infobox_contents.updateInfo()
    }

    sourceItem: Rectangle {
        Image {
            id: infobox_arrow
            source: "qrc:/VialInfoboxArrow.png"
            horizontalAlignment: Image.AlignHCenter
            x: -infobox_arrow.width/2
            y: vial_marker.height/2
        }

        Rectangle {
            id: infobox_contents
            width: 220
            height: 150
            x: -infobox_contents.width/2
            y: vial_marker.height/2 + infobox_arrow.height - 2
            border.color: "black"
            border.width: 1

            // I wonder why javascript doesn't already include a date formater
            function formatDate(date) {
                var d = new Date(date),
                    month = '' + (d.getMonth() + 1),
                    day = '' + d.getDate(),
                    year = d.getFullYear(),
                    hour = '' + d.getHours(),
                    minute = '' + d.getMinutes(),
                    second = '' + d.getSeconds();

                if (month.length < 2)
                    month = '0' + month;
                if (day.length < 2)
                    day = '0' + day;

                if (hour.length < 2)
                    hour = '0' + hour;
                if (minute.length < 2)
                    minute = '0' + minute;
                if (second.length < 2)
                    second = '0' + second;

                return [year, month, day].join('-') + ' ' + [hour, minute, second].join(':');
            }

            function formatLongitude(longitude){
                var lng_abs = Math.abs(longitude);

                var lng_d = Math.trunc(lng_abs);
                var lng_m = Math.trunc(Math.abs(lng_abs - lng_d)*60)
                var lng_s = ((Math.abs(lng_abs - lng_d) - (lng_m/60)) * 3600).toFixed(2);

                var lng_str = lng_d + "\xB0" + lng_m + "'" + lng_s + '"'

                if (longitude > 0){
                    return lng_str + "E"
                } else {
                    return lng_str + "W"
                }
            }

            function formatLatitude(latitude){
                var lat_abs = Math.abs(latitude);

                var lat_d = Math.trunc(lat_abs);
                var lat_m = Math.trunc(Math.abs(lat_abs - lat_d)*60)
                var lat_s = ((Math.abs(lat_abs - lat_d) - (lat_m/60)) * 3600).toFixed(2);

                var lat_str = lat_d + "\xB0" + lat_m + "'" + lat_s + '"'

                if (latitude > 0){
                    return lat_str + "N";
                } else {
                    return lat_str + "S";
                }
            }

            function updateInfo(){
                vial_id.text = "#"+vial.id.toString().padStart(5, '0');
                vial_name.text = vial.name

                var status = vial.getStatusString().toLowerCase()
                vial_status.text =  status.charAt(0).toUpperCase() + status.slice(1)

                vial_created_on.text = "Created: " + formatDate(vial.dateCreated);

                if (vial.status === Vial.COLLECTED){
                    vial_collected_on.text = "Collected: " + formatDate(vial.dateCollected);
                } else {
                    vial_collected_on.text = "Collected: No";
                }

                vial_longitude.text = formatLongitude(vial.location.longitude);
                vial_latitude.text = formatLatitude(vial.location.latitude);
            }

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
                        id: vial_name
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
                        onClicked: editVial()
                    }

                    Button {
                        id: delete_vial_btn
                        width: 50
                        height: 50
                        text: qsTr("Delete")
                        Layout.margins: 0
                        Layout.maximumWidth: 50
                        onClicked: promptDeleteVial()
                    }

                    Button {
                        id: close_btn
                        width: 50
                        height: 50
                        text: qsTr("Close")
                        Layout.margins: 0
                        Layout.maximumWidth: 50
                        onClicked: infobox_container.close()
                    }
                }
            }
        }
    }
}




