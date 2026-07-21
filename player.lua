player = {
    x = 400, y = 300,
    w = 20, h = 20,
    speed = 175,
    health = 100,
    maxHealth = 100,
    alive = true,
    iron = 67,
    gold = 67,
    img = nil,
    respawnTimer = 0
}

function player_load()
    player.img = love.graphics.newImage("images/v1.png")
end

function player_update(dt)
    if not player.alive then return end
    
    local moveX = 0
    local moveY = 0
    
    if love.keyboard.isDown("w") or love.keyboard.isDown("up") then moveY = moveY - 1 end
    if love.keyboard.isDown("s") or love.keyboard.isDown("down") then moveY = moveY + 1 end
    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then moveX = moveX - 1 end
    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then moveX = moveX + 1 end
    
    if moveX ~= 0 and moveY ~= 0 then
        moveX = moveX * 0.707
        moveY = moveY * 0.707
    end
    
    local newX = player.x + moveX * player.speed * dt
    if not world_checkBlockCollision(newX, player.y, player.w, player.h) then
        player.x = newX
    end
    
    local newY = player.y + moveY * player.speed * dt
    if not world_checkBlockCollision(player.x, newY, player.w, player.h) then
        player.y = newY
    end
    
    player.x = math.max(10, math.min(1400, player.x))
    player.y = math.max(10, math.min(800, player.y))
end

function player_draw()
    if not player.alive then return end
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(player.img, player.x, player.y, 0, 0.065, 0.065, 223, 223)
end

function player_takeDamage(amount)
    player.health = player.health - amount
    if player.health <= 0 then
        player.alive = false
        player.respawnTimer = 5
    end
end

function player_respawn()
    -- ÈÑÏÐÀÂËÅÍÎ: èñïîëüçóåì world.bed1
    if world.bed1.alive then
        player.alive = true
        player.health = player.maxHealth
        player.x = 200
        player.y = 475
        return true
    end
    return false
end