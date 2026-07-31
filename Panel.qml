import QtQuick
import qs.Commons
import qs.Ui

Panel {
  id: root
  moduleName: "b.omadoro"
  manageIpc: false

  property var anchorItem: null
  property var hostWidget: null
  property var timerService: null
  readonly property var barIdentity: hostWidget || root

  readonly property color foreground: Color.popups.text
  readonly property color activeColor: Color.accent
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family
  property int selectedAction: 0
  property bool cursorActive: true

  function open() {
    selectedAction = 0
    cursorActive = true
    controller.show()
  }

  function close() {
    controller.hide()
  }

  function toggle() {
    if (opened) close()
    else open()
  }

  function selectAction(delta) {
    cursorActive = true
    if (!timerService || timerService.stopped) {
      selectedAction = 0
      return
    }
    selectedAction = ((selectedAction + delta) % 4 + 4) % 4
  }

  function activateSelected() {
    if (!timerService || !timerService.initialized) return
    if (selectedAction === 0) timerService.playOrStop()
    else if (selectedAction === 1 && !timerService.stopped) timerService.togglePause()
    else if (selectedAction === 2 && !timerService.stopped) timerService.addFiveMinutes()
    else if (selectedAction === 3 && !timerService.stopped) timerService.skip()
  }

  function actionHovered(index, hovered) {
    if (!hovered) return
    cursorActive = true
    selectedAction = index
  }

  function switchPanel(direction) {
    if (bar && typeof bar.switchPanelFrom === "function")
      return bar.switchPanelFrom(barIdentity, direction)
    return false
  }

  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root.barIdentity
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(330))
    contentHeight: panel.fittedContentHeight(content.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent

      onMoveRequested: function(dx, dy) {
        if (dx !== 0) root.selectAction(dx)
        else if (dy !== 0) root.selectAction(dy)
      }
      onActivateRequested: root.activateSelected()
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      Column {
        id: content
        width: parent.width
        spacing: Style.space(18)

        Item {
          id: timerFace
          width: parent.width
          height: Style.space(245)

          CircularProgress {
            anchors.centerIn: parent
            width: Math.min(parent.width, parent.height)
            height: width
            progress: root.timerService ? root.timerService.progress : 0
            trackColor: Color.muted
            fillColor: root.activeColor
            strokeWidth: Math.max(5, Style.spaceReal(7))
          }

          Column {
            anchors.centerIn: parent
            spacing: Style.space(5)

            Text {
              anchors.horizontalCenter: parent.horizontalCenter
              text: root.timerService ? root.timerService.remainingText : "25:00"
              color: root.foreground
              font.family: root.fontFamily
              font.pixelSize: Math.round(Style.font.displayLarge * 1.7)
              font.bold: true
            }

            Text {
              anchors.horizontalCenter: parent.horizontalCenter
              text: root.timerService ? root.timerService.phaseLabel : "Work"
              color: root.activeColor
              font.family: root.fontFamily
              font.pixelSize: Style.font.title
            }
          }
        }

        Row {
          anchors.horizontalCenter: parent.horizontalCenter
          spacing: Style.space(10)

          Button {
            id: stopButton
            iconText: root.timerService && root.timerService.stopped ? "" : ""
            tooltipText: root.timerService && root.timerService.stopped
              ? "Start a new Pomodoro"
              : "Stop Pomodoro"
            foreground: root.foreground
            accent: root.activeColor
            iconSize: Style.font.iconLarge
            horizontalPadding: Style.space(12)
            verticalPadding: Style.space(9)
            enabled: !!root.timerService && root.timerService.initialized
            opacity: enabled ? 1 : 0.35
            hasCursor: root.cursorActive && root.selectedAction === 0
            onHovered: function(value) { root.actionHovered(0, value) }
            onClicked: if (root.timerService) root.timerService.playOrStop()
          }

          Button {
            id: pauseButton
            iconText: root.timerService && root.timerService.paused ? "" : ""
            tooltipText: root.timerService && root.timerService.paused
              ? "Resume current phase"
              : "Pause current phase"
            foreground: root.foreground
            accent: root.activeColor
            iconSize: Style.font.iconLarge
            horizontalPadding: Style.space(12)
            verticalPadding: Style.space(9)
            enabled: !!root.timerService && root.timerService.initialized && !root.timerService.stopped
            opacity: enabled ? 1 : 0.35
            hasCursor: root.cursorActive && root.selectedAction === 1
            onHovered: function(value) { root.actionHovered(1, value) }
            onClicked: if (root.timerService) root.timerService.togglePause()
          }

          Button {
            id: addButton
            iconText: "󰐕"
            tooltipText: "Add 5 minutes"
            foreground: root.foreground
            accent: root.activeColor
            iconSize: Style.font.iconLarge
            horizontalPadding: Style.space(12)
            verticalPadding: Style.space(9)
            enabled: !!root.timerService && root.timerService.initialized && !root.timerService.stopped
            opacity: enabled ? 1 : 0.35
            hasCursor: root.cursorActive && root.selectedAction === 2
            onHovered: function(value) { root.actionHovered(2, value) }
            onClicked: if (root.timerService) root.timerService.addFiveMinutes()
          }

          Button {
            id: skipButton
            iconText: ""
            tooltipText: "Skip to next phase"
            foreground: root.foreground
            accent: root.activeColor
            iconSize: Style.font.iconLarge
            horizontalPadding: Style.space(12)
            verticalPadding: Style.space(9)
            enabled: !!root.timerService && root.timerService.initialized && !root.timerService.stopped
            opacity: enabled ? 1 : 0.35
            hasCursor: root.cursorActive && root.selectedAction === 3
            onHovered: function(value) { root.actionHovered(3, value) }
            onClicked: if (root.timerService) root.timerService.skip()
          }
        }
      }
    }
  }
}
