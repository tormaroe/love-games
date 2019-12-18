--[[
    S P E E D   J U M P E R

    My first löve game (Lua 2d game)

    Author: Torbjørn Marø
    When:   2019.12.05

    Objective: Get the highest score possible by eating green dots as rapidly as
    you can manage while avoiding the red mines. Eating several dots in quick
    succession awards bonus points, while time spent in game is a points penalty.

    Controls:  a    - move left
               d    - move right
             space  - jump
               r    - reload
--]]

platform = {}
player = {}
food = {}
mines = {}

function love.load()
    love.window.setTitle "Speed Jumper"
    platform.width = love.graphics.getWidth()
    platform.height = love.graphics.getHeight()
    
    platform.x = 0
    platform.y = platform.height - 50
    
    player.x = platform.width / 2
    player.y = platform.height / 2
    player.r = 10
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
        food[i].color = { r = 0, g = 1, b = 0}
        food[i].value = 1
    end
    for i = 21, 30 do
        food[i] = randomDot(platform.width, platform.y)
        food[i].color = { r = 1, g = 0.4, b = 0.6}
        food[i].value = 5
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
        speed = math.random(100),
        up = true,
        visible = true,
        cooldown = 0
    }
end

function love.update(dt)
    if gameIsPaused then return end
    
    -- MOVE
    if love.keyboard.isDown('d') then
        if player.x < (love.graphics.getWidth() - player.r) then
            player.x = player.x + (player.speed * dt)
        end
    elseif love.keyboard.isDown('a') then
        if player.x > player.r then
            player.x = player.x - (player.speed * dt)
        end
    end
    
    -- JUMP
    if love.keyboard.isDown('space') then
        if player.y_velocity == 0 then
            player.y_velocity = player.jump_height
        end
    end
    
    if player.y_velocity ~= 0 then
        player.y = player.y + player.y_velocity * dt
        player.y_velocity = player.y_velocity - player.gravity * dt
    end
    
    if player.y > player.ground - player.r then
        player.y_velocity = 0
        player.y = player.ground - player.r
    end
    
    updateDots(food, dt, function(food)
        player.points = player.points + food.value
        player.pointsPrSec = player.pointsPrSec + 1.0
    end)
    
    updateDots(mines, dt, function()
        player.lives = player.lives - 1
    end)
    
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

function updateDots(dots, dt, hitCallback)
    for i = 1, #dots do
        if dots[i].visible then
            if dots[i].up and dots[i].y < 0 then dots[i].up = false end
            if not dots[i].up and dots[i].y > player.ground then dots[i].up = true end
            
            if dots[i].up then
                dots[i].y = dots[i].y - (dots[i].speed * dt)
            else
                dots[i].y = dots[i].y + (dots[i].speed * dt)
            end
            
            -- HIT
            if (math.abs(player.x - dots[i].x) < player.r) and (math.abs(player.y - dots[i].y) < player.r) then
                dots[i].visible = false
                dots[i].cooldown = 15
                hitCallback(dots[i])
            end
        else
            dots[i].cooldown = dots[i].cooldown - dt
            if dots[i].cooldown < 0 then
                dots[i].cooldown = 0
                dots[i].visible = true
            end
        end
    end
end

function love.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle('fill', platform.x, platform.y, platform.width, platform.height)
    
    for i = 1, #food do
        if food[i].visible then
            love.graphics.setColor(food[i].color.r, food[i].color.g, food[i].color.b)
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
    love.graphics.print("SCORE: " .. player.points + math.floor(player.bonus) - math.floor(player.timePenalty) .. " points", 380, platform.y + 10)
    love.graphics.print("Lives: " .. player.lives, 10, platform.y + 30)
    love.graphics.print("Rate: " .. player.pointsPrSec .. " points/sec", 140, platform.y + 30)
    love.graphics.print("Time penalty: " .. player.timePenalty .. " points", 380, platform.y + 30)
end

function love.mousepressed(x, y, button, istouch)
end

function love.mousereleased(x, y, button, istouch)
end

function love.keypressed(key)
    if key == 'r' then 
        love.load() 
    end
end

function love.keyreleased(key)
end

function love.focus(f)
    gameIsPaused = not f
end

function love.quit()
    print("Thanks for playing! Come back soon!")
end
