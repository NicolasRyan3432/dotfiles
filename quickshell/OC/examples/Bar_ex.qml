// Bar.qml

import Quickshell

/* Usa as Variants para criar instancias do
// Component baseado no modelo passado
// Único problema do código é que ao rodar denovo,
// vai ser criado um novo processo e que vai gastar mais recursos, para isso, colocamos a definição do texto
// separado do processo
// Move a criação do processo e do timer através do Scope, os dois não estão mais dentro de Window
// Problema que agora a gnt não consegue setar direto valor de relógio
// porque ele não pode ser referenciado fora do seu componente (relógio tá dentro de PanelWindow e Process dentro de Scope)
// Ou seja, pode ser que não exista um relogio ou pode ser que existe mais de um relógio q pode ser referido naquele local
// Para isso, nos usamos a definição de propriedades
// Separamos o relógio em um Widget e o processo do tempo em dois arquivos.
// Com isso, nós não precisamos mais importar o Time assim: Time { id: timeSource }
// podemos transformar o Time em um Singleton,
 que é um PP que garante que classe tenha só uma instância global acessível por todas as outras classes
*/


Scope {
    // Não precisa mais da entrada do tempo
    Variants {
        // Nesse caso é as telas que o quickshell achou
        model: Quickshell.screens;

        // Component pode ser criado implicitamente e o Variants.delegate é uma propriedade padrão,
        // ou seja, não é necessário a estrutura anterior
        PanelWindow {
            // Além das ancoras,
            // precisamos da tela da lista de telas que será injetado essa propriedade
            required property var modelData

            // joga a propriedade para tela
            screen: modelData

    	    anchors {
        		top: true
        		left: true
        		right: true
        	}

            // Altura da barra
        	implicitHeight: 30

            // Widget do relógio que contem só o texto, modularizado
            ClockWidget {
                anchors.centerIn: parent

                // Não precisa mais de entrada de tempo
                // Agora usa o timeSource
                // time: Time.time
            }
    	}
    }
}
