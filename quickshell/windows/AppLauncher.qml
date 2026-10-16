pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import "../singletons" as Singletons


PanelWindow {
    id: root

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "quickshell-launcher"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    color: "transparent"

    mask: Region {
        item: Singletons.AppLauncherState.launcherVisible ? maskCover : null
    }
    Item {
        id: maskCover
        anchors.fill: parent
    }

    // Força o focus no campo de pesquisa
    Component.onCompleted: searchInput.forceActiveFocus()

    // FUZZY SEARCH
    function isSubsequence(query, target) {
        if(!target) return false;
        let qIdx = 0;
        let tIdx = 0;

        while(qIdx < query.length && tIdx < target.length) {
            // encontrou a letra na ordem, avança o ponteiro da query
            if(query[qIdx] === target[tIdx]) {
                qIdx++;
            }
            // sempre avança o ponteiro do nome do app
            tIdx++;
        }
        // achou todas as letras, retorna verdadeiro
        return qIdx === query.length;
    }


    // ── State ──────────────────────────────────────────────────────────────
    property string searchQuery: ""
    property int selectedIndex: 0
    readonly property bool isSearching: searchQuery.trim() !== ""

    property var filteredApps: {
        var q = searchQuery.trim().toLowerCase();
        var vals = DesktopEntries.applications.values;

        if (q !== "") {
            // Search mode: filter by name / genericName / fuzzy search / keywords / alpha sort
            return vals.filter(function (e) {
                let appName = e.name ? e.name.toLowerCase() : "";
                let appGeneric = e.genericName ? e.genericName.toLowerCase() : "";
                
                // Normal search (name or genericName)
                if(appName.includes(q)) return true;
                if(appGeneric.includes(q)) return true;

                // fuzzy search
                if(root.isSubsequence(q, appName)) return true;
                
                // keywords search
                if(e.keywords) {
                    for(var i = 0; i < e.keywords.length; i++) {
                        if(e.keywords[i] && e.keywords[i].toLowerCase().includes(q)) {
                            return true;
                        }
                    }
                }
                return false;
            }).sort(function (a, b) {
                return a.name.localeCompare(b.name);
            });
        }

        // Default mode: recent apps first, then alphabetical
        var recent = Singletons.AppLauncherState.recentIds;
        return vals.slice().sort(function (a, b) {
            var ai = recent.indexOf(a.id);
            var bi = recent.indexOf(b.id);
            if(ai !== -1 && bi !== -1) return ai - bi;
            if(ai !== -1) return -1;
            if(bi !== -1) return 1;
            return a.name.localeCompare(b.name);
        });
    }

    onFilteredAppsChanged: selectedIndex = 0

    // ── Launch ─────────────────────────────────────────────────────────────
    function launchEntry(entry) {
        Singletons.AppLauncherState.recordLaunch(entry.id);
        entry.execute();
        Singletons.AppLauncherState.hide();
    }

    // ── Navigation ─────────────────────────────────────────────────────────
    function navigate(delta) {
        if (filteredApps.length === 0)
            return;
        selectedIndex = (selectedIndex + delta + filteredApps.length) % filteredApps.length;
        listView.positionViewAtIndex(selectedIndex, ListView.Contain);
    }


    // ── Panel geometry ─────────────────────────────────────────────────────
    readonly property int maxVisible: 8
    readonly property int itemH: 42
    readonly property int panelW: 440

    // 12 top-pad + 4 handle + 8 + 44 search + 8 + list + 12 bot-pad 
    readonly property int panelH: 88 + Math.min(filteredApps.length, maxVisible) * itemH 

    // Click outside → close
    MouseArea {
        anchors.fill: parent
        enabled: Singletons.AppLauncherState.launcherVisible
        onClicked: Singletons.AppLauncherState.hide()
    }

    // ── Panel ──────────────────────────────────────────────────────────────
    Rectangle {
        id: panel
        width: root.panelW
        // Smooth height shrink/grow when filteredApps count changes
        height: root.panelH

        Behavior on height {
            NumberAnimation { duration: 500; easing.type: Easing.OutCubic }
        }

        clip: true   
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        radius: 18
        color: Singletons.Theme.bg
        border.color: Singletons.Theme.purple
        border.width: 1

        opacity: Singletons.AppLauncherState.launcherVisible ? 1 : 0
        scale: Singletons.AppLauncherState.launcherVisible ? 1 : 0.92
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
        }
        Behavior on scale {
            NumberAnimation { duration: 260; easing.type: Easing.OutBack }
        }

        // ── Content ────────────────────────────────────────────────────────
        Column {
            anchors {
                top: parent.top
                topMargin: 12
                left: parent.left
                leftMargin: 12
                right: parent.right
                rightMargin: 12
            }
            spacing: 0

            // Drag handle
            Rectangle {
                width: 36
                height: 4
                radius: 2
                anchors.horizontalCenter: parent.horizontalCenter
                color: Singletons.Theme.comment
            }

            Item {
                width: 1
                height: 8
            }

            // ── Search box ─────────────────────────────────────────────────
            Rectangle {
                width: parent.width
                height: 44
                radius: 10
                color: Singletons.Theme.comment
                opacity: 0.8

                Rectangle {
                    anchors.fill: parent
                    radius: 10
                    color: "transparent"
                    border.color: Singletons.Theme.purple
                    border.width: 1
                    opacity: searchInput.activeFocus ? 0.55 : 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 150
                        }
                    }
                }

                Row {
                    anchors {
                        fill: parent
                        leftMargin: 14
                        rightMargin: 14
                    }
                    spacing: 10 

                    Item {
                        width: parent.width - 40
                        height: parent.height

                        Text {
                            anchors.fill: parent
                            text: root.isSearching ? "" : "Search apps…"
                            color: Singletons.Theme.fg
                            opacity: 0.28
                            font {
                                pixelSize: Singletons.Theme.fontSize
                                family: Singletons.Theme.font
                            }
                            verticalAlignment: Text.AlignVCenter
                            visible: searchInput.text === ""
                        }

                        TextInput {
                            id: searchInput
                            anchors.fill: parent
                            color: Singletons.Theme.fg
                            selectionColor: Singletons.Theme.pink
                            font {
                                pixelSize: Singletons.Theme.fontSize
                                family: Singletons.Theme.font
                            }
                            verticalAlignment: TextInput.AlignVCenter
                            clip: true

                            onTextChanged: root.searchQuery = text

                            Keys.onPressed: function (event) {
                                if (event.key === Qt.Key_Up) {
                                    root.navigate(-1);
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Down) {
                                    root.navigate(1);
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                    if (root.filteredApps.length > 0)
                                        root.launchEntry(root.filteredApps[root.selectedIndex]);
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Escape) {
                                    Singletons.AppLauncherState.hide();
                                    event.accepted = true;
                                }
                            }
                        }
                    }
                }
            }

            Item {
                width: 1
                height: 8
            }

            // ── App list ──────────────────────────────────────────────────
            ListView {
                id: listView
                width: parent.width
                height: Math.min(root.filteredApps.length, root.maxVisible) * root.itemH
                model: root.filteredApps
                clip: true
                interactive: false
                

                Text {
                    anchors.centerIn: parent
                    visible: root.filteredApps.length === 0
                    text: "No apps found"
                    color: Singletons.Theme.fg
                    opacity: 0.8
                    font {
                        pixelSize: Singletons.Theme.fontSize
                        family: Singletons.Theme.font
                    }
                }

                // delegate 
                delegate: Item {
                    id: appRow
                    width: listView.width
                    height: root.itemH

                    required property int index
                    required property var modelData

                    readonly property bool sel: root.selectedIndex === index
                    readonly property bool isRecent: !root.isSearching 
                    && Singletons.AppLauncherState.recentIds.indexOf(appRow.modelData.id) !== -1 
                    && Singletons.AppLauncherState.recentIds.indexOf(appRow.modelData.id) < 5

                    Rectangle {
                        anchors {
                            fill: parent
                            topMargin: 2
                            bottomMargin: 2
                        }
                        radius: 10
                        
                        color: appRow.sel ? Singletons.Theme.comment_light : "transparent"
                        Behavior on color { ColorAnimation { duration: 100 } }

                        Row {
                            anchors {
                                fill: parent
                                rightMargin: 8
                            }
                            spacing: 12

                            // Icon bubble
                            Rectangle {
                                width: 36
                                height: parent.height
                                radius: 9
                                anchors.verticalCenter: parent.verticalCenter
                                color: appRow.sel ? Singletons.Theme.purple : Singletons.Theme.comment_light
                                
                                Behavior on color { ColorAnimation { duration: 100 } }

                                readonly property string path: Quickshell.iconPath(appRow.modelData.icon)

                                Image {
                                    id: appIcon
                                    anchors.centerIn: parent
                                    width: 22
                                    height: 22
                                    source: parent.path !== "" ? parent.path : ""
                                    mipmap: true
                                    visible: status === Image.Ready
                                }

                                // Fallback txt for icon
                                Text {
                                    anchors.centerIn: parent
                                    visible: appIcon.status !== Image.Ready
                                    text: appRow.modelData.name.charAt(0).toUpperCase()
                                    
                                    font {
                                        pixelSize: 15
                                        family: Singletons.Theme.fg
                                        weight: Font.Bold
                                    }
                                    color: appRow.sel ? Singletons.Theme.bg : Singletons.Theme.fg
                                    Behavior on color { ColorAnimation { duration: 100 } }
                                }
                            }

                            // Name + subtitle
                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 2

                                // Item name 
                                Text {
                                    text: appRow.modelData.name
                                    font {
                                        pixelSize: Singletons.Theme.fontSize
                                        family: Singletons.Theme.font
                                        weight: appRow.sel ? Font.Medium : Font.Normal
                                    }

                                    color: appRow.sel ? Singletons.Theme.fg : Singletons.Theme.comment
                                    Behavior on color { ColorAnimation { duration: 100 } }
                                }

                                // "Recently used" pill OR generic name
                                Row {
                                    spacing: 6
                                    visible: appRow.isRecent || appRow.modelData.genericName !== ""

                                    Rectangle {
                                        visible: appRow.isRecent
                                        width: recentLabel.width + 8
                                        height: 14
                                        radius: 4
                                        color: Singletons.Theme.pink_light
                                        anchors.verticalCenter: parent.verticalCenter
                                        
                                        // Recent app
                                        Text {
                                            id: recentLabel
                                            anchors.centerIn: parent
                                            text: "recent"
                                            font {
                                                pixelSize: 9
                                                family: Singletons.Theme.font
                                            }

                                            opacity: appRow.sel ? 1 : 0.8 
                                            color: Singletons.Theme.fg

                                            Behavior on opacity { OpacityAnimator { duration:100 } }
                                        }
                                    }

                                    // Generic name
                                    Text {
                                        visible: appRow.modelData.genericName !== ""
                                        text: appRow.modelData.genericName
                                        anchors.verticalCenter: parent.verticalCenter

                                        font {
                                            pixelSize: 11
                                            family: Singletons.Theme.font
                                        }
                                        color: appRow.sel ? Singletons.Theme.fg : Singletons.Theme.comment
                                        Behavior on color { ColorAnimation { duration:100 } }
                                    }
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: root.selectedIndex = appRow.index
                            onClicked: root.launchEntry(appRow.modelData)
                            onWheel: function (wheel) {
                                if (wheel.angleDelta.y < 0)
                                    root.navigate(1);
                                else
                                    root.navigate(-1);
                            }
                        }
                    }
                }
            }

            Item {
                width: 1
                height: 4
            }
        }
    }
}

