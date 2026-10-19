pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import "../singletons" as Singletons
import "../components" as Components

Rectangle {
    id: root
    color: Singletons.Theme.bg
    radius: height / 2
    width: row.implicitWidth + 30
    height: row.implicitHeight + 9
    anchors.verticalCenter: parent.verticalCenter
    visible: SystemTray.items.values.length > 0
    property var shellWindow


    Row {
        id: row
        spacing: 10
        anchors.centerIn: parent
        

        Repeater {
            id: repeater
            model: SystemTray.items.values.length > 0? SystemTray.items.values : []
            
            Item {
                id: trayWrapper
                required property var modelData
                width: img.width
                height: img.height
                anchors.verticalCenter: parent.verticalCenter
                
                Components.Img {
                    id: img
                    imgHeight: 20
                    imgWidth: 20
                    anchors.centerIn: parent
                    
                    property bool path: trayWrapper.modelData.icon.trim() !== ""
                    imgSource: path ? trayWrapper.modelData.icon : Quickshell.iconPath("app-outlet") 
                }

                QsMenuAnchor {
                    id: menuAnchor
                    menu: trayWrapper.modelData.menu 
                    anchor {
                        // window from parent
                        window: root.shellWindow 
                        item: trayWrapper 
                        edges: Edges.Bottom | Edges.Right 
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                    cursorShape: Qt.PointingHandCursor

                    onClicked: (mouse) => {
                        if (mouse.button === Qt.LeftButton) {
                            // Left click, open the app
                            trayWrapper.modelData.activate() 
                        } 
                        else if (mouse.button === Qt.MiddleButton) {
                            // Middle click, secondary action
                            trayWrapper.modelData.secondaryActivate() 
                        } 
                        else if (mouse.button === Qt.RightButton) {
                            // Right click, opens the menu
                            // checks if the app has a native menu
                            if (trayWrapper.modelData.hasMenu) {
                                menuAnchor.open() // Abre a âncora do Quickshell
                            }
                            else {
                                trayWrapper.modelData.contextMenu()
                            }
                        }
                    }
                }
            }
        }
    }
}