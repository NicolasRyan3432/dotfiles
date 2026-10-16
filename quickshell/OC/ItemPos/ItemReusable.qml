import QtQuick

Item {
    property real margin: 5
    // id: wrapper
    // default required property Text child

    // Seta o filho visual do item com a propriedade child
    // children: [child]
    // Liga a posição do filho e tamanho com Binding
    // Porém, isso daqui é um Boilerplate (modelo genérico), 
    // para reduzir isso usamos o QtQuick.Anchors
    // Binding { wrapper.child.x: wrapper.margin }
    // Binding { wrapper.child.y: wrapper.margin }
    // Binding { wrapper.child.width: wrapper.width - wrapper.margin * 2 }
    // Binding { wrapper.child.height: wrapper.height - wrapper.margin * 2 }

    implicitHeight: child.implicitHeight + margin * 2
    implicitWidth: child.implicitWidth + margin * 2


    Rectangle {
        id: child

        // "preenche" o espaço ocupado pelo pai, setando a largura
        anchors.fill: parent
        // Adiciona margem para todos os lados ancorados
        anchors.margins: parent.margin

        implicitHeight: 50
        implicitWidth: 50

        Text {
            anchors.centerIn: parent
            text: "Texto aqui"
        }
    }
}
