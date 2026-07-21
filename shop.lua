shop = {
    isOpen = false
}

function shop_load()
    -- Пока пусто, но нужна для совместимости
end

function shop_update(dt)
    if love.keyboard.isDown("b") and not inventory.moveMode then
        shop.isOpen = true
    else
        shop.isOpen = false
    end
end

function shop_draw()
    if not shop.isOpen then return end
    
    love.graphics.setColor(0, 0, 0, 0.85)
    love.graphics.rectangle("fill", 550, 50, 230, 500)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("SHOP", 640, 60)
    love.graphics.print("-------------------", 570, 85)
    love.graphics.print("1. Blocks x4 (4 iron)", 560, 110)
    love.graphics.print("2. Upgrade Sword", 560, 140)
    love.graphics.print("3. Armor (5 gold)", 560, 170)
    love.graphics.print("4. Pickaxe (8 gold)", 560, 200)
    love.graphics.print("-------------------", 570, 240)
    love.graphics.print("Current sword: " .. swords[currentSword].name, 570, 260)
    love.graphics.print("Damage: " .. sword_getDamage(), 570, 280)
    
    -- Показываем цену следующего меча
    local order = {"wood", "stone", "iron", "diamond"}
    local nextSword = nil
    for i, s in ipairs(order) do
        if currentSword == s and i < #order then
            nextSword = order[i + 1]
            break
        end
    end
    
    if nextSword then
        love.graphics.print("Next: " .. swords[nextSword].name, 570, 300)
        love.graphics.print("Price: " .. swords[nextSword].price .. " gold", 570, 320)
    else
        love.graphics.print("MAX LEVEL!", 570, 300)
    end
    
    love.graphics.print("-------------------", 570, 350)
    love.graphics.print("Press 1-4 to buy", 590, 430)
end

function shop_keypressed(key)
    if not shop.isOpen then return false end
    
    if key == "1" then
        if player.iron >= 4 then
            player.iron = player.iron - 4
            inventory_add("block", 4)
            print("Bought 4 blocks")
        end
        return true
    elseif key == "2" then
        print("Attempting to upgrade sword...")
        local success = sword_upgrade()
        if success then
            -- Добавляем меч в инвентарь (если его там нет)
            inventory_add("sword", 1)
            sword.hasSword = true
        end
        return true
    elseif key == "3" then
        if player.gold >= 5 then
            player.gold = player.gold - 5
            player.maxHealth = 150
            player.health = player.maxHealth
            print("Bought armor! Health: " .. player.health)
        end
        return true
    elseif key == "4" then
        if player.gold >= 8 then
            player.gold = player.gold - 8
            inventory_add("pickaxe", 1)
            print("Bought pickaxe!")
        end
        return true
    end
    
    return false
end