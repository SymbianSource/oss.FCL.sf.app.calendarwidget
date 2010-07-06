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

#ifndef MAINLAYOUTHANDLER_H_
#define MAINLAYOUTHANDLER_H_

// System includes
#include <QObject>
#include <QGraphicsLinearLayout>

class HbDocumentLoader;
class HbLabel;
class HbWidget;
class HbFrameItem;

class MainLayoutHandler : public QObject, public QGraphicsLinearLayout
{
    Q_OBJECT

public:
    MainLayoutHandler();
    ~MainLayoutHandler();

public slots:
    void initializeLayout(const HbDocumentLoader &layoutLoader, QObject *owner);
    void updateLayout();
    void onThemeChange();

private:
    HbWidget* mWidget;

    //separator
    HbLabel* mSeparatorLabel;

    //to paint icon and widget background
    HbFrameItem* mIconLayoutItem;
    HbFrameItem* mBackgroundLayoutItem;
    HbFrameItem* mSeparatorLayoutItem;

};

#endif // MAINLAYOUTHANDLER_H_
