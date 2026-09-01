import QtQuick
import qs.Commons

Canvas {
  id: root

  property real progress: 0
  property color trackColor: Color.muted
  property color fillColor: Color.accent
  property real strokeWidth: Math.max(2, Style.spaceReal(2))

  antialiasing: true

  onProgressChanged: requestPaint()
  onTrackColorChanged: requestPaint()
  onFillColorChanged: requestPaint()
  onStrokeWidthChanged: requestPaint()
  onWidthChanged: requestPaint()
  onHeightChanged: requestPaint()

  onPaint: {
    var context = getContext("2d")
    context.clearRect(0, 0, width, height)

    var lineWidth = Math.max(1, Number(root.strokeWidth))
    var radius = Math.max(0, Math.min(width, height) / 2 - lineWidth / 2)
    if (radius <= 0) return

    var centerX = width / 2
    var centerY = height / 2
    var value = Math.max(0, Math.min(1, Number(root.progress) || 0))

    context.save()

    // Face rim.
    context.lineWidth = lineWidth
    context.lineCap = "round"
    context.beginPath()
    context.strokeStyle = root.trackColor
    context.arc(centerX, centerY, radius, 0, Math.PI * 2, false)
    context.stroke()

    // Hour ticks at 12/3/6/9.
    var tickLength = Math.max(1, radius * 0.22)
    var tickWidth = Math.max(1, lineWidth * 0.6)
    context.lineWidth = tickWidth
    context.strokeStyle = root.trackColor
    for (var i = 0; i < 4; i++) {
      var tickAngle = i * (Math.PI / 2)
      var outerX = centerX + Math.sin(tickAngle) * (radius - lineWidth / 2)
      var outerY = centerY - Math.cos(tickAngle) * (radius - lineWidth / 2)
      var innerX = centerX + Math.sin(tickAngle) * (radius - lineWidth / 2 - tickLength)
      var innerY = centerY - Math.cos(tickAngle) * (radius - lineWidth / 2 - tickLength)
      context.beginPath()
      context.moveTo(innerX, innerY)
      context.lineTo(outerX, outerY)
      context.stroke()
    }

    // Sweeping hand: one full turn from 12 o'clock over the phase's duration.
    var handAngle = value * Math.PI * 2
    var handLength = radius - lineWidth
    context.lineWidth = Math.max(1, lineWidth * 0.85)
    context.strokeStyle = root.fillColor
    context.beginPath()
    context.moveTo(centerX, centerY)
    context.lineTo(centerX + Math.sin(handAngle) * handLength,
                    centerY - Math.cos(handAngle) * handLength)
    context.stroke()

    // Center pivot.
    context.beginPath()
    context.fillStyle = root.fillColor
    context.arc(centerX, centerY, Math.max(1, lineWidth * 0.45), 0, Math.PI * 2, false)
    context.fill()

    context.restore()
  }
}
