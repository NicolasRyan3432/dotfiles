import QtQuick
import QtQuick.Controls
import '../singletons' as Singletons
import '../components' as Components

Item {
    id: root
    width: parent.width
    height: 30

    property string title: "Menu"
    property bool showSwitch: false
    property bool isChecked: false
    property bool divEnabled: false

    signal backClicked()
    signal switchToggled()
    
    // Arrow back
    Components.Widgets {
        icon: "arrow_back"
        anchors.left: parent.left
        onClicked: root.backClicked()
    }

    // Title
    Text {
        anchors.centerIn: parent
        text: root.title
        color: Singletons.Theme.base6
        font {
            pixelSize: Singletons.Theme.fontSize
            family: Singletons.Theme.font
        }
    }

    Switch {
        id: customSwitch
        visible: root.showSwitch
        checked: root.isChecked
        onToggled: root.switchToggled()

        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }

        // Parte de fora
        indicator: Rectangle {
            implicitHeight: 26
            implicitWidth: 48
            radius: height/2
            color: customSwitch.checked ? Singletons.Theme.base1 : Singletons.Theme.base3

            // Bolinha do switch
            Rectangle {
                x: customSwitch.checked ? parent.width - width - 3 : 3
                y: 3
                width: 20
                height: 20
                radius: height/2
                color: customSwitch.checked ? Singletons.Theme.base7 : Singletons.Theme.bg
                Behavior on x { NumberAnimation { duration: 200 } }
                Behavior on color { ColorAnimation { duration: 200 } }
            }   
        }
    }

    // Div
    Rectangle {
        id: div
        visible: root.divEnabled
        anchors {
            top: root.bottom
            topMargin: 10
            horizontalCenter: parent.horizontalCenter
        } 
        width: parent.width - 20
        height: 1 
        color: Singletons.Theme.base3
    }
}