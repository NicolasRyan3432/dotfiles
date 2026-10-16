import QtQuick
import "../singletons"

Rectangle {
    id: root
    property alias value: textValue.text
    property alias icon: textIcon.text
    property alias rootBGColor: root.color
    property bool isVisible: true
    property int padX: 30
    property int padY: 2
    property var hasFill: { "FILL": mouseArea.containsMouse? 1:0 }
    signal clicked()
    
    color: mouseArea.containsMouse ? Theme.base1 : Theme.bg
    width: row.implicitWidth + padX 
    height: row.implicitHeight + padY
    radius: height / 2 
    anchors.verticalCenter: parent.verticalCenter
    
    Behavior on color {
        ColorAnimation { duration: 150 }
    }
    Behavior on width {
        NumberAnimation { 
            duration: 200 
            easing.type: Easing.BezierSpline
        }
    }
    Behavior on height {
        NumberAnimation { 
            duration: 200
            easing.type: Easing.OutExpo
        }
    }

    Row {
        id: row
        anchors.centerIn: parent
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4


        Text {
            id: textValue
            anchors.verticalCenter: parent.verticalCenter
            font.weight: Font.Normal
            font.pixelSize: Theme.fontSize
            font.family: Theme.font
            color: mouseArea.containsMouse ? Theme.base6 : Theme.base5
            visible: mouseArea.containsMouse || root.isVisible
        }

        Text {
            id: textIcon
            anchors.verticalCenter: parent.verticalCenter
            font.weight: Font.Normal
            font.pixelSize: Theme.fontSize
            font.family: Theme.iconFont
            color: mouseArea.containsMouse ? Theme.base6 : Theme.base5
            renderType: Text.NativeRendering
            font.variableAxes: root.hasFill
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}