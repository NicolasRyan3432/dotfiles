pragma ComponentBehavior: Bound
import Quickshell.Bluetooth
import QtQuick
import "../../components" 

Widgets {
    id: root
    property int trigger: 0
    property BluetoothAdapter defaultAdapter: Bluetooth.defaultAdapter

    property BluetoothDevice device: {
        let spy = trigger
        if (!root.defaultAdapter) return null

        let list = root.defaultAdapter.devices.values
        if (!list || list.length === 0) return null
        
        return list.find(d => d.state === BluetoothDeviceState.Connected) 
            ?? list.find(d => d.state === BluetoothDeviceState.Connecting) 
            ?? list[0] 
            ?? null
    }

    function getIcon() {
        if(!root.defaultAdapter) return "bluetooth"

        if(root.defaultAdapter.state === BluetoothAdapterState.Disabled) return "bluetooth_disabled"
        if(device && device.state === BluetoothDeviceState.Connected) return "bluetooth_connected"
        return "bluetooth"
    }

    // Gets all the current players and checks if theres any modification
    Repeater {
        /* gets all the players */

        model: root.defaultAdapter ? root.defaultAdapter.devices.values : []
        
        Item {
            required property var modelData
            // checks if has changed

            property int currentState: modelData ? modelData.state : 0
            
            // update trigger, than updates the bar value
            onCurrentStateChanged: {
                root.trigger += 1
            }
        }
    }

    isVisible: false
    value: device && device.connected && device.battery ? Math.round(device.battery * 100) + "%" : ""
    icon: getIcon()
}