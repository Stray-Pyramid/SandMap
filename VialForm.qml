import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.0
import QtPositioning 5.12
import QtQuick.Dialogs 1.2

import Vial 1.0
import VialLoader 1.0

Rectangle {
    id: vial_properties_forum
    width: 476
    height: 608
    visible: false
    color: "#aeaeae"
    radius: 10
    border.width: 1
    anchors.centerIn: parent
    z: 100

    property bool editing_vial: false
    property var active_vial_container // Vial container current being editted

    property alias latitude: latitude.text
    property alias longitude: longitude.text

    function newVial(){
        // Clear all fiels
        // Show vial forum
        title.text = qsTr("Create a new vial marker")
        editing_vial = false

        name.text = ""
        longitude.text = ""
        latitude.text = ""
        latitude_d.text = ""
        latitude_m.text = ""
        latitude_s.text = ""
        longitude_d.text = ""
        longitude_m.text = ""
        longitude_s.text = ""
        created_on.text = formatDate(new Date());
        collected_on.text = ""

        status.currentIndex = Vial.INACTIVE

        vial_properties_forum.visible = true
        map.disable_panning = true
        z = 10
    }

    function formatDate(date) {
        // Converts date object into formatted string YYYY-MM-DD HH:MM:SS
        if(date === null) return "None";

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

    function saveVial(){
        var invalid_reasons = validate()
        if(invalid_reasons.length > 0){
            invalid_form_dialog.show(invalid_reasons)
            return
        }

        var latitude_val = parseFloat(latitude.text);
        var longitude_val = parseFloat(longitude.text);

        var dateAdded = map.stringToDateTime(created_on.text);

        var dateCollected
        if (status.currentIndex === Vial.COLLECTED){
            dateCollected = map.stringToDateTime(collected_on.text);
        } else {
            dateCollected = invalidDate;
        }

        var vial
        if (editing_vial){
            // Existing Vial
            vial = active_vial_container.vial;
            vial.name = name.text;
            vial.location = QtPositioning.coordinate(latitude_val, longitude_val);
            vial.dateAdded = dateAdded;
            vial.dateCollected = dateCollected;
            vial.status = status.currentIndex;

        } else {
            // New Vial
            vial = loader.createVial(name.text, QtPositioning.coordinate(latitude_val, longitude_val), dateAdded, dateCollected);
            vial.status = status.currentIndex;
            map.addVial(vial);
        }

        map.disable_panning = false;
        vial_properties_forum.visible = false;
    }

    function editVial(vial_container){
        var vial = vial_container.vial;
        editing_vial = true;
        active_vial_container = vial_container;

        title.text = "#"+vial.id.toString().padStart(5, '0') + " " + vial.name;

        // Vial name
        name.text = vial.name;

        // lat, long
        latitude.text = vial.location.latitude;
        update_latitude_dms();

        longitude.text = vial.location.longitude;
        update_longitude_dms();

        // status
        status.currentIndex = vial.status;

        // created on
        created_on.text = formatDate(vial.dateCreated);

        // collected on
        collected_on.text = formatDate(vial.dateCollected);

        vial_properties_forum.visible = true;
    }

    function closeVialForum(){
        map.disable_panning = false;
        vial_properties_forum.visible = false;
    }

    function validate(){
        var invalid_reasons = [];

        // Name
        //should not be null
        if (!name.acceptableInput){
            invalid_reasons.push("Name invalid")
        }

        // Location (latitude/longitude)
        // Should be a int or float
        if(!latitude.acceptableInput){
            invalid_reasons.push("Latitude Invalid")
        }

        if(!longitude.acceptableInput){
            invalid_reasons.push("Longitude Invalid")
        }

        // dateCreated/dateCollected
        // Should be of the format YYYY-MM-DD HH:MM:SS
        if(!created_on.acceptableInput){
            invalid_reasons.push("Created on date Invalid")
        }

        if(status.currentIndex === Vial.COLLECTED){
            if(!collected_on.acceptableInput){
                invalid_reasons.push("Collected on date Invalid")
            }
        }

        // status
        // status index should exist within vial status enum.
        if(!(status.currentIndex >= 0 && status.currentIndex <= Vial.INVALID)){
            invalid_reasons.push("Status invalid")
        }

        return invalid_reasons
    }

    function update_latitude_dec(){
        var lat_d = parseFloat(latitude_d.text) || 0;
        var lat_m = parseFloat(latitude_m.text) || 0;
        var lat_s = parseFloat(latitude_s.text) || 0;

        if (lat_d > 0){
            latitude.text = lat_d + (lat_m/60) + (lat_s/3600);
        } else {
            latitude.text = lat_d - (lat_m/60) - (lat_s/3600);
        }

    }

    function update_longitude_dec(){
        var lng_d = parseFloat(longitude_d.text) || 0;
        var lng_m = parseFloat(longitude_m.text) || 0;
        var lng_s = parseFloat(longitude_s.text) || 0;

        if (lng_d > 0){
            longitude.text = lng_d + (lng_m/60) + (lng_s/3600);
        } else {
            longitude.text = lng_d - (lng_m/60) - (lng_s/3600);
        }
    }

    function update_latitude_dms(){
        var lat = parseFloat(latitude.text) || 0;

        var lat_d = Math.trunc(lat);
        var lat_m = Math.trunc(Math.abs(lat - lat_d)*60);
        var lat_s = (Math.abs(lat - lat_d) - (lat_m/60)) * 3600;

        latitude_d.text = lat_d;
        latitude_m.text = lat_m;
        latitude_s.text = lat_s;

    }

    function update_longitude_dms(){
        var lng = parseFloat(longitude.text) || 0;

        var lng_d = Math.trunc(lng);
        var lng_m = Math.trunc(Math.abs(lng - lng_d)*60);
        var lng_s = (Math.abs(lng - lng_d) - (lng_m/60)) * 3600;

        longitude_d.text = lng_d;
        longitude_m.text = lng_m;
        longitude_s.text = lng_s;

    }

    function selectMapLocation(){
        vial_properties_forum.visible = false;
        map.selectLocation();
    }

    MessageDialog {
        id: invalid_form_dialog
        title: "Form Invalid"
        icon: StandardIcon.Critical

        function show(invalid_reasons){
            text = invalid_reasons.join('\n')
            open()
        }
    }

    ColumnLayout {
        id: columnLayout
        anchors.fill: parent
        spacing: 5
        anchors.rightMargin: 10
        anchors.leftMargin: 10
        anchors.bottomMargin: 10
        anchors.topMargin: 10

        Text {
            id: title
            text: qsTr("Create a new vial marker")
            font.pixelSize: 28
            Layout.columnSpan: 1
            font.bold: true
        }

        Label {
            id: name_label
            text: qsTr("Name")
            topPadding: 5
            Layout.columnSpan: 1
            font.pointSize: 12

        }

        TextField {
            id: name
            visible: true
            placeholderText: "Name"
            Layout.fillWidth: true
            Layout.columnSpan: 1
            selectByMouse: true // Default true the docs say...
            validator: RegExpValidator { regExp: /.+/ }
        }

        RowLayout {
            id: rowLayout
            width: 100
            height: 100

            Label {
                id: location_label
                text: qsTr("Location")
                topPadding: 5
                Layout.columnSpan: 1
                font.pointSize: 12
            }

            Button {
                id: location_pin
                display: AbstractButton.IconOnly
                Layout.preferredHeight: 20
                Layout.preferredWidth: 20
                onClicked: vial_properties_forum.selectMapLocation()
            }


        }

        TextField {
            id: latitude
            placeholderText: "Latitude"
            Layout.fillWidth: true
            Layout.columnSpan: 1
            selectByMouse: true
            onTextEdited: vial_properties_forum.update_latitude_dms()
            validator: DoubleValidator { bottom: -90; top:90 }
        }

        TextField {
            id: longitude
            placeholderText: "Longitude"
            Layout.fillWidth: true
            Layout.columnSpan: 1
            selectByMouse: true
            onTextEdited: vial_properties_forum.update_longitude_dms()
            validator: DoubleValidator { bottom: -180; top: 180 }
        }

        RowLayout {
            id: latitude_dms
            width: 100
            height: 100
            spacing: 0

            TextField {
                id: latitude_d
                leftPadding: 10
                placeholderText: "D"
                Layout.fillWidth: true
                selectByMouse: true
                onTextEdited: vial_properties_forum.update_latitude_dec()
            }

            TextField {
                id: latitude_m
                placeholderText: "M"
                Layout.fillWidth: true
                selectByMouse: true
                onTextEdited: vial_properties_forum.update_latitude_dec()
            }

            TextField {
                id: latitude_s
                placeholderText: "S"
                Layout.fillWidth: true
                selectByMouse: true
                onTextEdited: vial_properties_forum.update_latitude_dec()
            }



        }

        RowLayout {
            id: longitude_dms
            width: 100
            height: 100
            spacing: 0

            TextField {
                id: longitude_d
                placeholderText: "D"
                Layout.fillWidth: true
                selectByMouse: true
                onTextEdited: vial_properties_forum.update_longitude_dec()
            }

            TextField {
                id: longitude_m
                placeholderText: "M"
                Layout.fillWidth: true
                selectByMouse: true
                onTextEdited: vial_properties_forum.update_longitude_dec()
            }

            TextField {
                id: longitude_s
                placeholderText: "S"
                Layout.fillWidth: true
                selectByMouse: true
                onTextEdited: vial_properties_forum.update_longitude_dec()
            }


        }

        Label {
            id: status_label
            text: qsTr("Status")
            topPadding: 5
            Layout.columnSpan: 1
            font.pointSize: 12
        }

        ComboBox {
            id: status
            currentIndex: 1
            textRole: "text"
            model: [
                {value: Vial.COLLECTED, text: qsTr("Collected")},
                {value: Vial.ACTIVE, text: qsTr("Active")},
                {value: Vial.INACTIVE, text: qsTr("Inactive")},
                {value: Vial.SKIPPED, text: qsTr("Skipped")},
                {value: Vial.INVALID, text: qsTr("Invalid")},
            ]
            Layout.fillWidth: true
            editable: false
            onCurrentIndexChanged: {
                if (status.currentIndex == Vial.COLLECTED){
                    collected_on.enabled = true
                } else {
                    collected_on.enabled = false
                    collected_on.clear()
                }
            }

        }

        Label {
            id: created_on_label
            text: qsTr("Created on")
            topPadding: 5
            font.pointSize: 12
            Layout.columnSpan: 1
        }

        TextField {
            id: created_on
            text: qsTr("")
            placeholderText: "YYYY-MM-DD HH:MM:SS"
            Layout.fillWidth: true
            Layout.columnSpan: 1
            selectByMouse: true
            validator: RegExpValidator{ regExp: /^\d{4}-[01]\d-[0-3]\d [0-2]\d:[0-5]\d:[0-5]\d$/ }
        }

        Label {
            id: collected_on_label
            text: qsTr("Collected on")
            topPadding: 5
            font.pointSize: 12
            Layout.columnSpan: 1
        }

        TextField {
            id: collected_on
            placeholderText: "YYYY-MM-DD HH:MM:SS"
            Layout.fillWidth: true
            Layout.columnSpan: 1
            selectByMouse: true
            validator: RegExpValidator{ regExp: /^\d{4}-[01]\d-[0-3]\d [0-2]\d:[0-5]\d:[0-5]\d$/ }
        }

        RowLayout {
            id: action_buttons
            width: 100
            height: 100
            Layout.topMargin: 5

            Button {
                id: cancel
                text: qsTr("Cancel")
                font.pointSize: 12
                Layout.fillWidth: true
                Layout.columnSpan: 1
                onClicked: vial_properties_forum.closeVialForum()
            }

            Button {
                id: save
                text: qsTr("Save")
                font.bold: true
                font.pointSize: 12
                Layout.fillWidth: true
                Layout.columnSpan: 1
                onClicked: vial_properties_forum.saveVial()
            }
        }
    }
}


