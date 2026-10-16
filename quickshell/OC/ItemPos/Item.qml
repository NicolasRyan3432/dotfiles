import QtQuick
import Quickshell

FloatingWindow {

// O tamanho implicito do pai de um item deve ser utilizado 
// para determinar o tamanho implicito de seu pai 
// O tamanho atual do pai de um item deve ser utilizado
// para definir o tamanho atual de um filho.
Item {
    property real margin: 5

    // Coloca o tamanho implicito (que vem do filho para o pai) 
    // do Rectangle mais o dobro da margem
    implicitWidth: child.implicitWidth + margin * 2
    implicitHeight: child.implicitHeight + margin * 2
    
    Rectangle {
        id: child

        // coloca a posição x e y relativo ao tamanho atual do pai.
        x: parent.margin
        y: parent.margin
        width: parent.width - parent.margin * 2
        height: parent.height - parent.margin * 2

        // O tamanho implicito / desejado, vai ser respeitado pelo pai
        // caso o mesmo não seja diminuido
        implicitWidth: 50
        implicitHeight: 50
        Text {
            text: "Texto dentro do Rectangle!!"
        }
    }
}
}