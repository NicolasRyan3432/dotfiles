pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Bluetooth
import QtQuick.Controls
import QtQuick
import "../../components" as Components
import "../../singletons" as Singletons

Item {
    id: rootBluetooth

    property BluetoothAdapter defaultAdapter: Bluetooth.defaultAdapter 
    property bool discovering: rootBluetooth.defaultAdapter.discovering

    function findTypeOfBT(iconName) {
        if (!iconName) return "Unknown";
        
        const types = {
            "audio-headset": "Headset",
            "audio-headphones": "Headphones",
            "audio-card": "Audio Device",
            "phone": "Smartphone",
            "smartphone": "Smartphone",
            "input-mouse": "Mouse",
            "input-keyboard": "Keyboard",
            "input-gaming": "Controller",
            "computer": "Computer",
            "network-wireless": "Network",
            "bluetooth": "Bluetooth Device"
        };

        return types[iconName] || iconName.replace("-", " ");
    }

    // Timer for kill the discovering proc of Bluetooth
    Timer {
        id: timer
        interval: 30000 
        repeat: false 
        onTriggered: {
            if (rootBluetooth.defaultAdapter && rootBluetooth.defaultAdapter.discovering) {
                rootBluetooth.defaultAdapter.discovering = false 
            }
        }
    }

    Connections {
        target: Singletons.ControlCenterState
        // If CCS not visible, if bluetooth is discovering, kill the process and stop the timer
        function onLauncherVisibleChanged() {
            if (!Singletons.ControlCenterState.launcherVisible) {
                if (rootBluetooth.defaultAdapter && rootBluetooth.defaultAdapter.discovering) {
                    rootBluetooth.defaultAdapter.discovering = false 
                    timer.stop()
                }
            }
        }
    }

    

    Item {
        anchors.fill: parent
        anchors.margins: 20

        Components.MenuHeader {
            id: header
            title: "Bluetooth"
            divEnabled: true
            onBackClicked: Singletons.ControlCenterState.activeTab = "main"
            showSwitch: true
            isChecked: rootBluetooth.defaultAdapter.enabled
            onSwitchToggled: rootBluetooth.defaultAdapter.enabled = !rootBluetooth.defaultAdapter.enabled
        }

        
        // If bluetooth is disabled, show text, otherwise show the 
        Text {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            
            visible: !rootBluetooth.defaultAdapter.enabled
            
            text: "Active the Bluetooth to see all the devices!!!"
            color: Singletons.Theme.comment_light
            font.pixelSize: Singletons.Theme.fontSize
            font.family: Singletons.Theme.font
        }

        // Text paired
        Text {
            id: textPaired
            visible: rootBluetooth.defaultAdapter.enabled 
            && rootBluetooth.defaultAdapter.devices.values.filter(d => d.paired).length > 0
            anchors {
                top: header.bottom
                topMargin: 20 
                horizontalCenter: parent.horizontalCenter
            }
            text: "Paired devices"
            color: Singletons.Theme.fg
            font.pixelSize: Singletons.Theme.fontSize
            font.family: Singletons.Theme.font
        }

        // No paired
        Text {
            id: textNoPaired
            visible: rootBluetooth.defaultAdapter.enabled 
            && rootBluetooth.defaultAdapter.devices.values.filter(d => d.paired).length === 0
            anchors.top: header.bottom
            anchors.topMargin: 15 
            anchors.horizontalCenter: parent.horizontalCenter

            text: "There are no paired devices."
            color: Singletons.Theme.comment_light
            font.pixelSize: Singletons.Theme.fontSize
            font.family: Singletons.Theme.font
        }

        // Paired devices
        Column {
            id: listPaired
            visible: rootBluetooth.defaultAdapter.enabled
            spacing: 10 

            anchors {
                top: textPaired.bottom
                left: parent.left
                right: parent.right
                topMargin: 15
            }

            Repeater {
                model: rootBluetooth.defaultAdapter ? rootBluetooth.defaultAdapter.devices.values.filter(d => d.paired) : []
                delegate: itemDelegate
            }
            
        }

        // Icon and Text "avaliable devices"
        Row {
            id: rowAvailable
            visible: rootBluetooth.defaultAdapter.enabled 
            spacing: 10

            anchors {
                top: listPaired.bottom
                left: parent.left
                right: parent.right
                topMargin: 20
                bottomMargin: 30
            }


            // Avaliable devices text
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "Available devices"
                color: Singletons.Theme.fg
                font {
                    pixelSize: Singletons.Theme.fontSize
                    family: Singletons.Theme.font
                }
            }

            // Refresh/Stop icon
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: iconRefresh.implicitWidth + 30
                height: iconRefresh.implicitHeight + 2
                radius: height/2
                color: rootBluetooth.discovering 
                ? Singletons.Theme.base5 : Singletons.Theme.fg_light

                Behavior on color { ColorAnimation { duration: 250 } }

                Text {
                    id: iconRefresh
                    anchors.centerIn: parent
                    text: rootBluetooth.discovering? "stop" : "refresh"
                    color: rootBluetooth.discovering
                    ? Singletons.Theme.comment : iconArea.containsMouse 
                    ? Singletons.Theme.fg : Singletons.Theme.comment_light 
                    renderType: Text.NativeRendering
                    font {
                        pixelSize: Singletons.Theme.fontSize
                        family: Singletons.Theme.iconFont
                        variableAxes: {"FILL": 1}
                    }
                    Behavior on color { ColorAnimation { duration: 250 } }
                }


                MouseArea {
                    id: iconArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked:  {
                        rootBluetooth.defaultAdapter.discovering = !rootBluetooth.defaultAdapter.discovering
                        if(rootBluetooth.defaultAdapter.discovering) {
                            timer.restart()
                        } 
                        else {
                            timer.stop()
                        }
                    }
                }
            }
        }

        // Avaliable devices
        ListView {
            id: listAvailable
            visible: rootBluetooth.defaultAdapter.enabled && rootBluetooth.defaultAdapter.discovering
            spacing: 10 
            clip: true

            anchors {
                top: rowAvailable.bottom
                bottom: parent.bottom
                left: parent.left
                right: parent.right
                topMargin: 10
            }
            
            model: rootBluetooth.defaultAdapter ? rootBluetooth.defaultAdapter.devices.values.filter(d => !d.paired) : []
            delegate: itemDelegate
        }

        Component {
            id: itemDelegate
            Rectangle {
                id: itens
                required property var modelData
                width: parent.width
                height: 60
                radius: 12
                color: itensArea.containsMouse? Singletons.Theme.comment : "transparent"

                Behavior on color { ColorAnimation { duration: 250 } }

                // Icon Rectangle
                Rectangle {
                    id: imageRec
                    anchors {
                        left: parent.left
                        leftMargin: 10
                        verticalCenter: parent.verticalCenter
                    }

                    color: "transparent"
                    implicitWidth: 56
                    implicitHeight: 46

                    // Main icon
                    Components.Img {
                        imgWidth: 46
                        imgHeight: parent.height
                        anchors {
                            verticalCenter: parent.verticalCenter
                            centerIn: parent
                        }
                        property bool path: itens.modelData.icon.trim() !== ""
                        imgSource: path 
                        ? Quickshell.iconPath(itens.modelData.icon) 
                        : Quickshell.iconPath("bluetooth")
                    }

                    // connected icon
                    Components.Img {
                        isVisible: itens.modelData.paired && itens.modelData.connected
                        imgWidth: 18
                        imgHeight: 18
                        imgSource: Quickshell.iconPath("blueman-connected-emblem") 
                        
                        anchors {
                            top: imageRec.top
                            left: imageRec.left
                        }
                    }
                    
                    // paired icon
                    Components.Img {
                        isVisible: itens.modelData.paired && !itens.modelData.connected
                        imgWidth: 18
                        imgHeight: 18
                        anchors {
                            top: imageRec.top
                            left: imageRec.left
                        }
                        imgSource: Quickshell.iconPath("blueman-paired-emblem")
                    }

                    // trusted
                    Components.Img {
                        isVisible: itens.modelData.trusted
                        imgWidth: 18
                        imgHeight: 18
                        anchors {
                            bottom: imageRec.bottom
                            left: imageRec.left
                        }
                        imgSource: Quickshell.iconPath("blueman-trusted-emblem")
                    }
                }

                // itens info
                Column {
                    id: pairedInfo
                    anchors {
                        left: parent.left
                        leftMargin: 70   
                        verticalCenter: parent.verticalCenter
                    }

                    // device name
                    Text {
                        color: itens.modelData.paired
                        ? Singletons.Theme.fg : itensArea.containsMouse
                        ? Singletons.Theme.fg : Singletons.Theme.fg_light
                        text: itens.modelData.name !== "" ? itens.modelData.name: ""
                        Behavior on color { ColorAnimation {duration: 250 } }

                        font {
                            pixelSize: 18
                            family: Singletons.Theme.font
                            weight: Font.Bold
                        }
                    }

                    // Device type
                    Text {
                        color: Singletons.Theme.comment_light
                        font {
                            pixelSize: 12
                            family: Singletons.Theme.font
                        }
                        text: rootBluetooth.findTypeOfBT(itens.modelData.icon)
                    }

                    // device mac address
                    Text {
                        color: Singletons.Theme.comment_light
                        font {
                            pixelSize: 12
                            family: Singletons.Theme.font
                            weight: Font.StyleItalic
                        }
                        text: itens.modelData.address
                    }
                }

                // battery level
                Text {
                    color: Singletons.Theme.fg
                    font {
                        pixelSize: 12
                        family: Singletons.Theme.font
                    }
                    anchors {
                        bottom: parent.bottom 
                        right: parent.right
                        bottomMargin: 2
                        rightMargin: 10
                    } 

                    text: itens.modelData.connected 
                    && itens.modelData.batteryAvailable 
                    ? "Battery level: " + Math.round(itens.modelData.battery * 100) + "%" 
                    : ""
                }   

                MouseArea {
                    id: itensArea
                    anchors.fill: itens
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                    onDoubleClicked: (mouse) => {
                        if(mouse.button === Qt.LeftButton) {
                            if (!itens.modelData.paired) {
                                itens.modelData.pair() 
                            } 
                            else if (!itens.modelData.connected) {
                                itens.modelData.connect() 
                            } 
                            else {
                                itens.modelData.disconnect() 
                            }
                        }
                    }
                    onClicked: (mouse) => {
                        if (mouse.button === Qt.RightButton) btMenu.popup() 
                        else if (mouse.button === Qt.LeftButton) return;
                    }
                }

                // Menu
                Menu {  
                    id: btMenu
                    background: Rectangle {
                        implicitWidth: 150
                        border.width: 1
                        border.color: Singletons.Theme.base5
                        color: Singletons.Theme.bg
                        radius: 8
                    }

                    // menu item connect
                    MenuItem {
                        id: itemConnect
                        text: itens.modelData.connected ? "Disconnect" : "Connect"
                        
                        background: Rectangle {
                            color: itemConnect.highlighted ? Singletons.Theme.fg_light : "transparent"
                            implicitHeight: 36  
                            topRightRadius: 8
                            topLeftRadius: 8  
                        }

                        contentItem: Text {
                            text: itemConnect.text
                            color: Singletons.Theme.comment_light
                            font.family: Singletons.Theme.font
                            font.pixelSize: Singletons.Theme.fontSize
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 10
                        }
                        
                        onTriggered: {
                            if (itens.modelData.connected) itens.modelData.disconnect()
                            else itens.modelData.connect()
                        }
                    }
                    // Menu Item trust 
                    MenuItem {
                        id: itemTrust
                        text: itens.modelData.paired && itens.modelData.trusted ? "Untrust" : "Trust"

                        background: Rectangle {
                            color: itemTrust.highlighted ? Singletons.Theme.fg_light : "transparent"
                            implicitHeight: 36 
                        }

                        contentItem: Text {
                            text: itemTrust.text
                            color: Singletons.Theme.comment_light
                            font.family: Singletons.Theme.font
                            font.pixelSize: Singletons.Theme.fontSize
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 10
                        }
                        
                        onTriggered: {
                            if (itens.modelData.paired && itens.modelData.trusted) itens.modelData.trusted = false
                            else itens.modelData.trusted = true
                        }
                    }

                    // Menu item forget
                    MenuItem {
                        id: itemForget
                        text: itens.modelData.paired ? "Forget Device" : "Pair Device"

                        background: Rectangle {
                            color: itemForget.highlighted ? Singletons.Theme.fg_light : "transparent"
                            implicitHeight: 36 
                            bottomLeftRadius: 8
                            bottomRightRadius: 8   
                        }

                        contentItem: Text {
                            text: itemForget.text
                            color: itemForget.highlighted ? Singletons.Theme.fg : Singletons.Theme.fg_light
                            font.family: Singletons.Theme.font
                            font.pixelSize: Singletons.Theme.fontSize
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 10
                            Behavior on color { ColorAnimation { duration: 250 } }
                        }
                        
                        onTriggered: {
                            if (itens.modelData.paired) itens.modelData.forget()
                            else itens.modelData.pair()
                        }
                    }
                }
            }

        }
    }
}