import QtQuick 
import "../singletons"
import "../components"

Widgets {
    id: root
    radius: height / 2
    padX: 40
    padY: 10
    value: Time.time
}