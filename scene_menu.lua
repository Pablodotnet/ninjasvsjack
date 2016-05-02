-- FILE: scene_menu.lua
-- DESCRIPTION: Start the menu and allow sound on/off


local composer = require( "composer" )

local scene = composer.newScene()

local widget = require "widget"
widget.setTheme("widget_theme_ios7")
-- -----------------------------------------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.
-- -----------------------------------------------------------------------------------------------------------------

-- local forward references should go here
local btn_play, btn_upgrades, btn_sounds
local movePirate, moveNinja

user = loadsave.loadTable("user.json")

local function onPlayTouch(event)
	if(event.phase == "ended") then
		audio.play(_CLICK)
		-- composer.gotoScene("scene_game", "slideLeft")
		composer.gotoScene("scene_characterselect", "slideLeft")
	end
end

local function onUpgradesTouch(event)
	if(event.phase == "ended") then
		audio.play(_CLICK)
		composer.gotoScene("scene_upgrades", "slideUp")
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
    	background.x = _CX; background.y = _CY;

    local gameTitle = display.newImageRect(sceneGroup, "images/menuscreen/title.png", 1108, 270)
    	gameTitle.x = _CX; gameTitle.y = _CH * 0.2

    local myJack = display.newImageRect(sceneGroup, "images/menuscreen/menu_jack.png", 334, 430)
    	myJack.x = _L - myJack.width; myJack.y = _CH * 0.7

    local myNinja = display.newImageRect(sceneGroup, "images/menuscreen/menu_ninja1.png", 234, 346)
    	myNinja.x = _R + myNinja.width; myNinja.y = _CH * 0.7

    -- Create some buttons
    btn_play = widget.newButton{
    	width = 426,
    	height = 183,
    	defaultFile = "images/menuscreen/btn_play.png",
    	overFile = "images/menuscreen/btn_play_over.png",
    	onEvent = onPlayTouch
	}

	btn_play.x = _CX
	btn_play.y = _CY
	sceneGroup:insert(btn_play)

	btn_upgrades = widget.newButton{
		width = 426,
		height = 183,
		defaultFile = "images/menuscreen/btn_upgrades.png",
		overFile = "images/menuscreen/btn_upgrades_over.png",
		onEvent = onUpgradesTouch
	}

	btn_upgrades.x = _CX
	btn_upgrades.y = btn_play.y + (btn_upgrades.height * 1.25)
	sceneGroup:insert(btn_upgrades)

	btn_sounds = widget.newButton{
		width = 78,
		height = 79,
		defaultFile = "images/menuscreen/btn_music.png",
		overFile = "images/menuscreen/btn_music_over.png",
		onEvent = onSoundsTouch
	}

	btn_sounds.x = _L + 100
	btn_sounds.y = _T + 190
	sceneGroup:insert(btn_sounds)

	-- Transitions
	moveNinja = transition.to(myNinja, {x=950, delay=250})
	movePirate = transition.to(myJack, {x=250, delay=250})

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

        audio.play(_BACKGROUNDMUSIC, {loops=1, fadein=2500})
        
        local prevScene = composer.getSceneName("previous")
        if(prevScene) then
            composer.removeScene(prevScene)
        end
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
