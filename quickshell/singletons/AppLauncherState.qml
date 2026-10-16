pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick
import QtCore

Singleton {
    id: root

    property bool launcherVisible: false
    property var recentIds: []
    
    IpcHandler {
        target: "applauncher"
        function toggle() {
            root.toggle();
        }
    }
    
    // Faz com que fique salvo as configurações mesmo após reiniciar o computador
    property var _settings: Settings {
        category: "AppLauncher"
        property string recentIdsSerialized: "[]"
    }

    Component.onCompleted: {
        recentIds = JSON.parse(_settings.recentIdsSerialized)
    }

    function toggle() { launcherVisible = !launcherVisible }
    function open() { launcherVisible = true }
    function hide() { launcherVisible = false }

    function recordLaunch(id) {
        // create a copy of the current recent IDs array
        var list = recentIds.slice()

        // find if this app is already in the list
        var idx = list.indexOf(id)

        // if exists, remove it from its current position
        if(idx !== -1) list.splice(idx, 1)

        // add the app to the FRONT of the list (most recent)
        list.unshift(id)

        // keep only the 12 most recent apps
        if(list.length > 12) list = list.slice(0, 12)

        // Update the UI and save to disk
        recentIds = list
        _settings.recentIdsSerialized = JSON.stringify(list)
    } 

    function clearRecents() {
        recentIds = []
        _settings.recentIdsSerialized = "[]"
    }
  }