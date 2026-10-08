return function(mod)
local config = mod.exports.turboConfig

local heldA = false
local heldB = false
local heldSpeedup = false

local activeSpeedupButton = nil
local savedSpeedOverride = nil

local accumulatorA = 0
local accumulatorB = 0

local interval = 1 / 10

local triggerHeld = {
    triggerleft = false,
    triggerright = false,
}

local function get(game, key)
return config.get(game, key)
end

local function resetState(game)
heldA = false
heldB = false
heldSpeedup = false

activeSpeedupButton = nil

accumulatorA = 0
accumulatorB = 0

triggerHeld.triggerleft = false
triggerHeld.triggerright = false

if savedSpeedOverride ~= nil then
    game.speedOverride = savedSpeedOverride
    savedSpeedOverride = nil
    end
    end

    mod.exports.turboBeginEditing = function(game)
    mod.exports.turboEditing = true
    resetState(game)
    end

    mod.exports.turboEndEditing = function(game)
    resetState(game)
    mod.exports.turboEditing = false
    end

    local function setSpeedup(game, active, button)
    if active then
        if heldSpeedup then
            return
            end

            heldSpeedup = true
            activeSpeedupButton = button
            savedSpeedOverride = game.speedOverride
            game.speedOverride = get(game, "multiplier")

            else
                if not heldSpeedup then
                    return
                    end

                    heldSpeedup = false
                    activeSpeedupButton = nil
                    game.speedOverride = savedSpeedOverride
                    savedSpeedOverride = nil
                    end
                    end

                    local function checkSpeedupBinding(game)
                    if heldSpeedup
                        and activeSpeedupButton ~= get(game, "speedup")
                        then
                        setSpeedup(game, false)
                        end
                        end

                        local function setTurbo(button, active, game)
                        if button == get(game, "turboA") then
                            if active then
                                if heldA then
                                    return
                                    end

                                    heldA = true
                                    accumulatorA = 0

                                    mod.input:tap(game, "a")
                                    else
                                        heldA = false
                                        accumulatorA = 0
                                        end

                                        elseif button == get(game, "turboB") then
                                            if active then
                                                if heldB then
                                                    return
                                                    end

                                                    heldB = true
                                                    accumulatorB = 0

                                                    mod.input:tap(game, "b")
                                                    else
                                                        heldB = false
                                                        accumulatorB = 0
                                                        end
                                                        end
                                                        end

                                                        mod.hooks:wrap(
                                                            "input.gamepad",
                                                            function(next, game, ev)
                                                            if not ev then
                                                                return
                                                                end

                                                                if mod.exports.turboEditing then
                                                                    return next(game, ev)
                                                                    end

                                                                    checkSpeedupBinding(game)

                                                                    if ev.phase == "pressed" then
                                                                        setTurbo(
                                                                            ev.button,
                                                                            true,
                                                                            game
                                                                        )

                                                                        if ev.button == get(game, "speedup") then
                                                                            setSpeedup(
                                                                                game,
                                                                                true,
                                                                                ev.button
                                                                            )
                                                                            end

                                                                            elseif ev.phase == "released" then
                                                                                setTurbo(
                                                                                    ev.button,
                                                                                    false,
                                                                                    game
                                                                                )

                                                                                if ev.button == activeSpeedupButton then
                                                                                    setSpeedup(game, false)
                                                                                    end

                                                                                    elseif ev.phase == "axis" then
                                                                                        local axis = ev.axis
                                                                                        local value = ev.value

                                                                                        if axis == "triggerleft" then
                                                                                            if not triggerHeld.triggerleft
                                                                                                and value >= 0.35
                                                                                                then
                                                                                                triggerHeld.triggerleft = true

                                                                                                setTurbo(
                                                                                                    "triggerleft",
                                                                                                    true,
                                                                                                    game
                                                                                                )

                                                                                                if get(game, "speedup")
                                                                                                    == "triggerleft"
                                                                                                    then
                                                                                                    setSpeedup(
                                                                                                        game,
                                                                                                        true,
                                                                                                        "triggerleft"
                                                                                                    )
                                                                                                    end

                                                                                                    elseif triggerHeld.triggerleft
                                                                                                        and value <= 0.20
                                                                                                        then
                                                                                                        triggerHeld.triggerleft = false

                                                                                                        setTurbo(
                                                                                                            "triggerleft",
                                                                                                            false,
                                                                                                            game
                                                                                                        )

                                                                                                        if activeSpeedupButton
                                                                                                            == "triggerleft"
                                                                                                            then
                                                                                                            setSpeedup(
                                                                                                                game,
                                                                                                                false
                                                                                                            )
                                                                                                            end
                                                                                                            end

                                                                                                            elseif axis == "triggerright" then
                                                                                                                if not triggerHeld.triggerright
                                                                                                                    and value >= 0.35
                                                                                                                    then
                                                                                                                    triggerHeld.triggerright = true

                                                                                                                    setTurbo(
                                                                                                                        "triggerright",
                                                                                                                        true,
                                                                                                                        game
                                                                                                                    )

                                                                                                                    if get(game, "speedup")
                                                                                                                        == "triggerright"
                                                                                                                        then
                                                                                                                        setSpeedup(
                                                                                                                            game,
                                                                                                                            true,
                                                                                                                            "triggerright"
                                                                                                                        )
                                                                                                                        end

                                                                                                                        elseif triggerHeld.triggerright
                                                                                                                            and value <= 0.20
                                                                                                                            then
                                                                                                                            triggerHeld.triggerright = false

                                                                                                                            setTurbo(
                                                                                                                                "triggerright",
                                                                                                                                false,
                                                                                                                                game
                                                                                                                            )

                                                                                                                            if activeSpeedupButton
                                                                                                                                == "triggerright"
                                                                                                                                then
                                                                                                                                setSpeedup(
                                                                                                                                    game,
                                                                                                                                    false
                                                                                                                                )
                                                                                                                                end
                                                                                                                                end
                                                                                                                                end
                                                                                                                                end

                                                                                                                                return next(game, ev)
                                                                                                                                end
                                                        )

                                                        mod.hooks:wrap(
                                                            "input.step",
                                                            function(next, game, dt)
                                                            next(game, dt)

                                                            if mod.exports.turboEditing then
                                                                return
                                                                end

                                                                checkSpeedupBinding(game)

                                                                if heldA then
                                                                    accumulatorA =
                                                                    accumulatorA + dt

                                                                    while accumulatorA >= interval do
                                                                        accumulatorA =
                                                                        accumulatorA - interval

                                                                        mod.input:tap(game, "a")
                                                                        end
                                                                        end

                                                                        if heldB then
                                                                            accumulatorB =
                                                                            accumulatorB + dt

                                                                            while accumulatorB >= interval do
                                                                                accumulatorB =
                                                                                accumulatorB - interval

                                                                                mod.input:tap(game, "b")
                                                                                end
                                                                                end
                                                                                end
                                                        )

                                                        mod.log:info(
                                                            "Turbo autofire and speedup initialized"
                                                        )
                                                        end
