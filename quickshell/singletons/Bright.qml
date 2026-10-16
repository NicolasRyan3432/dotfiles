pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    property string brightness: "0"

    Process {
        id: brightProc
        running: true
        command: ["bash", ".config/quickshell/scripts/brightness.sh"]
        stdout: SplitParser {
            onRead: data => { root.brightness = data.trim(); }
        }
    }
}