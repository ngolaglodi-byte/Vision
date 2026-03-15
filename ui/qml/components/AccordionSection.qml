import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Column {
    id: root
    property string sectionIcon: ""
    property string sectionTitle: ""
    property Item contentItem

    property bool expanded: false

    Rectangle {
        id: header
        width: parent.width
        height: 38
        color: root.expanded ? "#1F2937" : "#161B22"
        border.color: "#30363D"

        Row {
            anchors.fill: parent
            anchors.leftMargin: 10
            spacing: 8

            Text {
                text: root.sectionIcon
                font.pixelSize: 14
                color: "#58A6FF"
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: root.sectionTitle
                font.pixelSize: 13
                color: "#E6EDF3"
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.expanded = !root.expanded
        }
    }

    // Contenu animé
    Item {
        id: contentWrapper
        width: parent.width
        height: root.expanded ? contentItem.implicitHeight : 0
        clip: true

        Behavior on height {
            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
        }

        Rectangle {
            anchors.fill: parent
            color: "#0D1117"
            border.color: "#30363D"
            border.width: 1

            Loader {
                id: loader
                anchors.fill: parent
                sourceComponent: root.expanded ? contentItem : null
            }
        }
    }
}
