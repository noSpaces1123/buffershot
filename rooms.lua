WallProperties = {
    types = {
        regular = {
            fillColor = {.8,1,1},
        },
    },
    cornerRounding = 0,
    outlineWidth = 6,
    order2LinePadding = 10,
    screenBorderWallThickness = 60,

    getOutlineColor = function (type, order)
        local fill = WallProperties.types[type].fillColor

        local multiply
        if order == 1 then multiply = .5
        elseif order == 2 then multiply = .95
        end

        return { fill[1] * multiply, fill[2] * multiply, fill[3] * multiply }
    end,
}

Rooms = {}

CurrentRoom = {
    walls = {},
}


function InitializeRooms()
    Rooms[1] = {
        walls = {
            NewWall(-WallProperties.cornerRounding, -WallProperties.cornerRounding, WINDOW.WIDTH + WallProperties.cornerRounding * 2, WallProperties.screenBorderWallThickness + WallProperties.cornerRounding, "regular"),
            NewWall(-WallProperties.cornerRounding, -WallProperties.cornerRounding, WallProperties.screenBorderWallThickness + WallProperties.cornerRounding, WINDOW.HEIGHT + WallProperties.cornerRounding * 2, "regular"),
            NewWall(WINDOW.WIDTH - WallProperties.screenBorderWallThickness + WallProperties.cornerRounding, -WallProperties.cornerRounding, WallProperties.screenBorderWallThickness + WallProperties.cornerRounding, WINDOW.HEIGHT + WallProperties.cornerRounding * 2, "regular"),
            NewWall(-WallProperties.cornerRounding, WINDOW.HEIGHT - WallProperties.screenBorderWallThickness + WallProperties.cornerRounding, WINDOW.WIDTH + WallProperties.cornerRounding * 2, WallProperties.screenBorderWallThickness + WallProperties.cornerRounding, "regular"),
        },
    }

    CurrentRoom.walls = Rooms[1].walls
end


function NewWall(x, y, width, height, type)
    return {
        x = x, y = y, width = width, height = height,
        type = type,
    }
end
function DrawWalls(tableOfWalls)
    local function outlines(order)
        love.graphics.setLineWidth(WallProperties.outlineWidth)
        for _, self in ipairs(tableOfWalls) do
            if order == 1 then
                love.graphics.setColor(WallProperties.getOutlineColor(self.type, 1))
                love.graphics.rectangle("line", self.x, self.y, self.width, self.height, WallProperties.cornerRounding)
            else
                love.graphics.setColor(WallProperties.getOutlineColor(self.type, 2))
                love.graphics.rectangle("line", self.x + WallProperties.order2LinePadding, self.y + WallProperties.order2LinePadding, self.width - WallProperties.order2LinePadding * 2, self.height - WallProperties.order2LinePadding * 2, WallProperties.cornerRounding)
            end
        end
    end
    local function fills(order)
        for _, self in ipairs(tableOfWalls) do
            local properties = WallProperties.types[self.type]
            love.graphics.setColor(properties.fillColor)

            if order == 1 then
                love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, WallProperties.cornerRounding)
            elseif order == 2 then
                love.graphics.rectangle("fill", self.x + WallProperties.order2LinePadding, self.y + WallProperties.order2LinePadding, self.width - WallProperties.order2LinePadding * 2, self.height - WallProperties.order2LinePadding * 2, WallProperties.cornerRounding)
            end
        end
    end

    outlines(1)
    fills(1)
    outlines(2)
    fills(2)
end