return {
    makeScreen = function(mod, game, shared)
    local OptionRows =
    require("src.ui.OptionRows")

    mod.exports.turboBeginEditing(game)

    local screen = {
        game = game,
        rows = shared.makeRows(mod, game),
        index = 1,
        scroll = 0,
        isOpaque = true,
    }

    function screen:update()
    shared.updateGen12Screen(
        mod,
        self
    )

    self.scroll =
    OptionRows.clampScroll(
        self.index,
        self.scroll,
        #self.rows,
        nil
    )
    end

    function screen:draw()
        OptionRows.draw(
            self.game,
            self.rows,
            self.index,
            self.scroll,
            "A:BIND/SEL:CLEAR"
        )

        if self.assigningKey then
            local Font =
            require("src.render.Font")

            Font.drawBox(
                1,
                6,
                18,
                6
            )

            Font.draw(
                "PRESS A BUTTON",
                3 * 8,
                8 * 8
            )

            Font.draw(
                "TO ASSIGN",
                5 * 8,
                10 * 8
            )
        end
    end

    function screen:close()
    shared.clearActiveScreen(self)
    self.game.stack:pop()
    end

    return screen
    end,
}
