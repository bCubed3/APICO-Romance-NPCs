-- mod.lua

MOD_NAME = "romance"

ROMANCEABLE_NPCS = {"npc1", "npc2", "npc3"}
PRONOUNS = {
    pronouns1 = "(He/Him)",
    pronouns2 = "(She/Her)",
    pronouns3 = "(They/Them)",
    pronouns4 = "(She/They)",
    pronouns5 = "(He/They)"
}
NPC_INFO = {}
NPC_INFO_PERSISTENT = {}
FULL_DATA = {}
OPEN_MENUS = {}
ROMANCE_BUTTON_SPR = -1
GIFT_SLOT_SPR = -1
GIFT_BUTTON_SPR = -1
GIFT_ERROR_SPR = -1
BUTTON_WIDTH = 16
BUTTON_HEIGHT = 16
TIMER = 0
LAST_DAY = 0

function register()
    return {
        name = MOD_NAME,
        hooks = {"clock", "gui", "create", "draw", "click", "save", "ready", "destroy"},
        modules = {"romance", "util", "dialogue"}
    }
end

function init()
    make_letter_lengths()
    api_set_devmode(true)
    define_sprites()
    define_npc_menus()
    return "Success"
end

function ready()
    api_get_data()
    setup_dialogue_variables()
    LAST_DAY = api_get_time()["day"]
end

function create(id, x, y, oid, inst_type)
    if inst_type == "menu_obj" then
        for i=1,#ROMANCEABLE_NPCS do
            if oid == ROMANCEABLE_NPCS[i] then
                local inst = api_get_inst(id)
                if inst ~= nil then
                    create_npc_info(ROMANCEABLE_NPCS[i])
                end
            end
        end
    end
end

function destroy(id, x, y, oid)
    if is_romanceable(oid) then
        NPC_INFO[oid] = nil
    end
end

function gui()
    local cam = api_get_cam()
    local mouse = api_get_mouse_position()
    mouse = {x = mouse["x"] - cam["x"], y = mouse["y"] - cam["y"]}
    for oid, info in pairs(NPC_INFO) do
        local menu_id = info["menu_id"]
        local open = api_gp(menu_id, "open")
        if open then
            local mx = api_gp(menu_id, "x")
            local my = api_gp(menu_id, "y")
            local button_pos = {x = 59 + 6 + get_string_px(info["name"]) + get_string_px(NPC_INFO[oid]["pronouns"]), y = 21}
            local bx = mx - cam["x"] + button_pos["x"]
            local by = my - cam["y"] + button_pos["y"]
            local hover = 0
            if bx <= mouse["x"] and mouse["x"] <= bx + BUTTON_WIDTH and by <= mouse["y"] and mouse["y"] <= by + BUTTON_HEIGHT then
                hover = 1
            end
            api_draw_sprite(ROMANCE_BUTTON_SPR, hover, bx, by + 1)
        end
    end
end

function clock()
    TIMER = TIMER + 1
    local day = api_get_time()["day"]
    --api_log("day", day)
    if day > LAST_DAY then
        LAST_DAY = day
        api_log("new_day", "new_day")
        renew_gifts()
    end
end

function click(button, click_type)
    local menu_id = api_get_highlighted("menu")
    if button == "LEFT" and click_type == "PRESSED" then 
        if menu_id ~= nil then
            local hl = api_get_inst(menu_id)
            if hl ~= nil and is_romanceable(hl["oid"]) then
                local oid = hl["oid"]
                local cam = api_get_cam()
                local mouse = api_get_mouse_position()
                mouse = {x = mouse["x"] - cam["x"], y = mouse["y"] - cam["y"]}
                local mx = api_gp(menu_id, "x")
                local my = api_gp(menu_id, "y")
                local button_pos = {x = 59 + 6 + get_string_px(NPC_INFO[oid]["name"]) + get_string_px(NPC_INFO[oid]["pronouns"]), y = 21}
                local bx = mx - cam["x"] + button_pos["x"]
                local by = my - cam["y"] + button_pos["y"]
                api_log("love", "love ?")
                if bx <= mouse["x"] and mouse["x"] <= bx + BUTTON_WIDTH and by <= mouse["y"] and mouse["y"] <= by + BUTTON_HEIGHT then
                    api_toggle_menu(menu_id, false)
                    api_log("npc", menu_id)
                    api_toggle_menu(NPC_INFO[oid]["romance_menu_id"], true)
                    api_log("flirt", NPC_INFO[oid]["romance_menu_id"])
                end
            end
        end
    end
end

function draw()
    local cam = api_get_cam()
    cam = {x = 100, y = 100}
    --api_draw_sprite(ROMANCE_BUTTON_SPR, 0, cam["x"] + 0, cam["y"] + 0)
end

function open_romance(menu_id)
    api_log("romance !!", menu_id)
end

function define_sprites()
    ROMANCE_BUTTON_SPR = api_define_sprite("romance_button", "sprites/romance_button.png", 4)
    GIFT_SLOT_SPR = api_define_sprite("gift_slot", "sprites/npc_gift_slot.png", 1)
    GIFT_BUTTON_SPR = api_define_sprite("gift_button", "sprites/npc_gift_button.png", 2)
    GIFT_ERROR_SPR = api_define_sprite("gift_error", "sprites/npc_gift_error.png", 2)
    api_log("romance_npcs", "defined sprites !")
end

function is_romanceable(oid)
    for i=1,#ROMANCEABLE_NPCS do
        if ROMANCEABLE_NPCS[i] == oid then
            return true
        end
    end
    return false
end

function get_npc_base_stats()
    return {hearts = 0, next_gift = 0}
end

function save()
    local data = FULL_DATA
    local file = api_get_filename()
    api_log("data", data)
    if data[file] == nil then
        data[file] = {}
    end
    data[file]["NPC_INFO"] = NPC_INFO_PERSISTENT
    api_set_data(data)
end

function data(ev, data)
    local file = api_get_filename()
    if ev == "LOAD" then
        if data[file] ~= nil then
            FULL_DATA = data
            NPC_INFO_PERSISTENT = data[file]["NPC_INFO"]
        else
            for i=1,#ROMANCEABLE_NPCS do
                create_npc_info(ROMANCEABLE_NPCS[i])
            end
        end
        create_romance_menus()
        load_gift_buttons()
    end
end

function create_npc_info(npc_oid)
    if NPC_INFO[npc_oid] == nil then
        NPC_INFO[npc_oid] = {}
    end
    NPC_INFO[npc_oid]["menu_id"] = api_get_inst(api_all_menu_objects(npc_oid)[1])["menu_id"]
    if NPC_INFO_PERSISTENT[npc_oid] == nil then
        NPC_INFO_PERSISTENT[npc_oid] = get_npc_base_stats()
    end
end

function create_romance_menus()
    for i=1,#ROMANCEABLE_NPCS do
        local npc_oid = ROMANCEABLE_NPCS[i]
        local flirt_oid = MOD_NAME .. "_" .. string.sub(npc_oid, 3, -1) .. "f"
        api_log("oid", flirt_oid)
        local old_objs = api_all_menu_objects(flirt_oid)
        for j=1,#old_objs do
            api_destroy_inst(old_objs[j])
        end
        local menu_id = api_get_inst(api_all_menu_objects(npc_oid)[1])["menu_id"]
        local npc_def = api_get_definition(npc_oid) or {}
        local pronouns = PRONOUNS[api_gp(menu_id, "my_pronouns")]
        api_log("npc", npc_def)
        NPC_INFO[npc_oid] = {
            menu_id = menu_id,
            romance_menu_id = "",
            bust_sprite = api_get_sprite(npc_oid .. "_bust"),
            menu_sprite = api_get_sprite(npc_oid .. "_menu"),
            name = npc_def["name"],
            next_dialogues = {"exhausted"},
            pronouns = pronouns,
        }
        api_create_obj(flirt_oid, 0, 2)
    end
end
