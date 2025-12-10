import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

ShellRoot {
    property var col_bg: "#2c2d30"
    property var col_bg2: "#232326"
    property var col_text: "#a7aab0"
    property var col_borders: "#5a5b5e"
    property var col_focused: "#bb70d2"
    property var col_focused2: "#57a5e5"
    property var col_urgent: "#de5d68"

    property var font_size: 12
    property string font_family: "JetBrains Mono Nerd Font"

    function textProps(txt) {
        return {
            "Layout.alignment": Qt.AlignVCenter,
            "font.pointSize": font_size,
            "font.family": font_family,
            "color": col_text,
            "text": txt
        };
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar

            property var modelData
            screen: modelData

            property var workspaces: []
            property var activeWorkspaceRef: null

            anchors {
                top: true
                left: true
                right: true
            }

            // Fixed height ensures vertical centering works
            height: 36
            implicitHeight: 36
            aboveWindows: true
            exclusiveZone: height

            color: col_bg

            SystemClock {
                id: clock
                precision: SystemClock.Minutes
            }

            Timer {
                id: workspaceTimer
                interval: 50
                running: true
                repeat: true
                onTriggered: workspaceFetcher.exec({})
            }

            Process {
                id: workspaceFetcher
                command: ["niri", "msg", "--json", "workspaces"]
                running: false
                stdout: SplitParser {
                    onRead: function (data) {
                        try {
                            const parsed = JSON.parse(data);
                            let allWs = [];
                            if (Array.isArray(parsed))
                                allWs = parsed;
                            else if (parsed.Ok && Array.isArray(parsed.Ok.Workspaces))
                                allWs = parsed.Ok.Workspaces;
                            else if (parsed.Ok && Array.isArray(parsed.Ok.workspaces))
                                allWs = parsed.Ok.workspaces;
                            else if (parsed.Workspaces)
                                allWs = parsed.Workspaces;

                            if (!allWs.length)
                                return;

                            const outputName = bar.screen.name;
                            let wsForOutput = allWs.filter(ws => !ws.output || ws.output === outputName);
                            if (!wsForOutput.length)
                                wsForOutput = allWs;

                            wsForOutput.sort((a, b) => (a.idx || 0) - (b.idx || 0));

                            bar.workspaces = wsForOutput;

                            let activeRef = null;
                            for (let i = 0; i < wsForOutput.length; ++i) {
                                const ws = wsForOutput[i];
                                if (ws.is_active || ws.is_focused) {
                                    activeRef = (ws.name && ws.name.length) ? ws.name : ws.idx;
                                    break;
                                }
                            }
                            bar.activeWorkspaceRef = activeRef;
                        } catch (e) {
                            console.log("Error parsing workspaces:", e);
                        }
                    }
                }
            }

            Item {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8

                // --- LEFT ELEMENT ---

                RowLayout {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4

                    Text {
                        Layout.alignment: Qt.AlignVCenter

                        font.pointSize: font_size
                        // 4. Apply font
                        font.family: font_family
                        color: col_text

                        text: "[ " + Qt.formatDateTime(clock.date, "ddd d MMM h:mm AP") + " ]"
                    }
                }

                // --- CENTER ELEMENT (Workspaces) ---
                RowLayout {
                    anchors.centerIn: parent
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4

                    Text {
                        Layout.alignment: Qt.AlignVCenter

                        font.pointSize: font_size
                        font.family: font_family
                        color: col_text
                        text: "["
                    }

                    Repeater {
                        model: bar.workspaces.length

                        delegate: Rectangle {
                            property var hovered: false
                            property var ws: bar.workspaces[index]
                            property var wsRef: (ws.name && ws.name.length) ? ws.name : ws.idx
                            property bool isActive: (bar.activeWorkspaceRef === wsRef)

                            color: "transparent"
                            Layout.alignment: Qt.AlignVCenter

                            implicitHeight: label.implicitHeight + 6
                            implicitWidth: label.implicitWidth + 12

                            Text {
                                id: label
                                anchors.centerIn: parent
                                text: (ws.name && ws.name.length) ? ws.name : ws.idx.toString()
                                font.pointSize: font_size
                                // 3. Apply font
                                font.family: font_family
                                color: isActive ? col_focused : col_text
                                horizontalAlignment: Text.AlignHCenter
                                font.bold: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: Quickshell.execDetached(["niri", "msg", "action", "focus-workspace", wsRef.toString()])
                                onEntered: parent.hovered = true
                                onExited: parent.hovered = false
                            }

                            Rectangle {
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    bottom: parent.bottom
                                }
                                height: 2
                                radius: 1
                                color: hovered ? col_focused : "transparent"
                            }
                        }
                    }

                    Text {
                        Layout.alignment: Qt.AlignVCenter

                        font.pointSize: font_size
                        font.family: font_family
                        color: col_text
                        text: "]"
                    }
                }

                // --- RIGHT ELEMENT ---
                RowLayout {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4

                    StyledText {
                      text: "Hello"
                    }

                    Text {
                        Layout.alignment: Qt.AlignVCenter

                        text: "Lix"
                        font.pointSize: font_size
                        font.family: font_family
                        color: col_text
                    }
                }
            }
        }
    }
}
