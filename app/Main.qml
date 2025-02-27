import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12
import Lomiri.Components 1.3
import Morph.Web 0.1
import QtWebEngine 1.11
import QtSystemInfo 5.5

ApplicationWindow {

    id: window
    visible: true
    color: "transparent"

    ScreenSaver {
        id: screenSaver
        screenSaverEnabled: !Qt.application.active || !webview.recentlyAudible
    }

    width: units.gu(45)
    height: units.gu(75)

    objectName: "mainView"
    property bool loaded: false
    property bool onError: false


    property QtObject defaultProfile: WebEngineProfile {
        id: webContext
        storageName: "myProfile"
        offTheRecord: false
        persistentCookiesPolicy: WebEngineProfile.ForcePersistentCookies
        property alias dataPath: webContext.persistentStoragePath

        dataPath: dataLocation

        userScripts: [
            WebEngineScript {
                id: cssinjection
                injectionPoint: WebEngineScript.DocumentReady
                worldId: WebEngineScript.UserWorld
                sourceCode: "\n(function() {\nvar css = \"* {font-family: \\\"Ubuntu\\\" !important;} ytm-pivot-bar-renderer {display: none !important;} .related-chips-slot-wrapper { transform: none !important;} .related-chips-slot-wrapper.slot-open { transform: none !important; height: 295px !important;} \"\n\n;\n\n\nif (typeof GM_addStyle != \"undefined\") {\n\tGM_addStyle(css);\n} else if (typeof PRO_addStyle != \"undefined\") {\n\tPRO_addStyle(css);\n} else if (typeof addStyle != \"undefined\") {\n\taddStyle(css);\n} else {\n\tvar node = document.createElement(\"style\");\n\tnode.type = \"text/css\";\n\tnode.appendChild(document.createTextNode(css));\n\tvar heads = document.getElementsByTagName(\"head\");\n\tif (heads.length > 0) {\n\t\theads[0].appendChild(node); \n\t} else {\n\t\t// no head yet, stick it whereever\n\t\tdocument.documentElement.appendChild(node);\n\t}\n}\n\n})();"
            }
        ]

        httpUserAgent: "Mozilla/5.0 (Ubuntu; U; ; en) Version/1.7412.EU"

    }

    WebView {

        id: webview
        anchors.fill: parent
        url: "https://pairdrop.net/"
        settings.webRTCPublicInterfacesOnly: true

        profile: defaultProfile
        settings.fullScreenSupportEnabled: true
        settings.dnsPrefetchEnabled: true

        enableSelectOverride: true

        property var currentWebview: webview
        property ContextMenuRequest contextMenuRequest: null

        settings.pluginsEnabled: true
        settings.javascriptCanAccessClipboard: true

        onFeaturePermissionRequested: grantFeaturePermission(url, WebEngineView.MediaAudioVideoCapture, true);

        onFullScreenRequested: function(request) {
            request.accept();
            nav.visible = !nav.visible
            if (request.toggleOn) {
                window.showFullScreen();
            }
            else {
                window.showNormal();
            }
        }


        onLoadingChanged: {
            if (loadRequest.status === WebEngineLoadRequest.LoadStartedStatus) {
                window.loaded = true
            } else if (loadRequest.status === WebEngineLoadRequest.LoadFailedStatus) {
                window.onError = true
            }
        }

        //handle click on links
        onNewViewRequested: function(request) {
            console.log(request.destination, request.requestedUrl)

            var url = request.requestedUrl.toString()
                Qt.openUrlExternally(url)
        }

        onContextMenuRequested: function(request) {
            if (!Qt.inputMethod.visible) { //don't open it on when address bar is open
                request.accepted = true;
                contextMenuRequest = request
                contextMenu.x = request.x;
                contextMenu.y = request.y;
                contextMenu.open();
            }
        }
    }

    Menu {
        id: contextMenu

        MenuItem {
            id: copyItem
            text: i18n.tr("Copy link")
            enabled: webview.contextMenuRequest
            onTriggered: {

                var url = ''
                if (webview.contextMenuRequest.linkUrl.toString().length > 0) {
                    url = webview.contextMenuRequest.linkUrl.toString()
                } else {
                    //when clicking on the video
                    url = webview.url.toString()
                }
                console.log("push to clipboard:", url)

                Clipboard.push(url)
                webview.contextMenuRequest = null;
            }
        }
    }

    Rectangle {
        id: splashScreen
        anchors.fill: parent
        color: "#111111"

        states: [
            State { when: !window.loaded && !window.onError;
                PropertyChanges { target: splashScreen; opacity: 1.0 }
            },
            State { when: window.loaded || window.onError;
                PropertyChanges { target: splashScreen; opacity: 0.0 }
            }
        ]

        transitions: Transition {
            NumberAnimation { property: "opacity"; duration: 600}
        }
    }


    Connections {
        target: webview

        onIsFullScreenChanged: {

            console.log('onIsFullScreenChanged:')
            window.setFullscreen(webview.isFullScreen)
            if (webview.isFullScreen) {
                nav.state = "hidden"
                //  webview.height = units.gu(75)
            }
            else {
                nav.state = "shown"
            }
        }
    }

    Connections {
        target: UriHandler

        onOpened: {

            if (uris.length > 0) {
                console.log('Incoming call from UriHandler ' + uris[0]);
                webview.url = uris[0];
            }
        }
    }

    Component.onCompleted: {
        //Check if opened the app because we have an incoming call
        if (Qt.application.arguments && Qt.application.arguments.length > 0) {
            for (var i = 0; i < Qt.application.arguments.length; i++) {
                if (Qt.application.arguments[i].match(/^http/)) {
                    console.log(' open video to:', Qt.application.arguments[i])
                    webview.url = Qt.application.arguments[i];
                }
            }
        }
        else {
            webview.url = myurl;
        }
    }

    function setFullscreen(fullscreen) {
        if (fullscreen) {
            if (window.visibility != ApplicationWindow.FullScreen) {
                window.visibility = ApplicationWindow.FullScreen
            }
        } else {
            window.visibility = ApplicationWindow.Windowed
        }
    }

    function toggleApplicationLevelFullscreen() {
        setFullscreen(visibility !== ApplicationWindow.FullScreen)
    }

    Shortcut {
        sequence: StandardKey.FullScreen
        onActivated: window.toggleApplicationLevelFullscreen()
    }

    Shortcut {
        sequence: "F11"
        onActivated: window.toggleApplicationLevelFullscreen()
    }
}
