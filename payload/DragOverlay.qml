import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.modules.config

PanelWindow {
    id: root

    required property var targetScreen
    screen: targetScreen

    property bool dragging: false
    property point startPosition: Qt.point(0, 0)
    property rect selectionRect: Qt.rect(0, 0, 0, 0)

    anchors {
        top: true
        bottom: true
        left: true
        right: right
    }

    color: "transparent"
    visible: dragging

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    Rectangle {
        x: root.selectionRect.x
        y: root.selectionRect.y - 40
        width: root.selectionRect.width
        height: root.selectionRect.height

        // Binds dynamically to Ambxst Config or fallback values
        color: Config.mods["com.manoj.rubberbandselectionoverlay"]?.overlayBgColor ?? "#445b93d3"
        border.width: Config.mods["com.manoj.rubberbandselectionoverlay"]?.overlayBorderWidth ?? 2
        border.color: Config.mods["com.manoj.rubberbandselectionoverlay"]?.overlayBorderColor ?? "#adaac7fc"
    }

    IpcHandler {
        target: "dragOverlay"

        function start(x: real, y: real) {
            root.startPosition = Qt.point(x, y)
            root.selectionRect = Qt.rect(x, y, 0, 0)
            root.dragging = true
        }

        function update(x: real, y: real) {
            if (!root.dragging)
                return

            const left = Math.min(root.startPosition.x, x)
            const top = Math.min(root.startPosition.y, y)
            root.selectionRect = Qt.rect(
                left,
                top,
                Math.abs(x - root.startPosition.x),
                Math.abs(y - root.startPosition.y)
            )
        }

        function stop() {
            root.dragging = false
        }
    }
}