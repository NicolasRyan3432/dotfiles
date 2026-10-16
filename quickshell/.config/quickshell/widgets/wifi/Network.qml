pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Networking
import "../../components"

Widgets {
    id: root
    property int trigger: 0

    property NetworkDevice device:  {
        let spy = trigger
        if (Networking.devices.values.length <= 0) return null

        return Networking.devices.values.find(d => d.connected) 
        ?? Networking.devices.values[0]
        ?? null
    }
    Repeater {
        model: Networking.devices.networks 
        && Networking.devices.networks.values.length !== 0 
        ? Networking.devices.networks.values : []
        
        Item {
            required property var modelData
            property int currentState: modelData ? modelData.stateChanging : 0
            
            // update trigger, than updates the bar value
            onCurrentStateChanged: {
                root.trigger += 1
            }
        }
    }
    function getConnectedNetwork(device) {
        if(!device) return null

        return device.networks.values.find(n => n.connected)
        ?? null
    }

    isVisible: false
    value: device && device.name ? getConnectedNetwork(device).name : "Not connected"
    icon: {
        if(!device) return ""
        if(device.name === "wlp2s0" ) {
            return device.connected ? "wifi" : Networking.wifiEnabled ? "wifi" : "wifi_off" 
        }
    }
}

