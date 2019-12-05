
--local math = require('math')

platform = {}
player = {}
food = {}
mines = {}

function love.load()
   platform.width = love.graphics.getWidth()
   platform.height = love.graphics.getHeight()

   platform.x = 0
   platform.y = platform.height - 50

   player.x = platform.width / 2
   player.y = platform.height / 2
   player.r = 10
   player.img = love.graphics.newImage('purple.png')
   player.speed = 100
   player.ground = platform.y
   player.y_velocity = 10
   player.jump_height = -400
   player.gravity = -200
   player.points = 0
   player.bonus = 0
   player.lives = 3
   player.pointsPrSec = 0.0
   player.timePenalty = 0.0

   for i = 1, 20 do
        food[i] = randomDot(platform.width, platform.y)
   end
   for i = 1, 15 do
        mines[i] = randomDot(platform.width, platform.y)
   end

   gameIsPaused = false
end

function randomDot(maxX, maxY)
    return {
        x = math.random(maxX),
        y = math.random(maxY),
        speed = math.random(50),
        up = true,
        visible = true,
        cooldown = 0
    }
end

function love.update(dt)
    if gameIsPaused then return end

    --if love.keyboard.isDown('r') then
    --    love.load()
    --end

    if love.keyboard.isDown('d') then
		-- This makes sure that the character doesn't go pass the game window's right edge.
		if player.x < (love.graphics.getWidth() - player.r) then
			player.x = player.x + (player.speed * dt)
		end
	elseif love.keyboard.isDown('a') then
		-- This makes sure that the character doesn't go pass the game window's left edge.
		if player.x > player.r then 
			player.x = player.x - (player.speed * dt)
		end
    end

    if love.keyboard.isDown('space') then                     -- Whenever the player presses or holds down the Spacebar:
		if player.y_velocity == 0 then
			player.y_velocity = player.jump_height    -- The player's Y-Axis Velocity is set to it's Jump Height.
		end
    end

    if player.y_velocity ~= 0 then                                      -- The game checks if player has "jumped" and left the ground.
		player.y = player.y + player.y_velocity * dt                -- This makes the character ascend/jump.
		player.y_velocity = player.y_velocity - player.gravity * dt -- This applies the gravity to the character.
    end

    if player.y > player.ground - player.r then    -- The game checks if the player has jumped.
		player.y_velocity = 0       -- The Y-Axis Velocity is set back to 0 meaning the character is on the ground again.
    	player.y = player.ground - player.r    -- The Y-Axis Velocity is set back to 0 meaning the character is on the ground again.
    end
    
    for i = 1, #food do
        if food[i].visible then
            if food[i].up and food[i].y < 0 then food[i].up = false end
            if not food[i].up and food[i].y > player.ground then food[i].up = true end

            if food[i].up then
                food[i].y = food[i].y - (food[i].speed * dt)
            else
                food[i].y = food[i].y + (food[i].speed * dt)
            end

            if (math.abs(player.x - food[i].x) < player.r) and (math.abs(player.y - food[i].y) < player.r) then
                food[i].visible = false
                food[i].cooldown = 15
                player.points = player.points + 1
                player.pointsPrSec = player.pointsPrSec + 1.0
                print("Score = " .. player.points)
            end
        else
            food[i].cooldown = food[i].cooldown - dt
            if food[i].cooldown < 0 then
                food[i].cooldown = 0
                food[i].visible = true
            end
        end
    end
    for i = 1, #mines do
        if mines[i].visible then
            if mines[i].up and mines[i].y < 0 then mines[i].up = false end
            if not mines[i].up and mines[i].y > player.ground then mines[i].up = true end

            if mines[i].up then
                mines[i].y = mines[i].y - (mines[i].speed * dt)
            else
                mines[i].y = mines[i].y + (mines[i].speed * dt)
            end

            if (math.abs(player.x - mines[i].x) < player.r) and (math.abs(player.y - mines[i].y) < player.r) then
                mines[i].visible = false
                mines[i].cooldown = 15
                player.lives = player.lives - 1
                print("Lives = " .. player.lives)
            end
        else
            mines[i].cooldown = mines[i].cooldown - dt
            if mines[i].cooldown < 0 then
                mines[i].cooldown = 0
                mines[i].visible = true
            end
        end
    end

    player.pointsPrSec = math.max(0, player.pointsPrSec - dt)
    player.timePenalty = player.timePenalty + (0.1 * dt)

    if player.pointsPrSec >= 2 then
        player.bonus = player.bonus + (10 * dt)
    elseif player.pointsPrSec >= 1 then
        player.bonus = player.bonus + (1 * dt)
    end

    if player.lives < 1 then
        gameIsPaused = true
    end
end

function love.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle('fill', platform.x, platform.y, platform.width, platform.height)

    love.graphics.setColor(0, 1, 0)
    for i = 1, #food do
        if food[i].visible then
            love.graphics.circle('fill', food[i].x, food[i].y, 5, 10)    
        end
    end
    love.graphics.setColor(1, 0, 0)
    for i = 1, #mines do
        if mines[i].visible then
            love.graphics.circle('fill', mines[i].x, mines[i].y, 5, 10)    
        end
    end

    love.graphics.setColor(0, 0, 1)
    love.graphics.circle('fill', player.x, player.y, player.r, 50)    

    love.graphics.print("Eaten: " .. player.points .. " blobs", 10, platform.y + 10)
    love.graphics.print("Bonus: " .. player.bonus .. " points", 140, platform.y + 10)
    love.graphics.print("SCORE: " .. player.points + math.floor(player.bonus) - math.floor(player.timePenalty) .. " points", 360, platform.y + 10)
    love.graphics.print("Lives: " .. player.lives, 10, platform.y + 30)
    love.graphics.print("Rate: " .. player.pointsPrSec .. " points/sec", 140, platform.y + 30)
    love.graphics.print("Time penalty: " .. player.timePenalty .. " points", 360, platform.y + 30)
end

function love.mousepressed(x, y, button, istouch)
end

function love.mousereleased(x, y, button, istouch)
end

function love.keypressed(key)
    if key == 'r' then love.load() end
end

function love.keyreleased(key)    
end

function love.focus(f)
    gameIsPaused = not f 
end

function love.quit()
  print("Thanks for playing! Come back soon!")
end