import Quickshell
import Quickshell.Wayland
import QtQuick
import '../components' as Components

PanelWindow {
    id: root

    WlrLayershell.layer: WlrLayer.Background
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "black"
    property string currentWallpaper: "/home/nicolasryan/Pictures/Wallpapers/dl_8.jpg"
    property string nextWallpaper: ""

    function changeWallpaper(newPath) {
        nextWallpaper = newPath;
        bgNext.opacity = 1;
    }

    Connections {
        target: bgNext
        function onOpacityChanged() {
            root.currentWallpaper = root.nextWallpaper;
            bgNext.opacity = 0
        }
    }

    // current image bg
    Components.Img {
        id: bgCurrent
        anchors.fill: parent
        imgSource: root.currentWallpaper
    }

    // next background that has the animation
    Components.Img {
        id: bgNext
        anchors.fill: parent
        imgSource: root.nextWallpaper
        opacity: 0

        Behavior on opacity {
            NumberAnimation {
                duration: 600
                easing.type: Easing.OutCubic
            }
        }
    }
}