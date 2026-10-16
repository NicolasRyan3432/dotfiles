// ClockWidget.qml
import QtQuick // pro objeto Text


Text {
    // Como o tempo vai ser separado,
    // a gnt fala que o time é uma propriedade requerida, tipo um parâmetro
    // required property string time

    // não precisamos mais disso pq Time agora é uma "classe" global

    text: Time.time
} 
