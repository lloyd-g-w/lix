import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

ShellRoot {
  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: bar

      property var modelData
      screen: modelData

      // All workspaces for this monitor from `niri msg --json workspaces`
      property var workspaces: []
      // idx or name of the currently active workspace
      property var activeWorkspaceRef: null

      anchors {
        top: true
        left: true
        right: true
      }

      implicitHeight: 28
      aboveWindows: true
      exclusiveZone: implicitHeight

      color: "#1e1e2e"

      SystemClock {
        id: clock
        precision: SystemClock.Minutes
      }

      // Poll workspaces every 50 us
Timer {
  id: workspaceTimer
  interval: 50
  running: true
  repeat: true
  onTriggered: workspaceFetcher.exec({})
}

      // Fetch workspace state from niri
Process {
  id: workspaceFetcher
  command: ["niri", "msg", "--json", "workspaces"]
  running: false

  stdout: SplitParser {
    onRead: function (data) {
      try {
        const parsed = JSON.parse(data)
        let allWs = []

        if (Array.isArray(parsed)) {
          allWs = parsed
        } else if (parsed.Ok) {
          const ok = parsed.Ok
          if (Array.isArray(ok.Workspaces)) {
            allWs = ok.Workspaces
          } else if (Array.isArray(ok.workspaces)) {
            allWs = ok.workspaces
          } else if (Array.isArray(ok)) {
            allWs = ok
          }
        } else if (Array.isArray(parsed.Workspaces)) {
          allWs = parsed.Workspaces
        } else if (Array.isArray(parsed.workspaces)) {
          allWs = parsed.workspaces
        }

        if (!allWs.length) {
          console.log("niri workspaces: no workspace array found:", data)
          return
        }

        const outputName = bar.screen.name
        console.log("bar.screen.name =", outputName)

        let wsForOutput = allWs.filter(function (ws) {
          return !ws.output || ws.output === outputName
        })

        if (!wsForOutput.length) {
          wsForOutput = allWs
        }

        wsForOutput.sort(function (a, b) {
          return (a.idx || 0) - (b.idx || 0)
        })

        console.log("workspaces for output:", JSON.stringify(wsForOutput))
        bar.workspaces = wsForOutput

        let activeRef = null
        for (let i = 0; i < wsForOutput.length; ++i) {
          const ws = wsForOutput[i]
          if (ws.is_active || ws.is_focused) {
            if (ws.name && ws.name.length) {
              activeRef = ws.name
            } else {
              activeRef = ws.idx
            }
            break
          }
        }
        bar.activeWorkspaceRef = activeRef
      } catch (e) {
        console.log("Failed to parse `niri msg --json workspaces`:", e, data)
      }
    }
  }
}

      RowLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: 6
        spacing: 8

        Text {
          text: "Lix"
          font.pixelSize: 13
          color: "#cdd6f4"
          Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
        }

        // Workspaces
        RowLayout {
          Layout.fillWidth: true
          Layout.alignment: Qt.AlignVCenter
          spacing: 4

          Repeater {
            // one entry per workspace on this output
            model: bar.workspaces.length

            delegate: Rectangle {
              // workspace object from JSON
              property var ws: bar.workspaces[index]
              // For display and focus-workspace, use name if set, otherwise idx
              property var wsRef: (ws.name && ws.name.length) ? ws.name : ws.idx
              property bool isActive: (bar.activeWorkspaceRef === wsRef)

              radius: 4
              border.width: 1
              border.color: isActive ? "#89b4fa" : "#45475a"
              color: isActive ? "#89b4fa33" : "transparent"
              implicitHeight: 20

              Layout.alignment: Qt.AlignVCenter
              Layout.minimumWidth: label.implicitWidth + 12

              Text {
                id: label
                anchors.centerIn: parent
                // Show name if present, else numeric idx
                text: (ws.name && ws.name.length)
                      ? ws.name
                      : ws.idx.toString()
                font.pixelSize: 12
                color: isActive ? "#cdd6f4" : "#bac2de"
                horizontalAlignment: Text.AlignHCenter
              }

              MouseArea {
                anchors.fill: parent
                hoverEnabled: true

                onClicked: {
                  // Works with both numeric indices and named workspaces
                  Quickshell.execDetached([
                    "niri", "msg", "action", "focus-workspace",
                    wsRef.toString()
                  ])
                }

                onEntered: parent.border.color = "#89b4fa"
                onExited: parent.border.color =
                  isActive ? "#89b4fa" : "#45475a"
              }
            }
          }
        }

        // Clock
        Text {
          Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
          font.pixelSize: 13
          color: "#cdd6f4"
          text: Qt.formatDateTime(clock.date, "ddd d MMM h:mm AP")
        }
      }
    }
  }
}

