require("swords")

sword = {
    hasSword = true,
    attackTimer = 0,
    attackDuration = 0.15,
    isAttacking = false,
    startAngle = 0,
    currentAngle = 0,
    width = 256,
    height = 256,
    scale = 0.15
}

function sword_load()
    swords_load()
end

function sword.update(dt)
    if sword.isAttacking then
        sword.attackTimer = sword.attackTimer + dt
        local t = sword.attackTimer / sword.attackDuration
        
        if t >= 1 then
            sword.isAttacking = false
        else
            local ease = math.sin(t * math.pi / 2)
            sword.currentAngle = sword.startAngle + (math.pi / 2) * ease
        end
    end
end

function sword.startAttack(player, angle)
    if not sword.hasSword then return false end
    if sword.isAttacking then return false end
    
    sword.isAttacking = true
    sword.attackTimer = 0
    sword.startAngle = angle - math.pi / 4
    sword.currentAngle = sword.startAngle
    
    return true
end

function sword.attack(player, enemies)
    if not sword.hasSword then return false end
    if not sword.isAttacking then return false end
    
    local hit = false
    local damage = sword_getDamage()
    
    -- Треугольный хитбокс (рабочий, как раньше)
    local directionX = math.cos(sword.currentAngle)
    local directionY = math.sin(sword.currentAngle)
    local perpX = -directionY
    local perpY = directionX
    
    local tipX = player.x + directionX * 70
    local tipY = player.y + directionY * 70
    local baseX = player.x + directionX * 20
    local baseY = player.y + directionY * 20
    local baseLeftX = baseX + perpX * 35
    local baseLeftY = baseY + perpY * 35
    local baseRightX = baseX - perpX * 35
    local baseRightY = baseY - perpY * 35
    
    for _, e in ipairs(enemies) do
        if e.alive then
            if pointInTriangle(e.x, e.y, tipX, tipY, baseLeftX, baseLeftY, baseRightX, baseRightY) then
                hit = true
                enemy_hit(damage, player.x, player.y)
            end
        end
    end
    
    return hit
end

-- Добавь эту функцию, если её нет
function pointInTriangle(px, py, ax, ay, bx, by, cx, cy)
    local function sign(x1, y1, x2, y2, x3, y3)
        return (x1 - x3) * (y2 - y3) - (x2 - x3) * (y1 - y3)
    end
    local d1 = sign(px, py, ax, ay, bx, by)
    local d2 = sign(px, py, bx, by, cx, cy)
    local d3 = sign(px, py, cx, cy, ax, ay)
    local hasNeg = (d1 < 0) or (d2 < 0) or (d3 < 0)
    local hasPos = (d1 > 0) or (d2 > 0) or (d3 > 0)
    return not (hasNeg and hasPos)
end

function sword.draw(player)
    if not sword.hasSword then return end
    if not sword.isAttacking then return end
    
    local currentTexture = sword_getTexture()
    if not currentTexture then return end
    
    local offsetX = math.cos(sword.currentAngle) * 25
    local offsetY = math.sin(sword.currentAngle) * 25
    
    local x = player.x + offsetX
    local y = player.y + offsetY
    local imageAngle = sword.currentAngle + math.pi / 4
    
    local t = sword.attackTimer / sword.attackDuration
    local alpha = math.sin(t * math.pi)
    
    love.graphics.setColor(1, 1, 1, alpha)
    love.graphics.draw(currentTexture, x, y, imageAngle, sword.scale, sword.scale, 
                       sword.width/2, sword.height/2)
    love.graphics.setColor(1, 1, 1, 1)
end