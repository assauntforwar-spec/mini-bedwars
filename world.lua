world = {
    island1 = { x = 100, y = 400, w = 200, h = 150 },
    island2 = { x = 1100, y = 400, w = 200, h = 150 },
    bed1 = { x = 200, y = 475, w = 50, h = 25, alive = true },
    bed2 = { x = 1200, y = 475, w = 50, h = 25, alive = true },
    placedBlocks = {},
    currentBlockType = "wool",
    breakingBlock = nil,
    breakProgress = 0
}

function world_load()
    -- Пустая, для совместимости
end

function world_update(dt)
    if world.breakingBlock == nil then return end
    
    world.breakProgress = world.breakProgress + dt
    
    -- Ломание кровати
    if world.breakingBlock == "bed" then
        if world.breakProgress >= 0.5 then
            world.bed2.alive = false
            world.breakingBlock = nil
            world.breakProgress = 0
            print("Enemy bed destroyed!")
        end
        return
    end
    
    -- Ломание обычного блока (оставляем как есть)
    if world.breakProgress >= 1.0 then
        for i, b in ipairs(world.placedBlocks) do
            if b == world.breakingBlock then
                table.remove(world.placedBlocks, i)
                break
            end
        end
        world.breakingBlock = nil
        world.breakProgress = 0
    end
end


function world_drawBed(bed)
    if bed.alive then
        love.graphics.setColor(0.8, 0.2, 0.2)
        love.graphics.rectangle("fill", bed.x - bed.w/2, bed.y - bed.h/2, bed.w, bed.h)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("BED", bed.x - 15, bed.y - 6)
        love.graphics.setColor(1, 1, 1, 0.5)
        love.graphics.rectangle("line", bed.x - bed.w/2, bed.y - bed.h/2, bed.w, bed.h)
    else
        love.graphics.setColor(0.3, 0.3, 0.3)
        love.graphics.rectangle("fill", bed.x - bed.w/2, bed.y - bed.h/2, bed.w, bed.h)
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.print("DESTROYED", bed.x - 30, bed.y - 6)
    end
end


function world_draw()
    -- Острова
    love.graphics.setColor(0.3, 0.8, 0.3)
    love.graphics.rectangle("fill", world.island1.x, world.island1.y, world.island1.w, world.island1.h)
    love.graphics.rectangle("fill", world.island2.x, world.island2.y, world.island2.w, world.island2.h)
    love.graphics.setColor(0.4, 0.3, 0.2)
    love.graphics.rectangle("line", world.island1.x, world.island1.y, world.island1.w, world.island1.h)
    love.graphics.rectangle("line", world.island2.x, world.island2.y, world.island2.w, world.island2.h)
    
    -- Кровати
    world_drawBed(world.bed1)
    world_drawBed(world.bed2)
    
-- Шкала ломания КРОВАТИ
if world.breakingBlock == "bed" and world.breakProgress > 0 then
    local bedX = world.bed2.x
    local bedY = world.bed2.y - 25
    
    love.graphics.setColor(0.3, 0.3, 0.3, 0.8)
    love.graphics.rectangle("fill", bedX - 30, bedY, 60, 8)
    
    local progressWidth = 60 * (world.breakProgress / 0.5)
    love.graphics.setColor(1, 0.5, 0, 0.9)
    love.graphics.rectangle("fill", bedX - 30, bedY, progressWidth, 8)
    
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.rectangle("line", bedX - 30, bedY, 60, 8)
end

    -- Прозрачная сетка
    love.graphics.setColor(1, 1, 1, 0.08)
    for gx = 0, WORLD_WIDTH, BLOCK_SIZE do
        love.graphics.line(gx, 0, gx, WORLD_HEIGHT)
    end
    for gy = 0, WORLD_HEIGHT, BLOCK_SIZE do
        love.graphics.line(0, gy, WORLD_WIDTH, gy)
    end
    
    -- Блоки
    for _, b in ipairs(world.placedBlocks) do
        love.graphics.setColor(b.color)
        love.graphics.rectangle("fill", b.x, b.y, b.w, b.h)
        
        if b.type == "wool" then
            love.graphics.setColor(1, 1, 1, 0.6)
        else
            love.graphics.setColor(1, 1, 0, 0.6)
        end
        love.graphics.rectangle("line", b.x, b.y, b.w, b.h)
    end
    
    -- Шкала ломания
    if world.breakingBlock and world.breakingBlock ~= "bed" and world.breakProgress > 0 then
        local block = world.breakingBlock
        local blockX = block.x + BLOCK_SIZE/2
        local blockY = block.y - 10
        
        love.graphics.setColor(0.3, 0.3, 0.3, 0.8)
        love.graphics.rectangle("fill", blockX - 25, blockY, 50, 8)
        
        local progressWidth = 50 * (world.breakProgress / BREAK_TIME)
        love.graphics.setColor(1, 1, 0, 0.9)
        love.graphics.rectangle("fill", blockX - 25, blockY, progressWidth, 8)
        
        love.graphics.setColor(1, 1, 1, 0.8)
        love.graphics.rectangle("line", blockX - 25, blockY, 50, 8)
    end
end

function world_placeBlock(worldX, worldY)
    local gx = math.floor(worldX / BLOCK_SIZE) * BLOCK_SIZE
    local gy = math.floor(worldY / BLOCK_SIZE) * BLOCK_SIZE
    
    local color = world.currentBlockType == "wool" and {0.2, 0.4, 1} or {0.6, 0.4, 0.2}
    
    table.insert(world.placedBlocks, {
        x = gx, y = gy,
        w = BLOCK_SIZE, h = BLOCK_SIZE,
        color = color,
        type = world.currentBlockType
    })
end

function world_canPlaceBlock(worldX, worldY)
    local gx = math.floor(worldX / BLOCK_SIZE) * BLOCK_SIZE
    local gy = math.floor(worldY / BLOCK_SIZE) * BLOCK_SIZE
    
    for _, b in ipairs(world.placedBlocks) do
        if b.x == gx and b.y == gy then return false end
    end
    
    local blockCenterX = gx + 15
    local blockCenterY = gy + 15
    local isOnIsland = pointInRect(blockCenterX, blockCenterY, world.island1.x, world.island1.y, world.island1.w, world.island1.h) or
                       pointInRect(blockCenterX, blockCenterY, world.island2.x, world.island2.y, world.island2.w, world.island2.h)
    
    if world.currentBlockType == "wool" and not isOnIsland then return false end
    if world.currentBlockType == "bridge" and isOnIsland then return false end
    
    return true
end

function world_checkBlockCollision(x, y, w, h)
    local left = x - w/2
    local right = x + w/2
    local top = y - h/2
    local bottom = y + h/2
    
    for _, b in ipairs(world.placedBlocks) do
        if b.type == "wool" then
            if right > b.x and left < b.x + b.w and bottom > b.y and top < b.y + b.h then
                return true
            end
        end
    end
    return false
end

function world_isOnGround(x, y, w, h)
    local left = x - w/2
    local right = x + w/2
    local bottom = y + h/2 + 3
    
    if right + 10 > world.island1.x and left - 10 < world.island1.x + world.island1.w and
       bottom > world.island1.y and bottom < world.island1.y + world.island1.h then
        return true
    end
    
    if right + 10 > world.island2.x and left - 10 < world.island2.x + world.island2.w and
       bottom > world.island2.y and bottom < world.island2.y + world.island2.h then
        return true
    end
    
    for _, b in ipairs(world.placedBlocks) do
        if b.type == "bridge" then
            if right + 10 > b.x and left - 10 < b.x + b.w and
               bottom > b.y and bottom < b.y + b.h then
                return true
            end
        end
    end
    
    return false
end

function world_switchBlockType()
    world.currentBlockType = world.currentBlockType == "wool" and "bridge" or "wool"
end


function world_startBreaking(worldX, worldY)
    local gx = math.floor(worldX / 30) * 30
    local gy = math.floor(worldY / 30) * 30
    
    -- Проверка блоков (работает)
    for _, b in ipairs(world.placedBlocks) do
        if b.x == gx and b.y == gy then
            world.breakingBlock = b
            world.breakProgress = 0
            return true
        end
    end
    
    -- ДОБАВЬ ЭТО: проверка кровати
    local bedLeft = world.bed2.x - world.bed2.w/2
    local bedRight = world.bed2.x + world.bed2.w/2
    local bedTop = world.bed2.y - world.bed2.h/2
    local bedBottom = world.bed2.y + world.bed2.h/2
    
    if worldX > bedLeft and worldX < bedRight and 
       worldY > bedTop and worldY < bedBottom then
        if world.bed2.alive then
            world.breakingBlock = "bed"
            world.breakProgress = 0
            return true
        end
    end
    
    return false
end