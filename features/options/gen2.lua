return {
    makeScreen = function(mod, game, shared)
        local Chrome =
            require("src.ui.gen2.Chrome")

        local Marquee =
            require("src.ui.Marquee")

        mod.exports.turboBeginEditing(game)

        local screen = {
            game = game,
            rows = shared.makeRows(mod, game),
            index = 1,
            scroll = 0,
            isOpaque = true,
        }

        local VISIBLE_ROWS = 7

        function screen:ensureVisible()
            if self.index <= self.scroll then
                self.scroll =
                    self.index - 1

            elseif self.index >
                self.scroll + VISIBLE_ROWS
            then
                self.scroll =
                    self.index - VISIBLE_ROWS
            end

            self.scroll =
                math.max(
                    0,
                    math.min(
                        self.scroll,
                        math.max(
                            0,
                            #self.rows - VISIBLE_ROWS
                        )
                    )
                )
        end

        function screen:update()
        shared.updateGen12Screen(
            mod,
            self
        )

        self:ensureVisible()
        end

        function screen:draw()
            Chrome.clear()

            Chrome.textbox(
                0,
                0,
                Chrome.SCREEN_W - 2,
                Chrome.SCREEN_H - 2
            )

            for slot = 1,
                math.min(
                    VISIBLE_ROWS,
                    #self.rows
                )
            do
                local i =
                    slot + self.scroll

                local row =
                    self.rows[i]

                if row then
                    local labelY =
                        2 + (slot - 1) * 2

                    local hot =
                        i == self.index

                    local key =
                        tostring(
                            row.label
                        )

                    local function fit(text, col)
                        local room =
                            19 - col

                        if hot then
                            return Marquee.scroll(
                                tostring(text),
                                room,
                                key
                            )
                        end

                        return Marquee.clip(
                            tostring(text),
                            room
                        )
                    end

                    Chrome.print(
                        fit(
                            row.label,
                            2
                        ),
                        2,
                        labelY
                    )

                    Chrome.print(
                        ":",
                        10,
                        labelY + 1
                    )

                    Chrome.print(
                        fit(
                            row.value(),
                            11
                        ),
                        11,
                        labelY + 1
                    )
                end
            end

            Chrome.cursor(
                1,
                2 + (
                    self.index
                    - self.scroll
                    - 1
                ) * 2
            )

            if self.scroll + VISIBLE_ROWS
                < #self.rows
            then
                love.graphics.setColor(
                    0,
                    0,
                    0,
                    1
                )

                local Font =
                    require("src.render.Font")

                Font.drawCode(
                    Chrome.DOWN_ARROW,
                    1 * 8,
                    (
                        2
                        + VISIBLE_ROWS * 2
                        - 1
                    ) * 8
                )
            end
            Chrome.print(
                "A:BIND/SEL:CLEAR",
                2,
                14
            )

            Chrome.print(
                "B:BACK",
                12,
                16
            )
            if self.assigningKey then
                Chrome.textbox(
                    1,
                    5,
                    16,
                    7
                )

                Chrome.print(
                    "PRESS A BUTTON",
                    3,
                    8
                )

                Chrome.print(
                    "TO ASSIGN",
                    5,
                    10
                )
            end
        end

        function screen:close()
            shared.clearActiveScreen(self)
            mod.exports.turboEndEditing(
                self.game
            )

            self.game.stack:pop()
        end

        return screen
    end,
}
