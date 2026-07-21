resources = {
    items = {},
    spawner = { x = 200, y = 440, timer = 0, interval = 3 }
}

function resources_load()
    -- ѕусто
end

function resources_update(dt)
    resources.spawner.timer = resources.spawner.timer + dt
    if resources.spawner.timer >= resources.spawner.interval then
        resources.spawner.timer = 0
        resources_spawn()
    end
    
    -- —бор ресурсов
    for i = #resources.items, 1, -1 do
        local r = resources.items[i]
        local dist = math.sqrt((player.x - r.x)^2 + (player.y - r.y)^2)
        if dist < 25 then
            if r.type == "iron" then
                player.iron = player.iron + 1
            elseif r.type == "gold" then
                player.gold = player.gold + 1
            end
            table.remove(resources.items, i)
        end
    end
end

function resources_draw()
    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.circle("line", resources.spawner.x, resources.spawner.y, 20)
    
    for _, r in ipairs(resources.items) do
        if r.type == "iron" then
            love.graphics.setColor(0.7, 0.7, 0.7)
        elseif r.type == "gold" then
            love.graphics.setColor(1, 0.8, 0)
        end
        love.graphics.circle("fill", r.x, r.y, 8)
    end
end

function resources_spawn()
    local offsetX = (math.random() - 0.5) * 40
    local offsetY = (math.random() - 0.5) * 40
    local r = {
        x = resources.spawner.x + offsetX,
        y = resources.spawner.y + offsetY,
        type = "iron"
    }
    if math.random() < 0.2 then
        r.type = "gold"
    end
    table.insert(resources.items, r)
end