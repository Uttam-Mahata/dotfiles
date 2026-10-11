import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#181920"

    // Background Image
    Image {
        id: bg
        anchors.fill: parent
        source: config.background || ""
        fillMode: Image.PreserveAspectCrop
        visible: source != ""
    }

    // Dark backdrop overlay for contrast
    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.45
    }

    // Top Right Clock & Date
    Column {
        anchors {
            top: parent.top
            right: parent.right
            margins: 36
        }
        spacing: 4

        Text {
            id: clock
            anchors.right: parent.right
            text: Qt.formatDateTime(new Date(), "hh:mm")
            color: "#f2f2f2"
            font.pixelSize: 42
            font.bold: true
            font.family: config.font || "Sans"
        }

        Text {
            id: date
            anchors.right: parent.right
            text: Qt.formatDateTime(new Date(), "dddd, d MMMM yyyy")
            color: "#8c96a0"
            font.pixelSize: 16
            font.family: config.font || "Sans"
        }

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: {
                clock.text = Qt.formatDateTime(new Date(), "hh:mm")
                date.text = Qt.formatDateTime(new Date(), "dddd, d MMMM yyyy")
            }
        }
    }

    // Central Login Box
    Rectangle {
        id: loginCard
        width: 360
        height: 440
        anchors.centerIn: parent
        radius: 16
        color: config.cardColor || "#d9222222"
        border.color: config.accentColor || "#1793d1"
        border.width: 1

        Column {
            anchors.centerIn: parent
            width: parent.width - 56
            spacing: 16

            // Arch Logo
            Image {
                id: archLogo
                anchors.horizontalCenter: parent.horizontalCenter
                source: "archlinux-logo.png"
                width: 64
                height: 64
                fillMode: Image.PreserveAspectFit
                smooth: true
            }

            // Title & Username
            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 4

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Arch Linux"
                    color: "#f2f2f2"
                    font.pixelSize: 20
                    font.bold: true
                    font.family: config.font || "Sans"
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: (userModel.lastUser ? userModel.lastUser : "uttam") + "@" + (sddm.hostName ? sddm.hostName : "archlinux")
                    color: config.accentColor || "#1793d1"
                    font.pixelSize: 14
                    font.bold: true
                    font.family: config.font || "Sans"
                }
            }

            // Password Field
            TextField {
                id: passwordInput
                width: parent.width
                height: 46
                echoMode: TextInput.Password
                focus: true
                placeholderText: "Password..."
                placeholderTextColor: "#8c96a0"
                color: "#f2f2f2"
                font.pixelSize: 14
                font.family: config.font || "Sans"
                selectionColor: config.accentColor || "#1793d1"

                background: Rectangle {
                    radius: 10
                    color: "#2a2b30"
                    border.color: passwordInput.activeFocus ? (config.accentColor || "#1793d1") : "#3d3e46"
                    border.width: 1
                }

                Keys.onReturnPressed: doLogin()
                Keys.onEnterPressed: doLogin()
            }

            // Error Message Display
            Text {
                id: errorLabel
                anchors.horizontalCenter: parent.horizontalCenter
                text: ""
                color: "#e05555"
                font.pixelSize: 12
                font.family: config.font || "Sans"
                visible: text !== ""
            }

            // Login Button
            Button {
                id: loginBtn
                width: parent.width
                height: 44
                contentItem: Text {
                    text: "Log In"
                    color: "#ffffff"
                    font.bold: true
                    font.pixelSize: 14
                    font.family: config.font || "Sans"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    radius: 10
                    color: loginBtn.down ? "#0f6998" : (config.accentColor || "#1793d1")
                }
                onClicked: doLogin()
            }
        }
    }

    // Bottom Power Controls
    Row {
        anchors {
            bottom: parent.bottom
            right: parent.right
            margins: 24
        }
        spacing: 16

        Button {
            text: "Reboot"
            contentItem: Text {
                text: "Reboot"
                color: "#8c96a0"
                font.pixelSize: 13
                font.family: config.font || "Sans"
            }
            background: Rectangle { color: "transparent" }
            onClicked: sddm.reboot()
        }

        Button {
            text: "Shutdown"
            contentItem: Text {
                text: "Power Off"
                color: "#8c96a0"
                font.pixelSize: 13
                font.family: config.font || "Sans"
            }
            background: Rectangle { color: "transparent" }
            onClicked: sddm.powerOff()
        }
    }

    function doLogin() {
        var user = (userModel && userModel.lastUser) ? userModel.lastUser : "uttam"
        var sessionIdx = (typeof sessionModel !== "undefined" && sessionModel.lastIndex >= 0) ? sessionModel.lastIndex : 0
        sddm.login(user, passwordInput.text, sessionIdx)
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            passwordInput.text = ""
            errorLabel.text = "Authentication failed"
        }
    }
}
