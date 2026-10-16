//@ pragma IconTheme Papirus 
//@ pragma UseQApplication 
//@ pragma Env QT_QPA_PLATFORMTHEME = qt6ct
pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Io
import Quickshell.I3
import "windows" as Windows
import "singletons" as Singletons

ShellRoot {
    id: root
    readonly property ShellScreen currentScreen: Quickshell.screens ?
    Quickshell.screens.find(s => s.name === I3.focusedMonitor.name) : []

    // BAR
    Scope {
        Variants {
            model: Quickshell.screens
            Windows.Bar {
                required property var modelData
                screen: modelData
            }
        }
    }

    // AppLauncher
    LazyLoader {
        id: laucherLoader
        active: Singletons.AppLauncherState.launcherVisible

        Windows.AppLauncher { screen: root.currentScreen }
    }

    // ControlCenter
    LazyLoader {
        id: ccLoader
        active: Singletons.ControlCenterState.launcherVisible
        Windows.ControlCenter { screen: root.currentScreen }
    }

    // Wallpaper
    Scope {
        Variants {
            model: Quickshell.screens
            Windows.WallpaperWindow {
                required property var modelData
                screen: modelData
            }
        }
    }
}
