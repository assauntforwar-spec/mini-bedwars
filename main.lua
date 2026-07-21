require("constants")
require("utils")
require("camera")
require("player")
require("enemy")
require("sword")
require("swords")  -- <-- ÄÎÁÀÂÜ ÝÒÓ ÑÒÐÎÊÓ
require("inventory")
require("world")
require("shop")
require("resources")

function love.load()
    love.window.setMode(800, 600)
    
    -- Çàãðóæàåì âñ¸
    player_load()
    sword_load()
    inventory_load()
    world_load()
    resources_load()
    shop_load()
    
    -- Çàãðóæàåì ñåðäå÷êè
    heartFull = love.graphics.newImage("images/heart_full.png")
    heartHalf = love.graphics.newImage("images/heart_half.png")
    heartEmpty = love.graphics.newImage("images/heart_container.png")
    
    font = love.graphics.newFont(14)
    
    voidTimer = 0
-- sdk.init(123) -- ID ïîçæå ïîëó÷èøü â èõ âåá-ïàíåëè
-- sdk.join()
end

function love.update(dt)
    if dt > 0.05 then dt = 0.05 end
    
    if not player.alive then
        player.respawnTimer = (player.respawnTimer or 5) - dt
        if player.respawnTimer <= 0 then
            if player_respawn() then
                enemy_respawn()
            end
        end
        return
    end
    
    player_update(dt)
    enemy_update(dt, player)
    sword.update(dt)  -- ÈÑÏÐÀÂËÅÍÎ: áûëî sword_update(dt)
    inventory_update(dt)
    resources_update(dt)
    shop_update(dt)
    world_update(dt)
    
    camera_setTarget(player.x, player.y)
    
    -- Ïðîâåðêà ïóñòîòû
    if not world_isOnGround(player.x, player.y, player.w, player.h) then
        voidTimer = voidTimer + dt
        if voidTimer >= 1.0 then
            player.alive = false
            player.respawnTimer = 5
            voidTimer = 0
        end
    else
        voidTimer = 0
    end
-- sdk.update()
end

function love.mousepressed(x, y, button)
    if not player.alive then return end
    if inventory.moveMode then return end
    
    local worldX, worldY = camera_getWorldPos(x, y)
    
    if button == 1 then  -- ËÊÌ
        local selectedType = inventory_useSelected()
        
        if selectedType == "sword" then
local angle = math.atan2(worldY - player.y, worldX - player.x)
            print("Mouse angle: " .. (angle * 180 / math.pi))
            
            -- ÇÀÏÓÑÊÀÅÌ ÀÒÀÊÓ
            if sword.startAttack(player, angle) then
                -- ÍÀÍÎÑÈÌ ÓÐÎÍ
                if sword.attack(player, {enemy}) and enemy.alive then
                    print("Enemy defeated!")
                end
            end
        elseif selectedType == "block" then
            if world_canPlaceBlock(worldX, worldY) then
                if inventory_remove(inventory.selectedSlot, 1) then
                    world_placeBlock(worldX, worldY)
                end
            end
        end
    elseif button == 2 then  -- ÏÊÌ - ëîìàòü
        local selectedType = inventory_useSelected()
        if selectedType == "pickaxe" then
            world_startBreaking(worldX, worldY)
        end
    end
end
function love.draw()
    -- Çàëèâàåì ôîí ãîëóáûì (êàê áûëî)
    love.graphics.setColor(0.5, 0.7, 1)
    love.graphics.rectangle("fill", 0, 0, 800, 600)
    
    camera_begin()
    
    world_draw()
    resources_draw()
    player_draw()
    sword.draw(player)
    enemy_draw()
    
    camera_end()
    
    -- HUD
    drawHearts(player.health, player.maxHealth, 10, 10)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Iron: " .. player.iron .. "  Gold: " .. player.gold, 10, 35)
    love.graphics.print("Block type (Q): " .. (world.currentBlockType == "wool" and "WOOL (on islands)" or "BRIDGE (in void)"), 10, 60)
    love.graphics.print("Sword: " .. swords[currentSword].name .. " (" .. sword_getDamage() .. " dmg)", 10, 85)
    inventory_draw()
    
    if shop.isOpen then
        shop_draw()
    end
    
    -- ÑÎÎÁÙÅÍÈÅ Î ÑÌÅÐÒÈ
    if not player.alive then
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 250, 270, 300, 60)
        
        love.graphics.setColor(1, 0.3, 0.3)
        love.graphics.print("YOU DIED!", 370, 280)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Respawn in " .. math.ceil(player.respawnTimer) .. "s", 355, 305)
    end
end

function love.keypressed(key)
    if inventory_keypressed(key) then return end
    if shop_keypressed(key) then return end
    
    if key == "q" then
        world_switchBlockType()
    end
end

function drawHearts(health, maxHealth, x, y)
    local spacing = 4
    local heartsCount = maxHealth / 20
    
    local emptyW = heartEmpty:getWidth()
    local heartWidth = emptyW
    
    for i = 0, heartsCount - 1 do
        local heartX = x + i * (heartWidth + spacing)
        local fullHearts = math.floor(health / 20)
        local remainder = health % 20
        local halfHeart = remainder >= 10 and i == fullHearts
        
        love.graphics.draw(heartEmpty, heartX, y)
        
        if i < fullHearts then
            love.graphics.draw(heartFull, heartX, y)
        elseif halfHeart then
            love.graphics.draw(heartHalf, heartX, y)
        end
    end
end