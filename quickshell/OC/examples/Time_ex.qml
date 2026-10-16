// Time.qml

// com essa linha nós falamos que é um Singleton
pragma Singleton

import Quickshell
import QtQuick


// Ao invés de criar um processo para rodar a hora, o Quickshell tem uma biblioteca chamada SystemClock
// o tipo agora é Singleton  ao invés de Scope (que cria só uma instância e a reutiliza)
// a qual dá o tempo do sistema atual de uma forma fácil de se manusear
Singleton {
    id: root

    // uma expressão assim pode ser quebrada usando {}
    readonly property string time: {
        Qt.formatDateTime(clock.date, "hh:mm a")
    }

    // Não é mais necessário o Process e o Timer
    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
