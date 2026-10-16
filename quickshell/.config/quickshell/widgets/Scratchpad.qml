pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.I3
import Quickshell.Io
import "../singletons" as Singletons

Rectangle {
    id: root
    color: Singletons.Theme.base1
    radius: height / 2
    width: row.implicitWidth + 10
    height: row.implicitHeight + 10
    anchors.verticalCenter: parent.verticalCenter

    property int scratchWindows: 0
    visible: scratchWindows > 0

    // Grep the size of Scratchpad
    Process {
        id: scratchProc
        running: true
        command: ["bash", ".config/quickshell/scripts/scratchpadWindows.sh"]
        stdout: StdioCollector {
            onStreamFinished: root.scratchWindows = parseInt(text)
        }
    }

    // Execute the process after 50ms 
    Timer {
        id: debounceTimer
        interval: 50
        repeat: false
        onTriggered: scratchProc.running = true
    }

    // Listen to the scratchTrigger defined in Singleton IpcManager.qml
    Connections {
        target: Singletons.IpcManager

        function onScratchTriggerChanged() {
            debounceTimer.restart()
        }
    }


    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: 15
        leftPadding: 18
        rightPadding: 10

        Text {
            anchors.verticalCenter: parent.verticalCenter
            color:Singletons.Theme.base5
            text: root.scratchWindows
            font {
                pixelSize: Singletons.Theme.fontSize
                weight: Font.Normal
                family: Singletons.Theme.font
            }
            Behavior on color {
                ColorAnimation { duration: 250 }
            }  
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            color: Singletons.Theme.base5
            text: "select_window"
            font {
                pixelSize: Singletons.Theme.fontSize
                weight: Font.Normal
                family: Singletons.Theme.iconFont
            }
            Behavior on color {
                ColorAnimation { duration: 250 }
            }
        }
    }
}