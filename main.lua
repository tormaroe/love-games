
platform = {}
player = {}

function love.load()
   platform.width = love.graphics.getWidth()
   platform.height = love.graphics.getHeight()

   platform.x = 0
   platform.y = platform.height / 2

   player.x = platform.width / 2
   player.y = platform.height / 2
   player.img = love.graphics.newImage('purple.png')
   player.speed = 200
   player.ground = player.y
   player.y_velocity = 0
   player.jump_height = -400
   player.gravity = -500
end

function love.update(dt)
    if gameIsPaused then return end

    if love.keyboard.isDown('d') then
		-- This makes sure that the character doesn't go pass the game window's right edge.
		if player.x < (love.graphics.getWidth() - player.img:getWidth()) then
			player.x = player.x + (player.speed * dt)
		end
	elseif love.keyboard.isDown('a') then
		-- This makes sure that the character doesn't go pass the game window's left edge.
		if player.x > 0 then 
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

    if player.y > player.ground then    -- The game checks if the player has jumped.
		player.y_velocity = 0       -- The Y-Axis Velocity is set back to 0 meaning the character is on the ground again.
    	player.y = player.ground    -- The Y-Axis Velocity is set back to 0 meaning the character is on the ground again.
	end
end

function love.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle('fill', platform.x, platform.y, platform.width, platform.height)

    love.graphics.draw(player.img, player.x, player.y, 0, 1, 1, 0, 32)

end

function love.mousepressed(x, y, button, istouch)
end

function love.mousereleased(x, y, button, istouch)
end

function love.keypressed(key)
end

function love.keyreleased(key)    
end

function love.focus(f)
    gameIsPaused = not f 
end

function love.quit()
  print("Thanks for playing! Come back soon!")
end