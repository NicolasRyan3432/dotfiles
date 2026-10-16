import QtQuick 
import "../singletons"
import "../components"

Widgets {
    id: root
    function getIcon(brightness)  {
        if(brightness >= 80) return "brightness_7"
        if(brightness >= 60) return "brightness_5"
        if(brightness >= 40) return "brightness_medium"
        if(brightness >= 20) return "brightness_4"
        return "brightness_empty"
    }
    isVisible: false
    value: Bright.brightness + "%"
    icon: root.getIcon(Bright.brightness)
}
