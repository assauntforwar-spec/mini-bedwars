enemy = {
    x = 1250, y = 475,
    w = 20, h = 20,
    speed = 100,
    health = 50,
    maxHealth = 50,
    alive = true,
    attackTimer = 0,
    attackCooldown = 1.0,
    hitFlashTimer = 0,
    hitFlashDuration = 0.15,
    knockbackTimer = 0,
    knockbackDuration = 0.2,
    knockbackX = 0,
    knockbackY = 0
}

function enemy_update(dt, player)
    -- Обновляем таймер пульсации
    if enemy.hitFlashTimer > 0 then
        enemy.hitFlashTimer = enemy.hitFlashTimer - dt
    end
    
    -- Обновляем откидывание
    if enemy.knockbackTimer > 0 then
        enemy.knockbackTimer = enemy.knockbackTimer - dt
        enemy.x = enemy.x + enemy.knockbackX * dt
        enemy.y = enemy.y + enemy.knockbackY * dt
        return
    end
    
    if not enemy.alive then return end
    
    local dx = player.x - enemy.x
    local dy = player.y - enemy.y
    local dist = math.sqrt(dx*dx + dy*dy)
    
    if dist > 0 then
        local moveX = (dx / dist) * enemy.speed * dt
        local moveY = (dy / dist) * enemy.speed * dt
        
        local newX = enemy.x + moveX
        local newY = enemy.y + moveY
        
        -- ИСПРАВЛЕНО: используем world.island2
        newX = math.max(world.island2.x + 5, math.min(world.island2.x + world.island2.w - 5, newX))
        newY = math.max(world.island2.y + 5, math.min(world.island2.y + world.island2.h - 5, newY))
        
        enemy.x = newX
        enemy.y = newY
    end
    
    local distToPlayer = math.sqrt((player.x - enemy.x)^2 + (player.y - enemy.y)^2)
    if distToPlayer < 30 then
        enemy.attackTimer = enemy.attackTimer + dt
        if enemy.attackTimer >= enemy.attackCooldown then
            enemy.attackTimer = 0
            player.health = player.health - 10
            if player.health <= 0 then
                player.alive = false
                player.respawnTimer = 5
            end
        end
    end
end

function enemy_draw()
    if not enemy.alive then return end
    
    if enemy.hitFlashTimer > 0 then
        local intensity = enemy.hitFlashTimer / enemy.hitFlashDuration
        love.graphics.setColor(1, 0.3 + intensity * 0.7, 0.3 + intensity * 0.7)
    else
        love.graphics.setColor(1, 0, 0)
    end
    
    love.graphics.rectangle("fill", enemy.x - enemy.w/2, enemy.y - enemy.h/2, enemy.w, enemy.h)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("ENEMY", enemy.x - 20, enemy.y - 15)
    
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", enemy.x - 25, enemy.y - 25, 50 * (enemy.health/enemy.maxHealth), 5)
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("line", enemy.x - 25, enemy.y - 25, 50, 5)
end

function enemy_respawn()
    enemy.alive = true
    enemy.health = enemy.maxHealth
    enemy.x = 1250
    enemy.y = 475
    enemy.attackTimer = 0
    enemy.hitFlashTimer = 0
    enemy.knockbackTimer = 0
end

function enemy_hit(damage, sourceX, sourceY)
    if not enemy.alive then return false end
    
    enemy.health = enemy.health - damage
    enemy.hitFlashTimer = enemy.hitFlashDuration
    
    -- Откидывание
    local dx = enemy.x - sourceX
    local dy = enemy.y - sourceY
    local dist = math.sqrt(dx*dx + dy*dy)
    if dist > 0 then
        local knockbackForce = 50
        enemy.knockbackX = (dx / dist) * knockbackForce
        enemy.knockbackY = (dy / dist) * knockbackForce
        enemy.knockbackTimer = enemy.knockbackDuration
    end
    
    if enemy.health <= 0 then
        enemy.alive = false
        return true
    end
    return false
end