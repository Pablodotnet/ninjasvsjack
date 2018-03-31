-- FILE: scene_menu.lua
-- DESCRIPTION: Start the menu and allow sound on/off


local composer = require( "composer" )

local scene = composer.newScene()


-- -----------------------------------------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.
-- -----------------------------------------------------------------------------------------------------------------

-- local forward references should go here
local widget = require "widget"
widget.setTheme("widget_theme_ios7")

local btn_upgrade1, btn_upgrade2, btn_menu, sceneTitle, warningMessage, btn_upgradeGirl
local movePirate, moveNinja

user = loadsave.loadTable("user.json")

-- -----------------------------------------------

local function onMenuTouch(event)
	if(event.phase == "ended") then
		audio.play(_CLICK)
		composer.gotoScene("scene_menu", "slideDown")
	end
end

local function hideWarningMessage()
	warningMessage.alpha = 0
end

local function onUpgrade1Touch(event)
	if(event.phase == "ended") then
		audio.play(_CLICK)
		if(user.money >= (user.shootlevel*_SHOOTUPGRADECOST + _SHOOTUPGRADECOST)) then
			-- allow player to proceed with the upgrade
			if(user.shootlevel >= user.shootlevelmax) then
				-- display max level
				btn_upgrade1:setLabel("MAX Level")
			else
				-- proceed with upgrade
				user.money = user.money - (user.shootlevel*_SHOOTUPGRADECOST + _SHOOTUPGRADECOST)
				
				sceneTitle.text = "Upgrades - $"..user.money
				
				user.shootlevel = user.shootlevel + 1
				loadsave.saveTable(user, "user.json")
				user = loadsave.loadTable("user.json")

				btn_upgrade1:setLabel("$"..(user.shootlevel*_SHOOTUPGRADECOST + _SHOOTUPGRADECOST).."  Rank  "..user.shootlevel)
			end
		else
			-- otherwise, display the warning message of not enough money
			warningMessage.alpha = 1
			local tmr_hidewarningmessage = timer.performWithDelay(750, hideWarningMessage, 1)
		end
	end
end


local function onUpgrade2Touch(event)
	if(event.phase == "ended") then
		audio.play(_CLICK)
		if(user.money >= (user.liveslevel*_LIVESUPGRADECOST + _LIVESUPGRADECOST)) then
			-- allow player to proceed with the upgrade
			if(user.liveslevel >= user.liveslevelmax) then
				-- display max level
				btn_upgrade2:setLabel("MAX Level")
			else
				-- proceed with upgrade
				user.money = user.money - (user.liveslevel*_LIVESUPGRADECOST + _LIVESUPGRADECOST)
				
				sceneTitle.text = "Upgrades - $"..user.money
				
				user.liveslevel = user.liveslevel + 1
				loadsave.saveTable(user, "user.json")
				user = loadsave.loadTable("user.json")

				btn_upgrade2:setLabel("$"..(user.liveslevel*_LIVESUPGRADECOST + _LIVESUPGRADECOST).."  Rank  "..user.liveslevel)
			end
		else
			-- otherwise, display the warning message of not enough money
			warningMessage.alpha = 1
			local tmr_hidewarningmessage = timer.performWithDelay(750, hideWarningMessage, 1)
		end
	end
end

-- Function for buying character Ninja Girl
local function onUpgrade3Touch(event)
	if(event.phase == "ended") then
		audio.play(_CLICK)
		if (user.extraCharacter == true) then
			-- display message "Already Bought"
			btn_upgradeGirl:setLabel("Already Have It")
		else
			if (user.money >= _EXTRACHARACTERCOST) then
				-- allow player to proceed with the upgrade
				-- proceed with upgrade
				user.money = user.money - _EXTRACHARACTERCOST

				sceneTitle.text = "Upgrades - $"..user.money

				user.extraCharacter = true
				loadsave.saveTable(user, "user.json")
				user = loadsave.loadTable("user.json")

				btn_upgradeGirl:setLabel("$"..(_EXTRACHARACTERCOST))
			else
				-- otherwise, display the warning message of not enough money
				warningMessage.alpha = 1
				local tmr_hidewarningmessage = timer.performWithDelay(750, hideWarningMessage, 1)
			end
		end
	end
end


local function onSoundsTouch(event)
	if(event.phase == "ended") then
		if(user.playsound == true) then
			--mute the game
			audio.setVolume(0)
			btn_sounds.alpha = 0.5
			user.playsound = false
		else
			--unmute the game
			audio.setVolume(1)
			btn_sounds.alpha = 1
			user.playsound = true
		end
		loadsave.saveTable(user, "user.json")
	end
end
-- -------------------------------------------------------------------------------


-- "scene:create()"
function scene:create( event )

    local sceneGroup = self.view

    -- Initialize the scene here.
    -- Example: add display objects to "sceneGroup", add touch listeners, etc.
    local background = display.newImageRect(sceneGroup, "images/menuscreen/menu_bg.png", 1425, 1000)
		background.x = _CX
		background.y = _CY

    --local gameTitle = display.newImageRect(sceneGroup, "images/menuscreen/title.png", 1108, 270)
	--	gameTitle.x = _CX
	--	gameTitle.y = _CH * 0.2

    local banner = display.newImageRect(sceneGroup, "images/menuscreen/banner.png", 1400, 200)
		banner.x = _CX
		banner.y = _CH * 0.2

    sceneTitle = display.newText(sceneGroup, "Upgrades - $"..user.money, 0, 0, _FONT, 90)
		sceneTitle.x = _CX
		sceneTitle.y = banner.y - 30

    warningMessage = display.newText(sceneGroup, "Not enough money.", 0, 0, _FONT, 52)
		warningMessage.x = _CX
		warningMessage.y = sceneTitle.y + (sceneTitle.height * 0.7)
    	warningMessage.alpha = 0


    -- Create some buttons
	-- BUTTONS

	btn_upgrade1 = widget.newButton{
		width = 480,
		height = 183,
		defaultFile = "images/menuscreen/btn_shoot.png",
		overFile = "images/menuscreen/btn_shoot_over.png",
		font = _FONT,
		fontSize = 60,
		labelColor = {default={1,1,1},over={0,0,0}},
		labelYOffset = 15,
		label = "$"..(user.shootlevel*_SHOOTUPGRADECOST + _SHOOTUPGRADECOST).."  Rank  "..user.shootlevel,
		onEvent = onUpgrade1Touch
	}

	btn_upgrade1.x = _CX - (btn_upgrade1.width * 0.6)
	btn_upgrade1.y = _CY
	sceneGroup:insert(btn_upgrade1)


	btn_upgrade2 = widget.newButton{
		width = 480,
		height = 183,
		defaultFile = "images/menuscreen/btn_lives.png",
		overFile = "images/menuscreen/btn_lives_over.png",
		font = _FONT,
		fontSize = 60,
		labelColor = {default={1,1,1},over={0,0,0}},
		labelYOffset = 15,
		label = "$"..(user.liveslevel*_LIVESUPGRADECOST + _LIVESUPGRADECOST).."	 Rank  "..user.liveslevel,
		onEvent = onUpgrade2Touch
	}

	btn_upgrade2.x = _CX + (btn_upgrade2.width * 0.6)
	btn_upgrade2.y = _CY
	sceneGroup:insert(btn_upgrade2)


	btn_upgradeGirl = widget.newButton{
		width = 426,
		height = 183,
		defaultFile = "images/menuscreen/btn_girl.png",
		overFile = "images/menuscreen/btn_girl_over1.png",
		font = _FONT,
		fontSize = 60,
		labelColor = {default={1,1,1},over={0,0,0}},
		labelYOffset = -15,
		label = "$"..(_EXTRACHARACTERCOST),
		onEvent = onUpgrade3Touch
	}

	btn_upgradeGirl.x = _CX
	btn_upgradeGirl.y = _CY + (btn_upgradeGirl.height * 1.25) 
	sceneGroup:insert(btn_upgradeGirl)

	btn_menu = widget.newButton{
		width = 300,
		height = 83,
		defaultFile = "images/menuscreen/btn_menu.png",
		overFile = "images/menuscreen/btn_menu_over.png",
		onEvent = onMenuTouch
	}

	btn_menu.x = _CX + (btn_menu.width * 1.7)
	btn_menu.y = _CY + (btn_menu.height * 3.8)
	sceneGroup:insert(btn_menu)
end


-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
    elseif ( phase == "did" ) then
        -- Called when the scene is now on screen.
        -- Insert code here to make the scene come alive.
        -- Example: start timers, begin animation, play audio, etc.
    end
end


-- "scene:hide()"
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is on screen (but is about to go off screen).
        -- Insert code here to "pause" the scene.
        -- Example: stop timers, stop animation, stop audio, etc.
    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen.
    end
end


-- "scene:destroy()"
function scene:destroy( event )

    local sceneGroup = self.view

    -- Called prior to the removal of scene's view ("sceneGroup").
    -- Insert code here to clean up the scene.
    -- Example: remove display objects, save state, etc.
end


-- -------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene
