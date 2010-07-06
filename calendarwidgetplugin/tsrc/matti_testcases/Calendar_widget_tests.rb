#/*
#* Copyright (c) 2009 Nokia Corporation and/or its subsidiary(-ies).
#* All rights reserved.
#* This component and the accompanying materials are made available
#* under the terms of "Eclipse Public License v1.0"
#* which accompanies this distribution, and is available
#* at the URL "http://www.eclipse.org/legal/epl-v10.html".
#*
#* Initial Contributors:
#* Nokia Corporation - initial contribution.
#*
#* Contributors:
#*
#* Description: Calendar widget MATTI test cases
#*
#*/

# require needed Ruby, MATTI and Orbit files
require 'test/unit'
require 'matti'
require 'date'
#require 'parsedate'
#require 'OrbitBehaviours'
include MobyBase 
include MobyUtil
include MattiVerify 
@@z_index = ""

Parameter.instance.load_parameters_xml(File.expand_path(File.dirname(__FILE__)) + '/testdata/calendar_widget_test_script_parameters.xml') 
    
class TestClassCalendarWidget < Test::Unit::TestCase
    

##  def initialize (args)
##	super(args)
##	@sut = MATTI.sut(:Id => 'sut_s60_qt')
##	#@sut = MATTI.sut(:Id => 's60')
##	begin		
##		#check_phone_date
##		#check_phone_time
##		#if @sut.application.test_object_exists?("HbTextItem", {:text => 'Continue', :__timeout => 2})
##		#	@sut.application( :name => 'ftulanguage' ).HbTextItem(:text => 'Continue').tap
##		#end
##		#@sut.press_key(:kEnd)
##		@sut.application( :name => 'qttasserver' ).press_key(:kApp)
##	rescue Exception => ex
##		puts "INITIALIZE FAILED. ERROR:"
##		puts ex.message
##		puts "*************************"
##	end
##  end
  def initialize (args)
	super(args)
	# MANDATORY DEFINITION: Define device "suts" which are used in testing, remember defined [ut] name in matti_parameters.xml
	@sut = MATTI.sut(:Id => 'sut_s60_qt')
	#to see if there is some widgets on the screen
	retry_count = 0
	begin
		if @sut.application.test_object_exists?("HbTextItem", {:text => 'Continue', :__timeout => 2})
			@sut.application( :name => 'ftulanguage' ).HbTextItem(:text => 'Continue').tap
		end
		if @@z_index == ""
			@@z_index = -1
			begin
				if @sut.application(:name => 'hsapplication').test_object_exists?("HsDialerWidget", {:__timeout => 2})
				@@z_index += 1
				end
				if @sut.application(:name => 'hsapplication').test_object_exists?("HsClockWidget", {:__timeout => 2})
				@@z_index += 1
				end
				if @sut.application(:name => 'hsapplication').test_object_exists?("FtuHSWidget", {:__timeout => 2})
				@@z_index += 1
				end
			rescue
				retry
			end
		end
    rescue Exception => ex
		puts "INITIALIZE FAIL. Lets try again..."
		if retry_count <= 10
			retry_count = retry_count +1
			retry
		else
			puts "INITIALIZE FAILED. ERROR:"
			puts ex.message
			puts "*************************"
		end
	end
  #@real_phone_number = "02722990"
  #@widget_name = "Contact widget."
  #@@contact_array = Array.new() 
  end 
  
  def teardown
	puts "teardown actions"
	begin
		app = @sut.application.executable_name
		app_name = app.split(".exe")[0].to_s
		app_name = (app_name == 'tsapplication') ? 'hsapplication' : app_name
		if @sut.application(:name => app_name).test_object_exists?("HbIconItem", {:iconName => 'qtg_mono_applications_all', :__timeout => 2})
			navigate_to_first_homescreen
			if @sut.application(:name => app_name).test_object_exists?("HbWidget",{:name => 'CalendarWidget'}) then
				remove_calendar_widget_from_homescreen(0)
			end
			delete_calendar_events(@sut.application(:name => app_name))
		else
			app = @sut.application.executable_name
			app_name = app.split(".exe")[0].to_s
			app_name = (app_name == 'tsapplication') ? 'hsapplication' : app_name
			if @sut.application(:name => app_name).test_object_exists?("HbIconItem", {:iconName => 'qtg_mono_back', :__timeout => 2})
				@sut.application(:name => app_name).HbIconItem(:iconName => 'qtg_mono_back').tap
				sleep 2
			end
			app = @sut.application.executable_name
			app_name = app.split(".exe")[0].to_s
			app_name = (app_name == 'tsapplication') ? 'hsapplication' : app_name
			if @sut.application(:name => app_name).test_object_exists?("HbTextItem", {:text => 'Close', :__timeout => 2})
				@sut.application(:name => app_name).HbTextItem(:text => 'Close').tap
				sleep 1
			end
			app = @sut.application.executable_name
			app_name = app.split(".exe")[0].to_s
			app_name = (app_name == 'tsapplication') ? 'hsapplication' : app_name
			if @sut.application(:name => app_name).test_object_exists?("HbIconItem", {:iconName => 'qtg_mono_back', :__timeout => 2})
				@sut.application(:name => app_name).HbIconItem(:iconName => 'qtg_mono_back').tap
				sleep 2
			end
			app = @sut.application.executable_name
			app_name = app.split(".exe")[0].to_s
			app_name = (app_name == 'tsapplication') ? 'hsapplication' : app_name
			navigate_to_first_homescreen
			if @sut.application(:name => app_name).test_object_exists?("HbWidget",{:name => 'CalendarWidget'}) then
				remove_calendar_widget_from_homescreen(0)
			end
			delete_calendar_events(@sut.application(:name => app_name))
		end
	rescue Exception => ex
		puts "TEARDOWN FAILED. ERROR:"
		puts ex.message
		puts "*************************"
		begin
			#did MATTI found wrong application
			app = @sut.application.executable_name
			app_name = app.split(".exe")[0].to_s
			if app_name == 'tsapplication'
				puts "MATTI get wrong application in UI (" + app_name +"). Start rebooting...!!!!"
				@sut.reset
				puts "Reboot is done!!"
				app_name = @sut.application.executable_name.split(".exe")[0].to_s
				puts "Application on the screen is " + app_name
				#lets see that there is not any calendar widget on the homescreen
				navigate_to_first_homescreen
				if @sut.application(:name => app_name).test_object_exists?("HbWidget",{:name => 'CalendarWidget'}) then
					remove_calendar_widget_from_homescreen(0)
				end
				delete_calendar_events(@sut.application(:name => app_name))
			end
		rescue Exception => e
			puts "TEARDOWN BEGIN-RESCUE FAILED. ERROR:"
			puts e.message
			puts "*************************"
		end
	end		
	#begin
	#	navigate_to_first_homescreen
	#	if @sut.application(:name => 'hsapplication').test_object_exists?("HbWidget",{:name => 'CalendarWidget'}) then
	#		remove_calendar_widget_from_homescreen
	#	end
	#rescue
	#end 
	#delete_calendar_events(@sut.application(:name => 'hsapplication'))
  end # teardown
  
  def add_calendar_widget_to_homescreen(app, browse_to_list)
	#selects calendar widget from applications-menu and adds it to home screen
	#Lets calculate, how many application list items there is seen

	identificator = TestObjectIdentificator.new(:type => :HsListViewItem)
	xml =  app.HbListView( :name => 'allAppsListView' ).xml_data 
	element_set = xml.xpath( xpath = identificator.get_xpath_to_identify( xml ) ) 
	item_count = element_set.size
	#puts "item_count = ",item_count
	item_index = 4
	#lets check if calendar widget is visible on display. If not, we flick until we get it visible
	while item_index < item_count
		if app.test_object_exists?("HbTextItem",{:text => 'CalendarWidget',:visibleOnScreen => 'true'}) then
			#app.HbTextItem(:__index => item_index-1).tap_down
			#app.HbTextItem(:__index => item_index-1).flick(:Up)
			#app.HbListViewItem(:text => 'Bedrock').gesture(:Up,1,450,:Left,true)
			if browse_to_list == 'longpressHS' then
				app.HbTextItem(:text => 'CalendarWidget').tap
			else
				app.HbTextItem(:text => 'CalendarWidget').tap
				app.HbTextItem( :text => 'Add to Home screen' ).tap
				app.HbIconItem(:iconName => 'qtg_mono_back').tap
			end
			break
		else
			#app.HbTextItem(:__index => item_index-1).tap_down
			#app.HbListViewItem(:__index => item_index-1).flick(:Up)
			app.HsListViewItem(:__index => item_index-1).gesture(:Up,1,550,{:Left,true})
		end
		item_index +=2
		if item_index >= item_count then
			identificator = TestObjectIdentificator.new(:type => :HsListViewItem) 
			xml =  app.HbListView(:__index => 0).xml_data 
			element_set = xml.xpath( xpath = identificator.get_xpath_to_identify( xml ) ) 
			item_count = element_set.size
			#puts "item_count = ",item_count
			item_index = 4
		end
	end

	if browse_to_list != 'longpressHS' then
		app.HbIconItem(:iconName => 'qtg_mono_back').tap
	end
	#verify, that there exists calendar widget in homescreen
	#verify(){app.HbWidget( :name => 'CalendarWidget' )}
  end
  
    ########################################################################################################################################
	#
	#	remove_calendar_widget_from_homescreen
	#
	#	description:
	#		This function emoves calendar widget from homescreen
	#
	#	preconditions: 
	#		-Phone is in homescreen and there is calendar widget in HS
	#	parameters:
	#		hs_pagenumber:	Number of the homescreen page (0, 1 or 2)
	#
	#	created: Jarno Mäkelä
	#	creation date: 17-May-2010
	#
	########################################################################################################################################
	
  def remove_calendar_widget_from_homescreen(hs_pagenumber)
	app = @sut.application(:name => 'hsapplication')
	#verify(){@sut.application.HbIconItem(:iconName => 'hs_applib_button.png')}
	#verify(){app.HbWidget( :name => 'CalendarWidget' )}
	#find correct widget host object
	calendar_widget_object = app.HsPage(:__index => hs_pagenumber).find(:name => 'CalendarWidget')
	#app.HsPage(:__index => hs_pagenumber).HsWidgetHost.HsCalendarWidget.HbWidget( :name => 'CalendarWidget' ).tap_down
	calendar_widget_object.tap_down
	#app.HbWidget( :name => 'controlLayer' ).HsWidgetHost.HbWidget( :name => 'CalendarWidget' ).tap_down
	#app.HbWidget( :name => 'controlLayer' ).HsWidgetHost.HbWidget( :name => 'CalendarWidget' ).drag_to_object(app.HsTrashBinWidget( :name => 'trashBin' ))
	calendar_widget_object = app.HbWidget( :name => 'controlLayer' ).find(:name => 'CalendarWidget')
	calendar_widget_object.drag_to_object(app.HsTrashBinWidget( :name => 'trashBin' ))
  end
  
    ########################################################################################################################################
	#
	#	create_calendar_event
	#
	#	description:
	#		This function creates calendar event via fixture  
	#
	#	preconditions: 
	#
	#	parameters:
	#		-subject:			subject of the meeting
	#		-start_day:	    	start day of the meeting
	#		-start_month:		start month of the meeting
	#		-start_year:		start year of the meeting
	#		-start_hour:		start hour of the meeting
	#		-start_minute:		start minute of the meeting
	#		-duration_days: 	duration of the days, that meeting is lasting
	#		-duration_hours:	duration of the hours, that meeting is lasting
	#		-duration_minutes:	duration of the minutes, that meeting is lasting
	#
	#	return value:
	#		-time_to_verify:	time, that is supposed to be in the calendar widget (Format: hh:mm-hh:mm or hh:mm (am/pm)-hh:mm (am/pm))
	#
	#	created: Jarno Mäkelä
	#	creation date: 17-May-2010
	#
	########################################################################################################################################
	
  def create_calendar_event(app, subject,start_day, start_month, start_year, start_hour, start_minute, duration_days, duration_hours, duration_minutes)
	#Creates calendar event
	#let's calculate the real values of start date. In parameters, eg. the day value can exceed 31, so we need to change month and set day
	#to 1. Same calculation needed for other parameter values
	start_date = calculate_date(start_day, start_month, start_year, start_hour, start_minute)
	puts "start_date:",start_date.to_s
	start_time_split = (start_date.to_s).split
	start_time = start_time_split[1]
	start_time_to_verify = start_time[0..4]
	puts "start_time_to_verify:",start_time_to_verify
	end_date = calculate_date(start_day+duration_days, start_month, start_year, start_hour+duration_hours, start_minute+duration_minutes)
	puts "end_date:",end_date.to_s
	end_time_split = (end_date.to_s).split
	end_time = end_time_split[1]
	end_time_to_verify = end_time[0..4]
	puts "end_time_to_verify:",end_time_to_verify
	if @hourformat_12 == true then
		#12 hour time used
		time_to_verify = convert_time_to_12hour_format(start_time_to_verify)+'-'+convert_time_to_12hour_format(end_time_to_verify)
	else
		#24 hour time used
		time_to_verify = start_time_to_verify+'-'+end_time_to_verify
	end
	tmp_id = app.id
	tmp = @sut.execution_order
	@sut.execution_order = ['S60']
	app.apply_behaviour!( :name => 'S60Fixture' )
	app.set_application_id(app.attribute('applicationUid'));
	response = app.fixture('tapi_calendar_fixture', 'add_meeting', {:description =>  subject, :start_date => start_date, :end_date => end_date})
	@sut.execution_order = tmp
	app.apply_behaviour!( :name => 'QtFixture' ) 
	app.set_application_id(tmp_id)
	response
	#let's put date if event is in other future day than today
	if start_day > @day.to_i then
	   start_date = start_time_split[0]
	   month_text = case start_date[3..4]
			when "01" then "Jan"
			when "02" then "Feb"
			when "03" then "Mar"
			when "04" then "Apr"
			when "05" then "May"
			when "06" then "Jun"
			when "07" then "Jul"
			when "08" then "Aug"
			when "09" then "Sep"
			when "10" then "Oct"
			when "11" then "Nov"
			when "12" then "Dec"
		end
		puts "time_to_verify:", start_date[0..1]+' '+month_text+' '+time_to_verify
		return start_date[0..1]+' '+month_text+' '+time_to_verify
	else
		puts "time_to_verify:", time_to_verify
		return time_to_verify
	end
	#sut = MATTI.sut(:Id => 's60')
	#app = sut.run(:name => "HtiAdmin.exe")
	#app.fixture('tapi_calendar_fixture', 'add_meeting', {:description =>  subject, :start_date => '17-05-2010 15:00:00', :end_date => '17-05-2010 16:00:00'})
	#app.fixture('tapi_calendar_fixture', 'add_meeting', {:description =>  subject, :start_date => start_date, :end_date => end_date})
	#app.close()
  end
  
    ########################################################################################################################################
	#
	#	convert_time_to_12hour_format
	#
	#	description:
	#		This function converts 24 hour time to 12 hour time format
	#
	#	preconditions: 
	#
	#	parameters:
	#		-conv_timestr:				time string that is needed to convert
	#
	#	return value:
	#		correctly converted time string
	#
	#	created: Jarno Mäkelä
	#	creation date: 25-May-2010
	#
	########################################################################################################################################
	
  def convert_time_to_12hour_format(conv_timestr)
	#let's first check the hour
	hour = conv_timestr[0..1].to_i
	#puts "hour:", hour
	if hour >= 12 then
		if hour == 12 then
			return hour.to_s+':'+conv_timestr[3..4]+' pm'
		else
			hour = hour -12
			if hour < 10 then
				return '0'+hour.to_s+':'+conv_timestr[3..4]+' pm'
			else
				return hour.to_s+':'+conv_timestr[3..4]+' pm'
			end
		end
	else
		if hour == 0 then
			hour = 12
			return hour.to_s+':'+conv_timestr[3..4]+' am'
		elsif hour < 10 then
			return '0'+hour.to_s+':'+conv_timestr[3..4]+' am'
		else
			return hour.to_s+':'+conv_timestr[3..4]+' am'
		end
	end
  end
  
    ########################################################################################################################################
	#
	#	delete_calendar_events
	#
	#	description:
	#		This function deletes all calendar events via fixture  
	#
	#	preconditions: 
	#
	#	parameters:
	#		-app:				application needed
	#
	#	created: Jarno Mäkelä
	#	creation date: 19-May-2010
	#
	########################################################################################################################################
	
  def delete_calendar_events(app)
	tmp_id = app.id
	tmp = @sut.execution_order
	@sut.execution_order = ['S60']
	app.apply_behaviour!( :name => 'S60Fixture' )
	app.set_application_id(app.attribute('applicationUid'));
	response = app.fixture('tapi_calendar_fixture', 'delete_all', {})
	@sut.execution_order = tmp
	app.apply_behaviour!( :name => 'QtFixture' ) 
	app.set_application_id(tmp_id)
	response
  end
  
  def create_calendar_event_via_calendar(subject)
	#Creates calendar event
	cal_app = @sut.run(:name => "calendar.exe")
	cal_app.HbIconItem(:iconName => 'qtg_mono_options_menu').tap
	cal_app.HbTextItem(:text => 'New event')
	#Add the subject
	cal_app.HbDataFormViewItem(:__index =>0).HbWidget.tap
	cal_app.HbDataFormViewItem(:__index =>0).HbWidget.type_text(subject)
	cal_app.HbTextItem(:text => 'Subject').tap
	#Add start time
	cal_app.CalenEditorCustomItem(:__index=>0).HbWidget.HbPushButton(:__index=>0).tap
	
  end
  
    ########################################################################################################################################
	#
	#	check_phone_date
	#
	#	description:
	#		This function checks the date of phone 
	#
	#	preconditions: 
	#
	#	parameters:
	#		
	#
	#	created: Jarno Mäkelä
	#	creation date: 18-May-2010
	#
	########################################################################################################################################
	
  def check_phone_date
	#Temporarily lets assume, that phone date is same as current real time, since clock application crashes in phone
	clock_app = @sut.run(:name => "clock.exe")
	date = clock_app.HbLabel( :name => 'dateLabel' ).HbTextItem.attribute("text")
	#date = Time.now
	puts "date is: ",date
	#parse day,month and year
	@day = date[4..5]
	#@day = (date.day).to_s
	#if @day.to_i < 10 then
		#@day = '0'+ (date.day).to_s
	#end
	puts "day:", @day
	@month = date[7..8]
	#@month = (date.month).to_s
	#if @month.to_i < 10 then
	#	@month = '0'+ (date.month).to_s
	#end
	puts "month:", @month
	@year = date[10..13]
	#@year = (date.year).to_s
	puts "year:",@year
	clock_app.close
  end
  
    ########################################################################################################################################
	#
	#	check_phone_time
	#
	#	description:
	#		This function checks the time of phone 
	#
	#	preconditions: 
	#
	#	parameters:
	#		
	#
	#	created: Jarno Mäkelä
	#	creation date: 18-May-2010
	#
	########################################################################################################################################
	
  def check_phone_time
	app = @sut.application(:name => 'hsapplication')
	time = app.HbStatusBar.HbTextItem.attribute("text")
	puts "time is: ",time
	#parse hour and minute
	@hour = time[0..1]
	temp_hour = @hour.to_i
	if time.index('pm') != nil
		if temp_hour != 12 then
			temp_hour = temp_hour +12
		end
	end
	if time.index('am') != nil || time.index('pm') != nil then
		@hourformat_12 = true
	else
		@hourformat_12 = false
	end
	@hour = temp_hour.to_s
	puts "hour:", @hour
	@minute = time[3..4]
	puts "minute:", @minute
  end
  
    ########################################################################################################################################
	#
	#	calculate_date
	#
	#	description:
	#		This function calculates the correct date from unchecked date values
	#
	#	preconditions: 
	#
	#	parameters:
	#		-day: 		unhandled day value
	#		-month:		unhandled month value
	#		-year: 		unhandled year value
	#		-hour: 		unhandled hour value
	#		-minute: 	unhandled minute value
	#
	#	return value:
	#		handled date string in fixture needed format (dd-mm-yyyy hh:mm:00)
	#
	#	created: Jarno Mäkelä
	#	creation date: 18-May-2010
	#
	########################################################################################################################################
	
  def calculate_date(day, month, year, hour, minute)
	#let's check the minute
	if(minute >=60) then
		minute = minute - 60
		hour= hour +1
	end
	if(hour >=24) then
		hour = hour - 24
		day = day +1
	end
	if(day > 31) then
		if(month == 1)||(month == 3)||(month == 5)||(month == 7)||(month == 8)||(month == 10)||(month == 12) then
			month = month +1
			day = day - 31
		elsif(month == 4)||(month == 6)||(month == 9)||(month == 11) then
			month = month +1
			day = day - 30
		elsif(month == 2) then
			if ( year % 100 != 0 && year % 4 == 0 || year % 400 == 0 ) then
				month = month +1
				day = day -29
			else
				month = month +1
				day = day - 28
			end
		end
	end
	if(month > 12) then
		month = month - 12
		year = year +1
	end
	if(day <10) then
		returnday = '0'+day.to_s
	else
		returnday = day.to_s
	end
	if(month < 10) then
		returnmonth = '0' + month.to_s
	else
		returnmonth = month.to_s
	end
	if(minute < 10) then
		returnminute = '0'+minute.to_s
	else
		returnminute = minute.to_s
	end
	if(hour < 10) then
		returnhour = '0'+hour.to_s
	else
		returnhour = hour.to_s
	end
	
	return returnday,'-',returnmonth,'-',year.to_s,' ',returnhour,':',returnminute,':00'
	
  end
  
    ########################################################################################################################################
	#
	#	navigate_to_first_homescreen
	#
	#	description:
	#		This function goes to first homescreen page from anywhere of homescreen pages
	#
	#	preconditions: 
	#		-Phone is in homescreen
	#	parameters:
	#		None
	#
	#	created: Jarno Mäkelä
	#	creation date: 02-Jun-2010
	#
	########################################################################################################################################
	
  def navigate_to_first_homescreen
	app = @sut.application(:name => 'hsapplication')
	if app.HsPageIndicatorItem(:__index =>0).test_object_exists?("HbIconItem",{:iconName => 'qtg_graf_hspage_highlight'}) then
		page = 1
	elsif app.HsPageIndicatorItem(:__index =>1).test_object_exists?("HbIconItem",{:iconName => 'qtg_graf_hspage_highlight'}) then
		page = 2
		app.HsPageIndicatorItem(:__index =>1).gesture(:Right,1,170)
		if app.HsPageIndicatorItem(:__index =>0).test_object_exists?("HbIconItem",{:iconName => 'qtg_graf_hspage_highlight'}) then
			page = 1
		else
			raise VerificationError ,"ERROR: Cannot go to first home screen", caller
		end
	else
		page = 3
		app.HsPageIndicatorItem(:__index =>1).gesture(:Right,1,170)
		sleep 1
		app.HsPageIndicatorItem(:__index =>1).gesture(:Right,1,170)
		if app.HsPageIndicatorItem(:__index =>0).test_object_exists?("HbIconItem",{:iconName => 'qtg_graf_hspage_highlight'}) then
			page = 1
		else
			raise VerificationError ,"ERROR: Cannot go to first home screen", caller
		end
	end
  end
################################################################################################################################################
###
###						BAT cases start
###
################################################################################################################################################
  
  ##############################################################################################################################################
  # Calendar widget - Load-Unload widget in HomeScreen 
  ##############################################################################################################################################
  #
  # Purpose of the test is to check, that calendar widget can be load to Homescreen and unload from Homescreen
  #
  #	Created at: 17.05.2010
  #	Created by: Jarno Mäkelä
  #	Reviewed by: 
  #
  #	===	preconditions
  #	- Device is in Home Screen
  # - Some events in Calendar.
  #
  #	===	params
  #	none
  #
  ############################################################################################################################################
  
  def _test_calendar_widget_load_unload_widget_in_HomeScreen
	#running_round = 1
	#max_running_rounds = 2
	#begin
		#Preconditions:
		#Device is in Homescreen
		app = @sut.application(:name => 'hsapplication')
		navigate_to_first_homescreen
		verify(){app.HbIconItem(:iconName => 'qtg_mono_applications_all')}
		#Some events in calendar
		check_phone_date
		check_phone_time
		create_calendar_event(app, 'Meeting 1',@day.to_i+1,@month.to_i,@year.to_i,@hour.to_i+1,@minute.to_i,0,1,0)
		create_calendar_event(app, 'Meeting 2',@day.to_i+2,@month.to_i,@year.to_i,@hour.to_i-2,@minute.to_i,0,1,0)
		#Step 1:Tap application list button in the upper right corner of Home Screen
		app.HbIconItem(:iconName => 'qtg_mono_applications_all').tap
		#step 2: Select 'add to homescreen' by longpressing 'Calendar Widget' in the catalog list
		add_calendar_widget_to_homescreen(app,'AppListButton')
		#step 2 expected: Calendar widget is added to Home Screen.
		day_to_verify = @day.to_i
		#puts "day_to_verify =", day_to_verify
		verify(){app.HbTextItem(:text => day_to_verify)}
		#Calendar widget content contains "No event for next 7 days"
		#verify(){app.HbTextItem(:text => 'No events for next 7 days')}
		#Verify, that reminder icon in widget is not shown
		#if not(app.test_object_exists?("HbIconItem",{:iconName => 'images/bell.PNG'})) then
		#	raise VerificationError ,"ERROR: There is not reminder icon in calendar widget, when it should be there", caller
		#end
		#Step 3 and Step4:Remove calendar widget from display
		remove_calendar_widget_from_homescreen(0)
		delete_calendar_events(app)
	#rescue
	#	if (running_round < max_running_rounds) then
    #       running_round = running_round + 1
    #        puts "Some error came during run. Lets try again"
    #        teardown
	#		retry
    #    else
    #        puts "Test failed"
    #        raise
    #    end
	#end #rescue	
  end
  
  ##############################################################################################################################################
  # Calendar widget - One all day event and one other timed event overlapping 
  ##############################################################################################################################################
  #
  # Purpose of this test case ist to verify that "overlapping events" information will be shown on widget, when there is one all day event and 
  # one timed event overlapping. Also when removing timed event, only all dau event is shown in calendar widget
  #
  #	Created at: 17.05.2010
  #	Created by: Jarno Mäkelä
  #	Reviewed by: 
  #
  #	===	preconditions
  #	- Device is in Home Screen.
  # - Calendar widget is added to Home Screen.
  # - One all day event and one timed event happens few hours after current phone time at today in Calendar.
  #
  #	===	params
  #	none
  #
  ############################################################################################################################################
  
  def _test_calendar_widget_one_all_day_event_and_one_other_timed_event_overlapping
	
  end
  
  ##############################################################################################################################################
  # Calendar widget - one event today, one event tomorrow 
  ##############################################################################################################################################
  #
  # Purpose of the test is to check, that when there is one event today and one event tomorrow, calendar widget shows only the today's event.
  #
  #	Created at: 17.05.2010
  #	Created by: Jarno Mäkelä
  #	Reviewed by: 
  #
  #	===	preconditions
  #	- Device is in Home Screen.
  # - Calendar widget is added to Home Screen.
  # - One event happens few hours after current phone time at today and one event at tomorrow in Calendar.
  #
  #	===	params
  #	none
  #
  ############################################################################################################################################
  
  def _test_calendar_widget_one_event_today_one_event_tomorrow
	#running_round = 1
	#max_running_rounds = 2
	#begin
		#Preconditions:
		#Device is in Homescreen
		app = @sut.application(:name => 'hsapplication')
		verify(){app.HbIconItem(:iconName => 'qtg_mono_applications_all')}
		navigate_to_first_homescreen
		#- One event happens few hours after current phone time at today and one event at tomorrow in Calendar.
		check_phone_date
		check_phone_time
		today_time_for_verification = create_calendar_event(app, 'Today meeting',@day.to_i,@month.to_i,@year.to_i,@hour.to_i+3,@minute.to_i,0,1,0)
		tomorrow_time_for_verification = create_calendar_event(app, 'Tomorrow meeting',@day.to_i+1,@month.to_i,@year.to_i,@hour.to_i,@minute.to_i,0,1,0)
		#-Calendar widget is added to Home Screen.
		#Not adding calendar widget, if it already exists there
		if not(app.test_object_exists?("HbWidget",{:name => 'CalendarWidget'})) then
			#add calendar widget to home screen
			app.HbIconItem(:iconName => 'qtg_mono_applications_all').tap
			add_calendar_widget_to_homescreen(app,'AppListButton')
		end
		#Step 1:Check Calendar widget.
		#app.HbIconItem(:iconName => 'qtg_mono_applications_all').tap
		#step 1 Expected: - All icons (widget icon and reminder icon) are shown correctly.
		#- Only today event is shown in widget as two rows: first row shows the event time and second row shows the event title.
		day_to_verify = @day.to_i
		verify(){app.HbTextItem(:text => day_to_verify)}
		verify(){app.HbLabel( :name => 'upperLabel' ).HbTextItem( :text => today_time_for_verification )}
		verify(){app.HbLabel( :name => 'lowerLabel' ).HbTextItem( :text => 'Today meeting' )}
		#Verify, that reminder icon in widget is shown
		#cannot verify yet, since with calendar fixture only events, that has no reminder, are possible to create
		#if not(app.test_object_exists?("HbIconItem",{:iconName => 'images/bell.PNG'})) then
		#	raise VerificationError ,"ERROR: There is not reminder icon in calendar widget, when it should be there", caller
		#end
		
		remove_calendar_widget_from_homescreen(0)
		delete_calendar_events(app)
	#rescue
	#	if (running_round < max_running_rounds) then
    #       running_round = running_round + 1
    #       puts "Some error came during run. Lets try again"
    #       teardown
	#       retry
    #    else
    #       puts "Test failed"
    #       raise
    #    end
	#end #rescue	
  end
  
  ##############################################################################################################################################
  # Calendar widget - Overlapping events
  ##############################################################################################################################################
  #
  # Purpose of the test is to check, that when there are overlapping events, there comes information about that in calendar widget and 
  # when tapping the events, phone goes to calendar agenda view.
  #
  #	Created at: 17.05.2010
  #	Created by: Jarno Mäkelä
  #	Reviewed by: 
  #
  #	===	preconditions
  #	- Device is in Home Screen.
  # - Calendar widget is added to Home Screen.
  # - One event happens few hours after current phone time at today in Calendar.
  #
  #	===	params
  #	none
  #
  ############################################################################################################################################
  
  def _test_calendar_widget_overlapping_events
	running_round = 1
	max_running_rounds = 2
	begin
		#Preconditions:
		#Device is in Homescreen
		app = @sut.application(:name => 'hsapplication')
		verify(){app.HbIconItem(:iconName => 'qtg_mono_applications_all')}
		navigate_to_first_homescreen
		#- One event happens few hours after current phone time at today in Calendar.
		check_phone_date
		check_phone_time
		today_time_for_verification = create_calendar_event(app, 'Today meeting',@day.to_i,@month.to_i,@year.to_i,@hour.to_i+3,@minute.to_i,0,1,0)
		#-Calendar widget is added to Home Screen.
		#Not adding calendar widget, if it already exists there
		if not(app.test_object_exists?("HbWidget",{:name => 'CalendarWidget'})) then
			#add calendar widget to home screen
			app.HbIconItem(:iconName => 'qtg_mono_applications_all').tap
			add_calendar_widget_to_homescreen(app,'AppListButton')
		end
		#Step 1:Check Calendar widget.
		#step 1 Expected: - All icons (widget icon and reminder icon) are shown correctly.
		#- Calendar widget shows the event as two rows: first row show the event time and second row shows the event title.
		day_to_verify = @day.to_i
		verify(){app.HbTextItem(:text => day_to_verify)}
		verify(){app.HbLabel( :name => 'upperLabel' ).HbTextItem( :text => today_time_for_verification )}
		verify(){app.HbLabel( :name => 'lowerLabel' ).HbTextItem( :text => 'Today meeting' )}
		#Verify, that reminder icon in widget is shown
		#if not(app.test_object_exists?("HbIconItem",{:iconName => 'images/bell.PNG'})) then
		#	raise VerificationError ,"ERROR: There is not reminder icon in calendar widget, when it should be there", caller
		#end
		
		#Step 2:Create another event overlapping the first event in Calendar.
		another_time_for_verification = create_calendar_event(app, 'Another today meeting',@day.to_i,@month.to_i,@year.to_i,@hour.to_i+3,@minute.to_i+15,0,1,0)
		#Step 3:Return to Home Screen and check Calendar widget.
		#Step 3 Expected: - All icons (widget icon and reminder icon) are shown correctly.
		#- Calendar widget shows the overlapping information as two rows: first row shows overlapping time and second row shows  text 
		#'2 events overlapping'.
		if @hourformat_12 == true then
			overlapping_time_for_verification = today_time_for_verification[0..7]+'-'+another_time_for_verification[9..16]
		else
			overlapping_time_for_verification = today_time_for_verification[0..4]+'-'+another_time_for_verification[6..10]
		end
		puts "overlapping_time_for_verification: ",overlapping_time_for_verification
		verify(){app.HbLabel( :name => 'upperLabel' ).HbTextItem( :text => overlapping_time_for_verification )}
		verify(){app.HbLabel( :name => 'lowerLabel' ).HbTextItem( :text => '2 events overlapping' )}
		#Step 4: Tap the overlapping events part in calendar view
		app.HbLabel( :name => 'lowerLabel' ).HbTextItem( :text => '2 events overlapping' ).tap
		#Step 4 Expected: - Phone goes to calendar agenda view with  all events visible.
		#ToDo
		# - The date is same as the event date.
		#ToDo
		remove_calendar_widget_from_homescreen(0)
		delete_calendar_events(app)
	rescue
		if (running_round < max_running_rounds) then
           running_round = running_round + 1
           puts "Some error came during run. Lets try again"
           teardown
	       retry
        else
           puts "Test failed"
           raise
        end
	end #rescue	
  end
  
  ##############################################################################################################################################
  # Calendar widget - Tapping upcoming event
  ##############################################################################################################################################
  #
  # Purpose of the test is to check, that when tapping upcoming event in calendar widget, calendar agenda view is opened in calendar.
  #
  #	Created at: 17.05.2010
  #	Created by: Jarno Mäkelä
  #	Reviewed by: 
  #
  #	===	preconditions
  #	- Device is in Home Screen.
  # - Some events are created in Calendar.
  # - Calendar widget is added to Home Screen.
  #
  #	===	params
  #	none
  #
  ############################################################################################################################################
  
  def _test_calendar_widget_tapping_upcoming_event
	
  end
  
  ##############################################################################################################################################
  # Calendar widget - no events
  ##############################################################################################################################################
  #
  # Purpose of the test is to check, that when there are not any events in calendar, calendar widget shows text 'No event for next 7 days'
  #
  #	Created at: 10.03.2010
  #	Created by: Jarno Mäkelä
  #	Reviewed by: 
  #
  #	===	preconditions
  #	- Device is in Home Screen.
  # - Calendar widget is added to Home Screen.
  # - No any events in Calendar.
  #
  #	===	params
  #	none
  #
  ############################################################################################################################################
  
  def test_calendar_widget_no_events
	#running_round = 1
	#max_running_rounds = 2
	#begin
		#preconditions:
		#-Device is in Home Screen
		app = @sut.application(:name => 'hsapplication')
		#verify(){@sut.application(:name => 'hsapplication').HbIconItem(:iconName => 'qtg_mono_applications_all')}
		verify(){app.HbIconItem(:iconName => 'qtg_mono_applications_all')}
		navigate_to_first_homescreen
		#-Calendar widget is added to Home Screen.
		#Not adding calendar widget, if it already exists there
		if not(app.test_object_exists?("HbWidget",{:name => 'CalendarWidget'})) then
			#add calendar widget to home screen
			app.HbIconItem(:iconName => 'qtg_mono_applications_all').tap
			add_calendar_widget_to_homescreen(app,'AppListButton')
		end
		#ToDo:Checking, that there are no events in calendar
	
		#step 1: Check Calendar widget
		#Verify, that calendar widget shows current date
		check_phone_date
		month_in_view = case @month
			when "01" then "January"
			when "02" then "February"
			when "03" then "March"
			when "04" then "April"
			when "05" then "May"
			when "06" then "June"
			when "07" then "July"
			when "08" then "August"
			when "09" then "September"
			when "10" then "October"
			when "11" then "November"
			when "12" then "December"
		end
		day_to_verify = @day.to_i
		verify(){app.HbTextItem(:text => day_to_verify)}
		verify(){app.HbTextItem(:text => month_in_view)}
		#Calendar widget content contains "No event for next 7 days"
		verify(){app.HbTextItem(:text => 'No calendar entries today or next 7 days')}
	
		#Verify, that reminder icon in widget is not shown
		if (app.test_object_exists?("HbIconItem",{:iconName => 'images/bell.PNG'})) then
			raise VerificationError ,"ERROR: There is reminder icon in calendar widget, when it should not be there", caller
		end
		#Remove calendar widget from display
		remove_calendar_widget_from_homescreen(0)
	#rescue
	#	if (running_round < max_running_rounds) then
    #       running_round = running_round + 1
    #       puts "Some error came during run. Lets try again"
    #       teardown
	#       retry
    #    else
    #       puts "Test failed"
    #       raise
    #    end
	#end #rescue			
  end #test_calendar_widget_no_events

  def _test_create_meeting
	create_calendar_event_via_calendar('Meeting 1')
  end

################################################################################################################################################
###
###						BAT cases end. User story related FuTe cases start
###
################################################################################################################################################

  ##############################################################################################################################################
  # test_calendar_widget_One_upcoming_event_in_7_day_away_and_one_in_8_day_away
  ##############################################################################################################################################
  #
  # Purpose of the test is to check, that event, that is in 7 day away, can be seen in calendar widget, but event, that is 8 days away 
  # cannot be seen in calendar widget.
  #
  #	Created at: 04.06.2010
  #	Created by: Jarno Mäkelä
  #	Reviewed by: 
  #
  #	===	preconditions
  #	- Device is in Home Screen.
  # - Calendar widget is added to Home Screen.
  # - One event at 7 days away and one event at 8 days away in Calendar.
  #
  #	===	params
  #	none
  #
  ############################################################################################################################################
  
  def _test_calendar_widget_One_upcoming_event_in_7_day_away_and_one_in_8_day_away
	#running_round = 1
	#max_running_rounds = 2
	#begin
		#preconditions:
		#-Device is in Home Screen
		app = @sut.application(:name => 'hsapplication')
		verify(){app.HbIconItem(:iconName => 'qtg_mono_applications_all')}
		navigate_to_first_homescreen
		#-One event at 7 days away and one event at 8 days away in Calendar
		check_phone_date
		check_phone_time
		seventh_day_time_for_verification = create_calendar_event(app, '7th day meeting',@day.to_i+7,@month.to_i,@year.to_i,@hour.to_i,@minute.to_i,0,1,0)
		eight_day_time_for_verification = create_calendar_event(app, '8th day meeting',@day.to_i+8,@month.to_i,@year.to_i,@hour.to_i,@minute.to_i,0,1,0)
		#-Calendar widget is added to Home Screen.
		#Not adding calendar widget, if it already exists there
		if not(app.test_object_exists?("HbWidget",{:name => 'CalendarWidget'})) then
			#add calendar widget to home screen
			app.HbIconItem(:iconName => 'qtg_mono_applications_all').tap
			add_calendar_widget_to_homescreen(app,'AppListButton')
		end
		#step 1: Check Calendar widget
		#step 1 expected:
		#- All icons (widget icon and reminder icon) are shown correctly.
		#Verify, that reminder icon in widget is not shown. Cannot be verified currently, since fixture creating calendar event does not 
		#have reminders
		#if not(app.test_object_exists?("HbIconItem",{:iconName => 'images/bell.PNG'})) then
		#	raise VerificationError ,"ERROR: There is not reminder icon in calendar widget, when it should not be there", caller
		#end
		#- Only event at 7 days away is shown in widget as two rows: first row shows the event date and title, second row shows the text 'No calendar entries today'.
		#Verify, that calendar widget shows current date
		month_in_view = case @month
			when 1 then "January"
			when 2 then "February"
			when 3 then "March"
			when 4 then "April"
			when 5 then "May"
			when 6 then "June"
			when 7 then "July"
			when 8 then "August"
			when 9 then "September"
			when 10 then "October"
			when 11 then "November"
			when 12 then "December"
		end
		day_to_verify = @day.to_i
		verify(){app.HbTextItem(:text => day_to_verify)}
		verify(){app.HbTextItem(:text => month_in_view)}
		#- Only event at 7 days away is shown in widget as two rows: first row shows the event date and title, second row shows the text 'No calendar entries today'.
		seventh_date_for_verification = verify(){app.HbLabel( :name => 'upperLabel' ).HbTextItem( :text => seventh_day_time_for_verification+' 7th day meeting' )}
		#Remove calendar widget from display
		#remove_calendar_widget_from_homescreen(0)
	#rescue
	#	if (running_round < max_running_rounds) then
    #       running_round = running_round + 1
    #       puts "Some error came during run. Lets try again"
    #       teardown
	#       retry
    #    else
    #       puts "Test failed"
    #       raise
    #    end
	#end #rescue			
  end #test_calendar_widget_One_upcoming_event_in_7_day_away_and_one_in_8_day_away

################################################################################################################################################
###
###						User story related FuTe cases cases end. NFT cases start
###
################################################################################################################################################

  ##############################################################################################################################################
  # Calendar widget - NFT - Switch between HS and application library 50 times
  ##############################################################################################################################################
  #
  # The purpose of this test is to verify that calendar widget is shown properly under stress. Calendar widget set on every HS, switch between 
  # application library and HS 50 times. After this verify that calendar widget is functioning properly.
  #
  #	Created at: 28.05.2010
  #	Created by: Jarno Mäkelä
  #	Reviewed by: 
  #
  #	===	preconditions
  #	- Device is in Home Screen.
  # - Some events in Calendar.
  # - Calendar widget is added to every Home screen.
  #
  #	===	params
  #	none
  #
  ############################################################################################################################################
  
  def _test_Calendar_widget_NFT_Switch_between_HS_and_application_library_50_times
	#running_round = 1
	#max_running_rounds = 2
	#begin
		#preconditions:
		#-Device is in Home Screen
		app = @sut.application(:name => 'hsapplication')
		#- Some events in Calendar.
		check_phone_date
		check_phone_time
		today_time_for_verification = create_calendar_event(app, 'Today meeting',@day.to_i,@month.to_i,@year.to_i,@hour.to_i+3,@minute.to_i,0,1,0)
		tomorrow_time_for_verification = create_calendar_event(app, 'Tomorrow meeting',@day.to_i+1,@month.to_i,@year.to_i,@hour.to_i,@minute.to_i,0,1,0)
		day_after_tomorrow_time_for_verification = create_calendar_event(app, 'Day after tomorrow meeting',@day.to_i+2,@month.to_i,@year.to_i,@hour.to_i+2,@minute.to_i,0,2,0)
		# - Calendar widget is added to every Home screen.
		#let's first navigate to first home screen
		navigate_to_first_homescreen
		#add calendar widget to first home screen
		app.HbIconItem(:iconName => 'qtg_mono_applications_all').tap
		add_calendar_widget_to_homescreen(app,'AppListButton')
		#verify the calendar widget
		day_to_verify = @day.to_i
		verify(){app.HsPage(:__index => 0).HsWidgetHost.HsCalendarWidget.HbWidget( :name => 'CalendarWidget' ).HbTextItem(:text => day_to_verify)}
		#go to second homescreen
		app.HsPageIndicatorItem(:__index =>1).gesture(:Left,1,170)
		#add calendar widget to second home screen
		app.HbIconItem(:iconName => 'qtg_mono_applications_all').tap
		add_calendar_widget_to_homescreen(app,'AppListButton')
		#verify the calendar widget
		day_to_verify = @day.to_i
		verify(){app.HsPage(:__index => 1).HsWidgetHost.HsCalendarWidget.HbWidget( :name => 'CalendarWidget' ).HbTextItem(:text => day_to_verify)}
		#go to third homescreen
		app.HsPageIndicatorItem(:__index =>1).gesture(:Left,1,170)
		#add calendar widget to third home screen
		app.HbIconItem(:iconName => 'qtg_mono_applications_all').tap
		add_calendar_widget_to_homescreen(app,'AppListButton')
		#verify the calendar widget
		day_to_verify = @day.to_i
		verify(){app.HsPage(:__index => 2).HsWidgetHost.HsCalendarWidget.HbWidget( :name => 'CalendarWidget' ).HbTextItem(:text => day_to_verify)}
		#do 50 times
		50.times do
			#step 1: Go to application library
			app.HbIconItem(:iconName => 'qtg_mono_applications_all').tap
			#step 1 Expected: Phone goes to application library view
			verify(){app.HbMarqueeItem(:text => 'Applications')}
			#Step 2: Switch to Home Screen and check Calendar widget.
			app.HbIconItem(:iconName => 'qtg_mono_back').tap
			#Step 2 expected: 
			# - Phone goes to Home Screen.
			# - Calendar widget shows the correct information.
		end
		verify(){app.HsPage(:__index => 0).HsWidgetHost.HsCalendarWidget.HbWidget( :name => 'CalendarWidget' ).HbTextItem(:text => day_to_verify)}
		verify(){app.HsPage(:__index => 1).HsWidgetHost.HsCalendarWidget.HbWidget( :name => 'CalendarWidget' ).HbTextItem(:text => day_to_verify)}
		verify(){app.HsPage(:__index => 2).HsWidgetHost.HsCalendarWidget.HbWidget( :name => 'CalendarWidget' ).HbTextItem(:text => day_to_verify)}
		#verify(){app.HbLabel( :name => 'upperLabel' ).HbTextItem( :text => today_time_for_verification )}
		#verify(){app.HbLabel( :name => 'lowerLabel' ).HbTextItem( :text => 'Today meeting' )}
		remove_calendar_widget_from_homescreen(2)
		#Go to second homescreen and remove calendar widget
		app.HsPageIndicatorItem(:__index =>1).gesture(:Right,1,170)
		remove_calendar_widget_from_homescreen(1)
		#Go to first HS and remove calendar widget
		app.HsPageIndicatorItem(:__index =>1).gesture(:Right,1,170)
		remove_calendar_widget_from_homescreen(0)
		delete_calendar_events(app)
	#rescue
	#	if (running_round < max_running_rounds) then
    #       running_round = running_round + 1
    #       puts "Some error came during run. Lets try again"
    #       teardown
	#       retry
    #    else
    #       puts "Test failed"
    #       raise
    #    end
	#end #rescue			
  end #test_editor_view_new

end # test class
