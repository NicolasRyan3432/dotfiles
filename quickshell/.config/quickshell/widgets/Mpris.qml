pragma ComponentBehavior: Bound
import Quickshell.Services.Mpris
import QtQuick
import "../components"

Widgets {
    id: root
    property int trigger: 0

    property var player: {
        let spy = trigger
        let list = Mpris.players.values

        return list.find(p => p.playbackState === MprisPlaybackState.Playing) 
        ?? list.find(p => p.playbackState === MprisPlaybackState.Paused) 
        ?? list[0] 
        ?? null
    }

    // Gets all the current players and checks if theres any modification
    Repeater {
        /* gets all the players */

        model: Mpris.players.values
        
        Item {
            required property var modelData
            // checks if has changed
            property int currentState: modelData ? modelData.playbackState : 0
            
            // update trigger, than updates the bar value
            onCurrentStateChanged: {
                root.trigger += 1
            }
        }
    }

    property string name: {
        if (!player) return null

        let cleanName = player.trackTitle || "Unknown"
        let dbus = player.dbusName ? player.dbusName.toLowerCase() : ""
    
        if(dbus.includes("brave") || dbus.includes("firefox")) {
            return cleanName.replace(/^\(\d+\)\s*/, "").substring(0,17)
        }

        return cleanName.substring(0,17)
    }

    isVisible: false
    visible: player && player.playbackState !== MprisPlaybackState.Stopped
    value: name
    icon: player && player.playbackState === MprisPlaybackState.Playing? "play_circle" : "pause_circle"  
    onClicked: {
        player.togglePlaying()
    }
}

