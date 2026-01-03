import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import "../../common"
import "../../services"
import "."

Scope {
    id: overviewScope
    property var pluginApi: null
    Variants {
        id: overviewVariants
        model: Quickshell.screens
        PanelWindow {
            id: root

            

            required property var modelData
            readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.screen)
            property bool monitorIsFocused: (Hyprland.focusedMonitor?.id == monitor?.id)
            
            readonly property bool isFocused: Hyprland.focusedMonitor.name === modelData.name            
            screen: modelData
            visible: GlobalStates.overviewOpen

            WlrLayershell.keyboardFocus: isFocused 
                ? WlrKeyboardFocus.Exclusive 
                : WlrKeyboardFocus.None

            WlrLayershell.namespace: "quickshell:overview"
            WlrLayershell.layer: WlrLayer.Overlay
            // WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            color: "transparent"

            mask: Region {
                item: GlobalStates.overviewOpen ? keyHandler : null
            }

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                
                onPressed: {
                    // If we click the empty background, close the overview
                    GlobalStates.overviewOpen = false;
                }
            }

            HyprlandFocusGrab {
                id: grab
                windows: [root]
                
                // Use the focus property we defined earlier
                property bool canBeActive: (root.isTheActiveMonitor || false)
                
                // Keep active true whenever the overview is open globally
                active: GlobalStates.overviewOpen
                
                onCleared: () => {
                    // CHANGE: Only close the overview if we are NOT currently 
                    // switching focus to another monitor.
                    // If GlobalStates.overviewOpen is still true, it means we 
                    // probably just moved the mouse to the other screen.
                    
                    if (!GlobalStates.overviewOpen) {
                        return;
                    }

                    // Check if the focus actually left the Quickshell overview system 
                    // (e.g., clicking on a window behind the overview)
                    if (!root.isTheActiveMonitor) {
                        // If you want it to STAY open even when clicking away, 
                        // comment out the line below.
                        // GlobalStates.overviewOpen = false; 
                    }
                }
            }

            Connections {
                target: GlobalStates
                function onOverviewOpenChanged() {
                    if (GlobalStates.overviewOpen) {
                        delayedGrabTimer.start();
                    }
                }
            }

            Timer {
                id: delayedGrabTimer
                interval: Config.options.hacks.arbitraryRaceConditionDelay
                repeat: false
                onTriggered: {
                    if (!grab.canBeActive)
                        return;
                    grab.active = GlobalStates.overviewOpen;
                }
            }

            implicitWidth: columnLayout.implicitWidth
            implicitHeight: columnLayout.implicitHeight

            Item {
                id: keyHandler
                anchors.fill: parent
                visible: GlobalStates.overviewOpen
                focus: GlobalStates.overviewOpen

                Keys.onPressed: event => {
                // close: Escape or Enter
                if (event.key === Qt.Key_Escape || event.key === Qt.Key_Return) {
                    GlobalStates.overviewOpen = false;
                    event.accepted = true;
                    return;
                }

                // --- CONFIGURATION ---
                const rows = Config.options.overview.rows;
                const cols = Config.options.overview.columns;
                const workspacesPerMonitor = rows * cols;
                const totalWorkspaces = Quickshell.screens.length * workspacesPerMonitor;
                
                const currentId = Hyprland.focusedMonitor?.activeWorkspace?.id ?? 1;
                let targetId = null;

                // --- NAVIGATION LOGIC ---
                if (event.key === Qt.Key_Left || event.key === Qt.Key_H) {
                    targetId = currentId - 1;
                    // Global Loop: if before workspace 1, jump to the very last one
                    if (targetId < 1) targetId = totalWorkspaces;
                    
                } else if (event.key === Qt.Key_Right || event.key === Qt.Key_L) {
                    targetId = currentId + 1;
                    // Global Loop: if past the last workspace, jump to 1
                    if (targetId > totalWorkspaces) targetId = 1;
                    
                } else if (event.key === Qt.Key_Up || event.key === Qt.Key_K) {
                    targetId = currentId - cols;
                    // Vertical Loop: jump to the bottom of the stack if we go off the top
                    if (targetId < 1) targetId += totalWorkspaces;
                    
                } else if (event.key === Qt.Key_Down || event.key === Qt.Key_J) {
                    targetId = currentId + cols;
                    // Vertical Loop: jump to the top of the stack if we go off the bottom
                    if (targetId > totalWorkspaces) targetId -= totalWorkspaces;
                }

                // Number keys: Keep these relative to the CURRENT monitor for convenience
                else if (event.key >= Qt.Key_1 && event.key <= Qt.Key_9) {
                    const position = event.key - Qt.Key_0;
                    const currentMonitorBase = Math.floor((currentId - 1) / workspacesPerMonitor) * workspacesPerMonitor;
                    targetId = currentMonitorBase + position;
                } else if (event.key === Qt.Key_0) {
                    const currentMonitorBase = Math.floor((currentId - 1) / workspacesPerMonitor) * workspacesPerMonitor;
                    targetId = currentMonitorBase + 10;
                }

                if (targetId !== null) {
                    // Ensure targetId stays within Hyprland limits
                    targetId = Math.max(1, Math.min(targetId, totalWorkspaces));
                    Hyprland.dispatch("workspace " + targetId);
                    event.accepted = true;
                }
            }
            }

            ColumnLayout {
                id: columnLayout
                visible: GlobalStates.overviewOpen
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.top
                    topMargin: 20
                }

                Loader {
                    id: overviewLoader
                    active: GlobalStates.overviewOpen && (Config?.options.overview.enable ?? true)
                    sourceComponent: OverviewWidget {
                        panelWindow: root
                        visible: true
                    }
                }
            }
        }
    }
    
    IpcHandler {
        target: "plugin:hypr-overview"

        function toggle() {
            GlobalStates.overviewOpen = !GlobalStates.overviewOpen;
        }
        function close() {
            GlobalStates.overviewOpen = false;
        }
        function open() {
            GlobalStates.overviewOpen = true;
        }
    }
}
