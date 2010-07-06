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
* Description: Calendar widget's date icon layout handler
*
*/

// System includes
#include <QObject>
#include <HbLabel>
#include <HbColorScheme>
#include <HbFrameDrawer>
#include <HbFrameItem>
#include <HbDocumentLoader>
#include <QDateTime>
#include <QTimer>
#include <QPointF>
#include <QGraphicsLayout>
#include <xqaiwrequest.h>
#include <xqappmgr.h>

// User includes
#include "dateiconlayouthandler.h"
#include "calendarwidgetdebug.h"
#include "datetimeobserver.h"

// Local constants
namespace
{
    const HbFrameDrawer::FrameType BACKGROUND_FRAME_TYPE = HbFrameDrawer::OnePiece;
    const char *DAY_CONTAINER = "dayContainer";
    const char *DATE_ICON_DAYNUMBER = "dayNumber";
    const char *DATE_ICON_MONTHLABEL = "month";
    const char *NUMBER_LABEL_COLOR = "qtc_hs_cal";
    const char *MONTH_LABEL_COLOR = "qtc_hs_list_item_title_normal";
    const char *DATE_BACKGROUND = "qtg_large_calendar_dynamic";
} // namespace 

// ======== MEMBER FUNCTIONS ========

/*
 * DateIconLayoutHandler::DateIconLayoutHandler()
 */
DateIconLayoutHandler::DateIconLayoutHandler()
        : mWidget(0),
          mNumberLabel(0),
          mMonthLabel(0),
          mFrameDrawer(0),
          mDateObserver(0)
{
    LOGS("DateIconLayoutHandler::DateIconLayoutHandler");
}

/*
 * DateIconLayoutHandler::~DateIconLayoutHandler()
 */
DateIconLayoutHandler::~DateIconLayoutHandler()
{
    LOGS("DateIconLayoutHandler::~DateIconLayoutHandler()");
    delete mDateObserver;
}

/*
 * DateIconLayoutHandler::initializeLayout()
 */
void DateIconLayoutHandler::initializeLayout(const HbDocumentLoader &layoutLoader, QObject *owner)
{
    this->setParent(owner);
    mWidget = qobject_cast<HbWidget*>(layoutLoader.findWidget(QString(DAY_CONTAINER)));
    mNumberLabel = qobject_cast<HbLabel*>(layoutLoader.findWidget(QString(DATE_ICON_DAYNUMBER)));
    mMonthLabel = qobject_cast<HbLabel*>(layoutLoader.findWidget(QString(DATE_ICON_MONTHLABEL)));

    // Create background drawer only if day container loading succeeded
    if (mWidget) {
        mFrameDrawer = new HbFrameDrawer(DATE_BACKGROUND, BACKGROUND_FRAME_TYPE);
        HbFrameItem* frameItem = new HbFrameItem(mFrameDrawer);
        mWidget->setBackgroundItem(frameItem);
    }

    setCalendarIconContent();
    setLabelsColor();

    mDateObserver = new DateTimeObserver();
    connect(mDateObserver, SIGNAL(completed()), this, SIGNAL(dateChanged()));
    connect(this, SIGNAL( dateChanged() ), owner, SIGNAL( updateLayout() ));
}

/*
 * DateIconLayoutHandler::updateLayout()
 */
void DateIconLayoutHandler::updateLayout()
{
    LOGS("DateIconLayoutHandler::updateLayout");
    setCalendarIconContent();
}

/*
 * DateIconLayoutHandler::onTap()
 */
void DateIconLayoutHandler::onTap(QPointF &point)
{
    if (mWidget) {
        if (mWidget->sceneBoundingRect().contains(point)) {
            LOGS("[[[onTap in DateIcon area]]]");
            launchCalendarMonthView();
        }
    }
}

/*
 * DateIconLayoutHandler::onThemeChange()
 */
void DateIconLayoutHandler::onThemeChange()
{
    LOGS("DateIconLayoutHandler::onThemeChange");
    if (mFrameDrawer) {
        mFrameDrawer->themeChanged();
    }
    setLabelsColor();
}

void DateIconLayoutHandler::setLabelsColor()
{
    LOGS("CalendarWidget::CalendarWidget");
    
    const QString dayLabelColorAttribute(NUMBER_LABEL_COLOR);
    QColor numberLabelColor(HbColorScheme::color(dayLabelColorAttribute));
    if (numberLabelColor.isValid() && mNumberLabel) {
        mNumberLabel->setTextColor(numberLabelColor);
    }
    
    const QString monthLabelColorAttribute(MONTH_LABEL_COLOR);
    QColor monthLabelColor(HbColorScheme::color(monthLabelColorAttribute));
    if (monthLabelColor.isValid() && mMonthLabel) {
        mMonthLabel->setTextColor(monthLabelColor);
    }
}

/*
 * DateIconLayoutHandler::setCalendarIconContent()
 */
void DateIconLayoutHandler::setCalendarIconContent()
{
    LOGS("DateIconLayoutHandler::setCalendarIconContent");
    if (mNumberLabel) {
        mNumberLabel->setPlainText(QString::number(QDateTime::currentDateTime().date().day(), 10));
    }
    if (mMonthLabel) {
        mMonthLabel->setPlainText(QLocale::system().monthName(
            QDateTime::currentDateTime().date().month()));
    }
}

/*
 * DateIconLayoutHandler::launchCalendarMonthView()
 */
void DateIconLayoutHandler::launchCalendarMonthView()
{
    LOGS("DateIconLayoutHandler::launchCalendarMonthView");

    QString interface("calendar.Launch");
    QString service("com.nokia.services");
    QString method("launchCalendarApp(QDateTime,int)");

    XQApplicationManager aiwMgr;
    XQAiwRequest* request = aiwMgr.create(service, interface, method, false);
    if (request == NULL)
        {
        return;
        }

    // Connect result handling signal
    connect(request, SIGNAL(requestOk(const QVariant&)), this, SLOT(handleOk(const QVariant&)));
    // Connect error handling signal or apply lastError function instead.
    connect(request, SIGNAL(requestError(int,const QString&)), this, SLOT(handleError(int,const QString&)));

    QList<QVariant> args;
    //if there are no elements in the calendar open the current day view
    QDateTime currentDate = QDateTime::currentDateTime();
    args << currentDate;

    int viewId = 0;
    args << viewId;

    // Set function parameters
    request->setArguments(args);

    // Send the request
    bool res = request->send();
    if (!res) {
        // Request failed.
        int error = request->lastError();
        // Handle error
    }

    // All done.
    delete request;
}

/*
 * DateIconLayoutHandler::handleOk()
 */
void DateIconLayoutHandler::handleOk(const QVariant& var)
{
    Q_UNUSED(var);
    LOGS("DateIconLayoutHandler::handleOk");
    mTestResult = 0;
    emit requestComplete();
}

/*
 * DateIconLayoutHandler::handleError()
 */
void DateIconLayoutHandler::handleError(int err, const QString& str)
{
    Q_UNUSED(str);
    LOGS("ContentLayoutHandler::handleError");
    mTestResult = err;
    emit requestError();
}

/*
 * TEST Functions
 */

/*
 * DateIconLayoutHandler::testId()
 */
int DateIconLayoutHandler::testId()
{
    return mTestID;
}

/*
 * DateIconLayoutHandler::setTestId()
 */
void DateIconLayoutHandler::setTestId(int testID)
{
    mTestID = testID;
}

int DateIconLayoutHandler::testResult()
{
    return mTestResult;
}

void DateIconLayoutHandler::setTestResult(int testResult)
{
    mTestResult = testResult;
}

//End of file

