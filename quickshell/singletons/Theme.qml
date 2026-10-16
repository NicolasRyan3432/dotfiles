pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    readonly property string font: "JetBrains Mono" 
    readonly property string iconFont: "Material Symbols Rounded"
    readonly property int fontSize: 14
    readonly property int menuOffset: 32

    property string bg: "#1b1614"
    property string fg: "#463325"
    property string base1: "#392f20"
    property string base2: "#57472c"
    property string base3: "#766037"
    property string base4: "#947843"
    property string base5: "#b2914e"
    property string base6: "#d0a95a"
    property string base7: "#efc266"
    property string base8: "#1a1614"
    property string base9: "#484340"
    property string base10: "#37342d"
    property string base11: "#2d241e"
    property string base13: "#45372e"
    property string base14: "#3e2c21"
    property string base15: "#4a392d"


    FileView {
        id: colorFile
        path: Qt.resolvedUrl("../colors.json")
        watchChanges: true
        onFileChanged: this.reload()

        onTextChanged: {
            if(!text) return;
                try {
                    let json = JSON.parse(text());
                    
                    root.bg = json.colors.color0;
                    root.base1 = json.colors.color1;
                    root.base2 = json.colors.color2;
                    root.base3 = json.colors.color3;
                    root.base4 = json.colors.color4;
                    root.base5 = json.colors.color5;
                    root.base6 = json.colors.color6;
                    root.base7 = json.colors.color7;
                    root.base8 = json.colors.color8;
                    root.base9 = json.colors.color9;
                    root.base10 = json.colors.color10;
                    root.base11 = json.colors.color11;
                    root.base13 = json.colors.color12;
                    root.base14 = json.colors.color13;
                    root.base15 = json.colors.color14;
                    root.fg = json.colors.color15;
                } catch(e) {
                    console.log("Error: " + e)
                }
        }

    }
   
    readonly property string comment: "#75715e"
    readonly property string pink: "#f92672"
    readonly property string orange: "#fd971f"
    readonly property string purple: "#ae81ff"
    readonly property string green: "#a6e22e"
    readonly property string cyan: "#66d9ef"
    readonly property string bg_light: "#cc272822" 
    readonly property string comment_light: "#8075715e"
    readonly property string pink_light: "#b3f92672"
    readonly property string green_light: "#80a6e22e"
    readonly property string orange_light: "#80fd971f"
    readonly property string cyan_light: "#8066d9ef"
    readonly property string red: "#cf2323"
}