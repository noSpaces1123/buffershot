Player = {
    x = WINDOW.CENTER_X, y = WINDOW.CENTER_Y,
    velocity = { x = 0, y = 0, speed = .7, cap = 20, drag = .4 },
    radius = 8,
    movementNotches = 5,
}


function DoPlayerMovement()
    local helpingXVel = false -- is the player pressing a button to move the player faster in the x-direction they're currently going?
    local helpingYVel = false -- is the player pressing a button to move the player faster in the y-direction they're currently going?

    local keys = {
        w = function ()
            helpingYVel = Player.velocity.y <= 0
            Player.velocity.y = Player.velocity.y - Player.velocity.speed * GlobalDT / Player.movementNotches
        end,
        s = function ()
            helpingYVel = Player.velocity.y >= 0
            Player.velocity.y = Player.velocity.y + Player.velocity.speed * GlobalDT / Player.movementNotches
        end,
        a = function ()
            helpingXVel = Player.velocity.x <= 0
            Player.velocity.x = Player.velocity.x - Player.velocity.speed * GlobalDT / Player.movementNotches
        end,
        d = function ()
            helpingXVel = Player.velocity.x >= 0
            Player.velocity.x = Player.velocity.x + Player.velocity.speed * GlobalDT / Player.movementNotches
        end,
    }

    for _ = 1, Player.movementNotches do
        for key, func in pairs(keys) do
            if love.keyboard.isDown(key) then
                func()
            end
        end

        ApplyPlayerDrag(not helpingXVel, not helpingYVel) -- if the player is not 'helping the x velocity' (thus counteracting it like moving in the opposite direction), drag should apply to help counteract it. the same for y.
        CapPlayerVelocity()
        ApplyPlayerVelocity()
        DoPlayerCollisions()
    end

    -- DoPlayerParticles()
end
function ApplyPlayerDrag(doOnX, doOnY)
    -- both of these conditionals cancel the function
    if not doOnX and not doOnY then return end
    if not PlayerIsMoving() then return end

    -- picture a right triangle where the base and height are the x and y velocities of the player...
    local c = GetPlayerVelocityMagnitude() -- calculates the length of the hypotenuse (see the function definition)
    local cTarget = zutil.relu(c - Player.velocity.drag * GlobalDT / Player.movementNotches) -- calculates c minus the drag constant and relu's the difference (zutil.relu(x) returns x when x > 0. otherwise returns 0)
    local scaleFactor = cTarget / c -- calculates the scale factor needed to scale the triangle by to get the hypotenuse length (c) to equal cTarget

    -- multiplies the 'side lengths' of the triangle by the scale factor
    if doOnX then Player.velocity.x = Player.velocity.x * scaleFactor end
    if doOnY then Player.velocity.y = Player.velocity.y * scaleFactor end



    --[[ This whole function was made in such a way to navigate around the drag issue that treating the velocity of the player with two independent scalars spawns:

    Usually, when building a velocity system like this so that the player has x and y velocities, an issue comes about with applying drag.
    Subtracting the drag constant from the x and y velocities independently causes the x and y velocities to reach 0 at different times, causing the player's movement
    to slow in a strange way.
    This is because, picturing a right triangle with the base and height are the x and y velocities, the ratio of the side lengths does not stay the same when reducing
    the base and height (x and y velocities) by the same rate.

    Instead, we can figure out what scale factor to use to scale down the triangle to get the length of the hypotenuse (the actual vector that the player moves along
    every frame) to be subtracted by the fixed drag constant.
    For example, if the hypotenuse's length is 3 px (a vector with a magnitude of 3 px/frame) and the drag constant is 1 px/frame, the vector's magnitude subtracted by
    the drag constant is 3 - 1 = 2 px/frame. Thus, the triangle must scale by a scale factor of 2/3. Multiplying the x and y velocities of the player (the base and height of the
    triangle) by this scale factor, the ratio of side lengths stays the same and the player slows down smoothly. Ta-da!
    ]]
end
function ApplyPlayerVelocity()
    Player.x = Player.x + Player.velocity.x * GlobalDT / Player.movementNotches
    Player.y = Player.y + Player.velocity.y * GlobalDT / Player.movementNotches
end
function CapPlayerVelocity()
    if GetPlayerVelocityMagnitude() <= Player.velocity.cap then return end -- cancel the function if it doesn't need to be run

    -- This function's structure is similar to ApplyPlayerDrag.

    local c = GetPlayerVelocityMagnitude()
    local cTarget = zutil.clamp(c, 0, Player.velocity.cap)
    local scaleFactor = cTarget / c

    Player.velocity.x = Player.velocity.x * scaleFactor
    Player.velocity.y = Player.velocity.y * scaleFactor
end

function DoPlayerCollisions()
    for _, self in ipairs(CurrentRoom.walls) do
        local closestX = zutil.clamp(Player.x, self.x, self.x + self.width)
        local closestY = zutil.clamp(Player.y, self.y, self.y + self.height)
        local flattenVelocityOf = ""
        local side

        local function chooseXSide()
            if Player.x < self.x then
                side = "left"
            elseif Player.x > self.x + self.width then
                side = "right"
            end
        end
        local function chooseYSide()
            if Player.y < self.y then
                side = "up"
            elseif Player.y > self.y + self.height then
                side = "down"
            end
        end

        local distance = zutil.distance(closestX, closestY, Player.x, Player.y)

        if distance < Player.radius then
            if Player.x < self.x or Player.x > self.x + self.width then
                flattenVelocityOf = flattenVelocityOf .. "x"

                chooseXSide()
            end
            if Player.y < self.y or Player.y > self.y + self.height then
                flattenVelocityOf = flattenVelocityOf .. "y"

                chooseYSide()
            end
            if flattenVelocityOf == "xy" then
                if math.abs(Player.x - closestX) > math.abs(Player.y - closestY) then
                    flattenVelocityOf = "x"
                    chooseXSide()
                else
                    flattenVelocityOf = "y"
                    chooseYSide()
                end
            end

            if side == "left" then
                Player.x = self.x - Player.radius
            elseif side == "right" then
                Player.x = self.x + self.width + Player.radius
            elseif side == "up" then
                Player.y = self.y - Player.radius
            elseif side == "down" then
                Player.y = self.y + self.height + Player.radius
            end

            if flattenVelocityOf == "x" then
                Player.velocity.x = 0
            elseif flattenVelocityOf == "y" then
                Player.velocity.y = 0
            end
        end
    end
end

function DoPlayerParticles(cancel)
    if not PlayerIsMoving() or cancel then return end

    local x, y = Player.x, Player.y
    local offsetAngle = math.random() * 2 * math.pi -- in rad ofc
    local magnitude = math.random() * Player.radius
    x = x + math.cos(offsetAngle) * magnitude
    y = y + math.sin(offsetAngle) * magnitude

    local startRadius = math.random() * 2 + 1
    local startSpeed = .5 + zutil.jitter(.05)

    table.insert(Particles, NewParticle(
        x, y, -- position
        startRadius, -- radius
        {0,0,0,1}, -- color
        startSpeed, -- speed
        math.random(360), -- degrees (direction)
        0, -- gravity
        math.random() * 30 + 40, -- lifespan
        false, -- shrink?
        function (self)
            self.speed = zutil.relu(self.speed - .02 * GlobalDT)
            self.radius = startRadius * self.speed / startSpeed
            self.color[4] = self.speed / startSpeed -- alpha
            if self.color[4] <= 0 then
                zutil.remove(Particles, self)
            end
        end
    ))
end

function PlayerIsMoving()
    return Player.velocity.x ~= 0 or Player.velocity.y ~= 0
end
function GetPlayerVelocityMagnitude()
    return zutil.pythag(math.abs(Player.velocity.x), math.abs(Player.velocity.y))
end

function DrawPlayer()
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle("fill", Player.x, Player.y, Player.radius, 90)
end