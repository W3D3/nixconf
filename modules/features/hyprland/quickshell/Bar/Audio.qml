pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Pipewire

import "../Color.js" as Colors
import "../Components/"

Container {
  id: root

  required property HyprlandMonitor monitor

  readonly property double plaqueHeight: 60
  readonly property double plaqueSpacing: 4
  readonly property double sectionLabelHeight: 22

  readonly property var sinks: {
    let _ = Pipewire.nodes.count
    let result = []
    for (let i = 0; i < Pipewire.nodes.count; i++) {
      let node = Pipewire.nodes.values[i]
      if (node && (node.type & PwNodeType.AudioSink)) result.push(node)
    }
    return result
  }

  readonly property var sources: {
    let _ = Pipewire.nodes.count
    let result = []
    for (let i = 0; i < Pipewire.nodes.count; i++) {
      let node = Pipewire.nodes.values[i]
      if (node && (node.type & PwNodeType.AudioSource)) result.push(node)
    }
    return result
  }

  readonly property int totalRows: root.sinks.length + root.sources.length
  readonly property double totalHeight: (root.totalRows * root.plaqueHeight)
    + ((root.totalRows + 2) * root.plaqueSpacing)
    + (2 * root.sectionLabelHeight)
    + 4

  animOffset: 200
  boxColor: Colors.teal
  boxHeight: 25
  boxHeightOpened: root.totalHeight
  boxWidth: 33
  boxWidthOpened: 350
  defaultItem: icon
  exclusiveMonitor: root.monitor
  exclusiveToScreen: true
  forceHidden: false
  openedItem: deviceList

  Component {
    id: icon

    StyledText {
      property string component: "icon"

      horizontalAlignment: Qt.AlignCenter
      propo: true
      text: Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio && !Pipewire.defaultAudioSink.audio.muted ? "󰕾" : "󰖁"
      verticalAlignment: Qt.AlignVCenter
    }
  }

  Component {
    id: deviceList

    Column {
      id: deviceListRoot

      property string component: "deviceList"

      spacing: root.plaqueSpacing

      Item {
        implicitHeight: 1
        implicitWidth: 10
      }

      // --- Output section ---
      StyledText {
        color: Colors.subtext1
        fontSize: 10
        implicitHeight: root.sectionLabelHeight
        leftPadding: 8
        text: "OUTPUT"
      }

      Repeater {
        model: root.sinks

        delegate: Rectangle {
          id: sinkRow

          required property var modelData
          readonly property bool isDefault: Pipewire.defaultAudioSink === sinkRow.modelData
          readonly property double margin: 5

          color: Colors.surface1
          implicitHeight: root.plaqueHeight
          radius: 10

          anchors {
            left: parent.left
            leftMargin: sinkRow.margin
            right: parent.right
            rightMargin: sinkRow.margin
          }

          RowLayout {
            id: sinkInfoRow

            property double margin: 7

            spacing: margin * 2

            anchors {
              fill: parent
              leftMargin: margin
            }

            Rectangle {
              color: sinkRow.isDefault ? Colors.teal : Colors.surface2
              implicitHeight: root.plaqueHeight - (sinkInfoRow.margin * 2)
              implicitWidth: root.plaqueHeight - (sinkInfoRow.margin * 2)
              radius: 4

              CenteredText {
                fontSize: 17
                propo: true
                text: "󰕾"
              }
            }

            Column {
              Layout.alignment: Qt.AlignVCenter
              Layout.fillWidth: true

              StyledText {
                color: Colors.text
                fontSize: 14
                text: sinkRow.modelData.description ?? sinkRow.modelData.name
              }

              StyledText {
                color: Colors.subtext1
                fontSize: 10
                text: sinkRow.isDefault ? "Default output" : "Click to set as default"
              }
            }
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: Pipewire.preferredDefaultAudioSink = sinkRow.modelData
          }
        }
      }

      // --- Input section ---
      StyledText {
        color: Colors.subtext1
        fontSize: 10
        implicitHeight: root.sectionLabelHeight
        leftPadding: 8
        text: "INPUT"
        topPadding: 2
      }

      Repeater {
        model: root.sources

        delegate: Rectangle {
          id: sourceRow

          required property var modelData
          readonly property bool isDefault: Pipewire.defaultAudioSource === sourceRow.modelData
          readonly property double margin: 5

          color: Colors.surface1
          implicitHeight: root.plaqueHeight
          radius: 10

          anchors {
            left: parent.left
            leftMargin: sourceRow.margin
            right: parent.right
            rightMargin: sourceRow.margin
          }

          RowLayout {
            id: sourceInfoRow

            property double margin: 7

            spacing: margin * 2

            anchors {
              fill: parent
              leftMargin: margin
            }

            Rectangle {
              color: sourceRow.isDefault ? Colors.mauve : Colors.surface2
              implicitHeight: root.plaqueHeight - (sourceInfoRow.margin * 2)
              implicitWidth: root.plaqueHeight - (sourceInfoRow.margin * 2)
              radius: 4

              CenteredText {
                fontSize: 17
                propo: true
                text: "󰍬"
              }
            }

            Column {
              Layout.alignment: Qt.AlignVCenter
              Layout.fillWidth: true

              StyledText {
                color: Colors.text
                fontSize: 14
                text: sourceRow.modelData.description ?? sourceRow.modelData.name
              }

              StyledText {
                color: Colors.subtext1
                fontSize: 10
                text: sourceRow.isDefault ? "Default input" : "Click to set as default"
              }
            }
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: Pipewire.preferredDefaultAudioSource = sourceRow.modelData
          }
        }
      }
    }
  }
}
