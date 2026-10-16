import QtQuick
import Quickshell

Image {
    property var isVisible: true
    property int imgWidth
    property int imgHeight
    property string imgSource: Quickshell.iconPath("bluetooth-active")

    visible: isVisible
    width:   imgWidth
    height:  imgHeight
    source:  imgSource
    mipmap:  true
    fillMode: Image.PreserveAspectCrop
}
