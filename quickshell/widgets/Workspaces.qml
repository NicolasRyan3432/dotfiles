pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.I3
import "../singletons" as Singletons

Rectangle {
    id: root
    color: Singletons.Theme.bg
    radius: height / 2
    width: row.implicitWidth + 10
    height: row.implicitHeight + 8
    border.color: Singletons.Theme.base5

    Row {
        id: row
        spacing: 4
        anchors.verticalCenter: parent.verticalCenter
        leftPadding: 10


        Repeater {
            id: repeater
            model: 10 

            Rectangle {
                id: item
                required property int index
                // (0+1).toString() = "1"
                property string wsName: (index + 1).toString()    
                
                // procura o workspace pelo nome
                property var wsData: {
                    var dummy = Singletons.IpcManager.workspaceTrigger
                    return I3.findWorkspaceByName(wsName)
                }

                

                // only the workspaces 1, 2 and 3 are visible, from the fourth one onwards
                // stay invisible only if has nothing inside it. 
                visible: index < 3 || wsData !== null 

                implicitWidth: (wsData && wsData.focused) ? txtNum.implicitWidth + 40 : txtNum.implicitWidth + 20
                implicitHeight: txtNum.implicitHeight + 2

                radius: 10
                color: {
                    if(wsData && wsData.urgent) return Singletons.Theme.base1
                    else if(wsData && wsData.focused) return Singletons.Theme.base5
                    else if(mouseArea.containsMouse) return  Singletons.Theme.comment
                    return "transparent"
                }
                Behavior on color {
                    ColorAnimation { duration: 275 }
                }
                Behavior on implicitWidth {
                    NumberAnimation { 
                        duration: 175
                        easing.type: Easing.OutExpo
                    }
                }

                Text {
                    id: txtNum
                    text: (item.wsData && item.wsData.urgent)? "!" : item.wsName
                    color: {
                        if(item.wsData && item.wsData.urgent) return Singletons.Theme.fg
                        else if(item.wsData && parent.wsData.focused) return Singletons.Theme.comment
                        else if(mouseArea.containsMouse) return Singletons.Theme.fg
                        return Singletons.Theme.comment_light
                    }
                    anchors.centerIn: parent
                    font {
                        pixelSize: Singletons.Theme.fontSize
                        weight: Font.Normal
                        family: Singletons.Theme.font
                    }
                    Behavior on color {
                        ColorAnimation { duration: 250 }
                    }
                }
                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: I3.dispatch("workspace number " + item.wsName)
                }
            }
        }
    }
}