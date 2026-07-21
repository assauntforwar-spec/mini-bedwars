-- Ограничение числа
function clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

-- Расстояние между двумя точками
function distance(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math.sqrt(dx*dx + dy*dy)
end

-- Проверка точки в прямоугольнике
function pointInRect(px, py, rx, ry, rw, rh)
    return px > rx and px < rx + rw and py > ry and py < ry + rh
end

-- Линейная интерполяция
function lerp(a, b, t)
    return a + (b - a) * t
end