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

#ifndef DATEICONLAYOUTHANDLER_H
#define DATEICONLAYOUTHANDLER_H

// System includes
#include <QObject>

// Forward declarations
class HbLabel;
class HbFrameDrawer;
class HbWidget;
class QTimer;
class QPointF;
class XQServiceRequest;
class DateTimeObserver;
class TestDateIconLayoutHandler;
class HbDocumentLoader;

// Class declaration
class DateIconLayoutHandler: public QObject
{
    Q_OBJECT
    Q_PROPERTY(int testID READ testId WRITE setTestId)
    Q_PROPERTY(int testResult READ testResult WRITE setTestResult)

public:
    DateIconLayoutHandler();
    ~DateIconLayoutHandler();

    //Test property functions
    int testId();
    void setTestId(int testID);
    int testResult();
    void setTestResult(int testResult);

signals:
    void dateChanged();
    void requestComplete();
    void requestError();

public slots:
    void initializeLayout(const HbDocumentLoader &layoutLoader, QObject *owner);
    void updateLayout();
    void onTap(QPointF &point); //TODO: change this with onGesture at some point
    void onThemeChange();
    void handleOk(const QVariant& var);
    void handleError(int err, const QString& str);

private:
    void setCalendarIconContent();
    void launchCalendarMonthView();
    void setLabelsColor();

private: // data
    Q_DISABLE_COPY(DateIconLayoutHandler)

    HbWidget* mWidget;

    // Labels (not owned)
    HbLabel* mNumberLabel;
    HbLabel* mMonthLabel;

    // Background drawer (not owned)
    HbFrameDrawer* mFrameDrawer;

    // Owned
    DateTimeObserver* mDateObserver;

    // Test variables
    int mTestID;
    int mTestResult;

    friend class TestDateIconLayoutHandler;
};

#endif // DATEICONLAYOUTHANDLER_H
