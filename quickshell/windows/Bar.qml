import Quickshell
import Quickshell.Wayland
import QtQuick
import "../singletons" as Singletons
import "../widgets/" as Widgets
import "../widgets/bluetooth" as BT
import "../widgets/wifi" as Wifi

PanelWindow {
    id: pWindow
    color: "transparent"

    WlrLayershell.layer : WlrLayer.Bottom
    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: 36

    Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 15
        spacing: 8

        Widgets.Workspaces {}
        Widgets.Scratchpad {}
    }

    Widgets.Clock { 
        anchors.centerIn: parent
    }


    Row {
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
            rightMargin: 15
        }
        spacing: 8

        Widgets.Tray {
            shellWindow: pWindow
        }

        // sys module
        Rectangle {
            id: rectangle
            width: row.implicitWidth + 20
            height: row.implicitHeight + 8
            topRightRadius: height/2
            topLeftRadius: height/2
            bottomLeftRadius: Singletons.ControlCenterState.launcherVisible ? 0 : height/2
            bottomRightRadius: Singletons.ControlCenterState.launcherVisible ? 0 : height/2

            radius: height/2
            color: Singletons.Theme.bg
            
            anchors.verticalCenter: parent.verticalCenter

            Behavior on bottomLeftRadius { NumberAnimation { duration: 275; easing.type: Easing.OutCirc } }
            Behavior on bottomRightRadius { NumberAnimation { duration: 275; easing.type: Easing.OutCirc } }
            Behavior on border.color { ColorAnimation { duration: 275 } }
            Behavior on border.width { NumberAnimation { duration: 275 } }


            Row {
                id: row
                anchors.centerIn: parent
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4
                
                Widgets.Mpris { }
                Widgets.Pipewire { }
                BT.BluetoothWidget { 
                    onClicked: Singletons.ControlCenterState.toggleMenu("bluetooth")
                }
                Widgets.Brightness { }
                Wifi.Network { 
                    onClicked: Singletons.ControlCenterState.toggleMenu("wifi")
                }
                Widgets.Battery { }
            }
        }
    }
}
