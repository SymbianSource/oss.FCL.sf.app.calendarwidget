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
#include <HbDocumentLoader>
#include <HbFrameDrawer>
#include <HbLabel>
#include <HbWidget>
#include <HbFrameItem>

// User includes
#include "mainlayouthandler.h"
#include "calendarwidgetdebug.h"

// Local constants
namespace
	{
    const char WIDGET[] = "CalendarWidget";
    const char *SEPARATOR_LABEL = "separatorLabel";
    const char *SEPARATOR_IMAGE_NAME = "qtg_graf_divider_v_thin";
    const char *BACKGROUND_IMAGE_NAME = "qtg_fr_hswidget_normal";
    const HbFrameDrawer::FrameType BACKGROUND_FRAME_TYPE = HbFrameDrawer::NinePieces;
    const HbFrameDrawer::FrameType SEPARATOR_FRAME_TYPE = HbFrameDrawer::OnePiece;
	} // namespace 

// ======== MEMBER FUNCTIONS ========

MainLayoutHandler::MainLayoutHandler()
        : mWidget(0),
          mSeparatorLabel(0),
          mIconLayoutItem(0),
          mBackgroundLayoutItem(0),
          mSeparatorLayoutItem(0)
{
    LOGS("MainLayoutHandler::MainLayoutHandler");
}

MainLayoutHandler::~MainLayoutHandler()
{
    LOGS("MainLayoutHandler::~MainLayoutHandler");
}

void MainLayoutHandler::initializeLayout(const HbDocumentLoader &layoutLoader, QObject *owner)
{
    LOGS("MainLayoutHandler::initializeLayout");
    setParent(owner);

    mWidget = (HbWidget*)layoutLoader.findWidget(WIDGET);
    mSeparatorLabel = qobject_cast<HbLabel*>(layoutLoader.findWidget(QString(SEPARATOR_LABEL)));

    // The rest of the initializion is pointless if loading of the main widget fails.
    if (!mWidget) {
        return;
    }

    addItem(mWidget);
    mWidget->setVisible(true);

    HbFrameDrawer* backgroundFrameDrawer = new HbFrameDrawer(BACKGROUND_IMAGE_NAME,
        BACKGROUND_FRAME_TYPE);
    mBackgroundLayoutItem = new HbFrameItem(backgroundFrameDrawer);
    mWidget->setBackgroundItem(mBackgroundLayoutItem);
    HbFrameDrawer* separatorFrameDrawer = new HbFrameDrawer(SEPARATOR_IMAGE_NAME,
        SEPARATOR_FRAME_TYPE);
    mSeparatorLayoutItem = new HbFrameItem(separatorFrameDrawer);
    mSeparatorLabel->setBackgroundItem(mSeparatorLayoutItem);

    setPreferredSize(mWidget->preferredSize());
}

void MainLayoutHandler::updateLayout()
{
    LOGS("MainLayoutHandler::updateLayout");
}

void MainLayoutHandler::onThemeChange()
{
    LOGS("MainLayoutHandler::onThemeChange");
    if (mBackgroundLayoutItem) {
        mBackgroundLayoutItem->frameDrawer().themeChanged();
    }
    if (mSeparatorLayoutItem) {
        mSeparatorLayoutItem->frameDrawer().themeChanged();
    }
}
