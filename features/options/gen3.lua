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

local function getLogicalButton(game, physical)
    if physical == "leftstick_up" then
        return "up"
    elseif physical == "leftstick_down" then
        return "down"
    elseif physical == "leftstick_left" then
        return "left"
    elseif physical == "leftstick_right" then
        return "right"
    end

    if physical == "rightstick_up" then
        return "up"
    elseif physical == "rightstick_down" then
        return "down"
    elseif physical == "rightstick_left" then
        return "left"
    elseif physical == "rightstick_right" then
        return "right"
    end

    local options =
        game
        and game.save
        and game.save.options

    local bindings =
        options
        and options.bindings

    local effective = {
        up = "dpup",
        down = "dpdown",
        left = "dpleft",
        right = "dpright",
        a = "a",
        b = "b",
        select = "back",
        start = "start",
    }

    if bindings then
        for logical, binding in pairs(bindings) do
            if type(binding) == "table"
                and binding.pad
            then
                effective[logical] =
                    binding.pad

            elseif binding == false then
                effective[logical] = nil
            end
        end
    end

    for logical, bound in pairs(effective) do
        if bound == physical then
            return logical
        end
    end

    return nil
end

local function handleDirection(screen, direction)
    if direction == "up" then
        screen.index =
            (screen.index - 2)
            % #screen.rows + 1

    elseif direction == "down" then
        screen.index =
            screen.index
            % #screen.rows + 1

    elseif direction == "left" then
        local row =
            screen.rows[screen.index]

        if row
            and row.step
            and not getRowKey(row)
        then
            row.step(
                screen.game,
                -1
            )
        end

    elseif direction == "right" then
        local row =
            screen.rows[screen.index]

        if row
            and row.step
            and not getRowKey(row)
        then
            row.step(
                screen.game,
                1
            )
        end
    end
end

return {
    makeScreen = function(mod, game, shared)
        mod.exports.turboBeginEditing(game)

        local screen = {
            game = game,
            rows = shared.makeRows(mod, game),
            index = 1,
        }

        function screen:close()
            shared.clearActiveScreen(self)
            mod.exports.turboEndEditing(
                self.game
            )

            local Stack =
                require("src.ui.game3.stack")

            Stack.pop(shared.screenId)
        end

        screen.draw = function()
            local Window =
                require("src.ui.game3.window")

            local FrlgFont =
                require("src.ui.game3.frlg_font")

            local Chrome =
                require("src.ui.game3.chrome")

            love.graphics.setColor(
                0,
                0,
                0,
                1
            )

            love.graphics.rectangle(
                "fill",
                0,
                0,
                240,
                160
            )

            Chrome.fixedStdFrame(
                2,
                1,
                26,
                2
            )

            Window.printPx(
                "TURBO OPTIONS",
                24,
                9,
                {
                    colors =
                        FrlgFont.COLOR.NORMAL,
                }
            )

            Chrome.fixedStdFrame(
                2,
                5,
                26,
                14
            )

            local startY = 48
            local rowHeight = 20

            for i, row in ipairs(screen.rows) do
                local y =
                    startY
                    + (i - 1) * rowHeight

                if i == screen.index then
                    Window.cursorPx(
                        16,
                        y
                    )
                end

                Window.printPx(
                    row.label,
                    30,
                    y,
                    {
                        colors =
                            FrlgFont.COLOR.NORMAL,
                    }
                )

                Window.printPx(
                    tostring(row.value()),
                    160,
                    y,
                    {
                        colors =
                            FrlgFont.COLOR.NORMAL,
                    }
                )
            end

            Window.printPx(
                "A: ASSIGN  SELECT: CLEAR  B: BACK",
                16,
                140,
                {
                    colors =
                        FrlgFont.COLOR.NORMAL,
                }
            )

            if screen.assigningKey then
                Chrome.fixedStdFrame(
                    7,
                    7,
                    16,
                    7
                )

                Window.printPx(
                    "PRESS A BUTTON",
                    78,
                    68,
                    {
                        colors =
                            FrlgFont.COLOR.NORMAL,
                    }
                )

                Window.printPx(
                    "TO ASSIGN",
                    90,
                    88,
                    {
                        colors =
                            FrlgFont.COLOR.NORMAL,
                    }
                )
            end

            love.graphics.setColor(
                1,
                1,
                1,
                1
            )
        end

        return screen
    end,

    handleButton = function(
        mod,
        screen,
        physical,
        pendingOpeningButton,
        shared
    )
        if pendingOpeningButton ~= nil then
            if physical == pendingOpeningButton then
                return true, nil
            end
        end

        local button =
            getLogicalButton(
                screen.game,
                physical
            )

        if button == "up" then
            handleDirection(
                screen,
                "up"
            )

        elseif button == "down" then
            handleDirection(
                screen,
                "down"
            )

        elseif button == "left" then
            handleDirection(
                screen,
                "left"
            )

        elseif button == "right" then
            handleDirection(
                screen,
                "right"
            )

        elseif button == "a" then
            local row =
                screen.rows[screen.index]

            local key =
                getRowKey(row)

            if key then
                shared.beginAssignment(
                    screen,
                    row,
                    physical
                )

                return true, physical
            end

            if row and row.step then
                row.step(
                    screen.game,
                    1
                )
            end

        elseif button == "b" then
            screen:close()

        elseif button == "select" then
            shared.clearSelected(
                mod,
                screen.game,
                screen.rows[screen.index]
            )
        end

        return true, pendingOpeningButton
    end,

    handleAxis = function(
        screen,
        axis,
        value
    )
        local input =
            screen.game.input

        local events =
            input:stickAxisEvents(
                axis,
                value
            )

        if not events then
            return true
        end

        for i = 1, #events do
            local event =
                events[i]

            if event.phase == "pressed" then
                local button =
                    getLogicalButton(
                        screen.game,
                        event.button
                    )

                if button == "up"
                    or button == "down"
                    or button == "left"
                    or button == "right"
                then
                    handleDirection(
                        screen,
                        button
                    )
                end
            end
        end

        return true
    end,
}
