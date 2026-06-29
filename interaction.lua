DrawingWall = {
    key = "z",
    allowed = true,
    start = { x = 0, y = 0 },
}


function love.mousepressed(x, y, button)
    if DrawingWall.allowed and love.keyboard.isDown(DrawingWall.key) then
        if button == 1 then
            DrawingWall.start.x = x
            DrawingWall.start.y = y
        elseif button == 2 then
            for index, self in ipairs(CurrentRoom.walls) do
                if zutil.touching(x, y, 0, 0, self.x, self.y, self.width, self.height) then
                    table.remove(CurrentRoom.walls, index)
                    goto continue
                end
            end
            ::continue::
        end
    end
end

function love.mousereleased(x, y, button)
    if button == 1 then
        if DrawingWall.allowed and love.keyboard.isDown(DrawingWall.key) then
            table.insert(CurrentRoom.walls, NewWall(DrawingWall.start.x, DrawingWall.start.y, x - DrawingWall.start.x, y - DrawingWall.start.y, "regular"))
        end
    end
end