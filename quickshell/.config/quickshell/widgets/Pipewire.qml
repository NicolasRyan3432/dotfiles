import Quickshell.Services.Pipewire
import Quickshell.Io
import QtQuick
import "../components"

Widgets {
    id: root
    property var sink: Pipewire.defaultAudioSink
    
    // pega e liga o tracker com o defaultAudioSink
    PwObjectTracker { objects: root.sink ? [root.sink] : [] } 
    
    function getIcon(name, vol, isMuted) {
        let nameL = name ? name.toLowerCase() : ""

        if(name.includes("bluetooth") || nameL.includes("bluez")) {
            return isMuted ? "media_bluetooth_off": "media_bluetooth_on" 
        }

        if(isMuted) return "volume_off"
        if(vol >= 0.70) return "volume_up"
        if(vol >= 0.30) return "volume_down"
        return "volume_mute"
    }
    
    isVisible: false
    value: (sink && sink.audio) ? Math.round(sink.audio.volume * 100) + "%" : "0%"
    icon: (sink && sink.audio) ? root.getIcon(sink.name, sink.audio.volume, sink.audio.muted) : "volume_mute"
}
