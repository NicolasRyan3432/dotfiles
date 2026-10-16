import Quickshell.Services.UPower
import QtQuick
import "../components" 

Widgets {
    id: widget
    function getIcon(percentage, status) {
            if(status === 1 || status === 5) return "󰂄"

            if(percentage >= 0.80) return "󰁹"
            if(percentage >= 0.60) return "󰂀"
            if(percentage >= 0.40) return "󰁾"
            if(percentage >= 0.20) return "󰁻"
            return "󰂎"
    }
    
    isVisible: false
    value: UPower.displayDevice ? Math.round(UPower.displayDevice.percentage * 100) + "%" : ""
    icon: UPower.displayDevice ? 
    widget.getIcon(UPower.displayDevice.percentage, UPower.displayDevice.state) : '󰂎'
}


 



