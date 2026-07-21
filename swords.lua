-- swords.lua (должен быть ТОЛЬКО таким)

swords = {
    wood = {
        name = "Wood Sword",
        damage = 15,
        price = 0,
        color = {0.6, 0.4, 0.2},
        image = nil,
        unlocked = true
    },
    stone = {
        name = "Stone Sword",
        damage = 25,
        price = 15,
        color = {0.5, 0.5, 0.5},
        image = nil,
        unlocked = false
    },
    iron = {
        name = "Iron Sword",
        damage = 40,
        price = 30,
        color = {0.8, 0.8, 0.8},
        image = nil,
        unlocked = false
    },
    diamond = {
        name = "Diamond Sword",
        damage = 60,
        price = 50,
        color = {0.2, 0.8, 1},
        image = nil,
        unlocked = false
    }
}

currentSword = "wood"

function swords_load()
    swords.wood.image = love.graphics.newImage("images/wooden_sword.png")
    swords.stone.image = love.graphics.newImage("images/stone_sword.png")
    swords.iron.image = love.graphics.newImage("images/iron_sword.png")
    swords.diamond.image = love.graphics.newImage("images/diamond_sword.png")
    
    for _, s in pairs(swords) do
        if s.image then
            s.image:setFilter("linear", "linear")
        end
    end
end

function sword_upgrade()
    local order = {"wood", "stone", "iron", "diamond"}
    local currentIndex = 1
    for i, s in ipairs(order) do
        if currentSword == s then
            currentIndex = i
            break
        end
    end
    
    local nextIndex = currentIndex + 1
    if nextIndex <= #order then
        local nextSword = order[nextIndex]
        if player.gold >= swords[nextSword].price then
            player.gold = player.gold - swords[nextSword].price
            currentSword = nextSword
            sword.hasSword = true
            print("Upgraded to " .. swords[nextSword].name)
            return true
        end
    end
    return false
end

function sword_getDamage()
    return swords[currentSword].damage
end

function sword_getTexture()
    return swords[currentSword].image
end

function sword_getCurrentName()
    return swords[currentSword].name
end