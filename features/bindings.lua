local BUTTONS = {
    { "Y", "y" },
    { "X", "x" },
    { "A", "a" },
    { "B", "b" },
    { "UP", "dpup" },
    { "DOWN", "dpdown" },
    { "LEFT", "dpleft" },
    { "RIGHT", "dpright" },
    { "LB", "leftshoulder" },
    { "RB", "rightshoulder" },
    { "LT", "triggerleft" },
    { "RT", "triggerright" },
    { "L3", "leftstick" },
    { "R3", "rightstick" },
    { "START", "start" },
    { "SELECT", "back" },
}

local SPEEDS = {
    1,
    2,
    3,
    4,
    10,
    20,
    30,
    50,
    75,
    100,
    200,
}

local function buttonLabel(button)
if not button then
    return "---"
    end

    for _, choice in ipairs(BUTTONS) do
        if choice[2] == button then
            return choice[1]
            end
            end

            return tostring(button)
            end

            local function speedLabel(speed)
            return tostring(speed) .. "X"
            end

            return function(mod)
            mod.options:define({
                {
                    key = "turboA",
                    type = "choice",
                    label = "TURBO A",
                    choices = {
                        { "Y", "y" },
                        { "X", "x" },
                        { "A", "a" },
                        { "B", "b" },
                        { "UP", "dpup" },
                        { "DOWN", "dpdown" },
                        { "LEFT", "dpleft" },
                        { "RIGHT", "dpright" },
                        { "LB", "leftshoulder" },
                        { "RB", "rightshoulder" },
                        { "LT", "triggerleft" },
                        { "RT", "triggerright" },
                        { "L3", "leftstick" },
                        { "R3", "rightstick" },
                        { "START", "start" },
                        { "SELECT", "back" },
                        { "---", false },
                    },
                    default = "y",
                },

                {
                    key = "turboB",
                    type = "choice",
                    label = "TURBO B",
                    choices = {
                        { "Y", "y" },
                        { "X", "x" },
                        { "A", "a" },
                        { "B", "b" },
                        { "UP", "dpup" },
                        { "DOWN", "dpdown" },
                        { "LEFT", "dpleft" },
                        { "RIGHT", "dpright" },
                        { "LB", "leftshoulder" },
                        { "RB", "rightshoulder" },
                        { "LT", "triggerleft" },
                        { "RT", "triggerright" },
                        { "L3", "leftstick" },
                        { "R3", "rightstick" },
                        { "START", "start" },
                        { "SELECT", "back" },
                        { "---", false },
                    },
                    default = "x",
                },

                {
                    key = "speedup",
                    type = "choice",
                    label = "SPEEDUP",
                    choices = {
                        { "Y", "y" },
                        { "X", "x" },
                        { "A", "a" },
                        { "B", "b" },
                        { "UP", "dpup" },
                        { "DOWN", "dpdown" },
                        { "LEFT", "dpleft" },
                        { "RIGHT", "dpright" },
                        { "LB", "leftshoulder" },
                        { "RB", "rightshoulder" },
                        { "LT", "triggerleft" },
                        { "RT", "triggerright" },
                        { "L3", "leftstick" },
                        { "R3", "rightstick" },
                        { "START", "start" },
                        { "SELECT", "back" },
                        { "---", false },
                    },
                    default = false,
                },

                {
                    key = "multiplier",
                    type = "choice",
                    label = "SPEED",
                    choices = {
                        { "1X", 1 },
                        { "2X", 2 },
                        { "3X", 3 },
                        { "4X", 4 },
                        { "10X", 10 },
                        { "20X", 20 },
                        { "30X", 30 },
                        { "50X", 50 },
                        { "75X", 75 },
                        { "100X", 100 },
                        { "200X", 200 },
                    },
                    default = 2,
                },
            })

            mod.exports.turboConfig = {
                get = function(game, key)
                local defaults = {
                    turboA = false,
                    turboB = false,
                    speedup = false,
                    multiplier = 2,
                }

                local bucket =
                game
                and game.save
                and game.save.options
                and game.save.options.modOptions
                and game.save.options.modOptions[mod.id]

                if bucket and bucket[key] ~= nil then
                    return bucket[key]
                    end

                    return defaults[key]
                    end,

                    set = function(game, key, value)
                    if not game
                        or not game.save
                        or not game.save.options
                        then
                        return
                        end

                        local options = game.save.options

                        options.modOptions =
                        options.modOptions or {}

                        options.modOptions[mod.id] =
                        options.modOptions[mod.id] or {}

                        options.modOptions[mod.id][key] = value

                        if game.writeOptions then
                            game:writeOptions()
                            end
                            end,
                    assign = function(game, key, button)
                    local keys = {
                        "turboA",
                        "turboB",
                        "speedup",
                    }

                    for _, otherKey in ipairs(keys) do
                        if otherKey ~= key
                            and mod.exports.turboConfig.get(
                                game,
                                otherKey
                            ) == button
                            then
                            mod.exports.turboConfig.set(
                                game,
                                otherKey,
                                false
                            )
                            end
                            end

                            mod.exports.turboConfig.set(
                                game,
                                key,
                                button
                            )
                            end,

                            buttonLabel = buttonLabel,
                            speedLabel = speedLabel,
                            buttons = BUTTONS,
                            speeds = SPEEDS,
            }

            mod.log:info(
                "Turbo options registered: "
                .. "A=" .. buttonLabel(
                    mod.exports.turboConfig.get(nil, "turboA")
                )
                .. ", B=" .. buttonLabel(
                    mod.exports.turboConfig.get(nil, "turboB")
                )
                .. ", Speedup=" .. buttonLabel(
                    mod.exports.turboConfig.get(nil, "speedup")
                )
                .. ", Speed="
                .. tostring(
                    mod.exports.turboConfig.get(nil, "multiplier")
                )
                .. "x"
            )
            end
