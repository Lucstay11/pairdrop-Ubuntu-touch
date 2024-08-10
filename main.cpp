#include <QGuiApplication>
#include <QCoreApplication>
#include <QUrl>
#include <QString>
#include <QQuickStyle>
#include <QQmlEngine>
#include <QQmlContext>
#include <QQmlApplicationEngine>
#include <QQuickView>
#include <QVector>
#include <QtWebEngine/qtwebengineglobal.h>




int main(int argc, char** argv) {
    QGuiApplication::setOrganizationName("pairdrop.lucstay11");
    QGuiApplication::setApplicationName("pairdrop.lucstay11");
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication::setAttribute(Qt::AA_ShareOpenGLContexts);

    const auto chromiumFlags = qgetenv("QTWEBENGINE_CHROMIUM_FLAGS");
    qputenv("QTWEBENGINE_CHROMIUM_FLAGS", chromiumFlags + "--simulate-touch-screen-with-mouse --touch-events=enabled --enable-features=OverlayScrollbar,kEnableQuic,OverlayScrollbarFlashAfterAnyScrollUpdate,OverlayScrollbarFlashWhenMouseEnter --enable-blink-features=NeverSlowMode,BackFowardCache,Canvas2dScrollPathIntoView,BackForwardCacheExperimentHTTPHeader,Accelerated2dCanvas,AcceleratedSmallCanvases --enable-smooth-scrolling  --disable-low-res-tiling --enable-gpu --enable-gpu-rasterization --enable-zero-copy  --adaboost --enable-gpu-msemory-buffer-video-frames  --font-render-hinting=none --disable-font-subpixel-positioning --disable-new-content-rendering-timeout --enable-defer-all-script-without-optimization-hints  --enable-gpu-vsync  --enable-oop-rasterization --enable-accelerated-video-decode ");
        
    QGuiApplication app(argc, argv);

    QQuickStyle::setStyle("Suru");
      QQmlApplicationEngine engine(QUrl("qrc:///app/Main.qml"));

    return app.exec();
}
