--romance.lua

function define_npc_menus()
    for i=1,#ROMANCEABLE_NPCS do
        define_npc_flirt(ROMANCEABLE_NPCS[i])
    end
end

function define_npc_flirt(oid)
    api_define_menu_object({
        id = string.sub(oid, 3, -1) .. "f",
        name = oid,
        category = "Flirt",
        tooltip = "Hmm you shouldn't bee seeing this, tell bCubed to hide it from bei",
        layout = {
            {8, 114, "Gift"}
        },
        info = {},
        buttons = {},
        placeable = false,
        invisible = true,
        center = true
    }, "sprites/romance_button.png", "sprites/npc_flirt_menu.png", {
        define = "define_flirt",
        draw = "draw_flirt"
    })
end

function define_flirt(menu_id)
    local inst = api_get_inst(api_gp(menu_id, "obj"))
    if inst ~= nil then
        local npc_oid = "npc" .. string.sub(inst["oid"], 10, -2)
        api_dp(menu_id, "npc_oid", npc_oid)
        if NPC_INFO[npc_oid] == nil then
            NPC_INFO[npc_oid] = {}
        end
        NPC_INFO[npc_oid]["romance_menu_id"] = menu_id
        api_log("flirt", NPC_INFO)
        api_set_immortal(inst["id"], true)
    end
end

function draw_flirt(menu_id)
    local menu = api_get_inst(menu_id)
    if menu ~= nil then
        local cam = api_get_cam()
        local mx = math.floor(menu["x"] - cam["x"])
        local my = math.floor(menu["y"] - cam["y"])
        local oid = api_gp(menu_id, "npc_oid")
        local info = NPC_INFO[oid]
        --api_draw_sprite(info["menu_sprite"], 0, mx, my)
        local name_length = get_string_px(info["name"])
        local pronoun_length = get_string_px(NPC_INFO[oid]["pronouns"])
        local text_box_end = mx + 59 + name_length + 3 + pronoun_length + 3
        api_draw_rectangle(mx + 59, my + 22, mx + 59 + name_length + 3 + pronoun_length + 1, my + 35, "GREY", false, 1)
        api_draw_rectangle(mx + 59 + name_length + 3 + pronoun_length + 3, my + 24, mx + 59 + name_length + 3 + pronoun_length + 3, my + 35, "GREY", false, 1)
        api_draw_text(mx + 59, my + 23, info["name"], false, "FONT_YELLOW")
        api_draw_text(mx + 59 + name_length + 3, my + 23, NPC_INFO[oid]["pronouns"], false, "FONT_BGREY")
        api_draw_sprite(NPC_INFO[oid]["bust_sprite"], 0, mx + 14, my + 4)
        local hearts = NPC_INFO_PERSISTENT["npc1"]["hearts"]
        hearts = TIMER % 7
        for i=1,6 do
            local filled = 2
            if hearts >= i then
                filled = 0
            end
            api_draw_sprite(ROMANCE_BUTTON_SPR, filled, text_box_end + 14 * (i - 1), my + 22)
        end
        local dialogue = NPC_DIALOGUE[oid][info["next_dialogues"][1]][hearts + 1]
        api_draw_text(mx + 7, my + 46, dialogue, false, "FONT_WHITE", 307)
        --api_draw_sprite(GIFT_SLOT_SPR, 0, 6, 112)
    end
end