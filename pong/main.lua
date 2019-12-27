
-- https://coolors.co/0e7a8b-e0ffde-a0dfbf-668f87-e2d2af

colors = {
    lightGreen = { r = 0.2787, g = 0.3885, b = 0.3328 },
    lightestGreen = { r = 0.32, g = 1, b = 0.94 },
    darkGreen = { r = 0.52, g = 0.82, b = 0.3 }
}

field = {}
player1 = {}
player2 = {}
balls = {}

function love.load()
    love.window.setTitle "Pong"
    field.width = love.graphics.getWidth() - 20
    field.height = love.graphics.getHeight() - 50
    field.x = 10
    field.y = 40

    player1.x = 100
    player1.y = 100
    player1.width = 10
    player1.height = 100
    player1.speed = 150

    player2.x = 200
    player2.y = 100
    player2.width = 10
    player2.height = 100
    player2.speed = 150

    balls[1] = {
        x = (field.width - field.x) / 2,
        y = (field.height - field.y) / 2,
        r = 6,
        directon = 80,
        speed = 500
    }
end

function love.update(dt)
    if love.keyboard.isDown('w') then
        playerUp(player1, dt)
    end
    if love.keyboard.isDown('a') then
        playerLeft(player1, dt)
    end
    if love.keyboard.isDown('s') then
        playerDown(player1, dt)
    end
    if love.keyboard.isDown('d') then
        playerRight(player1, dt)
    end
    if love.keyboard.isDown('up') then
        playerUp(player2, dt)
    end
    if love.keyboard.isDown('left') then
        playerLeft(player2, dt)
    end
    if love.keyboard.isDown('down') then
        playerDown(player2, dt)
    end
    if love.keyboard.isDown('right') then
        playerRight(player2, dt)
    end

    for i = 1, #balls do
        updateBall(balls[i], dt)
    end
end

function updateBall(b, dt)
    if b.directon >= 0 and b.directon <= 90 then
        b.x = b.x + (b.speed * dt * (b.directon / 90.0))
        b.y = b.y - (b.speed * dt * ((90 - b.directon) / 90.0))
    elseif b.directon > 90 and b.directon <= 180 then
        b.x = b.x + (b.speed * dt * ((90 - (b.directon - 90)) / 90.0))
        b.y = b.y + (b.speed * dt * ((b.directon - 90) / 90.0))
    elseif b.directon > 180 and b.directon <= 270 then
        b.x = b.x - (b.speed * dt * ((b.directon - 180) / 90.0))
        b.y = b.y + (b.speed * dt * ((90 - (b.directon - 180)) / 90.0))
    elseif b.directon > 270 then
        b.x = b.x - (b.speed * dt * ((90 - (b.directon - 270)) / 90.0))
        b.y = b.y - (b.speed * dt * ((b.directon - 270) / 90.0))
    end

    -- HIT TOP WALL
    if b.y <= field.y then
        if b.directon < 90 then
            b.directon = 180 - b.directon
        else
            b.directon = 360 - b.directon
        end
    -- HIT LEFT WALL
    elseif b.x <= field.x then
        if b.directon > 270 then
            b.directon = 90 - (b.directon - 270)
        else
            b.directon = 180 - (b.directon - 180)
        end
    -- HIT BOTTOM WALL
    elseif b.y >= (field.height + field.y) then
        if b.directon > 180 then
            b.directon = 360 - (b.directon - 180)
        else
            b.directon = 90 - (b.directon - 90)
        end
    -- HIT RIGHT WALL
    elseif b.x >= (field.width + field.x) then
        if b.directon > 90 then
            b.directon = 270 - (b.directon - 90)
        else
            b.directon = 360 - b.directon
        end
    end
end

function playerDown(p, dt)
    if (p.y + p.height) < (field.y + field.height) then
        p.y = p.y + (dt * p.speed)
    end
end

function playerUp(p, dt)
    if p.y > field.y then
        p.y = p.y - (dt * p.speed)
    end
end

function playerLeft(p, dt)
    if p.x > field.x then
        p.x = p.x - (dt * p.speed)
    end
end

function playerRight(p, dt)
    if (p.x + p.width) < (field.x + field.width) then
        p.x = p.x + (dt * p.speed)
    end
end

function love.draw()
    setRGB(colors.lightGreen)
    love.graphics.rectangle('fill', field.x, field.y, field.width, field.height)

    drawPlayer(player1)
    drawPlayer(player2)
    for i = 1, #balls do
        drawBall(balls[i])
    end
end

function drawPlayer(p)
    setRGB(colors.lightestGreen)
    love.graphics.rectangle('fill', p.x, p.y, p.width, p.height)
end

function drawBall(b)
    setRGB(colors.lightestGreen)
    love.graphics.circle('fill', b.x, b.y, b.r, 20)
end

function setRGB(c)
    love.graphics.setColor(c.r, c.g, c.b)
end