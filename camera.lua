camera = {
    x = 0,
    y = 0,
    zoom = 1.0
}

function camera_setTarget(x, y)
    camera.x = x
    camera.y = y
end

function camera_begin()
    love.graphics.push()
    love.graphics.scale(camera.zoom, camera.zoom)
    love.graphics.translate(400 - camera.x, 300 - camera.y)
end

function camera_end()
    love.graphics.pop()
end

function camera_getWorldPos(screenX, screenY)
    local worldX = (screenX - 400) / camera.zoom + camera.x
    local worldY = (screenY - 300) / camera.zoom + camera.y
    return worldX, worldY
end