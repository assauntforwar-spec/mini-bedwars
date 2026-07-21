inventory = {
    slots = {},
    selectedSlot = 1,
    maxSlots = 5,
    moveMode = false,
    moveFromSlot = nil
}

function inventory_load()
    for i = 1, inventory.maxSlots do
        inventory.slots[i] = { type = nil, count = 0 }
    end
    
    inventory.slots[1] = { type = "block", count = 16, name = "BLOCKS", color = {0.2, 0.4, 1} }
    inventory.slots[2] = { type = nil, count = 0, name = "EMPTY", color = {0.3, 0.3, 0.3} }
    inventory.slots[3] = { type = nil, count = 0, name = "EMPTY", color = {0.3, 0.3, 0.3} }
    inventory.slots[4] = { type = nil, count = 0, name = "EMPTY", color = {0.3, 0.3, 0.3} }
    inventory.slots[5] = { type = nil, count = 0, name = "EMPTY", color = {0.3, 0.3, 0.3} }
end

function inventory_update(dt)
    if not inventory.moveMode then
        for i = 1, inventory.maxSlots do
            if love.keyboard.isDown(tostring(i)) then
                inventory.selectedSlot = i
            end
        end
    end
end

function inventory_keypressed(key)
    if key == "e" then
        if not inventory.moveMode then
            inventory.moveMode = true
            print("Move mode ON - Press number slot to move")
        else
            inventory.moveMode = false
            inventory.moveFromSlot = nil
            print("Move mode OFF")
        end
        return true
    end
    
    if inventory.moveMode then
        for i = 1, inventory.maxSlots do
            if key == tostring(i) then
                if inventory.moveFromSlot == nil then
                    if inventory.slots[i].type ~= nil then
                        inventory.moveFromSlot = i
                        print("Selected slot " .. i .. " - " .. inventory.slots[i].name)
                    else
                        print("Slot " .. i .. " is empty!")
                    end
                else
                    inventory_moveItem(inventory.moveFromSlot, i)
                    inventory.moveMode = false
                    inventory.moveFromSlot = nil
                    print("Move mode OFF")
                end
                return true
            end
        end
    end
    
    return false
end

function inventory_moveItem(from, to)
    if from == to then
        return false
    end
    
    local tempSlot = {
        type = inventory.slots[from].type,
        count = inventory.slots[from].count,
        name = inventory.slots[from].name,
        color = inventory.slots[from].color
    }
    
    inventory.slots[from].type = inventory.slots[to].type
    inventory.slots[from].count = inventory.slots[to].count
    inventory.slots[from].name = inventory.slots[to].name
    inventory.slots[from].color = inventory.slots[to].color
    
    inventory.slots[to].type = tempSlot.type
    inventory.slots[to].count = tempSlot.count
    inventory.slots[to].name = tempSlot.name
    inventory.slots[to].color = tempSlot.color
    
    return true
end

function inventory_add(type, count)
    for i, slot in ipairs(inventory.slots) do
        if slot.type == type then
            slot.count = slot.count + count
            return true
        end
    end
    
    for i, slot in ipairs(inventory.slots) do
        if slot.type == nil then
            slot.type = type
            slot.count = count
            if type == "block" then
                slot.name = "BLOCKS"
                slot.color = {0.2, 0.4, 1}
            elseif type == "sword" then
                slot.name = "SWORD"
                slot.color = {0.8, 0.8, 0.8}
            elseif type == "pickaxe" then
                slot.name = "PICKAXE"
                slot.color = {0.6, 0.6, 0.2}
            end
            return true
        end
    end
    
    return false
end

function inventory_remove(slotIndex, count)
    local slot = inventory.slots[slotIndex]
    if slot and slot.count >= count then
        slot.count = slot.count - count
        if slot.count <= 0 then
            slot.type = nil
            slot.name = "EMPTY"
            slot.color = {0.3, 0.3, 0.3}
        end
        return true
    end
    return false
end

function inventory_getSelectedSlot()
    return inventory.slots[inventory.selectedSlot]
end

function inventory_draw()
    local slotSize = 50
    local startX = love.graphics.getWidth() - (inventory.maxSlots * slotSize) - 10
    local startY = love.graphics.getHeight() - slotSize - 10
    
    for i, slot in ipairs(inventory.slots) do
        local x = startX + (i-1) * slotSize
        local y = startY
        
        if i == inventory.selectedSlot and not inventory.moveMode then
            love.graphics.setColor(1, 1, 0, 0.5)
        elseif inventory.moveMode and inventory.moveFromSlot == i then
            love.graphics.setColor(0, 1, 0, 0.5)
        elseif inventory.moveMode then
            love.graphics.setColor(1, 0, 0, 0.3)
        else
            love.graphics.setColor(0.2, 0.2, 0.2, 0.7)
        end
        love.graphics.rectangle("fill", x, y, slotSize, slotSize)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("line", x, y, slotSize, slotSize)
        
        if slot.type then
            love.graphics.setColor(slot.color)
            if slot.type == "block" then
                love.graphics.rectangle("fill", x + 10, y + 10, slotSize - 20, slotSize - 20)
                love.graphics.setColor(1, 1, 1)
                love.graphics.print(slot.count, x + 5, y + slotSize - 15)
            elseif slot.type == "sword" then
                love.graphics.setColor(0.8, 0.8, 0.8)
                love.graphics.rectangle("fill", x + 20, y + 10, 10, slotSize - 20)
                love.graphics.setColor(1, 1, 1)
                love.graphics.print("YES", x + 5, y + slotSize - 15)
            elseif slot.type == "pickaxe" then
                love.graphics.setColor(0.6, 0.6, 0.2)
                love.graphics.rectangle("fill", x + 15, y + 10, 20, slotSize - 20)
                love.graphics.setColor(1, 1, 1)
                love.graphics.print("YES", x + 5, y + slotSize - 15)
            end
        end
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(slot.name, x + 5, y - 12)
    end
    
    if inventory.moveMode then
        love.graphics.setColor(1, 1, 0)
        love.graphics.print("MOVE MODE: Press number slot to move", 10, 200)
        if inventory.moveFromSlot then
            love.graphics.print("Move FROM slot " .. inventory.moveFromSlot .. " - Press target slot", 10, 220)
        else
            love.graphics.print("Select source slot", 10, 220)
        end
    end
end

function inventory_getSelectedItemType()
    local slot = inventory_getSelectedSlot()
    if slot and slot.count > 0 then
        return slot.type
    end
    return nil
end

function inventory_useSelected()
    local slot = inventory_getSelectedSlot()
    if slot and slot.count > 0 then
        return slot.type
    end
    return nil
end