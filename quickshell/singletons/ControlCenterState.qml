pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: root
    property bool launcherVisible: false
    property string activeTab: "main"

    function toggleMenu(tabName) {
        // tava no bt e clicou denovo, sai da aba
        if(launcherVisible && activeTab === tabName) launcherVisible = false;
        else {
            activeTab = tabName;
            launcherVisible = true;
        }
    }

    function close() { root.launcherVisible = false }
    function toggle() { root.launcherVisible = !root.launcherVisible }
    function open() { root.launcherVisible = true}
}
