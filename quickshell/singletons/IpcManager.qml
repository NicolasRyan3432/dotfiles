pragma Singleton
import Quickshell
import QtQuick
import Quickshell.I3

Singleton {
    id: root
    property int workspaceTrigger: 0
    property int scratchTrigger: 0

    I3IpcListener {
        subscriptions: ["window", "workspace"]
    
        onIpcEvent: function (event) {
            if(event.data.includes("scratch")) root.scratchTrigger++
            if(event.type === "workspace" || event.type === "window") root.workspaceTrigger++
        } 
    }
}