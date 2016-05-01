-- File: scene_game.lua
-- Description: allow the player to play the game

local composer = require( "composer" )

local scene = composer.newScene()

local widget = require "widget"
widget.setTheme("widget_theme_ios")

local physics = require "physics"
physics.start()
physics.setGravity(0,0)

local playerSheetData = {width=146, height=175, numFrames = 8, sheetContentWidth=1168, sheetContentHeight=175}
local playerSheet = graphics.newImageSheet("images/characters/ninja.png", playerSheetData)
local playerSequenceData = {
    {name="shooting", start=1, count=7, time=300, loopCount=1},
    {name="hurt", start=8, count=1, time=200, loopCount=1}
}

local pirateSheetData = {width=148, height=195, numFrames=8, sheetContentWidth=1184, sheetContentHeight=195}
local pirateSheet1 = graphics.newImageSheet("images/characters/jack.png", pirateSheetData)
local pirateSequenceData = {
    {name="running", start=1, count=8, time=575, loopCount=0}
}

local poofSheetData = {width=128, height=128, numFrames=5, sheetContentWidth=640, sheetContentHeight=128}
local poofSheet = graphics.newImageSheet("images/characters/poof.png", poofSheetData)
local poofSequenceData = {
    {name="poof", start=1, count=5, time=250, loopCount=1}
}


-- -----------------------------------------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.
-- -----------------------------------------------------------------------------------------------------------------

-- local forward references should go here
local lane = {} -- create a table that will hold the four lanes

local player, tmr_playershoot, playerMoney -- forward declares
local playerShootSpeed = 1250 - ( user.shootlevel*100 ) -- determines how fast the player will shoot
local playerEarnMoney = 10 -- how much money is earned when jack is hit

local lives = {} -- table that will hold the lives objects
local livesCount = 1 + (user.liveslevel) -- the number of lives the player has

local bullets = {} -- table that will hold the bullet objects
local bulletCounter = 0 -- number of bullets shot
local bulletTransition = {} -- table to hold bullet transitions
local bulletTransitionCounter = 0 -- number of bullet transitions made

local enemy = {} -- table to hold enemy objects
local enemyCounter = 0 -- number of enemies sent
local enemySendSpeed = 75 -- how often to send the enemies
local enemyTravelSpeed = 3500 -- how fast enemies travel across the screen
local enemyIncrementSpeed = 1.5 -- how much to increase the enemy speed
local enemyMaxSendSpeed = 20 -- max send speed, if this is not set, the enemies could just be one big flood

local poof = {}
local poofCounter = 0

local timeCounter = 0 -- How much time has passed in the game
local pauseGame = false -- is the game paused?
local pauseBackground, btn_pause, pauseText, pause_returnToMenu, pauseReminder -- forward declares

local onGameOver, gameOverBox, gameoverBackground, btn_returnToMenu -- forward declare

-- -------------------------------------------------------------------------------


-- "scene:create()"
function scene:create( event )

    local sceneGroup = self.view

    -- Initialize the scene here.
    -- Example: add display objects to "sceneGroup", add touch listeners, etc.
    local function returnToMenu(event)
        if(event.phase == "ended") then
            audio.play(_CLICK)
            composer.gotoScene("scene_menu", "slideRight")
        end
    end

    local function onLaneTouch(event)
        local id = event.target.id

        if(event.phase == "began") then
            transition.to(player, {y=lane[id].y, time=125})
        end
    end

    local function playerShoot()
        audio.play(_THROW)

        bulletCounter = bulletCounter + 1
        bullets[bulletCounter] = display.newImageRect(sceneGroup, "images/gamescreen/kunai.png", 74, 30)
        bullets[bulletCounter].x = player.x - (player.width * 0.5)
        bullets[bulletCounter].y = player.y 
        bullets[bulletCounter].id = "bullet"
        physics.addBody(bullets[bulletCounter])
        bullets[bulletCounter].isSensor = true

        bulletTransition[bulletCounter] = transition.to(bullets[bulletCounter], {x=-250, time=2000, onComplete=function(self)
            if(self ~= nil) then
                display.remove(self)
            end
        end})

        player:setSequence("shooting")
        player:play()
    end


    local function sendEnemies()
        timeCounter = timeCounter + 1
        if((timeCounter%enemySendSpeed) == 0) then
            enemyCounter = enemyCounter + 1
            enemySendSpeed = enemySendSpeed - enemyIncrementSpeed
            if(enemySendSpeed <= enemyMaxSendSpeed) then
                enemySendSpeed = enemyMaxSendSpeed
            end

            local temp = math.random(1,3)
            if(temp == 1) then
                enemy[enemyCounter] = display.newSprite(pirateSheet1, pirateSequenceData)
            elseif(temp == 2) then
                enemy[enemyCounter] = display.newSprite(pirateSheet1, pirateSequenceData)
            else
                enemy[enemyCounter] = display.newSprite(pirateSheet1, pirateSequenceData)
            end

            enemy[enemyCounter].x = _L - 50
            enemy[enemyCounter].y = lane[math.random(1, #lane)].y
            enemy[enemyCounter].id = "enemy"
            physics.addBody(enemy[enemyCounter])
            enemy[enemyCounter].isFixedRotation = true
            sceneGroup:insert(enemy[enemyCounter])

            transition.to(enemy[enemyCounter], { x = _R+50, time=enemyTravelSpeed, onComplete=function(self) 
                if(self ~= nil) then display.remove(self); end
            end})

            enemy[enemyCounter]:setSequence("running")
            enemy[enemyCounter]:play()
        end
    end

    local function playerHit()
        audio.play(_PLAYERHIT)

        player.x = _R - (player.width * 1.2)
        player.alpha = 1

        if (livesCount>=0) then
            lives[livesCount].alpha = 0
        end
        livesCount = livesCount - 1
        if(livesCount <= 0) then
            onGameOver()
        end 
    end

    local function enemyHit(x,y)
        audio.play(_ENEMYHIT)

        user.money = user.money + playerEarnMoney
        playerMoney.text = "$"..user.money
        loadsave.saveTable(user, "user.json")

        poof = display.newSprite(poofSheet, poofSequenceData)
        poof.x = x
        poof.y = y
        sceneGroup:insert(poof)
        poof:setSequence("hurt")
        poof:play()

        local function removePoof()
            if(poof~=nil) then
                display.remove(poof)
            end
        end
        timer.performWithDelay(255, removePoof, 1)
    end

    local function onCollision(event)
        local function removeOnEnemyHit(obj1, obj2)
            display.remove(obj1)
            display.remove(obj2)
            if(obj1.id == "enemy") then
                enemyHit(event.object1.x, event.object1.y)
            else
                enemyHit(event.object2.x, event.object2.y)
            end
        end

        local function showPlayerHit()
            player:setSequence("hurt")
            player:play()
            player.alpha = 0.5
            local tmr_onPlayerHit = timer.performWithDelay(100, playerHit, 1)
        end

        local function removeOnPlayerHit(obj1, obj2)
            if(obj1~=nil and obj1.id == "enemy") then
                display.remove(obj1)
            end
            if(obj2 ~= nil and obj2.id == "enemy") then
                display.remove(obj2)
            end
        end

        if( (event.object1.id == "bullet" and event.object2.id == "enemy") or (event.object1.id == "enemy" and event.object2.id == "bullet" ) ) then
                removeOnEnemyHit(event.object1, event.object2)
            elseif(event.object1.id == "enemy" and event.object2.id == "player") then
                showPlayerHit()
                removeOnPlayerHit(event.object1, nil)
            elseif(event.object1.id == "player" and event.object2.id == "enemy") then
                showPlayerHit()
                removeOnPlayerHit(nil, event.object2)
        end

    end

    local function onPauseTouch(event)
        if(event.phase == "began") then
            audio.play(_CLICK)
            if(pauseGame == false) then
                -- the game is running and we need to pause it
                pauseGame = true
                physics.pause()

                timer.cancel(tmr_playershoot)
                Runtime:removeEventListener("enterFrame", sendEnemies)
                Runtime:removeEventListener("collision", onCollision)

                transition.pause()

                for i=1, #lane do
                    lane[i]:removeEventListener("touch", onLaneTouch)
                end
                for i=1,#enemy do
                    if(enemy[i].isPlaying == true) then
                        enemy[i]:pause()
                    end
                end

                pauseBackground = display.newRect(sceneGroup, 0, 0, _CW*1.25, _CH*1.25)
                    pauseBackground.x = _CX; pauseBackground.y = _CY
                    pauseBackground:setFillColor(0)
                    pauseBackground.alpha = 0.6
                    pauseBackground:addEventListener("touch", onPauseTouch)

                pauseText = display.newText(sceneGroup, "Game Pause  ", 0, 0, _FONT, 130)
                    pauseText.x = _CX; pauseText.y = _CY - pauseText.height

                pauseReminder = display.newText(sceneGroup, "Return To Game", 0, 0, _FONT, 56)
                    pauseReminder.x = btn_pause.x + 275; pauseReminder.y = btn_pause.y

                pause_returnToMenu = widget.newButton {
                    width = 426,
                    height = 183,
                    defaultFile = "images/gamescreen/btn_menu.png",
                    overFile = "images/gamescreen/btn_menu_over.png",
                    onEvent = returnToMenu
                }
                pause_returnToMenu.x = _CX
                pause_returnToMenu.y = pauseText.y + pause_returnToMenu.height
                sceneGroup:insert(pause_returnToMenu)

                btn_pause:toFront()
            else
                -- the game is paused and we need to unpause it
                pauseGame = false
                physics.start()
                Runtime:addEventListener("enterFrame", sendEnemies)
                Runtime:addEventListener("collision", onCollision)
                tmr_playershoot = timer.performWithDelay(playerShootSpeed, playerShoot, 0)
                transition.resume()

                for i=1,#lane do
                    lane[i]:addEventListener("touch", onLaneTouch)
                end
                for i=1,#enemy do
                    if(enemy[i].isPlaying == false) then
                        enemy[i]:play()
                    end
                end

                display.remove(pauseBackground)
                display.remove(pauseText)
                display.remove(pause_returnToMenu)
                display.remove(pauseReminder)
            end
            return true
        end
    end

    function onGameOver()
        audio.play(_GAMEOVER)

        if(tmr_playershoot) then timer.cancel(tmr_playershoot); end
        Runtime:removeEventListener("enterFrame", sendEnemies)
        Runtime:removeEventListener("collision", onCollision)

        transition.pause()

        for i=1,#lane do
            lane[i]:removeEventListener("touch", onLaneTouch)
        end

        for i=1,#enemy do
            if(enemy[i]~=nil) then
                display.remove(enemy[i])
            end
        end

        gameoverBackground = display.newRect(sceneGroup, 0, 0, _CW*1.25, _CH*1.25)
            gameoverBackground.x = _CX; gameoverBackground.y = _CY
            gameoverBackground:setFillColor(0)
            gameoverBackground.alpha = 0.6

            gameOverBox = display.newImageRect(sceneGroup, "images/gamescreen/title_gameover.png", 924, 154)
                gameOverBox.x = _CX; gameOverBox.y = _CY - gameOverBox.height

            btn_returnToMenu = widget.newButton{
                width = 426,
                height = 183,
                defaultFile = "images/gamescreen/btn_menu.png",
                overFile = "images/gamescreen/btn_menu_over.png",
                onEvent = returnToMenu
            }
        btn_returnToMenu.x = _CX
        btn_returnToMenu.y = gameOverBox.y + btn_returnToMenu.height
        sceneGroup:insert(btn_returnToMenu)
    end

    local background = display.newImageRect(sceneGroup, "images/gamescreen/story-background.png", 1425, 925)
        background.x = _CX
        background.y = _CY

        for i=1,4 do
            lane[i] = display.newImageRect(sceneGroup, "images/gamescreen/lane.png", 1425, 200)
            lane[i].x = _CX
            lane[i].y = (200*i) - 100
            lane[i].id = i
            lane[i]:addEventListener("touch", onLaneTouch)
        end

        for i=1, livesCount do
            lives[i] = display.newImageRect(sceneGroup, "images/gamescreen/heart.png", 50, 51)
            lives[i].x = _L + (i*65) - 25
            lives[i].y = _B - 50
        end

        btn_pause = display.newImageRect(sceneGroup, "images/gamescreen/btn_pause.png", 77, 71)
            btn_pause.x = _L + (btn_pause.width)
            btn_pause.y = _T + (btn_pause.height)
            btn_pause:addEventListener("touch", onPauseTouch)

    player = display.newSprite(playerSheet, playerSequenceData)
        player.x = _R - (player.width * 1.2)
        player.y = lane[1].y
        player.id = "player"
        sceneGroup:insert(player)
        physics.addBody(player)

    playerWall = display.newRect(sceneGroup, 0, 0, 50, _CH)
        playerWall.x = _R + 75
        playerWall.y = _CY
        playerWall.id = "player"
        physics.addBody(playerWall)

    playerMoney = display.newText(sceneGroup, "$"..user.money, 0, 0, _FONT, 72)
        playerMoney:setFillColor( 1, 0, 0 )
        playerMoney.anchorX = 1
        playerMoney.x = _R - 5
        playerMoney.y = _B - 50

    tmr_playershoot = timer.performWithDelay(playerShootSpeed, playerShoot, 0)
    Runtime:addEventListener("enterFrame", sendEnemies)
    Runtime:addEventListener("collision", onCollision) 

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