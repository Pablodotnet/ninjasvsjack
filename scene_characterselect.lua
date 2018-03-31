-- FILE: scene_menu.lua
-- DESCRIPTION: Shows a scene where we can choose which character we'll use in the game.

local composer = require("composer")

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.
-- -----------------------------------------------------------------------------------------------------------------

-- local forward references should go here
local widget = require "widget"
widget.setTheme("widget_theme_ios7")

local btn_ninjaGirl, btn_ninjaBoy, btn_menu, sceneTitle, warningMessage
local movePirate, moveNinja

user = loadsave.loadTable("user.json")

-- -----------------------------------------------

local function onMenuTouch(event)
	if(event.phase == "ended") then
		audio.play(_CLICK)
		composer.gotoScene("scene_menu", "slideDown")
	end
end

local function onPlayTouch(event)
	if(event.phase == "ended") then
		audio.play(_CLICK)
		composer.gotoScene("scene_game", "slideLeft")
	end
end

local function hideWarningMesssage()
	warningMessage.alpha = 0
end

local function selectAndSave(character)
	if (character == 'ninjaBoy') then
		user.characterSelected = "ninjaBoy"
	elseif (character == 'ninjaGirl') then
		user.characterSelected = "ninjaGirl"
	end
	loadsave.saveTable(user, "user.json")
	user = loadsave.loadTable("user.json")
end

local function onNinjaBoyTouch(event)
	if(event.phase == "ended") then
		audio.play(_CLICK)
		selectAndSave('ninjaBoy')
		btn_ninjaBoy:setLabel("Selected")
		btn_ninjaGirl:setLabel("")
	end
end

local function onNinjaGirlTouch(event)
	if(event.phase == "ended") then
		audio.play(_CLICK)
		if(user.extraCharacter == false) then
			-- Display message to advice the user doesn't have the character

			btn_ninjaGirl:setLabel("GO BUY IT")
		else
			-- Proceed to change character if the user have already bought it
			selectAndSave('ninjaGirl')

			btn_ninjaGirl:setLabel("Selected")
			btn_ninjaBoy:setLabel("")
		end
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

    local gameTitle = display.newImageRect(sceneGroup, "images/menuscreen/character_select.png", 1308, 270)
    	gameTitle.x = _CX
    	gameTitle.y = _CH * 0.2

    -- local myNinja = display.newImageRect(sceneGroup, "images/menuscreen/menu_ninja1.png", 234, 346)
    	-- myNinja.x = _R + myNinja.width
    	-- myNinja.y = _CH * 0.7


    -- local myJack = display.newImageRect(sceneGroup, "images/menuscreen/menu_girl.png", 243, 365)
    --	myJack.x = _L - myJack.width
    --	myJack.y = _CH * 0.7

    btn_ninjaBoy = widget.newButton{
    	width = 234,
		height = 346,
		font = _FONT,
		fontSize = 70,
		labelColor = {default={0,0,0},over={1,1,1}},
		labelYOffset = -230,
    	defaultFile = "images/menuscreen/menu_ninja1.png",
    	overFile = "images/menuscreen/menu_ninja1_over.png",
    	onEvent = onNinjaBoyTouch
	}

	btn_ninjaBoy.x = _R + btn_ninjaBoy.width
	btn_ninjaBoy.y = _CH * 0.7
	sceneGroup:insert(btn_ninjaBoy)

	btn_ninjaGirl = widget.newButton{
    	width = 243,
		height = 365,
		font = _FONT,
		fontSize = 70,
		labelColor = {default={0,0,0},over={1,1,1}},
		labelYOffset = -230,
    	defaultFile = "images/menuscreen/menu_girl.png",
    	overFile = "images/menuscreen/menu_girl_over.png",
    	onEvent = onNinjaGirlTouch
	}

	btn_ninjaGirl.x = _L - btn_ninjaGirl.width
	btn_ninjaGirl.y = _CH * 0.7
	sceneGroup:insert(btn_ninjaGirl)

    -- Button to enter to the game
    btn_play = widget.newButton{
    	width = 340,
    	height = 183,
    	defaultFile = "images/menuscreen/btn_play.png",
    	overFile = "images/menuscreen/btn_play_over.png",
    	onEvent = onPlayTouch
	}

	btn_play.x = _CX
	btn_play.y = _CY
	
	sceneGroup:insert(btn_play)

	-- Button to go back to menu
	btn_menu = widget.newButton{
		width = 260,
		height = 76,
		defaultFile = "images/menuscreen/btn_menu.png",
		overFile = "images/menuscreen/btn_menu_over.png",
		onEvent = onMenuTouch
	}

	btn_menu.x = _CX + (btn_menu.width * 2.1)
	btn_menu.y = _CY + (btn_menu.height * 4.0)
	sceneGroup:insert(btn_menu)

	-- Transitions
	moveNinja = transition.to(btn_ninjaBoy, {x=870, delay=250})
	movePirate = transition.to(btn_ninjaGirl, {x=275, delay=250})

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