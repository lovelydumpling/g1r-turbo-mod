local SCREEN_ID = "TurboOptions"

local lastGamepadPress = nil
local pendingOpeningButton = nil
local activeScreen = nil
local triggerState = {}

local function getRowKey(row)
    if not row then
        return nil
    end

    if row.label == "TURBO A" then
        return "turboA"
    elseif row.label == "TURBO B" then
        return "turboB"
    elseif row.label == "SPEEDUP" then
        return "speedup"
    end

    return nil
end

local function beginAssignment(screen, row, physical)
    local key = getRowKey(row)

    if not key then
        return
    end

    screen.assigningKey = key
    pendingOpeningButton = physical
    triggerState = {}
end

local function clearActiveScreen(screen)
    if activeScreen == screen then
        activeScreen = nil
    end
end

local function finishAssignment(mod, screen, physical)
    local key = screen.assigningKey

    if not key then
        return false
    end

    local valid = false

    for _, button in ipairs(
        mod.exports.turboConfig.buttons
    ) do
        if button[2] == physical then
            valid = true
            break
        end
    end

    if not valid then
        return true
    end

    mod.exports.turboConfig.assign(
        screen.game,
        key,
        physical
    )

    screen.assigningKey = nil
    pendingOpeningButton = nil

    return true
end

local function getTriggerPress(ev)
    if ev.phase ~= "axis" then
        return nil
    end

    local axis = ev.axis

    if axis == "lt"
        or axis == "lefttrigger"
    then
        axis = "triggerleft"
    elseif axis == "rt"
        or axis == "righttrigger"
    then
        axis = "triggerright"
    end

    if axis ~= "triggerleft"
        and axis ~= "triggerright"
    then
        return nil
    end

    local wasPressed =
        triggerState[axis] or false

    local value = ev.value or 0

    if not wasPressed and value >= 0.35 then
        triggerState[axis] = true
        return axis
    end

    if wasPressed and value <= 0.20 then
        triggerState[axis] = false
    end

    return nil
end

local loadedGenerations = {}

local generationCache =
setmetatable(
    {},
    {
        __mode = "k",
    }
)

local function getGeneration(game)
local cached = generationCache[game]

if cached then
    return cached
    end

    local ok, generation =
    pcall(function()
    return require("src.core.GameVersion").generation()
    end)

    if not ok or not generation then
        error(
            "Could not determine game generation: "
            .. tostring(generation)
        )
        end

        generationCache[game] = generation

        return generation
        end

local function loadGeneration(mod, generation)
    if loadedGenerations[generation] then
        return loadedGenerations[generation]
    end

    mod.log:info(
        "Loading options module for generation="
        .. tostring(generation)
    )

    local relative

    if generation == 1 then
        relative = "features/options/gen1.lua"
    elseif generation == 2 then
        relative = "features/options/gen2.lua"
    elseif generation == 3 then
        relative = "features/options/gen3.lua"
    else
        error("Unsupported game generation: " .. tostring(generation))
    end

    local source = assert(mod:read(relative))
    local chunk = assert(loadstring(source, "@" .. relative))
    local module = assert(chunk())

    loadedGenerations[generation] = module

    return module
end

local function makeRows(mod, game)
    local config = mod.exports.turboConfig

    local function cycleButton(key, direction)
        local current = config.get(game, key)
        local index = 0

        if current ~= false then
            for i, choice in ipairs(config.buttons) do
                if choice[2] == current then
                    index = i
                    break
                end
            end
        end

        index =
            (index + direction)
            % (#config.buttons + 1)

        local value = false

        if index > 0 then
            value = config.buttons[index][2]
        end

        config.set(game, key, value)
    end

    return {
        {
            label = "TURBO A",
            value = function()
                return config.buttonLabel(
                    config.get(game, "turboA")
                )
            end,
            step = function(_, direction)
                cycleButton("turboA", direction)
            end,
        },

        {
            label = "TURBO B",
            value = function()
                return config.buttonLabel(
                    config.get(game, "turboB")
                )
            end,
            step = function(_, direction)
                cycleButton("turboB", direction)
            end,
        },

        {
            label = "SPEEDUP",
            value = function()
                return config.buttonLabel(
                    config.get(game, "speedup")
                )
            end,
            step = function(_, direction)
                cycleButton("speedup", direction)
            end,
        },

        {
            label = "SPEED",
            value = function()
                return config.speedLabel(
                    config.get(game, "multiplier")
                )
            end,
            step = function(_, direction)
                local current =
                    config.get(game, "multiplier")

                local index = 1

                for i, speed in ipairs(config.speeds) do
                    if speed == current then
                        index = i
                        break
                    end
                end

                index =
                    (index - 1 + direction)
                    % #config.speeds + 1

                config.set(
                    game,
                    "multiplier",
                    config.speeds[index]
                )
            end,
        },
    }
end

local function clearSelected(mod, game, row)
    if not row then
        return
    end

    if row.label == "TURBO A" then
        mod.exports.turboConfig.set(
            game,
            "turboA",
            false
        )

    elseif row.label == "TURBO B" then
        mod.exports.turboConfig.set(
            game,
            "turboB",
            false
        )

    elseif row.label == "SPEEDUP" then
        mod.exports.turboConfig.set(
            game,
            "speedup",
            false
        )
    end
end

local function updateGen12Screen(mod, screen)
    local game = screen.game
    local input = game.input
    local row = screen.rows[screen.index]
    local key = getRowKey(row)

    if input:wasPressed("up") then
        screen.index =
            (screen.index - 2)
            % #screen.rows + 1

    elseif input:wasPressed("down") then
        screen.index =
            screen.index
            % #screen.rows + 1

    elseif input:wasPressed("a") then
        if key then
            beginAssignment(
                screen,
                row,
                lastGamepadPress
            )
        elseif row and row.step then
            row.step(game, 1)
        end

    elseif input:wasPressed("b") then
        mod.exports.turboEndEditing(game)
        screen:close()
        return

    elseif input:wasPressed("left") then
        if not key and row and row.step then
            row.step(game, -1)
        end

    elseif input:wasPressed("right") then
        if not key and row and row.step then
            row.step(game, 1)
        end

    elseif input:wasPressed("select") then
        clearSelected(mod, game, row)
    end
end

local shared = {
    makeRows = makeRows,
    clearSelected = clearSelected,
    updateGen12Screen = updateGen12Screen,
    clearActiveScreen = clearActiveScreen,
    beginAssignment = beginAssignment,
    screenId = SCREEN_ID,
}

local function makeScreen(mod)
return function(game)
if not game then
    return nil
    end

    local module =
    loadGeneration(
        mod,
        getGeneration(game)
    )

    local screen =
    module.makeScreen(
        mod,
        game,
        shared
    )

    screen.module = module
    activeScreen = screen

    return screen
    end
    end

return function(mod)
mod.content.screens:register(
    SCREEN_ID,
    {
        new = makeScreen(mod),
    }
)

mod.log:info("TurboOptions screen REGISTERED")

    mod.events:once(
        "mods.loaded",
        function()
            local ManagerState =
                require("src.mods.ManagerState")

            local routes =
                rawget(
                    ManagerState,
                    "__modOptionScreenRoutes"
                )

            if not routes then
                routes = {}

                local openOptions =
                    ManagerState.openOptions

                ManagerState.openOptions =
                    function(self, manifest)
                        local screenId =
                            manifest
                            and routes[manifest.id]

                        if screenId then
                            if self.game
                                and getGeneration(self.game) == 3
                            then
                                pendingOpeningButton =
                                    lastGamepadPress

                                local module =
                                    loadGeneration(
                                        mod,
                                        3
                                    )

                                local screen =
                                    module.makeScreen(
                                        mod,
                                        self.game,
                                        shared
                                    )

                                screen.module = module

                                local Stack =
                                    require(
                                        "src.ui.game3.stack"
                                    )

                                Stack.push(
                                    screenId,
                                    screen,
                                    {
                                        isMenu = true,
                                        fullscreen = true,
                                        hideBelow = true,
                                    }
                                )

                                return
                            end

                            return require(
                                "src.ui.Screens"
                            ).push(
                                self.game,
                                screenId
                            )
                        end

                        return openOptions(
                            self,
                            manifest
                        )
                    end

                ManagerState.__modOptionScreenRoutes =
                    routes
            end

            routes[mod.id] = SCREEN_ID
        end
    )

    mod.hooks:wrap(
        "input.gamepad",
        function(next, game, ev)
        if not ev then
            return
        end

            if ev.phase == "pressed" then
                lastGamepadPress =
                ev.button
            end

            if getGeneration(game) ~= 3 then
                if activeScreen
                    and activeScreen.assigningKey
                    and activeScreen.game == game
                then
                    if ev.phase == "released" then
                        if pendingOpeningButton == ev.button then
                            pendingOpeningButton = nil
                        end

                        return true
                    end

                    if ev.phase == "pressed" then
                        return finishAssignment(
                            mod,
                            activeScreen,
                            ev.button
                        )
                    end

                    if ev.phase == "axis" then
                        local trigger = getTriggerPress(ev)

                        if trigger then
                            return finishAssignment(
                                mod,
                                activeScreen,
                                trigger
                            )
                        end

                        return true
                    end

                    return true
                end

                return next(game, ev)
            end

            local Stack =
                require(
                    "src.ui.game3.stack"
                )

            local layer =
                Stack.top()

            if not layer
                or layer.id ~= SCREEN_ID
                or not layer.mod
            then
                return next(game, ev)
            end

            local screen =
                layer.mod

            local module = screen.module

            if screen.assigningKey then
                if ev.phase == "released" then
                    if pendingOpeningButton == ev.button then
                        pendingOpeningButton = nil
                    end

                    return true
                end

                if ev.phase == "pressed" then
                    return finishAssignment(
                        mod,
                        screen,
                        ev.button
                    )
                end

                if ev.phase == "axis" then
                    local trigger = getTriggerPress(ev)

                    if trigger then
                        return finishAssignment(
                            mod,
                            screen,
                            trigger
                        )
                    end

                    return true
                end

                return true
            end

            if ev.phase == "pressed" then
                local consumed, pending =
                module.handleButton(
                    mod,
                    screen,
                    ev.button,
                    pendingOpeningButton,
                    shared
                )

                pendingOpeningButton = pending

                return consumed
            end

            if ev.phase == "released" then
                if pendingOpeningButton == ev.button then
                    pendingOpeningButton = nil
                end

                return true
            end

            if ev.phase == "axis" then
                return module.handleAxis(
                    screen,
                    ev.axis,
                    ev.value
                )
            end

            return true
        end
    )

    mod.log:info(
        "Turbo options screen initialized"
    )
end
