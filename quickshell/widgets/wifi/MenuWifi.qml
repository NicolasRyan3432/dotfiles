pragma ComponentBehavior: Bound
import Quickshell.Networking
import QtQuick
import "../../components" as Components
import "../../singletons" as Singletons

Item {
    id: root
    
    // keeps the current network that is asking for password
    property string askingPasswordFor: ""
    property string askingConfigFor: ""

    property bool isEnabled: Networking.wifiEnabled
    property var wifiDevice: Networking.devices ? Networking.devices.values.find(d => d.type === DeviceType.Wifi) : null
    property var wifiNetworks: {
        if(!wifiDevice || !wifiDevice.networks) return [];

        // .slice() clona a lista principal para o .sort() poder ordenar
        return wifiDevice.networks.values.slice().sort((a,b) => {
            // who is connected stay in the top
            if(a.connected !== b.connected) {
                return a.connected ? -1 : 1;
            } 

            // who has a better signalStrength comes first (descending order)
            if(a.signalStrength !== b.signalStrength) {
                return b.signalStrength - a.signalStrength;
            }

            // alpabetical order by network name
            return (a.name || "").localeCompare(b.name || "");
        });
    }



    function getWifiIcon(strength) {
        if(strength >= 0.80) return "signal_wifi_4_bar"
        if(strength >= 0.60) return "network_wifi_3_bar"
        if(strength >= 0.40) return "network_wifi_2_bar"
        if(strength >= 0.20) return "network_wifi_1_bar"
        return "signal_wifi_0_bar"
    }

    // Liga a propiedade scannerEnabled do wifiDevice,
    // enquanto tiver visível o scanner fica ativo, ao fechar, desabilita
    Binding {
        target: root.wifiDevice
        property: "scannerEnabled"
        value: root.visible
        restoreMode: Binding.RestoreBinding
    }

    // timer used for restart button inside the subheader
    Timer {
        id: rescanTimer
        interval: 150
        repeat: false
        onTriggered: {
            if (root.wifiDevice) root.wifiDevice.scannerEnabled = true
        }
    }

    Item {
        anchors.fill: parent
        anchors.margins: 20


        Components.MenuHeader {
            id: head
            title: "Wifi"
            divEnabled: true
            showSwitch: true
            isChecked: root.wifiDevice && root.wifiDevice.state !== ConnectionState.Unknown
            onBackClicked: Singletons.ControlCenterState.activeTab = "main"
            onSwitchToggled: Networking.wifiEnabled = !Networking.wifiEnabled
        }

        // subheader
        Item {
            id: subheader
            width: parent.width
            height: 28
            anchors {
                top: head.bottom
                topMargin: 20
            }

            // placeholder text
            Text {
              visible: !root.isEnabled
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
                font {
                    family: Singletons.Theme.font
                    pixelSize: Singletons.Theme.fontSize
                }
                color: Singletons.Theme.fg_light
                text: "Enable the wifi to see all the networks!!"  
            }

            // Avaliable networks
            Text {
                visible: root.isEnabled
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
                font {
                    family: Singletons.Theme.font
                    pixelSize: Singletons.Theme.fontSize
                }
                color: Singletons.Theme.fg_light
                text: "Avaliable networks"
            }

            // Button
            Rectangle {
                id: refreshBtn
                visible: root.isEnabled
                width: 26
                height: 26
                radius: 13
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                color: refreshMouse.containsMouse ? Singletons.Theme.fg_light : "transparent"

                Behavior on color {
                    ColorAnimation {duration: 150}
                }

                // refresh icon
                Text {
                    id: refreshIcon
                    anchors.centerIn: parent
                    text: "refresh"
                    color: {
                        if(root.wifiDevice && root.wifiDevice.scannerEnabled) return Singletons.Theme.fg
                        if(refreshMouse.containsMouse) return Singletons.Theme.fg
                    }
                    font {
                        family: Singletons.Theme.iconFont
                        pixelSize: Singletons.Theme.fontSize
                    }


                    RotationAnimation on rotation {
                        id: spinAnim
                        from: 0
                        to: 360
                        duration: 700
                        easing.type: Easing.OutCubic
                        running: false
                    }
                }

                MouseArea {
                    id: refreshMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if(root.wifiDevice) {
                            spinAnim.restart()
                            root.wifiDevice.scannerEnabled = false
                            rescanTimer.restart()
                        }
                    }
                }
            }
        }


        // Itens
        ListView {
            id: wifiList
            width: parent.width 
            clip: true
            spacing: 10

            anchors {
                top: subheader.bottom
                topMargin: 20
                bottom: parent.bottom
            }

            model: root.wifiNetworks
            delegate: itemDelegate
        }

        Component {
            id: itemDelegate
            Rectangle {
                id: itens
                width: wifiList.width
                height: (showPasswordBox || showConfigBox) ? 100 : 55
                clip: true
                color: itensArea.containsMouse? Singletons.Theme.comment : "transparent"
                radius: 12
                required property var modelData
                
                // Checks if is that network has the password box opened
                readonly property bool showPasswordBox: root.askingPasswordFor === modelData.name
                readonly property bool showConfigBox: root.askingConfigFor === modelData.name

                property bool showPass: false
                

                Behavior on height {
                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                }
                Behavior on color { ColorAnimation { duration: 200 } }

                // wifi info
                Item {
                    id: topRow
                    width: parent.width
                    height: 55
                    anchors.top: parent.top

                    // Wifi icon
                    Rectangle {
                        id: imageRec
                        color: "transparent"
                        implicitWidth: 56
                        implicitHeight: 46

                        anchors {
                            left: parent.left
                            leftMargin: 10
                            verticalCenter: parent.verticalCenter
                        }
                        // Main icon
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: root.getWifiIcon(itens.modelData.signalStrength)
                            color: itens.modelData.connected ? Singletons.Theme.base2 : Singletons.Theme.fg
                            font {
                                family: Singletons.Theme.iconFont
                                pixelSize: 20
                            }
                        }
                    }

                    // wifi name
                    Text {  
                        anchors{
                            verticalCenter: parent.verticalCenter
                            verticalCenterOffset: -6
                            left: parent.left
                            leftMargin: 40   
                        }
                        font {
                            family: Singletons.Theme.font
                            pixelSize: Singletons.Theme.fontSize
                            weight: Font.Bold
                        }

                        color: itens.modelData.connected || itensArea.containsMouse ? Singletons.Theme.fg: Singletons.Theme.fg_light
                        text: itens.modelData.name
                        
                        Behavior on color { ColorAnimation { duration: 200} }
                    }

                    // networks info
                    Row {
                        anchors{
                            bottom: parent.bottom
                            bottomMargin: 4
                            left: parent.left
                            leftMargin: 40
                        }
                        spacing: 3

                        // security type
                        Text {
                            font {
                                family: Singletons.Theme.font
                                pixelSize: 11
                                weight: Font.Light
                            }

                            anchors.verticalCenter: parent.verticalCenter
                            color: itensArea.containsMouse 
                            ? Singletons.Theme.comment_light : Singletons.Theme.fg_light
                            text: "Security: " + WifiSecurityType.toString(itens.modelData.security)

                            Behavior on color { ColorAnimation { duration: 200 } }
                        }

                        // hyphen
                        Rectangle {
                            visible: itens.modelData.known
                            anchors.verticalCenter: parent.verticalCenter
                            width: 4
                            height: 4
                            radius: height/2
                            color: itens.modelData.connected ? Singletons.Theme.base11 : Singletons.Theme.base4
                        }

                        // Text connected/saved
                        Text {
                            font {
                                family: Singletons.Theme.font
                                pixelSize: 11
                                weight: Font.Light
                            }
                            anchors.verticalCenter: parent.verticalCenter
                            color: itens.modelData.connected || itensArea.containsMouse 
                            ? Singletons.Theme.base6 : Singletons.Theme.fg_light
                            text: itens.modelData.connected ? "Connected" : itens.modelData.known ? "Saved" : ""
                        }
                    }

                    // icon settings/lock
                    Rectangle {
                        anchors {
                            verticalCenter: parent.verticalCenter
                            right: parent.right
                            rightMargin: 30
                        }
                        color: settingsMouse.containsMouse ? Singletons.Theme.fg_light : "transparent"
                        z: 5
                        width: iconTxt.implicitWidth + 20
                        height: iconTxt.implicitHeight + 10
                        radius: height/2

                        // icon button 
                        Text {
                            id: iconTxt
                            anchors.centerIn: parent
            
                            font {
                                family: Singletons.Theme.iconFont
                                pixelSize: 15
                            }

                            color: settingsMouse.containsMouse 
                            ? Singletons.Theme.base6 : itens.modelData.connected 
                            ? Singletons.Theme.base11 : Singletons.Theme.base6

                            text: itens.modelData.connected 
                            ? "settings" : itens.modelData.security === WifiSecurityType.Open 
                            ? "" : "lock"

                            Behavior on color { ColorAnimation { duration: 200 } }

                            MouseArea {
                                id: settingsMouse
                                anchors.fill: parent
                                enabled: itens.modelData.connected
                                hoverEnabled: true
                                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: {
                                    root.askingPasswordFor = ""
                                    if(root.askingConfigFor === itens.modelData.name) {
                                        root.askingConfigFor = ""
                                    }
                                    else {
                                        root.askingConfigFor = itens.modelData.name
                                    }
                                }
                            }
                        }
                    }

                    MouseArea {
                        id: itensArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onDoubleClicked: {
                            root.askingConfigFor = ""
                            if(itens.modelData.connected) itens.modelData.disconnect()
                            else if(itens.modelData.known || itens.modelData.security === WifiSecurityType.Open) {
                                root.askingPasswordFor = ""
                                itens.modelData.connect()
                            }
                            else {
                                // needs password, open/close the password input box
                                if(root.askingPasswordFor === itens.modelData.name) {
                                    root.askingPasswordFor = ""
                                }
                                else {
                                    root.askingPasswordFor = itens.modelData.name
                                    passInput.text = ""
                                    passInput.forceActiveFocus()
                                }
                            }
                        }
                    }
                }
                // password box
                Rectangle {
                    id: passBox
                    visible: itens.showPasswordBox
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: topRow.bottom
                        margins: 8
                    }
                    height: 32
                    radius: 8
                    color: Singletons.Theme.bg
                    border.color: Singletons.Theme.base5

                    TextInput {
                        id: passInput
                        anchors {
                            fill: parent
                            leftMargin: 10
                            rightMargin: 36
                        }
                        font {
                            family: Singletons.Theme.font
                            pixelSize: Singletons.Theme.fontSize
                        }
                        verticalAlignment: TextInput.AlignVCenter
                        color: Singletons.Theme.base5
                        echoMode: itens.showPass ? TextInput.Normal : TextInput.Password
                        

                        // enter key pressed
                        Keys.onReturnPressed: {
                            if(text.length > 0) {
                                itens.modelData.connectWithPsk(text)
                                root.askingPasswordFor = ""
                            }
                        }
                        Keys.onEscapePressed: root.askingPasswordFor = ""
                    }

                    // input button
                    Text {
                        anchors {
                            right: parent.right
                            rightMargin: 8
                            verticalCenter: parent.verticalCenter
                        }
                        font {
                            family: Singletons.Theme.iconFont
                            pixelSize: 18
                        }
                        text: "arrow_forward"
                        color: Singletons.Theme.base4

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {    
                                if(passInput.text.length > 0) {
                                    itens.modelData.connectWithPsk(passInput.text)
                                    root.askingPasswordFor = ""
                                }
                            }
                        }
                    }
                    
                    // Visibility button
                    Text {
                        anchors {
                            right: parent.right
                            rightMargin: 34
                            verticalCenter: parent.verticalCenter
                        }  
                        font {
                            family: Singletons.Theme.iconFont
                            pixelSize: 18
                        }

                        text: itens.showPass ? "visibility" : "visibility_off"
                        color: Singletons.Theme.base4

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                itens.showPass = !itens.showPass
                                passInput.forceActiveFocus()
                            }
                        }
                    }
                }

                Row {
                    id: configRow
                    visible: itens.showConfigBox
                    height: 32
                    clip: true
                    spacing: 10

                    anchors {
                        top: topRow.bottom
                        left: parent.left
                        leftMargin: 10
                        topMargin: 10
                    }
                    
                    
                    Rectangle {
                        visible: itens.modelData.known
                        anchors.verticalCenter: parent.verticalCenter
                        width: txtForget.implicitWidth + 20
                        height: txtForget.implicitHeight + 10
                        color: forgetArea.containsMouse ? Singletons.Theme.bg : Singletons.Theme.base1
                        radius: 12
                        
                        Behavior on color { ColorAnimation { duration: 200 } }

                        // forget text
                        Text {
                            id: txtForget
                            anchors.centerIn: parent
                            text: itens.modelData.known ? "Forget" : ""
                            color: forgetArea.containsMouse ? Singletons.Theme.base7 : Singletons.Theme.base5
                            font {
                                family: Singletons.Theme.font
                                pixelSize: Singletons.Theme.fontSize
                            }
                        }
                        MouseArea {
                            id: forgetArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.askingConfigFor = ""
                                itens.modelData.forget()
                            }
                        }
                    }

                }
            }
        }
    }
}