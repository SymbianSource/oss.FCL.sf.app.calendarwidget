/*
* Copyright (c) 2009 Nokia Corporation and/or its subsidiary(-ies).
* All rights reserved.
* This component and the accompanying materials are made available
* under the terms of "Eclipse Public License v1.0"
* which accompanies this distribution, and is available
* at the URL "http://www.eclipse.org/legal/epl-v10.html".
*
* Initial Contributors:
* Nokia Corporation - initial contribution.
*
* Contributors:
*
* Description: Home screen Calendar widget
*
*/

// System includes
#include <QGraphicsProxyWidget>
#include <HbDocumentLoader>
#include <QGraphicsLinearLayout>
#include <QGraphicsWidget>
#include <QGraphicsSceneMouseEvent>
#include <QPainter>
#include <QDebug>
#include <QTranslator>
#include <QDir>
#include <QDateTime>
#include <xqservicerequest.h>
#include <HbFrameDrawer>
#include <HbFrameItem>
#include <HbColorScheme>
#include <HbEvent>
#include <HbLabel>
#include <QMetaMethod>
#include <QCoreApplication>
#include <QGesture>
#include <qxml.h>

// User includes
#include "calendarwidget.h"
#include "contentlayouthandler.h"
#include "contentlayoutgesture.h"
#include "calendarwidgetdebug.h"
#include "saxhandler.h"

//Local constants
const char DOCML[] = ":/CalendarWidget";

#define CALWIDGET_HIGHLIGHT_ACTIVE

// ======== MEMBER FUNCTIONS ========

/*
 * CalendarWidget::CalendarWidget()
 */
CalendarWidget::CalendarWidget(QGraphicsItem* parent, Qt::WindowFlags flags)
    : HbWidget(parent, flags)
{
    LOGS("CalendarWidget::CalendarWidget");
    grabGesture(Qt::TapGesture);
    grabGesture(Qt::PanGesture);
    grabGesture(Qt::PinchGesture);
    grabGesture(Qt::SwipeGesture);
}

/*
 * CalendarWidget::~CalendarWidget()
 */
CalendarWidget::~CalendarWidget()
{
    LOGS("CalendarWidget::~CalendarWidget");
}

/*
 * CalendarWidget::boundingRect()
 */
QRectF CalendarWidget::boundingRect() const
{
    LOGS("CalendarWidget::boundingRect");
    return childrenBoundingRect();
}

/*
 * CalendarWidget::shape()
 */
QPainterPath CalendarWidget::shape() const
{
    LOGS("CalendarWidget::shape");

    QPainterPath path;
    path.addRect(boundingRect());
    return path;
}

/*
 * CalendarWidget::loadWidget()
 */
bool CalendarWidget::loadWidget()
{
    LOGS("CalendarWidget::loadWidget");

    // Use document loader to load the contents
    HbDocumentLoader loader;
    bool loaded = true;
    bool ok = false;
    loader.load(DOCML, &ok);

    if (ok) {
        QObject* contentLayoutHandler = new ContentLayoutHandler();
        connectLayoutHandler(this, contentLayoutHandler, loader);
        
		QString fileName( "C:/private/20022F35/gestures.xml" );
		QFile xmlConfiguration(fileName);
		bool fileExists = xmlConfiguration.open( QIODevice::ReadOnly );
		if (fileExists) {
            xmlConfiguration.close();
        }
        else {
            QFile sourceFile("Z:/resource/gestures.xml");
            fileExists = sourceFile.open(QFile::ReadOnly);
            fileExists = xmlConfiguration.open(QFile::WriteOnly | QFile::Truncate);
            fileExists = xmlConfiguration.write(sourceFile.readAll()) >= 0;
            sourceFile.close();
            xmlConfiguration.close();
        }
		
		if (fileExists) {
            parseFile(fileName, loader);
        }

        if (dynamic_cast<QGraphicsLinearLayout*> (contentLayoutHandler)) {
            setPreferredSize(
                dynamic_cast<QGraphicsLinearLayout*>(contentLayoutHandler)->preferredSize());
            parentWidget()->resize(preferredSize()); // workaround for layouting
            setLayout(dynamic_cast<QGraphicsLinearLayout*>(contentLayoutHandler));
        }
        else {
            loaded = false;
        }    
    }
    else {
        loaded = false;
    }
    
    return loaded;
}

/*
 * CalendarWidget::connectLayoutHandler()
 */
void CalendarWidget::connectLayoutHandler(HbWidget *widget, QObject *layoutHandler, HbDocumentLoader& loader)
{
    LOGS("CalendarWidget::connectLayoutHandler");
    if (!widget || !layoutHandler) {
        return;
    }
    int methodIndex = layoutHandler->metaObject()->
        indexOfSlot("initializeLayout(HbDocumentLoader,QObject*)");
    if (methodIndex >= 0) {
        layoutHandler->metaObject()->method(methodIndex).invoke(layoutHandler,
            Q_ARG(const HbDocumentLoader, loader), Q_ARG(QObject*, this));
    }
    else {
        return;
    }

    methodIndex = layoutHandler->metaObject()->indexOfSlot("onThemeChange()");
    if (methodIndex >= 0) {
        connect(this, SIGNAL(themeChanged()), layoutHandler, SLOT(onThemeChange()));
    }

    methodIndex = layoutHandler->metaObject()->indexOfSlot("highlightOn(QPointF&)");
    if (methodIndex >= 0) {
        connect(this, SIGNAL(mousePressed(QPointF&)),
            layoutHandler, SLOT(highlightOn(QPointF&)));
    }
    
    methodIndex = layoutHandler->metaObject()->indexOfSlot("highlightOff()");
    if (methodIndex >= 0) {
        connect(this, SIGNAL(mouseReleased()),
            layoutHandler, SLOT(highlightOff()));
    }

}

/*
 * CalendarWidget::loadTranslator
 */
void CalendarWidget::loadTranslator()
{
    LOGS("CalendarWidget::loadTranslator");
    QLocale::setDefault(QLocale::English);
    QString locale = QLocale::system().languageToString(QLocale::system().language());
    qDebug() << "locale: " << locale;
    QString lang = QLocale::system().name();
    mCommonTranslator = new QTranslator();
    QString path = "Z:/resource/qt/translations/";
    QString filename = "calwidget_" + lang + ".qm";
    qDebug() << "path: " << path;
    qDebug() << "filename: " << filename;
    bool loaded = mCommonTranslator->load(filename,path);
    qDebug() << "loaded = " << loaded;
    QCoreApplication::installTranslator(mCommonTranslator);
}

/*
 * CalendarWidget::event()
 */
bool CalendarWidget::event(QEvent * event)
{
    LOGS("CalendarWidget::event");
    bool consumed = false;
    QEvent::Type eventType = event->type();

    if (eventType == HbEvent::ThemeChanged) {
        consumed = true;
        emit themeChanged();
    }
    
    if (eventType == QEvent::Gesture) {
        QGestureEvent* gesture = static_cast<QGestureEvent*>(event);
        QList<QGesture*> gestureList = gesture->gestures();
        for (int i = 0; i < gestureList.count(); i++) {
            int type = gestureList.at(i)->gestureType();
            qDebug() << "type = " << type;
        }
        gestureEvent(static_cast<QGestureEvent*>(event));
        consumed = true;
    }

    return consumed;
}

/*
 * CalendarWidget::onInitialize()
 */
void CalendarWidget::onInitialize()
{
    LOGS("CalendarWidget::onInitialize");
    loadTranslator();

    if (loadWidget()) {
#ifdef CALWIDGET_HIGHLIGHT_ACTIVE
        // Register event filter for highlighting
        QCoreApplication* coreApp = QCoreApplication::instance();
        if (coreApp) {
            coreApp->installEventFilter(this);
        }
#endif
    }
    else {
        //loading failed
        emit finished();
    }
}

/*
 * CalendarWidget::onShow()
 */
void CalendarWidget::onShow()
{
    LOGS("CalendarWidget::onShow");
    emit mouseReleased();
}

/*
* CalendarWidget::onHide()
*/
void CalendarWidget::onHide()
{
    LOGS("CalendarWidget::onHide");
}

/*
 * CalendarWidget::onUninitialize()
 */
void CalendarWidget::onUninitialize()
{
    LOGS("CalendarWidget::onUninitialize");
#ifdef CALWIDGET_HIGHLIGHT_ACTIVE
    // Uninstall event filter
    QCoreApplication* coreApp = QCoreApplication::instance();
    if (coreApp) {
        coreApp->removeEventFilter(this);
    }
#endif
}

/*
 * CalendarWidget::eventFilter()
 */
bool CalendarWidget::eventFilter(QObject *obj, QEvent *event)
{
    Q_UNUSED(obj);
    if (event->type() == QEvent::GraphicsSceneMousePress) {
        QGraphicsSceneMouseEvent* mouseEvent = (QGraphicsSceneMouseEvent*)event;
        QPointF pos = mouseEvent->scenePos();
//        emit mousePressed(pos);
    }
    else if (event->type() == QEvent::GraphicsSceneMouseRelease) {
//        emit mouseReleased();
    }
    return false;
}

/*
 * CalendarWidget::gestureEvent()
 */
void CalendarWidget::gestureEvent(QGestureEvent *event)
{
    LOGS("CalendarWidget::gestureEvent");
    if (QTapGesture *tap = (QTapGesture*)event->gesture(Qt::TapGesture)) {
        //QPointF pos = mapFromScene(event->mapToGraphicsScene(tap->position()));
        QPointF pos = tap->position();
        switch(tap->state()) {
            case Qt::GestureStarted:
                emit mousePressed(pos);
                LOGS("CalendarWidget::gestureEvent => gestureStarted");
                break;
            case Qt::GestureUpdated:
                LOGS("CalendarWidget::gestureEvent => gestureUpdated");
                break;
            case Qt::GestureFinished:
                emit tapGesture(pos);
                emit mouseReleased();
                LOGS("CalendarWidget::gestureEvent => gestureFinished");
                break;
            case Qt::GestureCanceled:
                LOGS("CalendarWidget::gestureEvent => gestureCanceled");
                break;
            default:
                break;
        }
    }
    
    if(QPanGesture *pan = (QPanGesture*)event->gesture(Qt::PanGesture)) {
        switch (pan->state()) {
            case Qt::GestureFinished:
                emit mouseReleased();
                break;
            default:
                break;
        }
    }
        
    if (QSwipeGesture *pan = (QSwipeGesture*)event->gesture(Qt::SwipeGesture)) {
        switch (pan->state()) {
            case Qt::GestureFinished:
                emit mouseReleased();
                break;
            default:
                break;
        }
    }

    if (QPinchGesture *pan = (QPinchGesture*)event->gesture(Qt::PinchGesture)) {
        switch (pan->state()) {
            case Qt::GestureFinished:
                emit mouseReleased();
                break;
            default:
                break;
        }
    }
}

/*
 *  CalendarWidget::mousePressEvent()
 */
void CalendarWidget::mousePressEvent(QGraphicsSceneMouseEvent *event)
{
    Q_UNUSED(event);
    LOGS("CalendarWidget::mousePressEvent");
}

/*
 *  CalendarWidget::mouseReleaseEvent()
 */
void CalendarWidget::mouseReleaseEvent(QGraphicsSceneMouseEvent *event)
{
    Q_UNUSED(event);
    LOGS("CalendarWidget::mouseReleaseEvent");
}

bool CalendarWidget::parseFile(QString& fileName, HbDocumentLoader& loader)
{
    LOGS("CalendarWidget::ParseFile");
    QFile file(fileName);
    QXmlInputSource inputSource(&file);
    QXmlSimpleReader reader;
    SaxHandler xmlParser(this, loader);
    reader.setContentHandler(&xmlParser);
    reader.setErrorHandler(&xmlParser);
    return reader.parse(inputSource);
}

//End of file
