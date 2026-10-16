pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Wayland
import QtQuick.Controls
import QtQuick
import "../singletons" as Singletons
import "../components"
import "../widgets/bluetooth" as BT
import "../widgets/wifi" as Wifi

PanelWindow {
    id: root
    color: "transparent"

    anchors {
        top: true
        right: true
        left: true
        bottom: true
    }
    // margins top para limitar o MouseArea
    margins.top: Singletons.Theme.menuOffset

    WlrLayershell.layer: WlrLayer.Top
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    // usado para chamar direto na tela do bluetooth
    property Component winBT: Component { BT.MenuBluetooth {} }
    property Component winWifi: Component { Wifi.MenuWifi {} }
    // começa vazio a pilha de janelas
    property Component currentWindow: null

    property int isVisible: Singletons.ControlCenterState.launcherVisible ? 1 : 0
    visible: isVisible


    /* 
        Função chamada quando o CC está ativo.
        Com o LazyLoader o CC já era aberto na aba,
        não ocorria o onActiveTab e ele abria no main
    */
    function applyRoute() {
        let tab = Singletons.ControlCenterState.activeTab
        if(tab === "bluetooth") drawer.replace(root.winBT);
        else if(tab === "wifi") drawer.replace(root.winWifi);
        else drawer.replace(main)
    }

    // Quando o LazyLoader carregar o CC ele chama o applyRoute
    Component.onCompleted: applyRoute()

    // Aba mudou? Aplica rota
    Connections {
        target: Singletons.ControlCenterState
        function onActiveTabChanged() {
            root.applyRoute()            
        }
    }

    // Anima a opacidade inteira do painel
    Behavior on isVisible {
        NumberAnimation { 
            duration: 200 
            easing.type: Easing.InOutQuad 
        }
    }

    // outside click -> exit 
    MouseArea {
        anchors.fill: parent
        enabled: Singletons.ControlCenterState.launcherVisible
        onClicked: Singletons.ControlCenterState.close()
        
    }

    Rectangle {
        id: rectangle
        implicitWidth: 500
        implicitHeight: 450
        color: Singletons.Theme.bg

        topRightRadius: 0
        topLeftRadius: 16
        bottomLeftRadius: 16
        bottomRightRadius: 16
        clip: true

        // Quando invisível, bota ele pra cima da barra, quando tiver visível vai pro zero
        anchors {
            top: parent.top
            right: parent.right
            rightMargin: 15
            topMargin: root.isVisible ? 0 : -20 
        }

        // Suaviza o deslize!
        Behavior on anchors.topMargin {
            NumberAnimation { 
                duration: 200 
                easing.type: Easing.OutExpo 
            }
        }

        // area de dentro do mouse, não faz nada no clique mas serve para que o de fora
        // não passe por cima da outra e ao clicar por dentro saia
        MouseArea {
            anchors.fill: parent
        }

        // Pilha das telas
        StackView {
            id: drawer
            anchors.fill: parent
            initialItem: main
        }

        // Componente, parecido com o delegate, começa no principal (CC)
        Component {
            id: main
            
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20
                
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 15

                    Widgets {
                        value: "Wi-Fi"
                        icon: "wifi"
                        rootBGColor: Singletons.Theme.comment
                        padX: 50
                        padY: 50
                        onClicked: {
                            Singletons.ControlCenterState.activeTab = "wifi"
                        }
                    }
                    Widgets {
                        value: "Bluetooth"
                        icon: "bluetooth"
                        rootBGColor: Singletons.Theme.comment
                        padX: 50
                        padY:50
                        onClicked: {
                            Singletons.ControlCenterState.activeTab = "bluetooth"
                        }
                    }
                    Widgets {
                        value: "Audio"
                        icon: "volume_up"
                        hasFill: {"FILL": 1}
                        rootBGColor: Singletons.Theme.comment
                        padX: 50
                        padY: 50
                    }
                }

                Row {
                    spacing: 15
                    anchors.horizontalCenter: parent.horizontalCenter
                    Widgets {
                        value: "Night Mode"
                        icon: "lightbulb"
                        rootBGColor: Singletons.Theme.comment
                        hasFill: {"FILL": 1}
                        padX: 50
                        padY: 50
                    }
                    Widgets {
                        value: "Profile"
                        icon: "battery_profile"
                        rootBGColor: Singletons.Theme.comment
                        hasFill: {"FILL": 1}
                        padX: 50
                        padY:50
                    }
                    Widgets {
                        value: "Audio"
                        icon: "volume_up"
                        hasFill: {"FILL": 1}
                        rootBGColor: Singletons.Theme.comment
                        padX: 50
                        padY: 50
                    }
                }

                // ==========================================
                // SETOR 2: BARRAS DE VOLUME E BRILHO (Placeholders)
                // ==========================================

                Rectangle {
                    width: parent.width // Pega a largura inteira da gaveta (menos as margens)
                    height: 40
                    radius: 10
                    color: Singletons.Theme.comment
                    
                    Text {
                        anchors.centerIn: parent
                        color: Singletons.Theme.font
                        text: "[ AQUI VAI ENTRAR O SLIDER DE VOLUME ]"
                    }
                }

                // ==========================================
                // SETOR 3: MEDIA PLAYER (Placeholder)
                // ==========================================

                Rectangle {
                    width: parent.width
                    height: 120
                    radius: 16
                    color: Singletons.Theme.comment

                    Text {
                        anchors.centerIn: parent
                        color: Singletons.Theme.font
                        text: "[ AQUI VAI ENTRAR A CAPA DO ÁLBUM DO MPRIS ]"
                    }
                }
            }
        }
    }
}