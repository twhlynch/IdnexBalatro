--- STEAMODDED HEADER
--- MOD_NAME: Idnex
--- MOD_ID: Idnex
--- MOD_AUTHOR: [.index]
--- MOD_DESCRIPTION: A custom joker and deck
--- BADGE_COLOUR: 00FFFF
--- VERSION: 0.1.0
--- PREFIX: idnex

----------------------------------------------
------------MOD CODE -------------------------

function SMODS.INIT.Idnex()

    SMODS.Atlas {
        key = "modicon",
        path = "modicon.png",
        px = 32,
        py = 32
    }

    local sprites = SMODS.Sprite:new('idnex_atlas', SMODS.findModByID("Idnex").path, "sprites.png", 71, 95, "asset_atli")
    sprites:register()

-- Joker (idnex)
    SMODS.Joker {
        key = "idnex_joker",
        config = { base_mult = 1, current_mult = 1, is_idnex_joker = true },
        loc_txt = {
            name = "idnex",
            text = {
                "{X:mult,C:white} X#1# {} Mult for every {C:attention}idnex{}",
                "{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult){}",
                "{C:inactive}(Creates idnex stickers at end of round){}"
            }
        },
        rarity = 4, -- legendary
        cost = 100,
        unlocked = true,
        discovered = true,
        blueprint_compat = true,
        eternal_compat = true,
        atlas = 'idnex_atlas',
        pos = { x = 0, y = 0 },
        soul_pos = { x = 1, y = 0 },
        loc_vars = function(self, info_queue, card)
            return {
                vars = {
                    card.ability.base_mult,
                    card.ability.current_mult,
                }
            }
        end,
        calculate = function(self, card, context)
            -- calculate x_mult
            card.ability.current_mult = 0
            for _, another_joker in ipairs(G.jokers.cards) do
                if another_joker.ability.idnex_sticker or another_joker.ability.is_idnex_joker then
                    if card.ability.current_mult == 0 then
                        card.ability.current_mult = card.ability.base_mult
                    else    
                        card.ability.current_mult = card.ability.current_mult + card.ability.base_mult
                    end
                end
            end

            -- create idnex stickers
            if context.end_of_round and not context.repetition and not context.individual then
                for _, another_joker in ipairs(G.jokers.cards) do
                    if not another_joker.ability.idnex_sticker and not another_joker.ability.is_idnex_joker then
                        Sticker:apply(another_joker, true)
                        card_eval_status_text(another_joker, "extra", nil, nil, nil,
                            { message = "idnex", colour = HEX("00FFFF") }
						)
                    end
                end
            end

            -- return mult
            if context.joker_main then
                return {
                    message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.current_mult } },
                    Xmult_mod = card.ability.current_mult,
                }
            end
        end,
    }

-- Back (idnex)
    SMODS.Back {
        name = "idnex deck",
        key = "idnex_deck",
        loc_txt = {
            name = "idnex deck",
            text = {
                "Start with {C:attention}idnex{}",
            }
        },
        atlas = 'idnex_atlas',
        pos = { x = 2, y = 0 },
        unlocked = true,
        discovered = true,
        loc_vars = function(self, info_queue, center)
            return { vars = {} }
        end,
        apply = function(self)
            -- create idnex joker
            G.E_MANAGER:add_event(Event({
                func = function()
                    local new_joker = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_idnex_joker")
                    new_joker:add_to_deck()
                    G.jokers:emplace(new_joker)
                    new_joker:start_materialize()
                    return true
                end
            }))
        end,
    }

-- Sticker (idnex)
    Sticker = SMODS.Sticker {
        key = "idnex_sticker",
        loc_txt = {
            label = 'idnex',
            name = 'idnex',
            text = {
                'Duplicates at end of round',
                '{C:inactive}(Must have room){}',
                '{C:inactive}(Removes negative from the copy){}'
            }
        },
        badge_colour = HEX("00FFFF"),
        rate = 0,
        default_compat = false,
        compat_exceptions = { Joker = true },
        atlas = 'idnex_atlas',
        pos = {x = 3, y = 0},
        discovered = true,
        unlocked = true,
        calculate = function(self, card, context)
            -- duplicate
            if context.end_of_round and not context.repetition and not context.individual then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        if #G.jokers.cards < G.jokers.config.card_limit then
                            local copy = copy_card(card)
                            copy:add_to_deck()
                            G.jokers:emplace(copy)
                            card_eval_status_text(copy, "extra", nil, nil, nil,
                                { message = "copy", colour = HEX("00FFFF") }
                            )
                            Sticker:apply(copy, false)
                            if copy.edition and copy.edition.negative then
                                copy:set_edition({ negative = false })
                            end
                            copy:start_materialize()
                            
                        else
                            card_eval_status_text(card, "extra", nil, nil, nil,
                                { message = "no room", colour = HEX("00FFFF") }
                            )
                        end
                        return true
                    end
                }))
            end
        end,
    }
end

----------------------------------------------
------------MOD CODE END----------------------