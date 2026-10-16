import QtQuick
import Quickshell.Widgets

/* 
        Isso daqui (children.Rect) pega o tamanho do filho do item diretamente 
        *-------------------------------------------*
        | implicitHeight: childrenRect.height       |
        | implicitWidth: childrenRect.width         |
        |                                           |
        | Rectangle {                               |
        |    anchors.fill: parent                   |
        |    implicitHeight: 50                     |
        |    implicitWidth: 50                      |
        | }                                         |
        *-------------------------------------------*

        Porém isso daqui esconde um bug cabuloso
        Como dito no Item.qml:
        Tamanho implícito do filho -> Tamanho implicito do pai
        Tamanho atual do pai -> Tamanho atual do filho
        o childrenRect quebra esse padrão,
        ele representa o tamanho ATUAL do filho e não o tamanho IMPLICITO. 

        Para resolver isso, o Quickshell tem um módulo chamado MarginWrapperManager,
        ele automaticamente relaciona a posição e tamanho do conteiner pai com o 
        tamanho do seu único filho. 
        Reescrevendo o código acima: 

        *-------------------------------------------*
        | MarginWrapperManager { margin: 5 }        |
        |                                           |
        |   O MWM automaticamente reconhece o       |
        |   Retangle como o primiero filho do       |
        |   container                               |
        |                                           |
        | Rectangle {                               |
        |   implicitHeight: 50                      |
        |   implicitWidth: 50                       |
        |   Text {                                  |
        |       text: "Texto aqui!!"                |
        |   }                                       |
        | }                                         |
        *-------------------------------------------*
        
        Ou o item reutilizável:
        *-----------------------------------------------*
        | atribuição bidirecional da margem             | 
        | property alias margin: manager.margin         |
        |                                               |
        | O MarginWrapperManager tenta detectar         |
        | o filho primário do conteiner, mas expondo    |
        | as propriedades do filho permite o acesso do  |
        | filho externamente quanto a sobrescrita caso  |
        | a detecção automática falhe.                  |
        | property alias child: manager.margin          |
        |                                               |
        | O MWM automaticamente gerencia o tamanho      |
        | implicito do conteiner e o tamanho atual      |
        | do filho                                      |
        |                                               |
        | MarginWrapperManager {                        |
        |     id: manager                               |
        |     margin: 5 // the default value of margin  |
        | }                                             |
        *-----------------------------------------------*
        
    */

Item {
    MarginWrapperManager { margin: 5 }

    // O MWM automaticamente reconhece o Retangle
    // como o primiero filho do container
    Rectangle {
        implicitHeight: 50
        implicitWidth: 50
        Text {
            text: "Texto aqui!!"
        }
    }
}