local bt = require "plugin.bt"
local json = require "json"
local widget = require "widget"
local bluetoothList
local bluetoothTable = {}
local deviceTable = {}
-- note location is required for bluetooth on android 6.0+ 

--request premission for 6.0+
native.showPopup( "requestAppPermission", {
   appPermission = "Location", urgency = "Critical", listener= function ( e )
   	
   end} )
--

local bg = display.newRect( display.contentCenterX, display.contentCenterY, display.actualContentWidth, display.actualContentHeight )
bg:setFillColor( .5,0,1 )
local title = display.newText( "Bluetooth Plugin", display.contentCenterX, 60, native.systemFontBold, 30 )
title:setFillColor( 0,0,1 )
local function isIDInTable( ID )
	for i=1,#bluetoothTable do
		if (bluetoothTable[i]["ID"] == ID ) then
			return true
		end
	end
	return false
end
local function loadBluetoothTable( )
	bluetoothList:deleteAllRows()
	bluetoothList:insertRow( {params= {title= "Devices Configured"}, isCategory = true} )
	for i=1,#deviceTable do
		bluetoothList:insertRow( {params= {title= deviceTable[i]["deviceName"], btType = "device", index = i, isDeviceRow = true}} )
	end
	bluetoothList:insertRow( {params= {title= "Devices Found"}, isCategory = true} )
	for i=1,#bluetoothTable do
		bluetoothList:insertRow( {params= {title= bluetoothTable[i]["deviceName"], btType = "bluetooth", index = i, isBluetoothRow = true}} )
	end

end
bt.init(function (event)
	if (event.type == "device found") then
		native.setActivityIndicator( false )
		if (isIDInTable(event.deviceID) == false) then
			local index = #bluetoothTable+1
			bluetoothTable[index] = {}
			bluetoothTable[index]["deviceID"]= event.deviceID
			bluetoothTable[index]["deviceName"]= event.deviceName
			bluetoothTable[index]["deviceState"]= event.deviceState
			loadBluetoothTable()
		end
	end
	if (event.type == "connected") then
		native.showAlert( "Connected to device", "Name:"..event.deviceName, {"Ok"} )
		bluetoothTable = nil
		bluetoothTable = {}
		bt.search()
		native.setActivityIndicator( false )
	end
	if (event.type == "disconnect") then
		native.showAlert( "Disconnected from device", "Name:"..event.deviceName, {"Ok"} )
		bluetoothTable = nil
		bluetoothTable = {}
		bt.search()
		native.setActivityIndicator( false )
	end
	if (event.type == "connection error") then
		native.showAlert( "Connection error", "Name:"..event.deviceName.."/Error: "..event.error, {"Ok"} )
		bluetoothTable = nil
		bluetoothTable = {}
		bt.search()
	end
	if (event.type == "discovery finished") then
		native.setActivityIndicator( false )
	end
	
	if (event.type == "error") then
		native.showAlert( "Disconnected from device", "Name:"..event.error, {"Ok"} )
	end
	if (event.type == "message") then
		native.showAlert( "Message Received", "Name:"..event.error, {"Ok"} )
	end
end)
local function onRowRenderBluetoothList( event )
    local row = event.row
    row.x = -5
    local rowHeight = row.contentHeight
    local rowWidth = row.contentWidth

    local rowTitle = display.newText( row, row.params.title, 0, 0, nil, 12 )
    rowTitle:setFillColor( 0 )

    rowTitle.anchorX = 0
    rowTitle.x = 20
    rowTitle.y = rowHeight * 0.5
    if (row.params.isBluetoothRow and row.params.isBluetoothRow == true) then
    	local connectionState = display.newText( row, bluetoothTable[row.params.index]["deviceState"], 0, 0, nil, 8 )
    	connectionState:setFillColor(0)
    	connectionState.anchorX = 1
    	connectionState.x = rowWidth
    	connectionState.y = rowHeight * 0.5
    end
end
bluetoothList = widget.newTableView
{
    x = display.contentCenterX,
    y = display.contentCenterY,
    height = 250,
    width = 250,
    onRowRender = onRowRenderBluetoothList,
    onRowTouch = function  (e)
      if e.phase == "release" then
      	if (e.row.params.btType == "bluetooth") then
      		bt.connect(bluetoothTable[e.row.params.index]["deviceID"])
      		native.setActivityIndicator( true )
      	else
      		bt.connect(deviceTable[e.row.params.index]["deviceID"])
      		native.setActivityIndicator( true )
      	end
      end
    end, 
}

local bluetoothSearch = widget.newButton{
	label = "Search",
	x = display.contentCenterX,
	y = display.actualContentHeight-50,
	onRelease = function ( event )
		bluetoothTable = nil
		bluetoothTable = {}
		bt.search()
		native.setActivityIndicator( true )
	end,
}
timer.performWithDelay( 2000, function (  )
	
	deviceTable = bt.getDevices()
	loadBluetoothTable( )
end, -1 )