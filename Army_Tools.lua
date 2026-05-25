require 'lib.sampfuncs'
require 'lib.moonloader'
local inicfg = require 'inicfg'
local lsg, sf               = pcall(require, 'sampfuncs')
local bNotf, notf = pcall(import, "lib/imgui_notf_cust.lua")
local dlstatus = require('moonloader').download_status
local imgui = require 'imgui'
local memory = require 'memory'
local encoding = require 'encoding'
local lkey, key = pcall(require, 'vkeys')
local fa = require 'faIcons'
local wm = require 'lib.windows.message'
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
local lrkeys, rkeys = pcall(require, 'rkeys')
local res,sampev = pcall(require,'lib.samp.events')
local limadd, imadd = pcall(require, 'imgui_addons')
local scriptname = '«Army Tools» '
encoding.default = 'CP1251'
u8 = encoding.UTF8

local vars = {
    menuselect  = 0,
    mainwindow  = imgui.ImBool(false),
    cmdbuf      = imgui.ImBuffer(256),
    cmdparams   = imgui.ImInt(0),
    cmdtext     = imgui.ImBuffer(20480)
}
local autoP = false
local ID_sec = -1
local fixbugabp = false
local positionX,  positionY,  positionZ
local commands = {}
local mcid = -1
local focusId = -1
local ToScreen = convertGameScreenCoordsToWindowScreenCoords
local enemystatus
local napal
local napadenie = false
local monikQuant = {}
local targetid = -1
local tLastKeys = {}
local vientDeRentrer = true
local unload = false
local fileb = getWorkingDirectory() .. "\\config\\Army-Tools\\armytools.bind"
local filec = getWorkingDirectory() .. "\\config\\Army-Tools\\shpora.shp"
local font = renderCreateFont("Arial", 15, 5)
local fontsize = nil
local workday = false
local checkStats = false
local frak = -1
local Player = {}
local rang = -1
local rank = -1
local base, mats
local departament = {}
local radio = {}
local sms = {}
local shpname = imgui.ImBuffer(256)
local shptext = imgui.ImBuffer(20480)
local tLastKeys = {}
local autoBP = 1
local stopFlood = {}
local tBindList = {}
local tShpList = {}
local nameNAR = imgui.ImBuffer(256)
local bindname = imgui.ImBuffer(256)
local bindtext = imgui.ImBuffer(20480)
local show = 1
local sub_show = 1.1
local tMembers = {}

cTable = {
    current_combo = imgui.ImInt(0),
    place_combo = imgui.ImInt(0),
    time_combo = imgui.ImInt(0),
    log_combo = imgui.ImInt(0),
    shp_combo = imgui.ImInt(0),
    dep = imgui.ImInt(0),
    time_value = {"14:25","16:25","19:25","21:25"}
}

sfaTable = {
    current_combo = imgui.ImInt(0),
    place_combo = imgui.ImInt(0),
    time_combo = imgui.ImInt(0),
    dep = imgui.ImInt(0),
    time_value = {"15:25","17:25","20:25","22:25"}
}

local tWeekdays = {
    [0] = 'Воскресенье',
    [1] = 'Понедельник', 
    [2] = 'Вторник', 
    [3] = 'Среда', 
    [4] = 'Четверг', 
    [5] = 'Пятница', 
    [6] = 'Суббота'
}

-- =============================== [ Авто-обновление ] =================================
local script_vers = 1.26
local script_vers_text = "1.26"

update_state = false

local update_url = "https://github.com/alekseyrulew/Army-Tools/raw/main/update.ini"
local update_path = getWorkingDirectory() .. "/update.ini"
local script_url = "https://github.com/alekseyrulew/Army-Tools/blob/main/Army_Tools.luac?raw=true"
local script_path = thisScript().path
-- =====================================================================================

local online = inicfg.load({
    statTimers = {
        state = true,
        clock = true,
        sesOnline = true,
        sesAfk = true, 
        sesFull = true,
        dayOnline = true,
        dayAfk = true,
        dayFull = true,
        weekOnline = true,
        weekAfk = true,
        weekFull = true,
        server = nil
    },
    onDay = {
        today = os.date("%a"),
        online = 0,
        afk = 0,
        full = 0
    },
    onWeek = {
        week = 1,
        online = 0,
        afk = 0,
        full = 0
    },
    myWeekOnline = {
        [0] = 0,
        [1] = 0,
        [2] = 0,
        [3] = 0,
        [4] = 0,
        [5] = 0,
        [6] = 0
    }
}, "online")

local dayFull = imgui.ImInt(online.onDay.full)
local weekFull = imgui.ImInt(online.onWeek.full)
local Radio = {
    ['clock'] = online.statTimers.clock,
    ['sesOnline'] = online.statTimers.sesOnline,
    ['sesAfk'] = online.statTimers.sesAfk,
    ['sesFull'] = online.statTimers.sesFull,
    ['dayOnline'] = online.statTimers.dayOnline,
    ['dayAfk'] = online.statTimers.dayAfk,
    ['dayFull'] = online.statTimers.dayFull,
    ['weekOnline'] = online.statTimers.weekOnline,
    ['weekAfk'] = online.statTimers.weekAfk,
    ['weekFull'] = online.statTimers.weekFull
}
local sesOnline = imgui.ImInt(0)
local sesAfk = imgui.ImInt(0)
local sesFull = imgui.ImInt(0)

local config = {
    main = {
        posX = 1566,
        posY = 916,
        widehud = 390,
        infobar = false,
        round = 10.0,
        tround = 10.0,
        colorW = 4279834905,
        targetcolorW = 4279834905,
        tar = '',
        tarb = false,
        clist = 0,
        clistb = false,
        style_vz = 0,
        parol = '',
        parolb = false,
        new_style = true,
        autobp = false,
        radio = false,
        carl = false,
        rpguns = false,
        male = true,
        colorradio = true,
        auto_SOS = true,
        warnings = true,
        chat = false,
        car = false,
        radio = false,
    },
    infobar = {
        ping = false,
        namebar = true,
        target = false,
        sektor = false,
        armour = false,
        health = false,
        time = false,
        direction = false,
        FPS = false,
        location = false,
    },
    autobp = {
        deagle = true,
        shot = true,
        smg = true,
        m4 = true,
        rifle = true,
        armour = true,
        spec = false
    },
    rpguns = {
        deagle = false,
        shotgun = false,
        mp5 = false,
        m4 = false,
        rifle = false,
    },
    udost = {
        dolzn = '',
        vzvod =''
    }
}
pTable = {
    type_reprimand = imgui.ImInt(0),
    punishment_combo = imgui.ImInt(0),
    krugi = imgui.ImBuffer(256),
    reason = imgui.ImBuffer(256)
}
local punishment  = {
   u8'Без действия', u8'Наряд', u8'Выговор'
}
local config_keys = {
    oopda = { v = {key.VK_F12}},
    oopnet = { v = {key.VK_F11}},
    vzaimkey = { v = {key.VK_Z}},
    cuffkey = { v = {}},
    followkey = { v = {}},
    uncuffkey = { v = {}},
    sirenkey = { v = {}}
}

local tCarsName = {"Landstalker", "Bravura", "Buffalo", "Linerunner", "Perrenial", "Sentinel", "Dumper", "Firetruck", "Trashmaster", "Stretch", "Manana", "Infernus",
"Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam", "Esperanto", "Taxi", "Washington", "Bobcat", "Whoopee", "BFInjection", "Hunter",
"Premier", "Enforcer", "Securicar", "Banshee", "Predator", "Bus", "Rhino", "Barracks", "Hotknife", "Trailer", "Previon", "Coach", "Cabbie", "Stallion", "Rumpo",
"RCBandit", "Romero","Packer", "Monster", "Admiral", "Squalo", "Seasparrow", "Pizzaboy", "Tram", "Trailer", "Turismo", "Speeder", "Reefer", "Tropic", "Flatbed",
"Yankee", "Caddy", "Solair", "Berkley'sRCVan", "Skimmer", "PCJ-600", "Faggio", "Freeway", "RCBaron", "RCRaider", "Glendale", "Oceanic", "Sanchez", "Sparrow",
"Patriot", "Quad", "Coastguard", "Dinghy", "Hermes", "Sabre", "Rustler", "ZR-350", "Walton", "Regina", "Comet", "BMX", "Burrito", "Camper", "Marquis", "Baggage",
"Dozer", "Maverick", "NewsChopper", "Rancher", "FBIRancher", "Virgo", "Greenwood", "Jetmax", "Hotring", "Sandking", "BlistaCompact", "PoliceMaverick",
"Boxvillde", "Benson", "Mesa", "RCGoblin", "HotringRacerA", "HotringRacerB", "BloodringBanger", "Rancher", "SuperGT", "Elegant", "Journey", "Bike",
"MountainBike", "Beagle", "Cropduster", "Stunt", "Tanker", "Roadtrain", "Nebula", "Majestic", "Buccaneer", "Shamal", "hydra", "FCR-900", "NRG-500", "HPV1000",
"CementTruck", "TowTruck", "Fortune", "Cadrona", "FBITruck", "Willard", "Forklift", "Tractor", "Combine", "Feltzer", "Remington", "Slamvan", "Blade", "Freight",
"Streak", "Vortex", "Vincent", "Bullet", "Clover", "Sadler", "Firetruck", "Hustler", "Intruder", "Primo", "Cargobob", "Tampa", "Sunrise", "Merit", "Utility", "Nevada",
"Yosemite", "Windsor", "Monster", "Monster", "Uranus", "Jester", "Sultan", "Stratum", "Elegy", "Raindance", "RCTiger", "Flash", "Tahoma", "Savanna", "Bandito",
"FreightFlat", "StreakCarriage", "Kart", "Mower", "Dune", "Sweeper", "Broadway", "Tornado", "AT-400", "DFT-30", "Huntley", "Stafford", "BF-400", "NewsVan",
"Tug", "Trailer", "Emperor", "Wayfarer", "Euros", "Hotdog", "Club", "FreightBox", "Trailer", "Andromada", "Dodo", "RCCam", "Launch", "PoliceCar", "PoliceCar",
"PoliceCar", "PoliceRanger", "Picador", "S.W.A.T", "Alpha", "Phoenix", "GlendaleShit", "SadlerShit", "Luggage A", "Luggage B", "Stairs", "Boxville", "Tiller",
"UtilityTrailer"}

local sRound = imgui.ImFloat(config.main.round)
local tRound = imgui.ImFloat(config.main.tround)
local style_vz_combo = imgui.ImInt(config.main.style_vz)
function main()
    if not isSampLoaded() or not isSampfuncsLoaded then return end
    while not isSampAvailable() do wait(100) end
        DownloadPNG()
        sampAddChatMessage(scriptname..'| {FFFFFF}Скрипт успешно запущен. Активация: /at.',0x7CFC00)
        registerCommands()  

        -- if config.main.style_vz == 0 then
        --     inv = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\dop_menu\\standart\\принять.png")
        --     uninv = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\dop_menu\\standart\\уволить.png")
        --     transport = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\dop_menu\\standart\\перевод.png")
        --     tie = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\dop_menu\\standart\\связать.png")
        --     rangi = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\dop_menu\\standart\\звание.png")
        --     untie = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\dop_menu\\standart\\развязать.png")
        --     closed = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\dop_menu\\закрыть.png")
        -- end
        -- if config.main.style_vz == 1 then --жёлтый
        --     inv = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\dop_menu\\yellow\\принять_yellow.png")
        --     uninv = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\dop_menu\\yellow\\уволить_yellow.png")
        --     transport = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\dop_menu\\yellow\\перевод_yellow.png")
        --     tie = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\dop_menu\\yellow\\связать_yellow.png")
        --     rangi = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\dop_menu\\yellow\\звание_yellow.png")
        --     untie = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\dop_menu\\yellow\\развязать_yellow.png")
        --     closed = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\dop_menu\\закрыть.png")
        -- end
        -- if config.main.style_vz == 2 then --зелёный
        --     inv = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\dop_menu\\green\\принять_green.png")
        --     uninv = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\dop_menu\\green\\уволить_green.png")
        --     transport = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\dop_menu\\green\\перевод_green.png")
        --     tie = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\dop_menu\\green\\связать_green.png")
        --     rangi = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\dop_menu\\green\\звание_green.png")
        --     untie = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\dop_menu\\green\\развязать_green.png")
        --     closed = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\dop_menu\\закрыть.png")
        -- end
        -- if config.main.style_vz == 3 then --серый
        --     inv = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\dop_menu\\grey\\принять_grey.png")
        --     uninv = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\dop_menu\\grey\\уволить_grey.png")
        --     transport = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\dop_menu\\grey\\перевод_grey.png")
        --     tie = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\dop_menu\\grey\\связать_grey.png")
        --     rangi = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\dop_menu\\grey\\звание_grey.png")
        --     untie = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\dop_menu\\grey\\развязать_grey.png")
        --     closed = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\dop_menu\\закрыть.png")
        -- end

        inv = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\dop_menu\\grey\\принять_grey.png")
        uninv = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\dop_menu\\grey\\уволить_grey.png")
        transport = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\dop_menu\\grey\\перевод_grey.png")
        tie = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\dop_menu\\grey\\связать_grey.png")
        rangi = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\dop_menu\\grey\\звание_grey.png")
        untie = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\dop_menu\\grey\\развязать_grey.png")
        closed = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\dop_menu\\закрыть.png")


        logo = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\logo-army-tools.png")
        background = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\main_window\\background.png")
        close_window = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\main_window\\close_window.png")
        keyboard = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\main_window\\keyboard.png")
        red_left = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\main_window\\red_left.png")


        add_code = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\main_window\\add.png")
        del_code = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\main_window\\delete.png")
        save_code = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\main_window\\save.png")
        key_code = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\main_window\\key.png")

        plan1 = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\main_window\\Plan1.png")
        plan2 = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\main_window\\Plan2.png")
        main1 = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\main_window\\Main_menu1.png")
        main2 = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\main_window\\Main_menu2.png")
        bind1 = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\main_window\\Binders1.png")
        bind2 = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\main_window\\Binders2.png")

        com_bind = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\main_window\\command_bind.png")
        block = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\main_window\\block.png")
        main_set = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\main_window\\main_set(active).png")
        main_set_non = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\main_window\\main_set(nact).png")
        shp_act = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\main_window\\shp(active).png")
        shp_non = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\main_window\\shp(nact).png")


        cb_act = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\main_window\\CB(active).png")
        cb_non = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\main_window\\CB(none).png")
        db_act = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\main_window\\DB(active).png")
        db_non = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\main_window\\DB(none).png")

        online_act = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\main_window\\online(active).png")
        online_non = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\main_window\\online(none).png")
        logs_act = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\main_window\\logs(active).png")
        logs_non = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\main_window\\logs(none).png")
        gos_act = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\main_window\\gos(active).png")
        gos_non = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\Army-Tools\\png\\main_window\\gos(none).png")

        apply_custom_style()
        lua_thread.create(strobes)
        local result, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
        local directoryes = {'config', 'config/Army-Tools/'..sampGetPlayerNickname(id)..'/', 'Army-Tools'}
        for k, v in pairs(directoryes) do
            if not doesDirectoryExist('moonloader/'..v) then 
                createDirectory("moonloader/"..v)
            end
        end
        if not doesFileExist('moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json') then
            io.open('moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json', 'w'):close()
        else
            local file = io.open('moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json', 'r')
            if file then
                config = decodeJson(file:read('*a'))
                if config.main.tar == nil then config.main.tar = "" end
                if config.main.tarb == nil then config.main.tarb = false end
                if config.main.parol == nil then config.main.parol = "" end
                if config.main.parolb == nil then config.main.parolb = false end
                if config.main.new_style == nil then config.main.new_style = true end
                if config.main.clist == nil then config.main.clist = 0 end
                if config.main.style_vz == nil then config.main.style_vz = 0 end
                if config.main.clistb == nil then config.main.clistb = false end
                if config.main.colorradio == nil then config.main.colorradio = true end
                if config.main.autobp == nil then config.main.autobp = false end
                if config.main.warnings == nil then config.main.warnings = true end
                if config.main.auto_SOS == nil then config.main.auto_SOS = true end
                if config.main.radio == nil then config.main.radio = false end
                if config.main.carl == nil then config.main.carl = false end
                if config.main.car == nil then config.main.car = false end
                if config.main.chat == nil then config.main.chat = false end
                if config.main.male == nil then config.main.male = true end
                if config.main.rpguns == nil then config.main.rpguns = false end
                if config.infobar.namebar == nil then config.infobar.namebar = true end
                if config.rpguns == nil then config.rpguns = {
                    deagle = false,
                    shotgun = false,
                    mp5 = false,
                    m4 = false,
                    rifle = false,
                }
                end
                if config.main.autobp == nil then config.main.autobp = false end
                if config.udost == nil then config.udost = {
                    dolzn = "",
                    vzvod = ""
                }
                end
                if config.infobar == nil then config.infobar = {
                    ping = false,
                    --namebar = true,
                    target = false,
                    sektor = false,
                    armour = false,
                    health = false,
                    time = false,
                    direction = false,
                    FPS = false,
                    location = false
                }
                end
                if config.autobp == nil then config.autobp = {
                    deagle = true,
                    shot = true,
                    smg = true,
                    m4 = true,
                    rifle = true,
                    armour = true,
                    spec = false
                }
                end
            end
        end
        saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json')

        if not sampIsDialogActive() then
            lua_thread.create(checkStats)
        else
            while sampIsDialogActive() do wait(0) end
            lua_thread.create(checkStats)
        end

        if doesFileExist("moonloader/config/Army-Tools/cmdbinder.json") then
            local file = io.open('moonloader/config/Army-Tools/cmdbinder.json', 'r')
            if file then
                commands = decodeJson(file:read('*a'))
            end
        end
        saveData(commands, "moonloader/config/Army-Tools/cmdbinder.json")
        registerCommandsBinder()

        if not doesFileExist("moonloader/config/Army-Tools/keys.json") then
            local fa = io.open("moonloader/config/Army-Tools/keys.json", "w")
            fa:write(encodeJson(config_keys))
            fa:close()
        else
            local fa = io.open("moonloader/config/Army-Tools/keys.json", 'r')
            if fa then
            config_keys = decodeJson(fa:read('*a'))
            if config_keys.oopda == nil then config_keys.oopda = {v = {key.VK_F12}} end
            if config_keys.oopnet == nil then config_keys.oopnet = {v = {key.VK_F11}} end
            if config_keys.vzaimkey == nil then config_keys.vzaimkey = {v = {key.VK_Z}} end
            if config_keys.cuffkey == nil then config_keys.cuffkey = {v = {}} end
            if config_keys.followkey == nil then config_keys.followkey = {v = {}} end
            if config_keys.uncuffkey == nil then config_keys.uncuffkey = {v = {}} end
            if config_keys.sirenkey == nil then config_keys.sirenkey = {v = {}} end
            end
        end
        saveData(config_keys, 'moonloader/config/Army-Tools/keys.json')

        downloadUrlToFile(update_url, update_path, function(id, status)
            if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                updateIni = inicfg.load(nil, update_path)
                if tonumber(updateIni.info.vers) > script_vers then
                    sampAddChatMessage(scriptname.. ' | {FFFFFF} Найдено обновление скрипта! Новая версия: ' .. updateIni.info.vers_text, 0x7FFF00)
                    update_state = true
                end
                os.remove(update_path)
            end
        end)

        registerHotKey()
        if doesFileExist(filec) then
            local f = io.open(filec, "r")
            if f then
                tShpList = decodeJson(f:read())
                f:close()
            end
        else
            tShpList = {
                [1] = {
                    text = "",
                    v = {},
                    name = "Шпаргалка №1"
                },
            }
        end
        saveData(tShpList, filec)

        for k, v in pairs(tShpList) do
            rkeys.registerHotKey(v.v, true, onHotKey)
            if v.time ~= nil then v.time = nil end
            if v.name == nil then v.name = "Шпаргалка №"..k end
            v.text = v.text:gsub("%[enter%]", ""):gsub("{noenter}", "{noe}")
        end
        saveData(tShpList, filec)

        if doesFileExist(fileb) then
            local f = io.open(fileb, "r")
            if f then
                tBindList = decodeJson(f:read())
                f:close()
            end
        else
            tBindList = {
                [1] = {
                    text = "",
                    v = {},
                    name = 'Бинд №1'
                },
                [2] = {
                    text = "",
                    v = {},
                    name = 'Бинд №2'
                },
                [3] = {
                    text = "",
                    v = {},
                    name = 'Бинд №3'
                }
            }
        end
        saveData(tBindList, fileb)

        for k, v in pairs(tBindList) do
            rkeys.registerHotKey(v.v, true, onHotKey)
            if v.time ~= nil then v.time = nil end
            if v.name == nil then v.name = "Бинд №"..k end
            v.text = v.text:gsub("%[enter%]", ""):gsub("{noenter}", "{noe}")
        end
        saveData(tBindList, fileb)

        lua_thread.create(time)
        lua_thread.create(autoSave)

        lua_thread.create(function()
            while true do
                wait(5000)
                for k, val in pairs(stopFlood) do stopFlood[k] = false end
            end
        end)

        if online.onDay.today ~= os.date("%a") then 
            online.onDay.today = os.date("%a")
            online.onDay.online = 0
            online.onDay.full = 0
            online.onDay.afk = 0
           dayFull.v = 0
           inicfg.save(online, 'online.ini')
        end
        if online.onWeek.week ~= number_week() then
            online.onWeek.week = number_week()
            online.onWeek.online = 0
            online.onWeek.full = 0
            online.onWeek.afk = 0
            weekFull.v = 0
            for _, v in pairs(online.myWeekOnline) do v = 0 end            
            inicfg.save(online, 'online.ini')
        end

        if not doesFileExist('moonloader/config/online.ini') then
            if inicfg.save(online, 'online.ini') then end
        end
        addEventHandler("onWindowMessage", function (msg, wparam, lparam)
            if wparam == key.VK_ESCAPE then
                if not sampIsChatInputActive() and not sampIsDialogActive() and not sampIsScoreboardOpen() then
                    if vzaimod.v then vzaimod.v = false consumeWindowMessage(true, true) end
                    if memw.v then memw.v = false consumeWindowMessage(true, true) end
                    if main_window_state.v then main_window_state.v = false consumeWindowMessage(true, true) end
                    if vzaim_new.v then vzaim_new.v = false consumeWindowMessage(true, true) end
                end
            end
        end)
    while true do wait(0)
        
        if update_state then
            downloadUrlToFile(script_url, script_path, function(id, status)
                if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    sampAddChatMessage(scriptname.. ' | {FFFFFF}Скрипт успешно обновлен!',0x7FFF00)
                    thisScript():reload()
                end
            end)
            break
        end

        hud = imgui.ImBool(config.main.infobar)
        imgui.ShowCursor = false
        siAssitDansWagon()
        if testCheat("KLK") then
            if isCharInAnyCar(playerPed) then
                if getCarModel(storeCarCharIsInNoSave(PLAYER_PED))== 520 or getCarModel(storeCarCharIsInNoSave(PLAYER_PED))== 487 or getCarModel(storeCarCharIsInNoSave(PLAYER_PED))== 488 or getCarModel(storeCarCharIsInNoSave(PLAYER_PED))== 417 or getCarModel(storeCarCharIsInNoSave(PLAYER_PED))== 425 or getCarModel(storeCarCharIsInNoSave(PLAYER_PED))== 447 or getCarModel(storeCarCharIsInNoSave(PLAYER_PED))== 469 or getCarModel(storeCarCharIsInNoSave(PLAYER_PED))== 497 or getCarModel(storeCarCharIsInNoSave(PLAYER_PED))== 548 or getCarModel(storeCarCharIsInNoSave(PLAYER_PED))== 563 then  
                    hpcar = getCarHealth(storeCarCharIsInNoSave(PLAYER_PED))
                    positionX,  positionY,  positionZ = getCarCoordinates(storeCarCharIsInNoSave(PLAYER_PED))
                    playerposX, playerposY, playerposZ = getCharCoordinates(PLAYER_PED)
                    if autoP then autoP = false
                    else autoP = true end
                end
            end
        end

        if changetextpos then
            sampToggleCursor(true)
            local CPX, CPY = getCursorPos()
            config.main.posX = CPX
            config.main.posY = CPY
        end

        if autoP  then
            if isCharInAnyCar(playerPed) then
                if getCarSpeed(storeCarCharIsInNoSave(PLAYER_PED)) <= 4 then
                    if isCarEngineOn(storeCarCharIsInNoSave(PLAYER_PED)) then
                        posX,  posY,  _ = getCarCoordinates(storeCarCharIsInNoSave(PLAYER_PED))
                        PposX, PposY, _ = getCharCoordinates(PLAYER_PED)
                        if posX < positionX-5  or posX > positionX+5  or getCarHealth(storeCarCharIsInNoSave(PLAYER_PED)) ~= hpcar or PposX < playerposX-3 or PposX > playerposX+3 then autoP = false return 1 end
                        setCarCoordinates(storeCarCharIsInNoSave(PLAYER_PED), positionX,  positionY,  positionZ-3)
                    else autoP = false return 1  end 
                else sampAddChatMessage(scriptname..'| {FFFFFF}Снизьте скорость.',0x7CFC00) autoP = false end
                else autoP = false return 1  end
            
         end
        if vzaimod.v or memw.v or main_window_state.v or vzaim_new.v then
            imgui.Process = true
            imgui.ShowCursor = true
        else
            imgui.Process = true
            imgui.ShowCursor = false
        end

        if isCharInAnyCar(PLAYER_PED) then mcid = select(2, sampGetVehicleIdByCarHandle(storeCarCharIsInNoSave(PLAYER_PED))) end

        if config.main.carl then
            if isKeyJustPressed(VK_L) and not sampIsCursorActive() then
                sampSendChat("/lock")
            end
        end

        if config.main.rpguns then
            if lastgun ~= getCurrentCharWeapon(PLAYER_PED) then
                local gun = getCurrentCharWeapon(PLAYER_PED)
                if config.rpguns.deagle then
                    if gun == 24 then 
                        sampSendChat(('/me %s с кобуры пистолет марки "Desert Eagle" и %s его'):format(config.main.male and 'достал' or 'достала', config.main.male and 'перезарядил' or 'перезарядила'))
                    end
                end
                if config.rpguns.shotgun then
                    if gun == 25 then
                        sampSendChat(('/me %s с чехла на спине помповый дробовик и %s его'):format(config.main.male and 'достал' or 'достала', config.main.male and 'зарядил' or 'зарядила'))
                    end
                end
                if config.rpguns.mp5 then
                    if gun == 29 then
                        sampSendChat(('/me %s с плеча пистолет-пулемет "MP-5" и %s его'):format(config.main.male and 'снял' or 'сняла', config.main.male and 'перезарядил' or 'перезарядила'))
                    end
                end
                if config.rpguns.m4 then
                    if gun == 31 then
                        sampSendChat(('/me %s с плеча карабин "M4A1" и %s затвор'):format(config.main.male and 'снял' or 'сняла', config.main.male and 'передернул' or 'передернула'))
                    end
                end
                if config.rpguns.rifle then
                    if gun == 33 then
                        sampSendChat(('/me %s с плеча полу-автоматическую винтовку и %s её'):format(config.main.male and 'снял' or 'сняла', config.main.male and 'перезарядил' or 'перезарядила'))
                    end
                end
                if gun == 0 then
                    sampSendChat(('/me %s оружие'):format(config.main.male and 'убрал' or 'убрала'))
                end
                lastgun = gun
            end
        end

        local myskin = getCharModel(PLAYER_PED)
        if myskin == 287 or myskin == 191 or myskin == 179 or myskin == 61 or myskin == 255 or myskin == 73 then
            workday = true
        end

        if coordX ~= nil and coordY ~= nil then
            cX, cY, cZ = getCharCoordinates(playerPed)
            cX = math.ceil(cX)
            cY = math.ceil(cY)
            cZ = math.ceil(cZ)
            sampAddChatMessage(scriptname.. '| {FFFFFF}Метка установлена на '..kvadY..'-'..kvadX, 0x7FFF00)
            placeWaypoint(coordX, coordY, 0)
            coordX = nil
            coordY = nil
        end
        if wasKeyPressed(key.VK_I) then
            print(sampGetCurrentDialogId())
        end
        if wasKeyPressed(key.VK_T) and config.main.chat and not sampIsChatInputActive() and not sampIsDialogActive() and not isSampfuncsConsoleActive() then
            sampSetChatInputEnabled(true)
        end
    end
end

function sampev.onShowDialog(id, style, title, button1, button2, text)
    if id == 1111 and config.main.parolb and #tostring(config.main.parol) >= 6 then
        sampSendDialogResponse(id, 1111, _, tostring(config.main.parol))
        return false
    end
    if id == 9901 and checkstat then
        frak1 = text:match('Организация(.+)Должность')
        rang1 = text:match('Должность(.+)Работа')
        frak = frak1:match('%a+')
        if frak == nil then frak = 'Нет' end
        rang = rang1:match('%p(.+)%p')
        print(frak)
        print(rang)
        checkstat = false
        setVirtualKeyDown(27, true)
        setVirtualKeyDown(27, false)
        return true
    end
    if config.main.autobp == true and id == 20057 then
        if config.main.autobp == true and id == 20057 then
            print(title);
            if fixbugabp == false then fixbugabp = true return false end
            local guns = getCompl()
            lua_thread.create(function()
                wait(300)
                if autoBP == #guns + 1 then
                    autoBP = 1
                    sampCloseCurrentDialogWithButton(0)
                    return
                end
                sampSendDialogResponse(20057, 1, guns[autoBP], "")
                autoBP = autoBP + 1
                return
            end)
        end
    end
    if config.main.autobp == true and id == 32700 then
        lua_thread.create(function()
            print(title);
            wait(250)
            sampSendDialogResponse(32700, 1, 2, "")
            wait(250)
            sampCloseCurrentDialogWithButton(0)
        end)
    end
end

if imgui then
    vzaimod = imgui.ImBool(false)
    main_window_state = imgui.ImBool(false)
    vzaim_new = imgui.ImBool(false)
    memw = imgui.ImBool(false) 
    targetbar = imgui.ImBool(true)
    show_set_window = imgui.ImBool(false)
end

function getweaponname(weapon)
    local names = {
    [0] = "Fist",
    [1] = "Brass Knuckles",
    [2] = "Golf Club",
    [3] = "Nightstick",
    [4] = "Knife",
    [5] = "Baseball Bat",
    [6] = "Shovel",
    [7] = "Pool Cue",
    [8] = "Katana",
    [9] = "Chainsaw",
    [10] = "Purple Dildo",
    [11] = "Dildo",
    [12] = "Vibrator",
    [13] = "Silver Vibrator",
    [14] = "Flowers",
    [15] = "Cane",
    [16] = "Grenade",
    [17] = "Tear Gas",
    [18] = "Molotov Cocktail",
    [22] = "9mm",
    [23] = "Silenced 9mm",
    [24] = "Desert Eagle",
    [25] = "Shotgun",
    [26] = "Sawnoff Shotgun",
    [27] = "Combat Shotgun",
    [28] = "Micro SMG/Uzi",
    [29] = "MP5",
    [30] = "AK-47",
    [31] = "M4",
    [32] = "Tec-9",
    [33] = "Country Rifle",
    [34] = "Sniper Rifle",
    [35] = "RPG",
    [36] = "HS Rocket",
    [37] = "Flamethrower",
    [38] = "Minigun",
    [39] = "Satchel Charge",
    [40] = "Detonator",
    [41] = "Spraycan",
    [42] = "Fire Extinguisher",
    [43] = "Camera",
    [44] = "Night Vis Goggles",
    [45] = "Thermal Goggles",
    [46] = "Parachute" }
    return names[weapon]
end
function registerCommands()
    --------------------- ТЕСТОВЫЕ
    ------------------------------
    if sampIsChatCommandDefined('r') then sampUnregisterChatCommand('r') end
    if sampIsChatCommandDefined('f') then sampUnregisterChatCommand('f') end
    if sampIsChatCommandDefined('blag') then sampUnregisterChatCommand('blag') end
    if sampIsChatCommandDefined('dmb') then sampUnregisterChatCommand('dmb') end
    if sampIsChatCommandDefined('cl') then sampUnregisterChatCommand('cl') end
    sampRegisterChatCommand('setkv',setkv)
    sampRegisterChatCommand('cam', cam)
    sampRegisterChatCommand('ns',cmd_lh)
    sampRegisterChatCommand('at', newscritp)
    sampRegisterChatCommand('csc',csc)
    sampRegisterChatCommand('aak',aak)
    sampRegisterChatCommand('ayk',ayk)
    sampRegisterChatCommand('afp',afp)
    sampRegisterChatCommand('aarmy',aarmy)
    sampRegisterChatCommand('trg',trg)
    sampRegisterChatCommand('r', r)
    sampRegisterChatCommand('cl', clistm)
    sampRegisterChatCommand('rinvite', rinvite)
    sampRegisterChatCommand('runinvite', runinvite)
    sampRegisterChatCommand('roffgiverank', roffgiverank)
    sampRegisterChatCommand('roffuninvite', roffuninvite)
    sampRegisterChatCommand('f', f)
    sampRegisterChatCommand('dmb', dmb)
    sampRegisterChatCommand("imask", imask)
    sampRegisterChatCommand("fmask", fmask)
    sampRegisterChatCommand('mon', mon)
    sampRegisterChatCommand('cc',clearchat)
    sampRegisterChatCommand('ast',sttime)
    sampRegisterChatCommand('asw',stweather)
    sampRegisterChatCommand('blg', blg)
    sampRegisterChatCommand('ntest',ntest)
    sampRegisterChatCommand('fyk', fyk)
    sampRegisterChatCommand('farmy', farmy)
    sampRegisterChatCommand('ffp', ffp)
    sampRegisterChatCommand('fak', fak)
    sampRegisterChatCommand('cn', copyrpnick)
    sampRegisterChatCommand('csn', copyrpsnick)
    sampRegisterChatCommand('sud', showudost)
    sampRegisterChatCommand('nar', naryad)
    sampRegisterChatCommand('plc', plc)
    sampRegisterChatCommand('loc', loc)
    sampRegisterChatCommand('fnr', fnr)
    sampRegisterChatCommand('vig', vigovor)
    -- sampRegisterChatCommand('cor', function()
    --     local myX, myY, myZ = getCharCoordinates(PLAYER_PED)
    --     sampAddChatMessage(getDistanceBetweenCoords3d(myX, myY, myZ, 213.0892,1913.8396,17.6406), -1)
    --     --print(isCh(arInArea3d(PLAYER_PED, 285.5162, 2004.1349, 24.1134, 267.1019, 1975.0342, 17.6406, false))
    -- end)
    -- sampRegisterChatCommand("ds", function ()
    --     local id = sampGetCurrentDialogId()
    --     print(id)
    -- end)
    
    -- sampRegisterChatCommand("avac", function (param)
    --     lua_thread.create(function()
    --         sampProcessChatInput('/av 13:25')
    --         wait(1300)
    --         sampProcessChatInput('/av 16:25')
    --         wait(1300)
    --         sampProcessChatInput('/av 19:25')
    --         wait(1300)
    --         sampProcessChatInput('/av 21:25')
    --     end)
    -- end)
    -- sampRegisterChatCommand("av", function (param)
    --     lua_thread.create(function()
    --         if param ~= nil then
    --             sampSendChat('/addvacancy')
    --             sampSendDialogResponse(8011, 1, 1, _)
    --             sampSendDialogResponse(8012, 1, _, param)
    --             sampSendDialogResponse(8011, 1, 2, _)
    --             sampSendDialogResponse(8013, 1, _, "30")
    --             sampSendDialogResponse(8011, 1, 4, _)
    --             sampSendDialogResponse(8015, 1, _, "2")
    --             bolLS()
    --         end
    --     end)
    -- end)

end

function apply_custom_style()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4

   

    style.WindowRounding = 2
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    style.ChildWindowRounding = 2.0
    style.FrameRounding = 3
    style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
    style.ScrollbarSize = 13.0
    style.ScrollbarRounding = 0
    style.GrabMinSize = 8.0
    style.GrabRounding = 1.0
    style.WindowPadding = imgui.ImVec2(4.0, 4.0)
    style.FramePadding = imgui.ImVec2(3.5, 3.5)
    style.ButtonTextAlign = imgui.ImVec2(0.0, 0.5)


    colors[clr.WindowBg]              = ImVec4(0.14, 0.12, 0.16, 1.00);
    colors[clr.ChildWindowBg]         = ImVec4(0.30, 0.20, 0.39, 0.00);
    colors[clr.PopupBg]               = ImVec4(0.05, 0.05, 0.10, 0.90);
    colors[clr.Border]                = ImVec4(0.89, 0.85, 0.92, 0.30);
    colors[clr.BorderShadow]          = ImVec4(0.00, 0.00, 0.00, 0.00);
    colors[clr.FrameBg]               = ImVec4(0.30, 0.20, 0.39, 1.00);
    colors[clr.FrameBgHovered]        = ImVec4(0.41, 0.19, 0.63, 0.68);
    colors[clr.FrameBgActive]         = ImVec4(0.41, 0.19, 0.63, 1.00);
    colors[clr.TitleBg]               = ImVec4(0.41, 0.19, 0.63, 0.45);
    colors[clr.TitleBgCollapsed]      = ImVec4(0.41, 0.19, 0.63, 0.35);
    colors[clr.TitleBgActive]         = ImVec4(0.41, 0.19, 0.63, 0.78);
    colors[clr.MenuBarBg]             = ImVec4(0.30, 0.20, 0.39, 0.57);
    colors[clr.ScrollbarBg]           = ImVec4(0.30, 0.20, 0.39, 1.00);
    colors[clr.ScrollbarGrab]         = ImVec4(0.41, 0.19, 0.63, 0.31);
    colors[clr.ScrollbarGrabHovered]  = ImVec4(0.41, 0.19, 0.63, 0.78);
    colors[clr.ScrollbarGrabActive]   = ImVec4(0.41, 0.19, 0.63, 1.00);
    colors[clr.ComboBg]               = ImVec4(0.30, 0.20, 0.39, 1.00);
    colors[clr.CheckMark]             = ImVec4(0.56, 0.61, 1.00, 1.00);
    colors[clr.SliderGrab]            = ImVec4(0.41, 0.19, 0.63, 0.24);
    colors[clr.SliderGrabActive]      = ImVec4(0.41, 0.19, 0.63, 1.00);
    colors[clr.Button]                = ImVec4(0.41, 0.19, 0.63, 0.44);
    colors[clr.ButtonHovered]         = ImVec4(0.41, 0.19, 0.63, 0.86);
    colors[clr.ButtonActive]          = ImVec4(0.64, 0.33, 0.94, 1.00);
    colors[clr.Header]                = ImVec4(0.41, 0.19, 0.63, 0.76);
    colors[clr.HeaderHovered]         = ImVec4(0.41, 0.19, 0.63, 0.86);
    colors[clr.HeaderActive]          = ImVec4(0.41, 0.19, 0.63, 1.00);
    colors[clr.ResizeGrip]            = ImVec4(0.41, 0.19, 0.63, 0.20);
    colors[clr.ResizeGripHovered]     = ImVec4(0.41, 0.19, 0.63, 0.78);
    colors[clr.ResizeGripActive]      = ImVec4(0.41, 0.19, 0.63, 1.00);
    colors[clr.CloseButton]           = ImVec4(1.00, 1.00, 1.00, 0.75);
    colors[clr.CloseButtonHovered]    = ImVec4(0.88, 0.74, 1.00, 0.59);
    colors[clr.CloseButtonActive]     = ImVec4(0.88, 0.85, 0.92, 1.00);
    colors[clr.PlotLines]             = ImVec4(0.89, 0.85, 0.92, 0.63);
    colors[clr.PlotLinesHovered]      = ImVec4(0.41, 0.19, 0.63, 1.00);
    colors[clr.PlotHistogram]         = ImVec4(0.89, 0.85, 0.92, 0.63);
    colors[clr.PlotHistogramHovered]  = ImVec4(0.41, 0.19, 0.63, 1.00);
    colors[clr.TextSelectedBg]        = ImVec4(0.41, 0.19, 0.63, 0.43);
    colors[clr.ModalWindowDarkening]  = ImVec4(0.20, 0.20, 0.20, 0.35);
end

function imgui.Value()
    pingb = imgui.ImBool(config.infobar.ping)
    targetb = imgui.ImBool(config.infobar.target)
    kvadrat = imgui.ImBool(config.infobar.sektor)
    healthb = imgui.ImBool(config.infobar.health)
    armourb = imgui.ImBool(config.infobar.armour)
    timeb = imgui.ImBool(config.infobar.time)
    directionb = imgui.ImBool(config.infobar.direction)
    FPSb = imgui.ImBool(config.infobar.FPS)
    namebarb = imgui.ImBool(config.infobar.namebar)
    infobarb = imgui.ImBool(config.main.infobar)
    dolznf = imgui.ImBuffer(u8(config.udost.dolzn), 256)
    vzvodf = imgui.ImBuffer(u8(config.udost.vzvod), 256)
    tagf = imgui.ImBuffer(u8(config.main.tar), 256)
    tagb = imgui.ImBool(config.main.tarb)
    parolf = imgui.ImBuffer(u8(tostring(config.main.parol)), 256)
    parolb = imgui.ImBool(config.main.parolb)
    new_style = imgui.ImBool(config.main.new_style)
    clistbuffer = imgui.ImInt(config.main.clist)
    clistb = imgui.ImBool(config.main.clistb)
    colorradiob = imgui.ImBool(config.main.colorradio)
    auto_SOSb = imgui.ImBool(config.main.auto_SOS)
    warningsb = imgui.ImBool(config.main.warnings)
    radiob = imgui.ImBool(config.main.radio)
    carlb = imgui.ImBool(config.main.carl)
    carb = imgui.ImBool(config.main.car)
    chatb = imgui.ImBool(config.main.chat)
    maleb = imgui.ImBool(config.main.male)
    rpguns = imgui.ImBool(config.main.rpguns)
    rpdeagle = imgui.ImBool(config.rpguns.deagle)
    rpshotgun = imgui.ImBool(config.rpguns.shotgun)
    rpmp5 = imgui.ImBool(config.rpguns.mp5)
    rpm4 = imgui.ImBool(config.rpguns.m4)
    rprifle = imgui.ImBool(config.rpguns.rifle)
    autobpb = imgui.ImBool(config.main.autobp)
    deagleb = imgui.ImBool(config.autobp.deagle)
    shotb = imgui.ImBool(config.autobp.shot)
    smgb = imgui.ImBool(config.autobp.smg)
    m4b = imgui.ImBool(config.autobp.m4)
    rifleb = imgui.ImBool(config.autobp.rifle)
    specb = imgui.ImBool(config.autobp.spec) 
    armb = imgui.ImBool(config.autobp.armour)
    locationb = imgui.ImBool(config.infobar.location)
end

function imgui.OnDrawFrame()
    ScreenX, ScreenY = getScreenResolution()
    if main_window_state.v then
        imgui.Value()
        local sw, sh = getScreenResolution()
        local clr = imgui.Col
        local ImVec4 = imgui.ImVec4
        imgui.SetNextWindowPos(imgui.ImVec2((sw / 2)-(sw / 3), (sh / 2)-(sh / 3)), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowSize(imgui.ImVec2(1000, 680))
        imgui.PushStyleColor(clr.WindowBg, ImVec4(0.23, 0.23, 0.23, 0.00))
        imgui.PushStyleColor(clr.Button, ImVec4(0.23, 0.23, 0.23, 0.00))
        imgui.PushStyleColor(clr.ButtonActive, ImVec4(0.23, 0.23, 0.23, 0.50))
        imgui.PushStyleColor(clr.ButtonHovered, ImVec4(0.23, 0.23, 0.23, 0.00))
        imgui.Begin('Imgui Interfaces', main_window_state, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
        local size = imgui.GetWindowSize()
        imgui.Image(background, imgui.ImVec2((size.x-(size.x/100)),size.y/1.1))
        imgui.SetCursorPos(imgui.ImVec2(size.x/1.04, size.y/100)) if imgui.ImageButton(close_window, imgui.ImVec2(17,17)) then main_window_state.v = not main_window_state.v end
        imgui.SetCursorPos(imgui.ImVec2(size.x/5, size.y/1.4)) if imgui.ImageButton(red_left, imgui.ImVec2(37,37)) then imgui.OpenPopup(u8"Редактировать данные") end
        if show == 1 then
            imgui.SetCursorPos(imgui.ImVec2(size.x/3.5, size.y/9)) imgui.Image(main1, imgui.ImVec2(130,25))
            imgui.SetCursorPos(imgui.ImVec2(size.x/1.9, size.y/9)) if imgui.ImageButton(plan2, imgui.ImVec2(100,16)) then show = 2 sub_show = 2.1 end
            imgui.SetCursorPos(imgui.ImVec2(size.x/1.3, size.y/9)) if imgui.ImageButton(bind2, imgui.ImVec2(100,19)) then show = 3 sub_show = 3.1 end
        end
        if show == 2 then
            imgui.SetCursorPos(imgui.ImVec2(size.x/3.5, size.y/9)) if imgui.ImageButton(main2, imgui.ImVec2(130,17)) then show = 1 sub_show = 1.1 end
            imgui.SetCursorPos(imgui.ImVec2(size.x/1.9, size.y/9)) imgui.Image(plan1, imgui.ImVec2(110,25)) 
            imgui.SetCursorPos(imgui.ImVec2(size.x/1.3, size.y/9)) if imgui.ImageButton(bind2, imgui.ImVec2(100,19)) then show = 3 sub_show = 3.1 end
        end
        if show == 3 then
            imgui.SetCursorPos(imgui.ImVec2(size.x/3.5, size.y/9)) if imgui.ImageButton(main2, imgui.ImVec2(130,17)) then show = 1 sub_show = 1.1 end
            imgui.SetCursorPos(imgui.ImVec2(size.x/1.9, size.y/9)) if imgui.ImageButton(plan2, imgui.ImVec2(100,16)) then show = 2 sub_show = 2.1 end
            imgui.SetCursorPos(imgui.ImVec2(size.x/1.3, size.y/9)) imgui.Image(bind1, imgui.ImVec2(100,25)) 
        end
        if imgui.BeginPopupModal(u8"Редактировать данные", _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove) then
            imgui.PushItemWidth(150)
            if imgui.InputText(u8'Введите название взвода', vzvodf) then config.udost.vzvod = u8:decode(vzvodf.v) saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json') end
            if imgui.InputText(u8'Введите занимаемую должность', dolznf) then config.udost.dolzn = u8:decode(dolznf.v)  saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json') end
            imgui.PopItemWidth()
            if imgui.Button(u8"Закрыть", imgui.ImVec2(100, 0)) then
                imgui.CloseCurrentPopup()
            end
            imgui.EndPopup()
        end
        imgui.SetCursorPos(imgui.ImVec2(size.x/90, size.y/6))
            imgui.BeginChild("ChildWindow", imgui.ImVec2(size.x/4.5, size.y/1.5), false)
                local size_child = imgui.GetWindowSize()
                _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
                local myname = sampGetPlayerNickname(myid)
                size_logo = size_child.x/1.7
                imgui.SetCursorPosX((size_child.x / 2 ) - (size_logo / 2))
                imgui.Image(logo, imgui.ImVec2(size_logo,size_logo))
                imgui.NewLine()imgui.NewLine()imgui.NewLine()imgui.NewLine()
                imgui.Text((u8'Имя: %s [%d]'):format(myname:gsub("_", " "), myid))
                if frak == "LVA" or frak == "SFA" then
                    if frak == "LVA" then imgui.Text(u8'Фракция: Army LV') end
                    if frak == "SFA" then imgui.Text(u8'Фракция: Army SF') end
                else imgui.Text((u8'Фракция: %s'):format(u8(frak))) end
                if frak == "LVA" or frak == "SFA" then imgui.Text((u8'Звание: %s'):format(u8(rang)))
                else imgui.Text((u8'Должность: %s'):format(u8(rang))) end
                imgui.Text((u8'Должность:  %s'):format(u8(config.udost.dolzn)))
                imgui.Text((u8'Взвод: %s'):format(u8(config.udost.vzvod)))
                imgui.NewLine()imgui.NewLine()
                imgui.Text((u8'Версия: %s'):format(script_vers_text))
            imgui.EndChild()

            imgui.SameLine()
            imgui.SetCursorPosX(size.x/3.9)
            if show == 1 then
                if sub_show == 1.1 then
                    imgui.BeginChild("ChildWindow2", imgui.ImVec2((size.x - (size.x/3.2)), size.y/1.5), false)
                        local size_child1 = imgui.GetWindowSize()
                        imgui.SetCursorPosX((size_child1.x / 2 ) - (size_child1.x/2.5))
                        imgui.Image(main_set, imgui.ImVec2(size_child1.x/3, size.y/11.3)) imgui.SameLine()
                        if imgui.ImageButton(shp_non, imgui.ImVec2(size_child1.x/3, size.y/11.3)) then sampAddChatMessage("[Army-Tools] В скором времени вернутся на новом интерфейсе. Доступны в /ns",-1) end --sub_show = 1.2 end
                        imgui.BeginChild("ChildWindow3", imgui.ImVec2((size.x - (size.x/2.9)), size.y/1.8), false)
                            local size_child3 = imgui.GetWindowSize()
                            _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
                            local myname = sampGetPlayerNickname(myid)
                            imgui.Image(block, imgui.ImVec2(size_child3.x, size_child3.y/1.05))
                            imgui.SetCursorPosY(size_child3.y/18)
                            imgui.Columns(3, "Columns", false) imgui.SetColumnWidth(0, size_child3.y/1.7); imgui.SetColumnWidth(1, size_child3.y/1.7); imgui.SetColumnWidth(2, size_child3.y/1.7);
                            if imadd.ToggleButton(u8'##male', maleb) then config.main.male = maleb.v end; imgui.SameLine() saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json'); imgui.Text(u8 'Мужские отыгровки')
                            if imadd.ToggleButton(u8'##radio', radiob) then config.main.radio = radiob.v end; imgui.SameLine() saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json'); imgui.Text(u8 'Отключить радио в авто')
                            if radiob.v then memory.copy(0x4EB9A0, memory.strptr('\xC2\x04\x00'), 3, true) end
                            if imadd.ToggleButton(u8'##carl', carlb) then config.main.carl = carlb.v end; imgui.SameLine() saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json'); imgui.Text(u8 'Открытие авто на L')
                            if imadd.ToggleButton(u8'Открывать чат на T', chatb) then config.main.chat = chatb.v end; imgui.SameLine() saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json'); imgui.Text(u8 'Открывать чат на T')
                            if imadd.ToggleButton(u8'##carb', carb) then config.main.car = carb.v end; imgui.SameLine() saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json'); imgui.Text(u8 'Автозапуск двигателя')
                            imgui.NextColumn()
                            if imadd.ToggleButton(u8'Автотег', tagb) then
                                config.main.tarb = tagb.v 
                                saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json')
                            end 
                            imgui.SameLine()
                            imgui.Text(u8 'Авто-тэг')
                            imgui.PushItemWidth(150)
                            if tagb.v then
                                if imgui.InputText(u8'Тэг', tagf) then
                                    config.main.tar = u8:decode(tagf.v) 
                                    saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json')
                                end
                            end
                            if imadd.ToggleButton(u8'Использовать авто-логин', parolb) then
                                config.main.parolb = parolb.v
                                saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json')
                            end
                            imgui.SameLine()
                            imgui.Text(u8 'Авто-логин')
                            if parolb.v then
                                if imgui.InputText(u8'Пароль', parolf, imgui.InputTextFlags.Password) then
                                    config.main.parol = u8:decode(parolf.v)
                                    saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json')
                                end
                            end
                            if imadd.ToggleButton(u8'Использовать автоклист', clistb) then config.main.clistb = clistb.v end; imgui.SameLine() saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json'); imgui.Text(u8 'Авто-клист')
                            if clistb.v then
                                if imgui.SliderInt(u8"Клист", clistbuffer, 0, 33) then config.main.clist = clistbuffer.v saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json') end
                            end
                            if imadd.ToggleButton(u8'Новое меню (ПКМ+Z)', new_style) then
                                config.main.new_style = new_style.v
                                saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json')
                            end
                            imgui.SameLine()
                            imgui.Text(u8 'Новое меню (ПКМ+Z)')
                            -- if new_style.v then imgui.Combo(u8'Стиль', style_vz_combo, u8("Стандартный\0".."Жёлтый\0".."Серый\0".."Зелёный\0\0")) end
                            -- if imgui.Button("SAVE") then
                            --     config.main.style_vz = style_vz_combo.v
                            --     sampAddChatMessage(config.main.style_vz,-1)
                            --     saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json') 
                            -- end
                            imgui.PopItemWidth()
                            imgui.NextColumn()
                            if imadd.ToggleButton(u8'##colorradio', colorradiob) then config.main.colorradio = colorradiob.v end; imgui.SameLine() saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json'); imgui.Text(u8 'Цветные сообщения в рацию')
                            if imadd.ToggleButton(u8'##warnings', warningsb) then config.main.warnings = warningsb.v end; imgui.SameLine() saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json'); imgui.Text(u8 'Варнинги на фуры, форму')
                            if imadd.ToggleButton(u8'##sos', auto_SOSb) then config.main.auto_SOS = auto_SOSb.v end; imgui.SameLine() saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json'); imgui.Text(u8 'Авто-запрос SOS')
                            
                        imgui.EndChild()
                    imgui.EndChild()
                end
                -- if sub_show == 1.2 then
                --     imgui.BeginChild("ChildWindow4", imgui.ImVec2((size.x - (size.x/3.2)), size.y/1.5), false)
                --         local size_child1 = imgui.GetWindowSize()
                --         imgui.SetCursorPosX((size_child1.x / 2 ) - (size_child1.x/2.5))
                --         if imgui.ImageButton(main_set_non, imgui.ImVec2(size_child1.x/3, size.y/11.3)) then sub_show = 1.1 end imgui.SameLine()
                --         imgui.Image(shp_act, imgui.ImVec2(size_child1.x/3, size.y/11.3))
                --         imgui.BeginChild("ChildWindow5", imgui.ImVec2((size.x - (size.x/2.9)), size.y/1.8), false)
                --             local size_child3 = imgui.GetWindowSize()
                --             _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
                --             local myname = sampGetPlayerNickname(myid)
                --             local amount = ""
                --             imgui.Image(block, imgui.ImVec2(size_child3.x, size_child3.y/1.05))
                --             imgui.SetCursorPosY(size_child3.y/18)
                --             for 6, v in pairs(tShpList) do
                --                 amount = amount .. v.name .. "\0"
                --             end
                --             imgui.Combo(u8'##combo112', cTable.shp_combo, {u8(v.name ..)}, 6)
                --             imgui.Text(u8(amount))
                --             for k, v in ipairs(tShpList) do
                --                 imgui.PushItemWidth(size_child3.y/0.8)
                --                 imgui.PopItemWidth()
                --                 imgui.SameLine()
                --                 if imgui.Button(u8 'Редактировать шпаргалку##'..k) then
                --                     imgui.OpenPopup(u8"Редактирование шпаргалки##editshp"..k) 
                --                     shpname.v = v.name
                --                     shptext.v = v.text
                --                 end
                --                 imgui.TextWrapped(u8(v.text))
                --                 if imgui.BeginPopupModal(u8 'Редактирование шпаргалки##editshp'..k, _, imgui.WindowFlags.NoResize) then
                --                     imgui.Text(u8 "Введите название шпаргалки:")
                --                     imgui.InputText("##Введите название биндера", shpname)
                --                     imgui.Text(u8 "Введите текст шпаргалки:")
                --                     imgui.InputTextMultiline("##Введите текст шпаргалки", shptext, imgui.ImVec2(500, 200))
                --                     imgui.Separator()
                --                     imgui.SetCursorPosX((imgui.GetWindowWidth() - 90 - imgui.GetStyle().ItemSpacing.x))
                --                     if imgui.Button(u8 "Удалить", imgui.ImVec2(90, 20)) then
                --                         table.remove(tShpList, k)
                --                         saveData(tShpList, filec)
                --                         imgui.CloseCurrentPopup()
                --                     end
                --                     imgui.SameLine()
                --                     imgui.SetCursorPosX((imgui.GetWindowWidth() - 180 + imgui.GetStyle().ItemSpacing.x) / 2)
                --                     if imgui.Button(u8 "Сохранить", imgui.ImVec2(90, 20)) then
                --                         v.name = u8:decode(shpname.v)
                --                         v.text = u8:decode(shptext.v)
                --                         shpname.v = ''
                --                         shptext.v = ''
                --                         saveData(tShpList, filec)
                --                         imgui.CloseCurrentPopup()
                --                     end
                --                     imgui.SameLine()
                --                     if imgui.Button(u8 "Закрыть##", imgui.ImVec2(90, 20)) then imgui.CloseCurrentPopup() end
                --                     imgui.EndPopup()
                --                 end
                --             end
                --             imgui.Separator()
                --             if imgui.Button(u8"Добавить шпаргалку") then
                --                 tShpList[#tShpList + 1] = {text = "", v = {}, time = 0, name = "Шпаргалка №"..#tShpList + 1}
                --                 saveData(tShpList, filec)
                --             end
                --         imgui.EndChild()
                --     imgui.EndChild()
                -- end
            end
            if show == 2 then
                if sub_show == 2.1 then
                    imgui.BeginChild("ChildWindow2", imgui.ImVec2((size.x - (size.x/3.2)), size.y/1.5), false)
                        local size_child1 = imgui.GetWindowSize()
                        imgui.SetCursorPosX((size_child1.x / 2.4 ) - (size_child1.x/2.5))
                        imgui.Image(logs_act, imgui.ImVec2(size_child1.x/3.2, size_child1.y/9.5)) imgui.SameLine()
                        if imgui.ImageButton(gos_non, imgui.ImVec2(size_child1.x/3.3, size_child1.y/14)) then sub_show = 2.2 end imgui.SameLine()
                        if imgui.ImageButton(online_non, imgui.ImVec2(size_child1.x/3.3, size_child1.y/14)) then sub_show = 2.3 end
                        imgui.BeginChild("ChildWindow3", imgui.ImVec2((size.x - (size.x/2.9)), size.y/1.8), false)
                            local size_child2 = imgui.GetWindowSize()
                            imgui.PushItemWidth(110)
                            imgui.Combo(u8'Выберите тип логирования', cTable.log_combo, u8("Департамент\0".."Рация\0".."SMS\0\0"))    
                            imgui.BeginChild("ChildWindow3", imgui.ImVec2((size_child2.x - 10), size_child2.y/1.085), false)
                                local size_child3 = imgui.GetWindowSize()
                                _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
                                local myname = sampGetPlayerNickname(myid)
                                imgui.Image(block, imgui.ImVec2(size_child3.x, size_child3.y/1.05))
                                imgui.SetCursorPosY(size_child3.y/18)
                                imgui.BeginChild("ChildWindow4", imgui.ImVec2((size_child3.x - 10), size_child3.y/1.17), false)
                                    if cTable.log_combo.v == 0 then    
                                        imgui.CentrText(u8'Лог департамента:')
                                        imgui.CenterTextColoredRGB(u8('%s'):format(table.concat(departament, '\n')))
                                    end
                                    if cTable.log_combo.v == 1 then    
                                        imgui.CentrText(u8'Лог рации:')
                                        imgui.CenterTextColoredRGB(u8('%s'):format(table.concat(radio, '\n')))
                                    end
                                    if cTable.log_combo.v == 2 then    
                                        imgui.CentrText(u8'Лог SMS:')
                                        imgui.CenterTextColoredRGB(u8('%s'):format(table.concat(sms, '\n')))
                                    end
                                imgui.EndChild()
                            imgui.EndChild()
                        imgui.EndChild()
                    imgui.EndChild()
                end
                if sub_show == 2.2 then
                    imgui.BeginChild("ChildWindow4", imgui.ImVec2((size.x - (size.x/3.2)), size.y/1.5), false)
                        local size_child1 = imgui.GetWindowSize()
                        imgui.SetCursorPosX((size_child1.x / 2.4 ) - (size_child1.x/2.5))
                        if imgui.ImageButton(logs_non, imgui.ImVec2(size_child1.x/3.3, size_child1.y/14)) then sub_show = 2.1 end imgui.SameLine()
                        imgui.Image(gos_act, imgui.ImVec2(size_child1.x/3.2, size_child1.y/9.5)) imgui.SameLine()
                        if imgui.ImageButton(online_non, imgui.ImVec2(size_child1.x/3.3, size_child1.y/14)) then sub_show = 2.3 end
                        imgui.BeginChild("ChildWindow5", imgui.ImVec2((size.x - (size.x/2.9)), size.y/1.8), false)
                            local size_child3 = imgui.GetWindowSize()
                            _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
                            local myname = sampGetPlayerNickname(myid)
                            imgui.Image(block, imgui.ImVec2(size_child3.x, size_child3.y/1.05))
                            imgui.SetCursorPosY(size_child3.y/18)
                            imgui.PushStyleColor(clr.Button, ImVec4(0.23, 0.23, 0.23, 0.94))
                            if frak == "LVA" then
                                imgui.SetCursorPosX(4)
                                imgui.PushItemWidth(70)
                                imgui.Combo(u8'Время начала призыва', cTable.time_combo, "14:25\0".."16:25\0".."19:25\0".."21:25\0\0")
                                imgui.SameLine()
                                imgui.PushItemWidth(140)
                                imgui.Combo(u8'Выберите место проведения призыва', cTable.place_combo , u8"Больница ЛС\0Больница ЛВ\0\0")
                                imgui.BeginChild('##csc_example', imgui.ImVec2(780, 110))
                                imgui.PushItemWidth(400)
                                imgui.SetCursorPos(imgui.ImVec2(5, 5))
                                imgui.Combo(u8'##combo_example', cTable.current_combo, u8"Предупреждение\0Начало\0Продолжение\0Конец\0Контракт\0Срочка\0Академия\0\0")
                                if cTable.current_combo.v == 0 then
                                    imgui.Text((u8" /gov [Army LV]: Уважаемые жители и гости штата San Andreas.\n /gov [Army LV]: Сегодня в "..cTable.time_value[cTable.time_combo.v + 1]..u8", в больнице %s, состоится призыв в Las Venturas Army.\n /gov [Army LV]: Требования: иметь прописку в штате от двух лет, не иметь проблем с законом.\n /gov [Army LV]: С уважением, Командование Вооружённых Сил г. Las Venturas."):format(cTable.place_combo.v == 0 and u8'Лос-Сантоса' or cTable.place_combo.v == 1 and u8'Лас-Вентураса'))
                                end
                                if cTable.current_combo.v == 1 then
                                    imgui.Text((u8" /gov [Army LV]: Уважаемые жители и гости штата San Andreas.\n /gov [Army LV]: Призыв в Las Venturas Army объявляется открытым.\n /gov [Army LV]: Требования: иметь прописку в штате от двух лет, не иметь проблем с законом.\n /gov [Army LV]: Призыв проходит в больнице %s, на втором этаже.\n /gov [Army LV]: С уважением, Командование Вооружённых Сил г. Las Venturas."):format(cTable.place_combo.v == 0 and u8'Лос-Сантоса' or cTable.place_combo.v == 1 and u8'Лас-Вентураса'))
                                end
                                if cTable.current_combo.v == 2 then
                                    imgui.Text((u8" /gov [Army LV]: Уважаемые жители и гости штата San Andreas.\n /gov [Army LV]: В данный момент проходит призыв в Las Venturas Army.\n /gov [Army LV]: Требования: иметь прописку в штате от двух лет, не иметь проблем с законом.\n /gov [Army LV]: Призыв проходит в больнице %s, на втором этаже.\n /gov [Army LV]: С уважением, Командование Вооружённых Сил г. Las Venturas."):format(cTable.place_combo.v == 0 and u8'Лос-Сантоса' or cTable.place_combo.v == 1 and u8'Лас-Вентураса'))
                                end
                                if cTable.current_combo.v == 3 then
                                    imgui.Text(u8" /gov [Army LV]: Уважаемые жители и гости штата San Andreas.\n /gov [Army LV]: Призыв в Las Venturas Army объявляется закрытым.\n /gov [Army LV]: Так же в нашей армии открыт набор желающих на контрактную службу с выплатой денежных средств.\n /gov [Army LV]: Вся информация находится на официальном портале Army Las Venturas.\n /gov [Army LV]: С уважением, Командование Вооружённых Сил г. Las Venturas.")
                                end
                                if cTable.current_combo.v == 4 then
                                    imgui.Text(u8" /gov [Army LV]: Уважаемые жители и гости штата San Andreas.\n /gov [Army LV]: В нашей армии открыт набор желающих на контрактную службу.\n /gov [Army LV]: За прохождение контракта вы можете получить от 200.000 до 600.000 вирт.\n /gov [Army LV]: Подробнее на оф.портале Army Las Venturas. С уважением, Командование Army Las Venturas")
                                end
                                if cTable.current_combo.v == 5 then
                                    imgui.Text(u8" /gov [Army LV]: Уважаемые жители и гости штата San Andreas.\n /gov [Army LV]: В нашей армии доступна срочная военная служба вне призыва с вознаграждением.\n /gov [Army LV]: Требования: иметь прописку в штате от двух лет, не иметь проблем с законом.\n /gov [Army LV]: Вся информация находится на официальном портале Army Las Venturas\n /gov [Army LV]: С уважением, Командование Вооружённых Сил г. Las Venturas.")
                                end
                                if cTable.current_combo.v == 6 then
                                    imgui.Text(u8" /gov [Army LV]: Уважаемые жители и гости штата San Andreas.\n /gov [Army LV]: В нашей армии открылись заявления в Военную академию Генерального Штаба.\n /gov [Army LV]: Требования: иметь прописку в штате от трех лет, не иметь проблем с законом.\n /gov [Army LV]: По окончанию обучения выплачивается 1.000.000 вирт и присваивается звание Мл.Лейтенант.\n /gov [Army LV]: Вся информация находится на официальном портале нашего Штата и Las Venturas Army.")
                                end
                                imgui.EndChild()
                                if imgui.Button(u8"О предупреждении", imgui.ImVec2(125, 20))  then
                                    lua_thread.create(function()
                                        if cTable.dep.v == 0 then 
                                            sampSendChat('/d OG, вещаю.')
                                            wait(3000)
                                        end
                                        sampSendChat('/gov [Army LV]: Уважаемые жители и гости штата San Andreas.')
                                        wait(5000)
                                        sampSendChat(('/gov [Army LV]: Сегодня в '..cTable.time_value[cTable.time_combo.v + 1]..', в больнице %s, состоится призыв в Las Venturas Army.'):format(cTable.place_combo.v == 0 and 'Лос-Сантоса' or cTable.place_combo.v == 1 and 'Лас-Вентураса'))
                                        wait(5000)
                                        sampSendChat('/gov [Army LV]: Требования: иметь прописку в штате от двух лет, не иметь проблем с законом.')
                                        wait(5000)
                                        sampSendChat('/gov [Army LV]: С уважением, Командование Вооружённых Сил г. Las Venturas.')
                                        if cTable.dep.v == 0 then
                                            wait(3000)
                                            sampSendChat('/d OG, закончил вещание.')
                                        end
                                    end)
                                end
                                imgui.SameLine()
                                if imgui.Button(u8"О начале", imgui.ImVec2(70, 20))  then
                                    lua_thread.create(function()
                                        if cTable.dep.v == 0 then 
                                            sampSendChat('/d OG, вещаю.')
                                            wait(3000)
                                        end
                                        sampSendChat('/gov [Army LV]: Уважаемые жители и гости штата San Andreas.')
                                        wait(5000)
                                        sampSendChat('/gov [Army LV]: Призыв в Las Venturas Army объявляется открытым.')
                                        wait(5000)
                                        sampSendChat('/gov [Army LV]: Требования: иметь прописку в штате от двух лет, не иметь проблем с законом.')
                                        wait(5000)
                                        sampSendChat(('/gov [Army LV]: Призыв проходит в больнице %s, на втором этаже.'):format(cTable.place_combo.v == 0 and 'Лос-Сантоса' or cTable.place_combo.v == 1 and 'Лас-Вентураса'))
                                        wait(5000)
                                        sampSendChat('/gov [Army LV]: С уважением, Командование Вооружённых Сил г. Las Venturas.')
                                        if cTable.dep.v == 0 then
                                            wait(3000)
                                            sampSendChat('/d OG, закончил вещание.')
                                        end
                                    end)
                                end
                                imgui.SameLine()
                                if imgui.Button(u8"О продолжении", imgui.ImVec2(100, 20))  then
                                    lua_thread.create(function()
                                        if cTable.dep.v == 0 then 
                                            sampSendChat('/d OG, вещаю.')
                                            wait(3000)
                                        end
                                        sampSendChat('/gov [Army LV]: Уважаемые жители и гости штата San Andreas.')
                                        wait(5000)
                                        sampSendChat('/gov [Army LV]: В данный момент проходит призыв в Las Venturas Army.')
                                        wait(5000)
                                        sampSendChat('/gov [Army LV]: Требования: иметь прописку в штате от двух лет, не иметь проблем с законом.')
                                        wait(5000)
                                        sampSendChat(('/gov [Army LV]: Призыв проходит в больнице %s, на втором этаже.'):format(cTable.place_combo.v == 0 and 'Лос-Сантоса' or cTable.place_combo.v == 1 and 'Лас-Вентураса'))
                                        wait(5000)
                                        sampSendChat('/gov [Army LV]: С уважением, Командование Вооружённых Сил г. Las Venturas.')
                                        if cTable.dep.v == 0 then
                                            wait(3000)
                                            sampSendChat('/d OG, закончил вещание.')
                                        end
                                    end)
                                end
                                imgui.SameLine()
                                if imgui.Button(u8"О конце", imgui.ImVec2(70, 20))  then
                                    lua_thread.create(function()
                                        if cTable.dep.v == 0 then 
                                            sampSendChat('/d OG, вещаю.')
                                            wait(3000)
                                        end
                                        sampSendChat('/gov [Army LV]: Уважаемые жители и гости штата San Andreas.')
                                        wait(5000)
                                        sampSendChat('/gov [Army LV]: Призыв в Las Venturas Army объяляется закрытым.')
                                        wait(5000)
                                        sampSendChat('/gov [Army LV]: Так же в нашей армии открыт набор желающих на контрактную службу с выплатой денежных средств.')
                                        wait(5000)
                                        sampSendChat('/gov [Army LV]: Вся информация находится на официальном портале Army Las Venturas.')
                                        wait(5000)
                                        sampSendChat('/gov [Army LV]: С уважением, Командование Вооружённых Сил г. Las Venturas.')
                                        if cTable.dep.v == 0 then
                                            wait(3000)
                                            sampSendChat('/d OG, закончил вещание.')
                                        end
                                    end)
                                end
                                imgui.SameLine()
                                if imgui.Button(u8"О контракте", imgui.ImVec2(90, 20))  then
                                    lua_thread.create(function()
                                        if cTable.dep.v == 0 then 
                                            sampSendChat('/d OG, вещаю.') 
                                            wait(3000)
                                        end
                                        sampSendChat('/gov [Army LV]: Уважаемые жители и гости штата San Andreas.')
                                        wait(5000)
                                        sampSendChat('/gov [Army LV]: В нашей армии открыт набор желающих на контрактную службу.')
                                        wait(5000)
                                        sampSendChat('/gov [Army LV]: За прохождение контракта вы можете получить от 200.000 до 600.000 вирт.')
                                        wait(5000)
                                        sampSendChat('/gov [Army LV]: Подробнее на оф.портале Army Las Venturas. С уважением, Командование Army Las Venturas')
                                        if cTable.dep.v == 0 then
                                            wait(3000)
                                            sampSendChat('/d OG, закончил вещание.')
                                        end
                                    end)
                                end
                                imgui.SameLine()
                                if imgui.Button(u8"Срочка", imgui.ImVec2(60, 20))  then
                                    lua_thread.create(function()
                                        if cTable.dep.v == 0 then 
                                            sampSendChat('/d OG, вещаю.')
                                            wait(3000)
                                        end
                                        sampSendChat('/gov [Army LV]: Уважаемые жители и гости штата San Andreas.')
                                        wait(5000)
                                        sampSendChat('/gov [Army LV]: В нашей армии доступна срочная военная служба вне призыва с вознаграждением.')
                                        wait(5000)
                                        sampSendChat('/gov [Army LV]: Требования: иметь прописку в штате от двух лет, не иметь проблем с законом.')
                                        wait(5000)
                                        sampSendChat('/gov [Army LV]: Вся информация находится на официальном портале Army Las Venturas.')
                                        wait(5000)
                                        sampSendChat('/gov [Army LV]: С уважением, Командование Вооружённых Сил г. Las Venturas.')
                                        if cTable.dep.v == 0 then
                                            wait(3000)
                                            sampSendChat('/d OG, закончил вещание.')
                                        end
                                    end)
                                end
                                imgui.SameLine()
                                if imgui.Button(u8"О Академии", imgui.ImVec2(80, 20))  then
                                    lua_thread.create(function()
                                        if cTable.dep.v == 0 then 
                                            sampSendChat('/d OG, вещаю.')
                                            wait(3000)
                                        end
                                        sampSendChat('/gov [Army LV]: Уважаемые жители и гости штата San Andreas.')
                                        wait(5000)
                                        sampSendChat('/gov [Army LV]: В нашей армии открылись заявления в Военную академию Генерального Штаба.')
                                        wait(5000)
                                        sampSendChat('/gov [Army LV]: Требования: иметь прописку в штате от трех лет, не иметь проблем с законом.')
                                        wait(5000)
                                        sampSendChat('/gov [Army LV]: По окончанию обучения выплачивается 1.000.000 вирт и присваивается звание Мл.Лейтенант.')
                                        wait(5000)
                                        sampSendChat('/gov [Army LV]: Вся информация находится на официальном портале нашего Штата и Las Venturas Army.')
                                        if cTable.dep.v == 0 then
                                            wait(3000)
                                            sampSendChat('/d OG, закончил вещание.')
                                        end
                                    end)
                                end
                                imgui.PushItemWidth(50)
                                imgui.Combo(u8'Вещать в /d?', cTable.dep, u8"Да\0Нет\0\0")
                                imgui.Text((u8 'Время: %s\t'):format(os.date('%H:%M:%S')))
                                imgui.SameLine()
                            end
                            if frak == "SFA" then
                                imgui.SetCursorPosX(4)
                                imgui.PushItemWidth(70)
                                imgui.Combo(u8'Время начала призыва', sfaTable.time_combo, "15:25\0".."17:25\0".."20:25\0".."22:25\0\0")
                                imgui.SameLine()
                                imgui.PushItemWidth(140)
                                imgui.Combo(u8'Выберите место проведения призыва', sfaTable.place_combo , u8"Больница ЛС\0Больница ЛВ\0\0")
                                imgui.BeginChild('##csc_example', imgui.ImVec2(780, 110))
                                imgui.PushItemWidth(400)
                                imgui.SetCursorPos(imgui.ImVec2(5, 5))
                                imgui.Combo(u8'##combo_example', sfaTable.current_combo, u8"Предупреждение\0Начало\0Продолжение\0Конец\0Контракт\0Срочка\0\0")
                                if sfaTable.current_combo.v == 0 then
                                    imgui.Text((u8" /gov [Army SF]: Уважаемые жители и гости штата San Andreas.\n /gov [Army SF]: Сегодня в "..sfaTable.time_value[sfaTable.time_combo.v + 1]..u8", в больнице %s, состоится призыв в San Fierro Army.\n /gov [Army SF]: Требования: иметь прописку в штате от двух лет, не иметь проблем с законом.\n /gov [Army SF]: С уважением, Командование Вооружённых Сил г. San Fierro."):format(sfaTable.place_combo.v == 0 and u8'Лос-Сантоса' or sfaTable.place_combo.v == 1 and u8'Лас-Вентураса'))
                                end
                                if sfaTable.current_combo.v == 1 then
                                    imgui.Text((u8" /gov [Army SF]: Уважаемые жители и гости штата San Andreas.\n /gov [Army SF]: Призыв в San Fierro Army объявляется открытым.\n /gov [Army SF]: Требования: иметь прописку в штате от двух лет, не иметь проблем с законом.\n /gov [Army SF]: Призыв проходит в больнице %s, на втором этаже.\n /gov [Army SF]: С уважением, Командование Вооружённых Сил г. San Fierro."):format(sfaTable.place_combo.v == 0 and u8'Лос-Сантоса' or sfaTable.place_combo.v == 1 and u8'Лас-Вентураса'))
                                end
                                if sfaTable.current_combo.v == 2 then
                                    imgui.Text((u8" /gov [Army SF]: Уважаемые жители и гости штата San Andreas.\n /gov [Army SF]: В данный момент проходит призыв в San Fierro Army.\n /gov [Army SF]: Требования: иметь прописку в штате от двух лет, не иметь проблем с законом.\n /gov [Army SF]: Призыв проходит в больнице %s, на втором этаже.\n /gov [Army SF]: С уважением, Командование Вооружённых Сил г. San Fierro."):format(sfaTable.place_combo.v == 0 and u8'Лос-Сантоса' or sfaTable.place_combo.v == 1 and u8'Лас-Вентураса'))
                                end
                                if sfaTable.current_combo.v == 3 then
                                    imgui.Text(u8" /gov [Army SF]: Уважаемые жители и гости штата San Andreas.\n /gov [Army SF]: Призыв в San Fierro Army объявляется закрытым.\n /gov [Army SF]: Так же в нашей армии открыт набор желающих на контрактную службу с выплатой денежных средств.\n /gov [Army SF]: Вся информация находится на официальном портале Army San Fierro.\n /gov [Army SF]: С уважением, Командование Вооружённых Сил г. San Fierro.")
                                end
                                if sfaTable.current_combo.v == 4 then
                                    imgui.Text(u8" /gov [Army SF]: Уважаемые жители и гости штата San Andreas.\n /gov [Army SF]: В нашей армии открыт набор желающих на контрактную службу.\n /gov [Army SF]: За прохождение контракта вы можете получить от 100.000 до 300.000 вирт.\n /gov [Army SF]: Подробнее на оф.портале Army San Fierro. С уважением, Командование Army San Fierro")
                                end
                                if sfaTable.current_combo.v == 5 then
                                    imgui.Text(u8" /gov [Army SF]: Уважаемые жители и гости штата San Andreas.\n /gov [Army SF]: В нашей армии доступна срочная военная служба вне призыва с вознаграждением.\n /gov [Army SF]: Требования: иметь прописку в штате от двух лет, не иметь проблем с законом.\n /gov [Army SF]: Вся информация находится на официальном портале Army San Fierro\n /gov [Army SF]: С уважением, Командование Вооружённых Сил г. San Fierro.")
                                end
                                imgui.EndChild()
                                if imgui.Button(u8"О предупреждении", imgui.ImVec2(125, 20))  then
                                    lua_thread.create(function()
                                        if sfaTable.dep.v == 0 then 
                                            sampSendChat('/d OG, занимаю волну вещания.')
                                            wait(3000)
                                        end
                                        sampSendChat('/gov [Army SF]: Уважаемые жители и гости штата San Andreas.')
                                        wait(5000)
                                        sampSendChat(('/gov [Army SF]: Сегодня в '..sfaTable.time_value[sfaTable.time_combo.v + 1]..', в больнице %s, состоится призыв в San Fierro Army.'):format(sfaTable.place_combo.v == 0 and 'Лос-Сантоса' or sfaTable.place_combo.v == 1 and 'Лас-Вентураса'))
                                        wait(5000)
                                        sampSendChat('/gov [Army SF]: Требования: иметь прописку в штате от двух лет, не иметь проблем с законом.')
                                        wait(5000)
                                        sampSendChat('/gov [Army SF]: С уважением, Командование Вооружённых Сил г. San Fierro.')
                                        if sfaTable.dep.v == 0 then
                                            wait(3000)
                                            sampSendChat('/d OG, освобождаю волну вещания.')
                                        end
                                    end)
                                end
                                imgui.SameLine()
                                if imgui.Button(u8"О начале", imgui.ImVec2(70, 20))  then
                                    lua_thread.create(function()
                                        if sfaTable.dep.v == 0 then 
                                            sampSendChat('/d OG, занимаю волну вещания.')
                                            wait(3000)
                                        end
                                        sampSendChat('/gov [Army SF]: Уважаемые жители и гости штата San Andreas.')
                                        wait(5000)
                                        sampSendChat('/gov [Army SF]: Призыв в San Fierro Army объявляется открытым.')
                                        wait(5000)
                                        sampSendChat('/gov [Army SF]: Требования: иметь прописку в штате от двух лет, не иметь проблем с законом.')
                                        wait(5000)
                                        sampSendChat(('/gov [Army SF]: Призыв проходит в больнице %s, на втором этаже.'):format(sfaTable.place_combo.v == 0 and 'Лос-Сантоса' or sfaTable.place_combo.v == 1 and 'Лас-Вентураса'))
                                        wait(5000)
                                        sampSendChat('/gov [Army SF]: С уважением, Командование Вооружённых Сил г. San Fierro.')
                                        if sfaTable.dep.v == 0 then
                                            wait(3000)
                                            sampSendChat('/d OG, освобождаю волну вещания.')
                                        end
                                    end)
                                end
                                imgui.SameLine()
                                if imgui.Button(u8"О продолжении", imgui.ImVec2(100, 20))  then
                                    lua_thread.create(function()
                                        if sfaTable.dep.v == 0 then 
                                            sampSendChat('/d OG, занимаю волну вещания.')
                                            wait(3000)
                                        end
                                        sampSendChat('/gov [Army SF]: Уважаемые жители и гости штата San Andreas.')
                                        wait(5000)
                                        sampSendChat('/gov [Army SF]: В данный момент проходит призыв в San Fierro Army.')
                                        wait(5000)
                                        sampSendChat('/gov [Army SF]: Требования: иметь прописку в штате от двух лет, не иметь проблем с законом.')
                                        wait(5000)
                                        sampSendChat(('/gov [Army SF]: Призыв проходит в больнице %s, на втором этаже.'):format(sfaTable.place_combo.v == 0 and 'Лос-Сантоса' or sfaTable.place_combo.v == 1 and 'Лас-Вентураса'))
                                        wait(5000)
                                        sampSendChat('/gov [Army SF]: С уважением, Командование Вооружённых Сил г. San Fierro.')
                                        if sfaTable.dep.v == 0 then
                                            wait(3000)
                                            sampSendChat('/d OG, освобождаю волну вещания.')
                                        end
                                    end)
                                end
                                imgui.SameLine()
                                if imgui.Button(u8"О конце", imgui.ImVec2(70, 20))  then
                                    lua_thread.create(function()
                                        if sfaTable.dep.v == 0 then 
                                            sampSendChat('/d OG, занимаю волну вещания.')
                                            wait(3000)
                                        end
                                        sampSendChat('/gov [Army SF]: Уважаемые жители и гости штата San Andreas.')
                                        wait(5000)
                                        sampSendChat('/gov [Army SF]: Призыв в San Fierro Army объяляется закрытым.')
                                        wait(5000)
                                        sampSendChat('/gov [Army SF]: Так же в нашей армии открыт набор желающих на контрактную службу с выплатой денежных средств.')
                                        wait(5000)
                                        sampSendChat('/gov [Army SF]: Вся информация находится на официальном портале Army San Fierro.')
                                        wait(5000)
                                        sampSendChat('/gov [Army SF]: С уважением, Командование Вооружённых Сил г. San Fierro.')
                                        if sfaTable.dep.v == 0 then
                                            wait(3000)
                                            sampSendChat('/d OG, освобождаю волну вещания.')
                                        end
                                    end)
                                end
                                imgui.SameLine()
                                if imgui.Button(u8"О контракте", imgui.ImVec2(90, 20))  then
                                    lua_thread.create(function()
                                        if sfaTable.dep.v == 0 then 
                                            sampSendChat('/d OG, занимаю волну вещания.')
                                            wait(3000)
                                        end
                                        sampSendChat('/gov [Army SF]: Уважаемые жители и гости штата San Andreas.')
                                        wait(5000)
                                        sampSendChat('/gov [Army SF]: В нашей армии открыт набор желающих на контрактную службу с выплатой денежных средств до 500.000 вирт.')
                                        wait(5000)
                                        sampSendChat('/gov [Army SF]: Требования: иметь прописку в штате от трех лет, не иметь проблем с законом.')
                                        wait(5000)
                                        sampSendChat('/gov [Army SF]: Вся информация находится на официальном портале Army San Fierro.')
                                        wait(5000)
                                        sampSendChat('/gov [Army SF]: С уважением, Командование Вооружённых Сил г. San Fierro.')
                                        if sfaTable.dep.v == 0 then
                                            wait(3000)
                                            sampSendChat('/d OG, освобождаю волну вещания.')
                                        end
                                    end)
                                end
                                imgui.SameLine()
                                if imgui.Button(u8"Срочка", imgui.ImVec2(60, 20))  then
                                    lua_thread.create(function()
                                        if sfaTable.dep.v == 0 then 
                                            sampSendChat('/d OG, занимаю волну вещания.')
                                            wait(3000)
                                        end
                                        sampSendChat('/gov [Army SF]: Уважаемые жители и гости штата San Andreas.')
                                        wait(5000)
                                        sampSendChat('/gov [Army SF]: В нашей армии доступна срочная военная служба вне призыва с вознаграждением.')
                                        wait(5000)
                                        sampSendChat('/gov [Army SF]: Требования: иметь прописку в штате от двух лет, не иметь проблем с законом.')
                                        wait(5000)
                                        sampSendChat('/gov [Army SF]: Вся информация находится на официальном портале Army San Fierro.')
                                        wait(5000)
                                        sampSendChat('/gov [Army SF]: С уважением, Командование Вооружённых Сил г. San Fierro.')
                                        if sfaTable.dep.v == 0 then
                                            wait(3000)
                                            sampSendChat('/d OG, освобождаю волну вещания.')
                                        end
                                    end)
                                end
                                imgui.PushItemWidth(50)
                                imgui.Combo(u8'Вещать в /d?', sfaTable.dep, u8"Да\0Нет\0\0")
                                imgui.Text((u8 'Время: %s'):format(os.date('%H:%M:%S')))
                            end
                            imgui.PopStyleColor(1)
                        imgui.EndChild()
                    imgui.EndChild()
                end
                if sub_show == 2.3 then
                    imgui.BeginChild("ChildWindow4", imgui.ImVec2((size.x - (size.x/3.2)), size.y/1.5), false)
                        local size_child1 = imgui.GetWindowSize()
                        imgui.SetCursorPosX((size_child1.x / 2.4 ) - (size_child1.x/2.5))
                        if imgui.ImageButton(logs_non, imgui.ImVec2(size_child1.x/3.3, size_child1.y/14)) then sub_show = 2.1 end imgui.SameLine()
                        if imgui.ImageButton(gos_non, imgui.ImVec2(size_child1.x/3.3, size_child1.y/14)) then sub_show = 2.2 end imgui.SameLine()
                        imgui.Image(online_act, imgui.ImVec2(size_child1.x/3.2, size_child1.y/9.5))
                        imgui.BeginChild("ChildWindow5", imgui.ImVec2((size.x - (size.x/2.9)), size.y/1.8), false)
                            local size_child2 = imgui.GetWindowSize()
                            imgui.BeginChild("ChildWindow3", imgui.ImVec2((size_child2.x - 10), size_child2.y/1.085), false)
                                local size_child3 = imgui.GetWindowSize()
                                _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
                                local myname = sampGetPlayerNickname(myid)
                                imgui.Image(block, imgui.ImVec2(size_child3.x, size_child3.y/1.05))
                                imgui.SetCursorPosY(size_child3.y/18)
                                imgui.BeginChild("ChildWindow4", imgui.ImVec2((size_child3.x - 10), size_child3.y/1.17), false)
                                    imgui.SetCursorPosY(30)
                                    imgui.CenterTextColoredRGB('\n\n\nВсего отыграно: '..get_clock(online.onWeek.full))
                                    imgui.SetCursorPosY(70)
                                    imgui.Separator()
                                    imgui.SetCursorPosY(80)
                                    for day = 1, 6 do -- ПН -> СБ
                                        imgui.SetCursorPosX(250)
                                        imgui.Text(u8(tWeekdays[day])); imgui.SameLine()
                                        imgui.Text(get_clock(online.myWeekOnline[day]))
                                    end 
                                    imgui.SetCursorPosX(250)
                                    imgui.Text(u8(tWeekdays[0])); imgui.SameLine()
                                    imgui.Text(get_clock(online.myWeekOnline[0]))
                                    imgui.SetCursorPosY(215)
                                    imgui.Separator()
                                imgui.EndChild()
                            imgui.EndChild()
                        imgui.EndChild()
                    imgui.EndChild()
                end
            end
            if show == 3 then
                if sub_show == 3.1 then
                    imgui.BeginChild("ChildWindow31", imgui.ImVec2((size.x - (size.x/3.2)), size.y/1.5), false)
                        local size_child1 = imgui.GetWindowSize()
                        local naprav = ""
                        if getCharHeading(playerPed) >= 337.5 or getCharHeading(playerPed) <= 22.5 then naprav = u8"Северное" end
                        if getCharHeading(playerPed) > 22.5 and getCharHeading(playerPed) <= 67.5 then naprav = u8"Северо-западное" end
                        if getCharHeading(playerPed) > 67.5 and getCharHeading(playerPed) <= 112.5 then naprav = u8"Западное" end
                        if getCharHeading(playerPed) > 112.5 and getCharHeading(playerPed) <= 157.5 then naprav = u8"Юго-западное" end
                        if getCharHeading(playerPed) > 157.5 and getCharHeading(playerPed) <= 202.5 then naprav = u8"Южное" end
                        if getCharHeading(playerPed) > 202.5 and getCharHeading(playerPed) <= 247.5 then naprav = u8"Юго-восточное" end
                        if getCharHeading(playerPed) > 247.5 and getCharHeading(playerPed) <= 292.5 then naprav = u8"Восточное" end
                        if getCharHeading(playerPed) > 292.5 and getCharHeading(playerPed) <= 337.5 then naprav = u8"Северо-восточное" end
                        imgui.SetCursorPosX((size_child1.x / 2 ) - (size_child1.x/2.5))
                        imgui.Image(db_act, imgui.ImVec2(size_child1.x/3, size.y/11.3)) imgui.SameLine()
                        if imgui.ImageButton(cb_non, imgui.ImVec2(size_child1.x/3, size.y/11.3)) then sub_show = 3.2 end
                        imgui.BeginChild("ChildWindow343", imgui.ImVec2((size.x - (size.x/2.9)), size.y/1.8), false)
                            local size_child5 = imgui.GetWindowSize()
                            imgui.Image(block, imgui.ImVec2(size_child5.x, size_child5.y/1.05))
                            imgui.SetCursorPosY(size_child5.y*0.01)
                            imgui.BeginChild("ChildWindow333", imgui.ImVec2((size.x - (size.x/2.9)), size.y/2), false)
                                local size_child3 = imgui.GetWindowSize()
                                _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
                                local myname = sampGetPlayerNickname(myid)
                                imgui.SetCursorPosY(size_child3.y/18)
                                for k, v in ipairs(tBindList) do
                                    imgui.SetCursorPosX(20)
                                    if imadd.HotKey("##HK" .. k, v, tLastKeys, 100) then
                                        if not rkeys.isHotKeyDefined(v.v) then
                                            if rkeys.isHotKeyDefined(tLastKeys.v) then
                                                rkeys.unRegisterHotKey(tLastKeys.v)
                                            end
                                            rkeys.registerHotKey(v.v, true, onHotKey)
                                        end
                                        saveData(tBindList, fileb)
                                    end
                                    imgui.SameLine()
                                    imgui.CentrText(u8(v.name))
                                    imgui.SameLine(size_child1.x/1.2)
                                    if imgui.Button(fa.ICON_PENCIL..u8'Edit##'..k) then imgui.OpenPopup(u8 "Редактирование биндера##editbind"..k) 
                                        bindname.v = u8(v.name) 
                                        bindtext.v = u8(v.text)
                                    end
                                    if imgui.BeginPopupModal(u8 'Редактирование биндера##editbind'..k, _, imgui.WindowFlags.NoResize) then
                                        imgui.Text(u8 "Введите название биндера:")
                                        imgui.InputText("##Введите название биндера", bindname)
                                        imgui.Text(u8 "Введите текст биндера:")
                                        imgui.InputTextMultiline("##Введите текст биндера", bindtext, imgui.ImVec2(500, 200))
                                        imgui.Separator()
                                        if imgui.ImageButton(key_code, imgui.ImVec2(25, 25)) then imgui.OpenPopup('##bindkey') end
                                        --if imgui.Button(u8 'Ключи', imgui.ImVec2(90, 20)) then imgui.OpenPopup('##bindkey') end
                                        if imgui.BeginPopup('##bindkey') then
                                            imgui.Text(u8 '{myid} - ID вашего персонажа | '..select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
                                            imgui.Text(u8 '{myrpnick} - РП ник вашего персонажа | '..sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))):gsub('_', ' '))
                                            imgui.Text(u8 '{targetid} - ID игрока на которого вы целитесь | '..targetid)
                                            imgui.Text(u8 '{targetrpnick} - РП ник игрока на которого вы целитесь | '..sampGetPlayerNicknameForBinder(targetid):gsub('_', ' '))
                                            imgui.Text(u8('{tag} - Ваш тэг | '..config.main.tar))
                                            imgui.Text(u8 ('{kv} - Ваш текущий квадрат | '..kvadratb()))
                                            imgui.Text(u8 '{rang} - Ваше звание | '..u8(rang))
                                            imgui.Text(u8 '{time} - Текущее время | '..os.date('%H:%M:%S'))
                                            imgui.Text(u8 '{data} - Текущяя дата | '..os.date('%d.%m.%Y'))
                                            imgui.Text(u8 '{frak} - Ваша фракция | '..u8(frak))
                                            imgui.Text(u8 '{naprav} - Направление | '..naprav)
                                            imgui.Text(u8 '{dl} - ID авто, в котором вы сидите | '..mcid)
                                            imgui.Text(u8 '{f6} - Отправить сообщение в чат через эмуляцию чата (использовать в самом начале)')
                                            imgui.Text(u8 '{noe} - Оставить сообщение в полле ввода а не отправлять его в чат (использовать в самом начале)')
                                            imgui.Text(u8 '{wait:sek} - Задержка между строками, где sek - кол-во миллисекунд. Пример: {wait:2000} - задержка 2 секунды. (использовать отдельно на новой строчке)')
                                            imgui.Text(u8 '{screen} - Сделать скриншот экрана (использовать отдельно на новой строчке)')
                                            imgui.EndPopup()
                                        end
                                        imgui.SameLine()
                                        imgui.SetCursorPosX((imgui.GetWindowWidth() - 90 - imgui.GetStyle().ItemSpacing.x))
                                        if imgui.ImageButton(del_code, imgui.ImVec2(25, 25)) then
                                            table.remove(tBindList, k)
                                            saveData(tBindList, fileb)
                                            imgui.CloseCurrentPopup()
                                        end
                                        imgui.SameLine()
                                        imgui.SetCursorPosX((imgui.GetWindowWidth() - 180 + imgui.GetStyle().ItemSpacing.x) / 2)
                                        if imgui.ImageButton(save_code, imgui.ImVec2(25, 25)) then
                                            v.name = u8:decode(bindname.v)
                                            v.text = u8:decode(bindtext.v)
                                            bindname.v = ''
                                            bindtext.v = ''
                                            saveData(tBindList, fileb)
                                            imgui.CloseCurrentPopup()
                                        end
                                        imgui.SameLine()
                                        if imgui.Button(u8 "Закрыть##"..k, imgui.ImVec2(90, 20)) then imgui.CloseCurrentPopup() end
                                        imgui.EndPopup()
                                    end
                                end
                            imgui.EndChild()
                        imgui.EndChild()
                    imgui.EndChild()
                    imgui.SetCursorPos(imgui.ImVec2(size.x-70, size.y/3)) if imgui.ImageButton(add_code, imgui.ImVec2(27, 27)) then 
                        tBindList[#tBindList + 1] = {text = "", v = {}, time = 0, name = "Бинд №"..#tBindList + 1}
                        saveData(tBindList, fileb)
                    end

                end
                if sub_show == 3.2 then
                    imgui.BeginChild("ChildWindow32", imgui.ImVec2((size.x - (size.x/3.2)), size.y/1.5), false)
                        local size_child1 = imgui.GetWindowSize()
                        local naprav = ""
                        if getCharHeading(playerPed) >= 337.5 or getCharHeading(playerPed) <= 22.5 then naprav = u8"Северное" end
                        if getCharHeading(playerPed) > 22.5 and getCharHeading(playerPed) <= 67.5 then naprav = u8"Северо-западное" end
                        if getCharHeading(playerPed) > 67.5 and getCharHeading(playerPed) <= 112.5 then naprav = u8"Западное" end
                        if getCharHeading(playerPed) > 112.5 and getCharHeading(playerPed) <= 157.5 then naprav = u8"Юго-западное" end
                        if getCharHeading(playerPed) > 157.5 and getCharHeading(playerPed) <= 202.5 then naprav = u8"Южное" end
                        if getCharHeading(playerPed) > 202.5 and getCharHeading(playerPed) <= 247.5 then naprav = u8"Юго-восточное" end
                        if getCharHeading(playerPed) > 247.5 and getCharHeading(playerPed) <= 292.5 then naprav = u8"Восточное" end
                        if getCharHeading(playerPed) > 292.5 and getCharHeading(playerPed) <= 337.5 then naprav = u8"Северо-восточное" end
                        imgui.SetCursorPosX((size_child1.x / 2 ) - (size_child1.x/2.5))
                        if imgui.ImageButton(db_non, imgui.ImVec2(size_child1.x/3, size.y/11.3)) then sub_show = 3.1 end imgui.SameLine()
                        imgui.Image(cb_act, imgui.ImVec2(size_child1.x/3, size.y/11.3))
                        imgui.BeginChild("ChildWindow34", imgui.ImVec2((size.x - (size.x/2.9)), size.y/1.8), false)
                            local size_child3 = imgui.GetWindowSize()
                            _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
                            local myname = sampGetPlayerNickname(myid)
                            imgui.Image(com_bind, imgui.ImVec2(size_child3.x, size_child3.y/1.05))
                            imgui.SetCursorPosY(size_child3.y/19)
                            imgui.BeginChild("##commandlist", imgui.ImVec2(140 ,320), false)
                            for k, v in pairs(commands) do
                                if imgui.Selectable(u8(("%s. /%s##%s"):format(k, v.cmd, k)), vars.menuselect == k) then 
                                    vars.menuselect     = k 
                                    vars.cmdbuf.v       = u8(v.cmd) 
                                    vars.cmdparams.v    = v.params
                                    vars.cmdtext.v      = u8(v.text)
                                    saveData(commands, "moonloader/config/Army-Tools/cmdbinder.json")
                                end
                            end
                            imgui.EndChild()
                            imgui.SameLine(170)
                            imgui.BeginChild("##commandsetting", imgui.ImVec2(470, 320), false)
                            for k, v in pairs(commands) do
                                if vars.menuselect == k then
                                    imgui.PushItemWidth(113)
                                    imgui.InputText(u8 "Введите саму команду", vars.cmdbuf)
                                    imgui.InputInt(u8 "Введите кол-во пар-тров", vars.cmdparams, 0)
                                    imgui.PopItemWidth()
                                    imgui.InputTextMultiline(u8 "##cmdtext", vars.cmdtext, imgui.ImVec2(450, 100))
                                    imgui.TextWrapped(u8 "Ключи параметров: {param:1}, {param:2} и т.д (Использовать в тексте на месте параметра)\nКлюч задержки: {wait:кол-во миллисекунд} (Использовать на новой строке)")
                                    if imgui.ImageButton(save_code, imgui.ImVec2(25, 25)) then
                                        sampUnregisterChatCommand(v.cmd)
                                        v.cmd = u8:decode(vars.cmdbuf.v)
                                        v.params = vars.cmdparams.v
                                        v.text = u8:decode(vars.cmdtext.v)
                                        saveData(commands, "moonloader/config/Army-Tools/cmdbinder.json")
                                        registerCommandsBinder()
                                        sampAddChatMessage(scriptname.. " | {FFFFFF}Команда сохранена", 0x7FFF00)
                                    end
                                    imgui.SameLine()
                                    if imgui.ImageButton(del_code, imgui.ImVec2(25, 25)) then
                                        imgui.OpenPopup(u8 "Удаление команды##"..k)
                                    end
                                    if imgui.BeginPopupModal(u8 "Удаление команды##"..k, _, imgui.WindowFlags.AlwaysAutoResize) then
                                        imgui.SetCursorPosX(imgui.GetWindowWidth()/2 - imgui.CalcTextSize(u8 "Вы действительно хотите удалить команду?").x / 2)
                                        imgui.Text(u8 "Вы действительно хотите удалить команду?")
                                        if imgui.Button(u8 "Удалить##"..k, imgui.ImVec2(170, 20)) then
                                            sampUnregisterChatCommand(v.cmd)
                                            vars.menuselect     = 0
                                            vars.cmdbuf.v       = ""
                                            vars.cmdparams.v    = 0
                                            vars.cmdtext.v      = ""
                                            table.remove(commands, k)
                                            saveData(commands, "moonloader/config/Army-Tools/cmdbinder.json")
                                            registerCommandsBinder()
                                            sampAddChatMessage(scriptname.. " | {FFFFFF}Команда удалена", 0x7FFF00)
                                            imgui.CloseCurrentPopup()
                                        end
                                        imgui.SameLine()
                                        if imgui.Button(u8 "Отмена##"..k, imgui.ImVec2(170, 20)) then
                                            imgui.CloseCurrentPopup()
                                        end
                                        imgui.EndPopup()
                                    end
                                    imgui.SameLine()
                                    local x,y,z = getCharCoordinates(PLAYER_PED)
                                    if imgui.ImageButton(key_code, imgui.ImVec2(25, 25)) then imgui.OpenPopup('##bindkey') end
                                    if imgui.BeginPopup('##bindkey') then
                                        imgui.Text(u8 'Используйте ключи биндера для более удобного использования биндера')
                                        imgui.Separator()
                                        imgui.Text(u8 '{myid} - ID вашего персонажа | '..select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
                                        imgui.Text(u8 '{myrpnick} - РП ник вашего персонажа | '..sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))):gsub('_', ' '))
                                        imgui.Text(u8 '{targetid} - ID игрока на которого вы целитесь | '..targetid)
                                        imgui.Text(u8 '{targetrpnick} - РП ник игрока на которого вы целитесь | '..sampGetPlayerNicknameForBinder(targetid):gsub('_', ' '))
                                        imgui.Text(u8('{tag} - Ваш тэг | '..config.main.tar))
                                        imgui.Text(u8 ('{kv} - Ваш текущий квадрат | '..kvadratb()))
                                        imgui.Text(u8 '{rang} - Ваше звание | '..u8(rang))
                                        imgui.Text(u8 '{time} - Текущее время | '..os.date('%H:%M:%S'))
                                        imgui.Text(u8 '{data} - Текущяя дата | '..os.date('%d.%m.%Y'))
                                        imgui.Text(u8 '{frak} - Ваша фракция | '..u8(frak))
                                        imgui.Text(u8 '{naprav} - Направление | '..naprav)
                                        imgui.Text(u8 '{location} - Локация | '..u8(calculateZone(x,y,z)))
                                        imgui.Text(u8 '{dl} - ID авто, в котором вы сидите | '..mcid)
                                        imgui.Text(u8 '{f6} - Отправить сообщение в чат через эмуляцию чата (использовать в самом начале)')
                                        imgui.Text(u8 '{noe} - Оставить сообщение в полле ввода а не отправлять его в чат (использовать в самом начале)')
                                        imgui.Text(u8 '{wait:sek} - Задержка между строками, где sek - кол-во миллисекунд. Пример: {wait:2000} - задержка 2 секунды. (использовать отдельно на новой строчке)')
                                        imgui.Text(u8 '{screen} - Сделать скриншот экрана (использовать отдельно на новой строчке)')
                                        imgui.EndPopup()
                                    end
                                end
                            end
                            imgui.EndChild()
                        imgui.EndChild()
                    imgui.EndChild()
                    imgui.SetCursorPos(imgui.ImVec2(size.x-70, size.y/3)) if imgui.ImageButton(add_code, imgui.ImVec2(27, 27)) then 
                        table.insert(commands, {cmd = "", params = 0, text = ""})
                        saveData(commands, "moonloader/config/Army-Tools/cmdbinder.json")
                    end
                end
            end
        imgui.End()
        imgui.PopStyleColor(4)
    end
    if vzaim_new.v then
        local sw, sh = getScreenResolution()
        local clr = imgui.Col
        local ImVec4 = imgui.ImVec4
        local id = ID_sec
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 1.5), imgui.Cond.FistUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(sw / 2.3, sh / 2.5), imgui.Cond.FirstUseEver)
        imgui.PushStyleColor(clr.WindowBg, ImVec4(0.23, 0.23, 0.23, 0.00))
        imgui.PushStyleColor(clr.Button, ImVec4(0.23, 0.23, 0.23, 0.00))
        imgui.PushStyleColor(clr.ButtonActive, ImVec4(0.23, 0.23, 0.23, 0.50))
        imgui.PushStyleColor(clr.ButtonHovered, ImVec4(0.23, 0.23, 0.23, 0.00))
        imgui.Begin('Imgui Interfaces', vzaim_new, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
            size_window = imgui.GetWindowSize() 
            size = imgui.ImVec2(size_window.x / 4.5, size_window.y / 9.5)
            if imgui.ImageButton(inv, size, imgui.ImVec2(0,0),  imgui.ImVec2(1,1), -1, imgui.ImVec4(1,1,1,0), imgui.ImVec4(1,1,1,1)) then
                lua_thread.create(function()
                if sampIsPlayerConnected(id) then
                    sampSendChat(string.format('/me %s все нужные документы на имя %s после %s форму', config.main.male and 'подписал' or 'подписала', sampGetPlayerNickname(id):gsub("_", " "), config.main.male and 'передал' or 'передала'))
                    wait(1400)
                    sampSendChat(string.format('/invite %d', tonumber(id)))
                end end)
            end
            imgui.SameLine(20,20)
            imgui.SetCursorPosX(size_window.x / 1.5)
            if imgui.ImageButton(uninv, size, imgui.ImVec2(0,0),  imgui.ImVec2(1,1), -1, imgui.ImVec4(1,1,1,0), imgui.ImVec4(1,1,1,1)) then
                lua_thread.create(function()
                sampShowDialog(2038, "Ввод текста", "Укажите причину", "ОК", "Отмена", DIALOG_STYLE_INPUT)
                while sampIsDialogActive(6406) do wait(100) end
                local result, button, _, input = sampHasDialogRespond(2038)
                if button == 1 and input ~= nil then
                    if sampIsPlayerConnected(id) then
                        sampSendChat(string.format('/me держа в руках контракт на имя %s %s печать "Расторгнут"', config.main.male and 'поставил' or 'поставила', sampGetPlayerNickname(id):gsub("_", " ")))
                        wait(1400)
                        sampSendChat(string.format('/uninvite %d %s', tonumber(id), input))
                        wait(1400)
                        sampSendChat(string.format('/r %s %s уволен из армии по причине: %s', config.main.tar, sampGetPlayerNickname(id):gsub("_", " "), input))
                    end
                end end)
            end
            imgui.Text("")
            if imgui.ImageButton(transport, size, imgui.ImVec2(0,0),  imgui.ImVec2(1,1), -1, imgui.ImVec4(1,1,1,0), imgui.ImVec4(1,1,1,1)) then
                lua_thread.create(function() sampShowDialog(2038, "Ввод текста", "Укажите фракцию (например SFPD)", "ОК", "Отмена", DIALOG_STYLE_INPUT)
                while sampIsDialogActive(6406) do wait(100) end
                local result, button, _, input = sampHasDialogRespond(2038)
                if button == 1 and input ~= nil then
                    if sampIsPlayerConnected(id) then
                        local result, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
                        sampSendChat(string.format('/me держа в руках рапорт на имя %s %s "Перевод одобрен"', config.main.male and 'расписался' or 'расписалась', sampGetPlayerNickname(id):gsub("_", " ")))
                        wait(1400)
                        sampSendChat(string.format('/do В рапорте: Я, %s %s, одобряю %s перевод в %s.', rang, sampGetPlayerNickname(myid):gsub("_", " "), sampGetPlayerNickname(id):gsub("_", " "), input))
                    end
                end end)
            end
            imgui.SameLine(20,20)
            imgui.SetCursorPosX(size_window.x / 1.5)
            if imgui.ImageButton(tie, size, imgui.ImVec2(0,0),  imgui.ImVec2(1,1), -1, imgui.ImVec4(1,1,1,0), imgui.ImVec4(1,1,1,1)) then
                local valid, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
                if valid then
                    result, targetid = sampGetPlayerIdByCharHandle(ped)
                    if result then
                        lua_thread.create(function()
                            sampSendChat(string.format('/me %s стяжки с разгрузки', config.main.male and 'снял' or 'сняла'))
                            wait(1400)
                            sampSendChat('/tie '..targetid)
                        end)
                    end
                else
                    local closeid = getClosestPlayerId()
                    if closeid ~= -1 then 
                        local result, closehandle = sampGetCharHandleBySampPlayerId(closeid)
                        if doesCharExist(closehandle) then
                            lua_thread.create(function()
                                sampSendChat(string.format('/me %s стяжки с разгрузки', config.main.male and 'снял' or 'сняла'))
                                wait(1400)
                                sampSendChat('/tie '..closeid)
                            end)
                        end
                    end
                end
            end
            imgui.Text("")
            if imgui.ImageButton(rangi, size, imgui.ImVec2(0,0),  imgui.ImVec2(1,1), -1, imgui.ImVec4(1,1,1,0), imgui.ImVec4(1,1,1,1)) then
                lua_thread.create(function() sampShowDialog(2038, "Ввод текста", "Укажите порядковый ранг (цифра)", "ОК", "Отмена", DIALOG_STYLE_INPUT)
                while sampIsDialogActive(6406) do wait(100) end
                local result, button, _, input = sampHasDialogRespond(2038)
                if button == 1 and input ~= nil then
                    if sampIsPlayerConnected(id) then
                        sampSendChat(string.format('/giverank %d %d', tonumber(id), tonumber(input)))
                        wait(1000)
                        sampSendChat(string.format("/me %s %s новые погоны", config.main.male and 'передал' or 'передала', sampGetPlayerNickname(id):gsub("_", " ")))
                    end
                end end)
            end
            imgui.SameLine(20,20)
            imgui.SetCursorPosX(size_window.x / 1.5)
            if imgui.ImageButton(untie, size, imgui.ImVec2(0,0),  imgui.ImVec2(1,1), -1, imgui.ImVec4(1,1,1,0), imgui.ImVec4(1,1,1,1)) then
                local valid, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
                if valid then
                    local result, targetid = sampGetPlayerIdByCharHandle(ped)
                    if result then
                        lua_thread.create(function()
                            sampSendChat(string.format('/me %s стяжки с человека напротив', config.main.male and 'снял' or 'сняла'))
                            wait(1400)
                            sampSendChat('/untie '..targetid)
                        end)
                    end
                else
                    local closeid = getClosestPlayerId()
                    if sampIsPlayerConnected(closeid) then
                        if closeid ~= -1 then
                            local result, closehandle = sampGetCharHandleBySampPlayerId(closeid)
                            if doesCharExist(closehandle) then
                                lua_thread.create(function()
                                    sampSendChat(string.format('/me %s стяжки с человека напротив', config.main.male and 'снял' or 'сняла'))
                                    wait(1400)
                                    sampSendChat('/untie '..closeid)
                                end)
                            end
                        end
                    end
                end
            end
            imgui.Text("")
            imgui.SetCursorPosX((size_window.x / 2) - (size_window.x / 6.45))
            if imgui.ImageButton(closed, size, imgui.ImVec2(0,0),  imgui.ImVec2(1,1), -1, imgui.ImVec4(1,1,1,0), imgui.ImVec4(1,1,1,1)) then
                vzaim_new.v = false
            end
        imgui.End()
        imgui.PopStyleColor(4)
    end
    if vzaimod.v then
        imgui.Value()
        imgui.SetNextWindowSize(imgui.ImVec2(1000, 560), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2(ScreenX / 2, ScreenY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8"Army Tools | Главное меню",vzaimod,imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.MenuBar)
        imgui.BeginMenuBar()
            imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 8)
            if imgui.MenuItem(u8'Основное', show == 1) then
                show = 1
            end
            imgui.PopStyleVar()
            imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 8)
            if imgui.MenuItem(u8'КПК', show == 3) then
                show = 3
            end
            imgui.PopStyleVar()
            imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 8)
            if imgui.MenuItem(u8'Биндеры', show == 4) then
                show = 4
            end
            imgui.PopStyleVar()
            imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 8)
            if imgui.MenuItem(u8'Настройки', show == 6) then
                show = 6
            end
            imgui.PopStyleVar()
        imgui.EndMenuBar()
        imgui.BeginChild('##set1', imgui.ImVec2(180, 500), true)
            if show == 1 or show == 8 or show == 9 or show == 10 then
                if imgui.Button(u8"Главное меню",imgui.ImVec2(167, 30)) then
                    show = 1
                end
                if imgui.Button(u8"Другие счетчики",imgui.ImVec2(167, 30)) then
                    show = 9
                end
                if imgui.Button(u8"Доступные команды",imgui.ImVec2(167, 30)) then
                    show = 10
                end
                if imgui.Button(u8"Информация",imgui.ImVec2(167, 30)) then
                    show = 8
                end
            end
            if show == 2 or show == 11 or show == 17 or show == 18 or show == 19 or show == 5 or show == 3 or show == 501 or show == 502 or show == 503 or show == 504 or show == 505 or show == 506 or show == 507 then
                if imgui.Button(u8"Действия с игроком",imgui.ImVec2(167, 30)) then
                    show = 3
                end
                if imgui.Button(u8"Занять гос.волну",imgui.ImVec2(167, 30)) then
                    show = 2
                end
                if imgui.Button(u8"Логирование",imgui.ImVec2(167, 30)) then
                    show = 11
                end
                if imgui.Button(u8"Шпаргалка",imgui.ImVec2(167, 30)) then
                    show = 5
                end  
            end
            if show == 4 or show == 12 then
                if imgui.Button(u8"Обычный биндер",imgui.ImVec2(167, 30)) then
                    show = 4
                end
                if imgui.Button(u8"Командный биндер",imgui.ImVec2(167, 30)) then
                    show = 12
                end
            end
            
            if show == 6 or show == 13 or show == 14 or show == 15 or show == 16 then
                if imgui.Button(u8"Основные настройки",imgui.ImVec2(167, 30)) then
                    show = 6
                end
                if imgui.Button(u8"Доп-бары",imgui.ImVec2(167, 30)) then
                    show = 13
                end
                if imgui.Button(u8"Авто-БП",imgui.ImVec2(167, 30)) then
                    show = 14
                end
                if imgui.Button(u8"РП отыгровки оружия",imgui.ImVec2(167, 30)) then
                    show = 15
                end
                if imgui.Button(u8"Настройка клавиш",imgui.ImVec2(167, 30)) then
                    show = 16
                end
                if imgui.Button(u8"Перезагрузить скрипт",imgui.ImVec2(167, 30)) then
                    sampAddChatMessage(scriptname..'| {FFFFFF}Идёт перезагрузка скрипта.',0x7CFC00)
                    showCursor(false, false)
                    thisScript():reload()
                end
                if imgui.Button(u8"Отключить скрипт",imgui.ImVec2(167, 30)) then
                    sampAddChatMessage(scriptname..'| {FFFFFF}Скрипт отключён.',0x7CFC00)
                    showCursor(false, false)
                    thisScript():unload()
                end
            end
        imgui.EndChild()
        imgui.SameLine()
        imgui.BeginChild('##set2', imgui.ImVec2(800, 500), true)
        if show == 1 then
            local mynick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
            local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
            local myskin = getCharModel(PLAYER_PED)
            local mylvl = sampGetPlayerScore(myid)
            local font = renderCreateFont("Arial", 15, 5)
            checkstat = true
            imgui.Text(u8'')
            imgui.Text(u8'')
            imgui.Text(u8'')
            imgui.PushFont(fontsize)
            imgui.CentrText(u8'Личная информация:')
            imgui.Text(u8'')
            imgui.PopFont()
            imgui.Text(u8'')
            imgui.Separator()
            imgui.Text(u8'')
            imgui.Text(u8'')
            imgui.Text(u8'')
            imgui.CentrText((u8'%s [%s]'):format(mynick, myid));
            if workday == true then
                imgui.CenterTextColoredRGB("{FFFFFF}Рабочий день: {80ff80}Начат")
            else
                imgui.CenterTextColoredRGB("{FFFFFF}Рабочий день: {ff0000}Выходной")
            end
            local ip = sampGetCurrentServerAddress()
            if ip ~= "185.169.134.67" and ip ~= "185.169.134.68" and ip ~= "185.169.134.91" then
            else
                imgui.CentrText((u8'Уровень: %s'):format(mylvl))
                if frak == "LVA" or frak == "SFA" then
                    if frak == "LVA" then
                        imgui.CentrText(u8'Фракция: Army LV')
                    end
                    if frak == "SFA" then
                        imgui.CentrText(u8'Фракция: Army SF')
                    end
                else
                    imgui.CentrText((u8'Фракция: %s'):format(u8(frak)))
                end
                if frak == "LVA" or frak == "SFA" then
                    imgui.CentrText((u8'Звание: %s'):format(u8(rang)))
                else
                    imgui.CentrText((u8'Должность: %s'):format(u8(rang)))
                end
            end
            imgui.Text(u8'')
            imgui.Text(u8'')
            imgui.Text(u8'')
            imgui.Separator()
            imgui.Text(u8'')
            imgui.Text(u8'')
            imgui.Text(u8'')
            imgui.CenterTextColoredRGB('Онлайн за сессию: '.. get_clock(sesOnline.v))
            imgui.CenterTextColoredRGB('Онлайн за день: '.. get_clock(online.onDay.full))
            imgui.CenterTextColoredRGB('АФК за день: '.. get_clock(online.onDay.afk))
        end
        if show == 2 then
            if frak == "LVA" then
                imgui.PushItemWidth(70)
                imgui.Combo(u8'Время начала призыва', cTable.time_combo, "14:25\0".."16:25\0".."19:25\0".."21:25\0\0")
                imgui.SameLine()
                imgui.PushItemWidth(140)
                imgui.Combo(u8'Выберите место проведения призыва', cTable.place_combo , u8"Больница ЛС\0Больница ЛВ\0\0")
                imgui.BeginChild('##csc_example', imgui.ImVec2(780, 110))
                imgui.PushItemWidth(400)
                imgui.SetCursorPos(imgui.ImVec2(5, 5))
                imgui.Combo(u8'##combo_example', cTable.current_combo, u8"Предупреждение\0Начало\0Продолжение\0Конец\0Контракт\0Срочка\0Академия\0\0")
                if cTable.current_combo.v == 0 then
                    imgui.Text((u8" /gov [Army LV]: Уважаемые жители и гости штата San Andreas.\n /gov [Army LV]: Сегодня в "..cTable.time_value[cTable.time_combo.v + 1]..u8", в больнице %s, состоится призыв в Las Venturas Army.\n /gov [Army LV]: Требования: иметь прописку в штате от двух лет, не иметь проблем с законом.\n /gov [Army LV]: С уважением, Командование Вооружённых Сил г. Las Venturas."):format(cTable.place_combo.v == 0 and u8'Лос-Сантоса' or cTable.place_combo.v == 1 and u8'Лас-Вентураса'))
                end
                if cTable.current_combo.v == 1 then
                    imgui.Text((u8" /gov [Army LV]: Уважаемые жители и гости штата San Andreas.\n /gov [Army LV]: Призыв в Las Venturas Army объявляется открытым.\n /gov [Army LV]: Требования: иметь прописку в штате от двух лет, не иметь проблем с законом.\n /gov [Army LV]: Призыв проходит в больнице %s, на втором этаже.\n /gov [Army LV]: С уважением, Командование Вооружённых Сил г. Las Venturas."):format(cTable.place_combo.v == 0 and u8'Лос-Сантоса' or cTable.place_combo.v == 1 and u8'Лас-Вентураса'))
                end
                if cTable.current_combo.v == 2 then
                    imgui.Text((u8" /gov [Army LV]: Уважаемые жители и гости штата San Andreas.\n /gov [Army LV]: В данный момент проходит призыв в Las Venturas Army.\n /gov [Army LV]: Требования: иметь прописку в штате от двух лет, не иметь проблем с законом.\n /gov [Army LV]: Призыв проходит в больнице %s, на втором этаже.\n /gov [Army LV]: С уважением, Командование Вооружённых Сил г. Las Venturas."):format(cTable.place_combo.v == 0 and u8'Лос-Сантоса' or cTable.place_combo.v == 1 and u8'Лас-Вентураса'))
                end
                if cTable.current_combo.v == 3 then
                    imgui.Text(u8" /gov [Army LV]: Уважаемые жители и гости штата San Andreas.\n /gov [Army LV]: Призыв в Las Venturas Army объявляется закрытым.\n /gov [Army LV]: Так же в нашей армии открыт набор желающих на контрактную службу с выплатой денежных средств.\n /gov [Army LV]: Вся информация находится на официальном портале Army Las Venturas.\n /gov [Army LV]: С уважением, Командование Вооружённых Сил г. Las Venturas.")
                end
                if cTable.current_combo.v == 4 then
                    imgui.Text(u8" /gov [Army LV]: Уважаемые жители и гости штата San Andreas.\n /gov [Army LV]: В нашей армии открыт набор желающих на контрактную службу.\n /gov [Army LV]: За прохождение контракта вы можете получить от 200.000 до 600.000 вирт.\n /gov [Army LV]: Подробнее на оф.портале Army Las Venturas. С уважением, Командование Army Las Venturas")
                end
                if cTable.current_combo.v == 5 then
                    imgui.Text(u8" /gov [Army LV]: Уважаемые жители и гости штата San Andreas.\n /gov [Army LV]: В нашей армии доступна срочная военная служба вне призыва с вознаграждением.\n /gov [Army LV]: Требования: иметь прописку в штате от двух лет, не иметь проблем с законом.\n /gov [Army LV]: Вся информация находится на официальном портале Army Las Venturas\n /gov [Army LV]: С уважением, Командование Вооружённых Сил г. Las Venturas.")
                end
                if cTable.current_combo.v == 6 then
                    imgui.Text(u8" /gov [Army LV]: Уважаемые жители и гости штата San Andreas.\n /gov [Army LV]: В нашей армии открылись заявления в Военную академию Генерального Штаба.\n /gov [Army LV]: Требования: иметь прописку в штате от трех лет, не иметь проблем с законом.\n /gov [Army LV]: По окончанию обучения выплачивается 1.000.000 вирт и присваивается звание Мл.Лейтенант.\n /gov [Army LV]: Вся информация находится на официальном портале нашего Штата и Las Venturas Army.")
                end
                imgui.EndChild()
                if imgui.Button(u8"О предупреждении", imgui.ImVec2(125, 20))  then
                    lua_thread.create(function()
                        if cTable.dep.v == 0 then 
                            sampSendChat('/d OG, вещаю.')
                            wait(3000)
                        end
                        sampSendChat('/gov [Army LV]: Уважаемые жители и гости штата San Andreas.')
                        wait(5000)
                        sampSendChat(('/gov [Army LV]: Сегодня в '..cTable.time_value[cTable.time_combo.v + 1]..', в больнице %s, состоится призыв в Las Venturas Army.'):format(cTable.place_combo.v == 0 and 'Лос-Сантоса' or cTable.place_combo.v == 1 and 'Лас-Вентураса'))
                        wait(5000)
                        sampSendChat('/gov [Army LV]: Требования: иметь прописку в штате от двух лет, не иметь проблем с законом.')
                        wait(5000)
                        sampSendChat('/gov [Army LV]: С уважением, Командование Вооружённых Сил г. Las Venturas.')
                        if cTable.dep.v == 0 then
                            wait(3000)
                            sampSendChat('/d OG, закончил вещание.')
                        end
                    end)
                end
                imgui.SameLine()
                if imgui.Button(u8"О начале", imgui.ImVec2(70, 20))  then
                    lua_thread.create(function()
                        if cTable.dep.v == 0 then 
                            sampSendChat('/d OG, вещаю.')
                            wait(3000)
                        end
                        sampSendChat('/gov [Army LV]: Уважаемые жители и гости штата San Andreas.')
                        wait(5000)
                        sampSendChat('/gov [Army LV]: Призыв в Las Venturas Army объявляется открытым.')
                        wait(5000)
                        sampSendChat('/gov [Army LV]: Требования: иметь прописку в штате от двух лет, не иметь проблем с законом.')
                        wait(5000)
                        sampSendChat(('/gov [Army LV]: Призыв проходит в больнице %s, на втором этаже.'):format(cTable.place_combo.v == 0 and 'Лос-Сантоса' or cTable.place_combo.v == 1 and 'Лас-Вентураса'))
                        wait(5000)
                        sampSendChat('/gov [Army LV]: С уважением, Командование Вооружённых Сил г. Las Venturas.')
                        if cTable.dep.v == 0 then
                            wait(3000)
                            sampSendChat('/d OG, закончил вещание.')
                        end
                    end)
                end
                imgui.SameLine()
                if imgui.Button(u8"О продолжении", imgui.ImVec2(100, 20))  then
                    lua_thread.create(function()
                        if cTable.dep.v == 0 then 
                            sampSendChat('/d OG, вещаю.')
                            wait(3000)
                        end
                        sampSendChat('/gov [Army LV]: Уважаемые жители и гости штата San Andreas.')
                        wait(5000)
                        sampSendChat('/gov [Army LV]: В данный момент проходит призыв в Las Venturas Army.')
                        wait(5000)
                        sampSendChat('/gov [Army LV]: Требования: иметь прописку в штате от двух лет, не иметь проблем с законом.')
                        wait(5000)
                        sampSendChat(('/gov [Army LV]: Призыв проходит в больнице %s, на втором этаже.'):format(cTable.place_combo.v == 0 and 'Лос-Сантоса' or cTable.place_combo.v == 1 and 'Лас-Вентураса'))
                        wait(5000)
                        sampSendChat('/gov [Army LV]: С уважением, Командование Вооружённых Сил г. Las Venturas.')
                        if cTable.dep.v == 0 then
                            wait(3000)
                            sampSendChat('/d OG, закончил вещание.')
                        end
                    end)
                end
                imgui.SameLine()
                if imgui.Button(u8"О конце", imgui.ImVec2(70, 20))  then
                    lua_thread.create(function()
                        if cTable.dep.v == 0 then 
                            sampSendChat('/d OG, вещаю.')
                            wait(3000)
                        end
                        sampSendChat('/gov [Army LV]: Уважаемые жители и гости штата San Andreas.')
                        wait(5000)
                        sampSendChat('/gov [Army LV]: Призыв в Las Venturas Army объяляется закрытым.')
                        wait(5000)
                        sampSendChat('/gov [Army LV]: Так же в нашей армии открыт набор желающих на контрактную службу с выплатой денежных средств.')
                        wait(5000)
                        sampSendChat('/gov [Army LV]: Вся информация находится на официальном портале Army Las Venturas.')
                        wait(5000)
                        sampSendChat('/gov [Army LV]: С уважением, Командование Вооружённых Сил г. Las Venturas.')
                        if cTable.dep.v == 0 then
                            wait(3000)
                            sampSendChat('/d OG, закончил вещание.')
                        end
                    end)
                end
                imgui.SameLine()
                if imgui.Button(u8"О контракте", imgui.ImVec2(90, 20))  then
                    lua_thread.create(function()
                        if cTable.dep.v == 0 then 
                            sampSendChat('/d OG, вещаю.') 
                            wait(3000)
                        end
                        sampSendChat('/gov [Army LV]: Уважаемые жители и гости штата San Andreas.')
                        wait(5000)
                        sampSendChat('/gov [Army LV]: В нашей армии открыт набор желающих на контрактную службу.')
                        wait(5000)
                        sampSendChat('/gov [Army LV]: За прохождение контракта вы можете получить от 200.000 до 600.000 вирт.')
                        wait(5000)
                        sampSendChat('/gov [Army LV]: Подробнее на оф.портале Army Las Venturas. С уважением, Командование Army Las Venturas')
                        if cTable.dep.v == 0 then
                            wait(3000)
                            sampSendChat('/d OG, закончил вещание.')
                        end
                    end)
                end
                imgui.SameLine()
                if imgui.Button(u8"Срочка", imgui.ImVec2(60, 20))  then
                    lua_thread.create(function()
                        if cTable.dep.v == 0 then 
                            sampSendChat('/d OG, вещаю.')
                            wait(3000)
                        end
                        sampSendChat('/gov [Army LV]: Уважаемые жители и гости штата San Andreas.')
                        wait(5000)
                        sampSendChat('/gov [Army LV]: В нашей армии доступна срочная военная служба вне призыва с вознаграждением.')
                        wait(5000)
                        sampSendChat('/gov [Army LV]: Требования: иметь прописку в штате от двух лет, не иметь проблем с законом.')
                        wait(5000)
                        sampSendChat('/gov [Army LV]: Вся информация находится на официальном портале Army Las Venturas.')
                        wait(5000)
                        sampSendChat('/gov [Army LV]: С уважением, Командование Вооружённых Сил г. Las Venturas.')
                        if cTable.dep.v == 0 then
                            wait(3000)
                            sampSendChat('/d OG, закончил вещание.')
                        end
                    end)
                end
                imgui.SameLine()
                if imgui.Button(u8"О Академии", imgui.ImVec2(80, 20))  then
                    lua_thread.create(function()
                        if cTable.dep.v == 0 then 
                            sampSendChat('/d OG, вещаю.')
                            wait(3000)
                        end
                        sampSendChat('/gov [Army LV]: Уважаемые жители и гости штата San Andreas.')
                        wait(5000)
                        sampSendChat('/gov [Army LV]: В нашей армии открылись заявления в Военную академию Генерального Штаба.')
                        wait(5000)
                        sampSendChat('/gov [Army LV]: Требования: иметь прописку в штате от трех лет, не иметь проблем с законом.')
                        wait(5000)
                        sampSendChat('/gov [Army LV]: По окончанию обучения выплачивается 1.000.000 вирт и присваивается звание Мл.Лейтенант.')
                        wait(5000)
                        sampSendChat('/gov [Army LV]: Вся информация находится на официальном портале нашего Штата и Las Venturas Army.')
                        if cTable.dep.v == 0 then
                            wait(3000)
                            sampSendChat('/d OG, закончил вещание.')
                        end
                    end)
                end
                imgui.PushItemWidth(50)
                imgui.Combo(u8'Вещать в /d?', cTable.dep, u8"Да\0Нет\0\0")
                imgui.Text((u8 'Время: %s\t'):format(os.date('%H:%M:%S')))
                imgui.SameLine()
            end
            if frak == "SFA" then
                imgui.PushItemWidth(70)
                imgui.Combo(u8'Время начала призыва', sfaTable.time_combo, "15:25\0".."17:25\0".."20:25\0".."22:25\0\0")
                imgui.SameLine()
                imgui.PushItemWidth(140)
                imgui.Combo(u8'Выберите место проведения призыва', sfaTable.place_combo , u8"Больница ЛС\0Больница ЛВ\0\0")
                imgui.BeginChild('##csc_example', imgui.ImVec2(780, 110))
                imgui.PushItemWidth(400)
                imgui.SetCursorPos(imgui.ImVec2(5, 5))
                imgui.Combo(u8'##combo_example', sfaTable.current_combo, u8"Предупреждение\0Начало\0Продолжение\0Конец\0Контракт\0Срочка\0\0")
                if sfaTable.current_combo.v == 0 then
                    imgui.Text((u8" /gov [Army SF]: Уважаемые жители и гости штата San Andreas.\n /gov [Army SF]: Сегодня в "..sfaTable.time_value[sfaTable.time_combo.v + 1]..u8", в больнице %s, состоится призыв в San Fierro Army.\n /gov [Army SF]: Требования: иметь прописку в штате от двух лет, не иметь проблем с законом.\n /gov [Army SF]: С уважением, Командование Вооружённых Сил г. San Fierro."):format(sfaTable.place_combo.v == 0 and u8'Лос-Сантоса' or sfaTable.place_combo.v == 1 and u8'Лас-Вентураса'))
                end
                if sfaTable.current_combo.v == 1 then
                    imgui.Text((u8" /gov [Army SF]: Уважаемые жители и гости штата San Andreas.\n /gov [Army SF]: Призыв в San Fierro Army объявляется открытым.\n /gov [Army SF]: Требования: иметь прописку в штате от двух лет, не иметь проблем с законом.\n /gov [Army SF]: Призыв проходит в больнице %s, на втором этаже.\n /gov [Army SF]: С уважением, Командование Вооружённых Сил г. San Fierro."):format(sfaTable.place_combo.v == 0 and u8'Лос-Сантоса' or sfaTable.place_combo.v == 1 and u8'Лас-Вентураса'))
                end
                if sfaTable.current_combo.v == 2 then
                    imgui.Text((u8" /gov [Army SF]: Уважаемые жители и гости штата San Andreas.\n /gov [Army SF]: В данный момент проходит призыв в San Fierro Army.\n /gov [Army SF]: Требования: иметь прописку в штате от двух лет, не иметь проблем с законом.\n /gov [Army SF]: Призыв проходит в больнице %s, на втором этаже.\n /gov [Army SF]: С уважением, Командование Вооружённых Сил г. San Fierro."):format(sfaTable.place_combo.v == 0 and u8'Лос-Сантоса' or sfaTable.place_combo.v == 1 and u8'Лас-Вентураса'))
                end
                if sfaTable.current_combo.v == 3 then
                    imgui.Text(u8" /gov [Army SF]: Уважаемые жители и гости штата San Andreas.\n /gov [Army SF]: Призыв в San Fierro Army объявляется закрытым.\n /gov [Army SF]: Так же в нашей армии открыт набор желающих на контрактную службу с выплатой денежных средств.\n /gov [Army SF]: Вся информация находится на официальном портале Army San Fierro.\n /gov [Army SF]: С уважением, Командование Вооружённых Сил г. San Fierro.")
                end
                if sfaTable.current_combo.v == 4 then
                    imgui.Text(u8" /gov [Army SF]: Уважаемые жители и гости штата San Andreas.\n /gov [Army SF]: В нашей армии открыт набор желающих на контрактную службу.\n /gov [Army SF]: За прохождение контракта вы можете получить от 100.000 до 300.000 вирт.\n /gov [Army SF]: Подробнее на оф.портале Army San Fierro. С уважением, Командование Army San Fierro")
                end
                if sfaTable.current_combo.v == 5 then
                    imgui.Text(u8" /gov [Army SF]: Уважаемые жители и гости штата San Andreas.\n /gov [Army SF]: В нашей армии доступна срочная военная служба вне призыва с вознаграждением.\n /gov [Army SF]: Требования: иметь прописку в штате от двух лет, не иметь проблем с законом.\n /gov [Army SF]: Вся информация находится на официальном портале Army San Fierro\n /gov [Army SF]: С уважением, Командование Вооружённых Сил г. San Fierro.")
                end
                imgui.EndChild()
                if imgui.Button(u8"О предупреждении", imgui.ImVec2(125, 20))  then
                    lua_thread.create(function()
                        if sfaTable.dep.v == 0 then 
                            sampSendChat('/d OG, занимаю волну вещания.')
                            wait(3000)
                        end
                        sampSendChat('/gov [Army SF]: Уважаемые жители и гости штата San Andreas.')
                        wait(5000)
                        sampSendChat(('/gov [Army SF]: Сегодня в '..sfaTable.time_value[sfaTable.time_combo.v + 1]..', в больнице %s, состоится призыв в San Fierro Army.'):format(sfaTable.place_combo.v == 0 and 'Лос-Сантоса' or sfaTable.place_combo.v == 1 and 'Лас-Вентураса'))
                        wait(5000)
                        sampSendChat('/gov [Army SF]: Требования: иметь прописку в штате от двух лет, не иметь проблем с законом.')
                        wait(5000)
                        sampSendChat('/gov [Army SF]: С уважением, Командование Вооружённых Сил г. San Fierro.')
                        if sfaTable.dep.v == 0 then
                            wait(3000)
                            sampSendChat('/d OG, освобождаю волну вещания.')
                        end
                    end)
                end
                imgui.SameLine()
                if imgui.Button(u8"О начале", imgui.ImVec2(70, 20))  then
                    lua_thread.create(function()
                        if sfaTable.dep.v == 0 then 
                            sampSendChat('/d OG, занимаю волну вещания.')
                            wait(3000)
                        end
                        sampSendChat('/gov [Army SF]: Уважаемые жители и гости штата San Andreas.')
                        wait(5000)
                        sampSendChat('/gov [Army SF]: Призыв в San Fierro Army объявляется открытым.')
                        wait(5000)
                        sampSendChat('/gov [Army SF]: Требования: иметь прописку в штате от двух лет, не иметь проблем с законом.')
                        wait(5000)
                        sampSendChat(('/gov [Army SF]: Призыв проходит в больнице %s, на втором этаже.'):format(sfaTable.place_combo.v == 0 and 'Лос-Сантоса' or sfaTable.place_combo.v == 1 and 'Лас-Вентураса'))
                        wait(5000)
                        sampSendChat('/gov [Army SF]: С уважением, Командование Вооружённых Сил г. San Fierro.')
                        if sfaTable.dep.v == 0 then
                            wait(3000)
                            sampSendChat('/d OG, освобождаю волну вещания.')
                        end
                    end)
                end
                imgui.SameLine()
                if imgui.Button(u8"О продолжении", imgui.ImVec2(100, 20))  then
                    lua_thread.create(function()
                        if sfaTable.dep.v == 0 then 
                            sampSendChat('/d OG, занимаю волну вещания.')
                            wait(3000)
                        end
                        sampSendChat('/gov [Army SF]: Уважаемые жители и гости штата San Andreas.')
                        wait(5000)
                        sampSendChat('/gov [Army SF]: В данный момент проходит призыв в San Fierro Army.')
                        wait(5000)
                        sampSendChat('/gov [Army SF]: Требования: иметь прописку в штате от двух лет, не иметь проблем с законом.')
                        wait(5000)
                        sampSendChat(('/gov [Army SF]: Призыв проходит в больнице %s, на втором этаже.'):format(sfaTable.place_combo.v == 0 and 'Лос-Сантоса' or sfaTable.place_combo.v == 1 and 'Лас-Вентураса'))
                        wait(5000)
                        sampSendChat('/gov [Army SF]: С уважением, Командование Вооружённых Сил г. San Fierro.')
                        if sfaTable.dep.v == 0 then
                            wait(3000)
                            sampSendChat('/d OG, освобождаю волну вещания.')
                        end
                    end)
                end
                imgui.SameLine()
                if imgui.Button(u8"О конце", imgui.ImVec2(70, 20))  then
                    lua_thread.create(function()
                        if sfaTable.dep.v == 0 then 
                            sampSendChat('/d OG, занимаю волну вещания.')
                            wait(3000)
                        end
                        sampSendChat('/gov [Army SF]: Уважаемые жители и гости штата San Andreas.')
                        wait(5000)
                        sampSendChat('/gov [Army SF]: Призыв в San Fierro Army объяляется закрытым.')
                        wait(5000)
                        sampSendChat('/gov [Army SF]: Так же в нашей армии открыт набор желающих на контрактную службу с выплатой денежных средств.')
                        wait(5000)
                        sampSendChat('/gov [Army SF]: Вся информация находится на официальном портале Army San Fierro.')
                        wait(5000)
                        sampSendChat('/gov [Army SF]: С уважением, Командование Вооружённых Сил г. San Fierro.')
                        if sfaTable.dep.v == 0 then
                            wait(3000)
                            sampSendChat('/d OG, освобождаю волну вещания.')
                        end
                    end)
                end
                imgui.SameLine()
                if imgui.Button(u8"О контракте", imgui.ImVec2(90, 20))  then
                    lua_thread.create(function()
                        if sfaTable.dep.v == 0 then 
                            sampSendChat('/d OG, занимаю волну вещания.')
                            wait(3000)
                        end
                        sampSendChat('/gov [Army SF]: Уважаемые жители и гости штата San Andreas.')
                        wait(5000)
                        sampSendChat('/gov [Army SF]: В нашей армии открыт набор желающих на контрактную службу с выплатой денежных средств до 500.000 вирт.')
                        wait(5000)
                        sampSendChat('/gov [Army SF]: Требования: иметь прописку в штате от трех лет, не иметь проблем с законом.')
                        wait(5000)
                        sampSendChat('/gov [Army SF]: Вся информация находится на официальном портале Army San Fierro.')
                        wait(5000)
                        sampSendChat('/gov [Army SF]: С уважением, Командование Вооружённых Сил г. San Fierro.')
                        if sfaTable.dep.v == 0 then
                            wait(3000)
                            sampSendChat('/d OG, освобождаю волну вещания.')
                        end
                    end)
                end
                imgui.SameLine()
                if imgui.Button(u8"Срочка", imgui.ImVec2(60, 20))  then
                    lua_thread.create(function()
                        if sfaTable.dep.v == 0 then 
                            sampSendChat('/d OG, занимаю волну вещания.')
                            wait(3000)
                        end
                        sampSendChat('/gov [Army SF]: Уважаемые жители и гости штата San Andreas.')
                        wait(5000)
                        sampSendChat('/gov [Army SF]: В нашей армии доступна срочная военная служба вне призыва с вознаграждением.')
                        wait(5000)
                        sampSendChat('/gov [Army SF]: Требования: иметь прописку в штате от двух лет, не иметь проблем с законом.')
                        wait(5000)
                        sampSendChat('/gov [Army SF]: Вся информация находится на официальном портале Army San Fierro.')
                        wait(5000)
                        sampSendChat('/gov [Army SF]: С уважением, Командование Вооружённых Сил г. San Fierro.')
                        if sfaTable.dep.v == 0 then
                            wait(3000)
                            sampSendChat('/d OG, освобождаю волну вещания.')
                        end
                    end)
                end
                imgui.PushItemWidth(50)
                imgui.Combo(u8'Вещать в /d?', sfaTable.dep, u8"Да\0Нет\0\0")
                imgui.Text((u8 'Время: %s'):format(os.date('%H:%M:%S')))
            end
        end
        if show == 3 then
            local mynick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
            local skinid = getCharModel(PLAYER_PED)
            imgui.Text(u8'Ваше имя: ' ..mynick) 
            imgui.PushItemWidth(40)
            imgui.InputText(u8 "Укажите ID нарушителя", nameNAR)
            imgui.PopItemWidth()
            if imgui.Button(u8'Запросить местоположение', imgui.ImVec2(200, 20)) then if nameNAR.v ~= ''  then sampSendChat("/r " .. config.main.tar .. " " .. sampGetPlayerNickname(tonumber(nameNAR.v)):gsub("_", " ") .. " ваше местоположение?") end end
            if imgui.Button(u8'Вызвать на плац', imgui.ImVec2(200, 20)) then if nameNAR.v ~= ''  then sampSendChat("/r " .. config.main.tar .. " " .. sampGetPlayerNickname(tonumber(nameNAR.v)):gsub("_", " ") .. " на плац.") end end
            
            imgui.Separator()
            imgui.Text('\n')
            -- imgui.BeginChild("##punish", imgui.ImVec2(300, 300), true, imgui.WindowFlags.NoScrollbar)
            imgui.PushItemWidth(120)
            imgui.Combo(u8'Выберите действие', pTable.punishment_combo , punishment)
            imgui.PopItemWidth()
            if nameNAR.v ~= "" and sampIsPlayerConnected(tonumber(nameNAR.v)) then imgui.Text(u8'Имя сотрудника: ' .. sampGetPlayerNickname(tonumber(nameNAR.v)):gsub("_", " ")) end
            if nameNAR.v == "" or sampIsPlayerConnected(tonumber(nameNAR.v)) == false then imgui.Text(u8'Имя сотрудника: Отсутствует') end
            if pTable.punishment_combo.v == 0 then end
            if pTable.punishment_combo.v == 1 then
                imgui.PushItemWidth(40) imgui.InputText(u8 "Кол-во кругов", pTable.krugi)  imgui.PopItemWidth()
                imgui.InputText(u8 "Причина", pTable.reason)
                imgui.PushItemWidth(150)
                if imgui.Button(u8'Выдать наказание', imgui.ImVec2(200, 20)) then
                    if nameNAR.v ~= "" and sampIsPlayerConnected(tonumber(nameNAR.v)) then
                        local krug = tonumber(pTable.krugi.v)
                        local kr = ''
                        if krug < 5 then kr = "круга"end
                        if krug == 1 then kr = "круг"end
                        if krug > 4 then kr = "кругов" end
                        sampSendChat('/r ' .. config.main.tar .. ' ' .. sampGetPlayerNickname(tonumber(nameNAR.v)):gsub("_", " ") .. ' получает наряд ' .. krug .. ' ' .. kr .. ' за ' .. u8:decode(pTable.reason.v))
                    end
                end
                imgui.PopItemWidth()
            end
            if pTable.punishment_combo.v == 2 then
                imgui.InputText(u8 "Причина", pTable.reason)
                imgui.PushItemWidth(200)
                if imgui.Button(u8'Выдать наказание', imgui.ImVec2(200, 20)) then
                    if nameNAR.v ~= "" and sampIsPlayerConnected(tonumber(nameNAR.v)) then
                        sampSendChat('/r ' .. config.main.tar .. ' ' .. sampGetPlayerNickname(tonumber(nameNAR.v)):gsub("_", " ") .. ' получает выговор за ' .. u8:decode(pTable.reason.v))
                    end
                end
                imgui.PopItemWidth()
            end
        end
        if show == 4 then
            local naprav = ""
            if getCharHeading(playerPed) >= 337.5 or getCharHeading(playerPed) <= 22.5 then naprav = u8"Северное" end
            if getCharHeading(playerPed) > 22.5 and getCharHeading(playerPed) <= 67.5 then naprav = u8"Северо-западное" end
            if getCharHeading(playerPed) > 67.5 and getCharHeading(playerPed) <= 112.5 then naprav = u8"Западное" end
            if getCharHeading(playerPed) > 112.5 and getCharHeading(playerPed) <= 157.5 then naprav = u8"Юго-западное" end
            if getCharHeading(playerPed) > 157.5 and getCharHeading(playerPed) <= 202.5 then naprav = u8"Южное" end
            if getCharHeading(playerPed) > 202.5 and getCharHeading(playerPed) <= 247.5 then naprav = u8"Юго-восточное" end
            if getCharHeading(playerPed) > 247.5 and getCharHeading(playerPed) <= 292.5 then naprav = u8"Восточное" end
            if getCharHeading(playerPed) > 292.5 and getCharHeading(playerPed) <= 337.5 then naprav = u8"Северо-восточное" end
            for k, v in ipairs(tBindList) do
                if imadd.HotKey("##HK" .. k, v, tLastKeys, 100) then
                    if not rkeys.isHotKeyDefined(v.v) then
                        if rkeys.isHotKeyDefined(tLastKeys.v) then
                            rkeys.unRegisterHotKey(tLastKeys.v)
                        end
                        rkeys.registerHotKey(v.v, true, onHotKey)
                    end
                    saveData(tBindList, fileb)
                end
                imgui.SameLine()
                imgui.CentrText(u8(v.name))
                imgui.SameLine(663)
                if imgui.Button(u8 'Редактировать бинд##'..k) then imgui.OpenPopup(u8 "Редактирование биндера##editbind"..k) 
                    bindname.v = u8(v.name) 
                    bindtext.v = u8(v.text)
                end
                if imgui.BeginPopupModal(u8 'Редактирование биндера##editbind'..k, _, imgui.WindowFlags.NoResize) then
                    imgui.Text(u8 "Введите название биндера:")
                    imgui.InputText("##Введите название биндера", bindname)
                    imgui.Text(u8 "Введите текст биндера:")
                    imgui.InputTextMultiline("##Введите текст биндера", bindtext, imgui.ImVec2(500, 200))
                    imgui.Separator()
                    if imgui.Button(u8 'Ключи', imgui.ImVec2(90, 20)) then imgui.OpenPopup('##bindkey') end
                    if imgui.BeginPopup('##bindkey') then
                        imgui.Text(u8 '{myid} - ID вашего персонажа | '..select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
                        imgui.Text(u8 '{myrpnick} - РП ник вашего персонажа | '..sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))):gsub('_', ' '))
                        imgui.Text(u8 '{targetid} - ID игрока на которого вы целитесь | '..targetid)
                        imgui.Text(u8 '{targetrpnick} - РП ник игрока на которого вы целитесь | '..sampGetPlayerNicknameForBinder(targetid):gsub('_', ' '))
                        imgui.Text(u8('{tag} - Ваш тэг | '..config.main.tar))
                        imgui.Text(u8 ('{kv} - Ваш текущий квадрат | '..kvadratb()))
                        imgui.Text(u8 '{rang} - Ваше звание | '..u8(rang))
                        imgui.Text(u8 '{time} - Текущее время | '..os.date('%H:%M:%S'))
                        imgui.Text(u8 '{data} - Текущяя дата | '..os.date('%d.%m.%Y'))
                        imgui.Text(u8 '{frak} - Ваша фракция | '..u8(frak))
                        imgui.Text(u8 '{naprav} - Направление | '..naprav)
                        imgui.Text(u8 '{dl} - ID авто, в котором вы сидите | '..mcid)
                        imgui.Text(u8 '{f6} - Отправить сообщение в чат через эмуляцию чата (использовать в самом начале)')
                        imgui.Text(u8 '{noe} - Оставить сообщение в полле ввода а не отправлять его в чат (использовать в самом начале)')
                        imgui.Text(u8 '{wait:sek} - Задержка между строками, где sek - кол-во миллисекунд. Пример: {wait:2000} - задержка 2 секунды. (использовать отдельно на новой строчке)')
                        imgui.Text(u8 '{screen} - Сделать скриншот экрана (использовать отдельно на новой строчке)')
                        imgui.EndPopup()
                    end
                    imgui.SameLine()
                    imgui.SetCursorPosX((imgui.GetWindowWidth() - 90 - imgui.GetStyle().ItemSpacing.x))
                    if imgui.Button(u8 "Удалить бинд##"..k, imgui.ImVec2(90, 20)) then
                        table.remove(tBindList, k)
                        saveData(tBindList, fileb)
                        imgui.CloseCurrentPopup()
                    end
                    imgui.SameLine()
                    imgui.SetCursorPosX((imgui.GetWindowWidth() - 180 + imgui.GetStyle().ItemSpacing.x) / 2)
                    if imgui.Button(u8 "Сохранить##"..k, imgui.ImVec2(90, 20)) then
                        v.name = u8:decode(bindname.v)
                        v.text = u8:decode(bindtext.v)
                        bindname.v = ''
                        bindtext.v = ''
                        saveData(tBindList, fileb)
                        imgui.CloseCurrentPopup()
                    end
                    imgui.SameLine()
                    if imgui.Button(u8 "Закрыть##"..k, imgui.ImVec2(90, 20)) then imgui.CloseCurrentPopup() end
                    imgui.EndPopup()
                end
            end
            imgui.Separator()
            if imgui.Button(u8"Добавить клавишу") then
                tBindList[#tBindList + 1] = {text = "", v = {}, time = 0, name = "Бинд №"..#tBindList + 1}
                saveData(tBindList, fileb)
            end
        end
        if show == 5 or show == 501 or show == 502 or show == 503 or show == 504 or show == 505 or show == 506 or show == 507 then
                if imgui.Button(u8"Федеральное постановление",imgui.ImVec2(200, 20)) then
                      show = 501
                end
                imgui.SameLine()
                if imgui.Button(u8"Уголовный кодекс",imgui.ImVec2(180, 20)) then
                    show = 502
                end
                imgui.SameLine()
                if imgui.Button(u8"Административный кодекс",imgui.ImVec2(200, 20)) then
                    show = 503
                end
                imgui.SameLine()
                if imgui.Button(u8"Устав армии",imgui.ImVec2(140, 20)) then
                    show = 504
                end
                if imgui.Button(u8"Шпаргалка №1",imgui.ImVec2(241, 20)) then
                    show = 505
                end
                imgui.SameLine()
                if imgui.Button(u8"Шпаргалка №2",imgui.ImVec2(242, 20)) then
                    show = 506
                end
                imgui.SameLine()
                if imgui.Button(u8"Шпаргалка №3",imgui.ImVec2(241, 20)) then
                    show = 507
                end
                imgui.BeginChild('##set3', imgui.ImVec2(740, 500), true)
                if show == 501 then
                    imgui.Text(u8'')
                    for line in io.lines('moonloader\\Army-Tools\\fp.txt') do
                        imgui.TextWrapped(u8(line))
                    end
                end
                if show == 502 then
                    imgui.Text(u8'')
                    for line in io.lines('moonloader\\Army-Tools\\yk.txt') do
                        imgui.TextWrapped(u8(line))
                    end
                end
                if show == 503 then
                    imgui.Text(u8'')
                    for line in io.lines('moonloader\\Army-Tools\\ak.txt') do
                        imgui.TextWrapped(u8(line))
                    end
                end
                if show == 504 then
                    imgui.Text(u8'')
                    for line in io.lines('moonloader\\Army-Tools\\army.txt') do
                        imgui.TextWrapped(u8(line))
                    end
                end
                if show == 505 then
                    imgui.Text(u8'')
                    for line in io.lines('moonloader\\Army-Tools\\shp1.txt') do
                        imgui.TextWrapped(u8(line))
                    end
                end
                if show == 506 then
                    imgui.Text(u8'')
                    for line in io.lines('moonloader\\Army-Tools\\shp2.txt') do
                        imgui.TextWrapped(u8(line))
                    end
                end
                if show == 507 then
                    imgui.Text(u8'')
                    for line in io.lines('moonloader\\Army-Tools\\shp3.txt') do
                        imgui.TextWrapped(u8(line))
                    end
                end
                imgui.EndChild()
            end
        if show == 6 then
            local result, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
            if imadd.ToggleButton(u8'Использовать автотег', tagb) then
                config.main.tarb = tagb.v 
                saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json')
            end 
            imgui.SameLine()
            imgui.Text(u8 'Авто-тэг')
            imgui.PushItemWidth(150)
            if tagb.v then
                if imgui.InputText(u8'Введите тэг', tagf) then
                    config.main.tar = u8:decode(tagf.v) 
                    saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json')
                end
            end
            if imadd.ToggleButton(u8'Использовать авто-логин', parolb) then
                config.main.parolb = parolb.v
                saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json')
            end
            imgui.SameLine()
            imgui.Text(u8 'Авто-логин')
            if parolb.v then
                if imgui.InputText(u8'Введите ваш пароль.', parolf, imgui.InputTextFlags.Password) then
                    config.main.parol = u8:decode(parolf.v)
                    saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json')
                end
            end
            if imadd.ToggleButton(u8'Использовать автоклист', clistb) then config.main.clistb = clistb.v end; imgui.SameLine() saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json'); imgui.Text(u8 'Авто-клист')
            if clistb.v then
                if imgui.SliderInt(u8"Выберите значение клиста", clistbuffer, 0, 33) then config.main.clist = clistbuffer.v saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json') end
            end
            imgui.PopItemWidth()
            imgui.Separator()
            imgui.Text(u8 'Удостоверение')
            imgui.PushItemWidth(150)
            if imgui.InputText(u8'Введите название взвода', vzvodf) then
                config.udost.vzvod = u8:decode(vzvodf.v) 
                saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json')
            end
            if imgui.InputText(u8'Введите занимаемую должность', dolznf) then config.udost.dolzn = u8:decode(dolznf.v)  saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json') end
            imgui.PopItemWidth()
            imgui.Separator()
            imgui.Text(u8'Дополнительные функции:')
            if imadd.ToggleButton(u8'##male', maleb) then config.main.male = maleb.v end; imgui.SameLine() saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json'); imgui.Text(u8 'Мужские отыгровки')
            if imadd.ToggleButton(u8'##radio', radiob) then config.main.radio = radiob.v end; imgui.SameLine() saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json'); imgui.Text(u8 'Отключить радио в авто')
            if radiob.v then
                memory.copy(0x4EB9A0, memory.strptr('\xC2\x04\x00'), 3, true)
            end
            if imadd.ToggleButton(u8'##carl', carlb) then config.main.carl = carlb.v end; imgui.SameLine() saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json'); imgui.Text(u8 'Открытие авто на L')
            if imadd.ToggleButton(u8'Открывать чат на T', chatb) then config.main.chat = chatb.v end; imgui.SameLine() saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json'); imgui.Text(u8 'Открывать чат на T')
            if imadd.ToggleButton(u8'##carb', carb) then config.main.car = carb.v end; imgui.SameLine() saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json'); imgui.Text(u8 'Автоматически заводить двигатель')
            if imadd.ToggleButton(u8'##colorradio', colorradiob) then config.main.colorradio = colorradiob.v end; imgui.SameLine() saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json'); imgui.Text(u8 'Цветные сообщения в рацию')
            if imadd.ToggleButton(u8'##warnings', warningsb) then config.main.warnings = warningsb.v end; imgui.SameLine() saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json'); imgui.Text(u8 'Варнинги на фуры, форму')
            if imadd.ToggleButton(u8'##sos', auto_SOSb) then config.main.auto_SOS = auto_SOSb.v end; imgui.SameLine() saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json'); imgui.Text(u8 'Авто-запрос SOS')
            if imgui.Button(u8'Сохранить и закрыть', imgui.ImVec2(-1, 20)) then
                saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json')
                lua_thread.create(function()
                    vzaimod.v = false
                end)
            end
        end
        if show == 8 then
            imgui.CentrText(u8'\n\n\n\n\n\nArmy Tools - это многофункциональный скрипт,')
            imgui.CentrText(u8'написанный на языке программирования Lua и работающий на базе "MoonLoader')
            imgui.CentrText(u8'целью данного скрипта является облегчение работы сотрудникам гос.структуры "Army"')
            imgui.CentrText(u8'Включает в себя полноценно работающий Авто-БП, отыгровки оружия и многие другие функции\n\n\n\n\n\n')
            imgui.SetCursorPosX(175)
            if imgui.Button(u8'Техническая поддержка') then
                os.execute('explorer "https://vk.com/im?media=&sel=-204867921"')
            end
            imgui.SameLine()
            if imgui.Button(u8'Официальная группа') then
                os.execute('explorer "https://vk.com/armytoolserp"')
            end
            imgui.SameLine()
            if imgui.Button(u8'Предложения по улучшению') then
                os.execute('explorer "https://vk.com/topic-204867921_47782649"')
            end
            imgui.CentrText(u8'\n\n\n\n\nРазработчики скрипта: James Awoken, Luis Barton')
            imgui.CentrText(u8'\nВерсия: ' .. script_vers_text)
        end
        if show == 9 then
            imgui.Text(u8'')
            imgui.Text(u8'')
            imgui.Text(u8'')
            imgui.CenterTextColoredRGB('Всего отыграно: '..get_clock(online.onWeek.full))
            imgui.Text(u8'')
            imgui.Text(u8'')
            imgui.Text(u8'')
            imgui.Separator()
            imgui.Text(u8'')
            imgui.Text(u8'')
            imgui.Text(u8'')
            imgui.Text(u8'')
            for day = 1, 6 do -- ПН -> СБ
                imgui.SetCursorPosX(330)
                imgui.Text(u8(tWeekdays[day])); imgui.SameLine()
                imgui.Text(get_clock(online.myWeekOnline[day]))
            end 
            imgui.SetCursorPosX(330)
            imgui.Text(u8(tWeekdays[0])); imgui.SameLine()
            imgui.Text(get_clock(online.myWeekOnline[0]))
            imgui.Text(u8'')
            imgui.Text(u8'')
            imgui.Text(u8'')
            imgui.Text(u8'')
            imgui.Separator()
            imgui.Text(u8'')
        end
        if show == 10 then
            imgui.Text(u8'Список доступных команд\n')
            imgui.Text(u8'/at — открыть меню скрипта.')
            imgui.Text(u8'/csc — открыть меню Государственной волны.')
            imgui.Text(u8'KLK — Зависание на вертолёте. [Не варнят, резко остановится не выйдет. Вводить как ЧИТ-код]')
            imgui.Text(u8'#id — Отправив в чат получите РП-ник игрока по ID: #1 -> Luis Barton')
            imgui.Text(u8'!id — Отправив в чат получите фамилию игрока по ID: !1 -> Barton')
            imgui.Text(u8'/cn — скопировать РП-ник игрока')
            imgui.Text(u8'/csn — скопировать фамилию игрока')
            imgui.Text(u8'/cc — очистить чат.')
            imgui.Text(u8'/dmb — посмотреть список сотрудников организации онлайн')
            imgui.Text(u8'/mon [1/2] - мониторинг складов')
            imgui.Text(u8'/imask — быстрая маска с отыгровкой [Аксессуар не должен быть надет иначе вы просто её снимете]')
            imgui.Text(u8'/fmask — быстрая маска без отыгровки и выключения клиста (clist 0) [Аксессуар не должен быть надет иначе вы просто её снимете]')
            imgui.Text(u8'/ast [time] — установить время')
            imgui.Text(u8'/asw [id погоды] — установить погоду')
            imgui.Text(u8'/sud — показать удостоверение')
            imgui.Text(u8'/setkv [Л-6] - установка маркера на определенный квадрат')
            imgui.Text(u8'/vig [id] - выдать выговор игроку')
            imgui.Text(u8'/nar [id] [круги] [причина] - выдать наряд игроку')
            imgui.Text(u8'/blag [id] [фракция] [причина] - выразить игроку благодарность')
            imgui.Text(u8'/plc [id] [минуты] - вызвать бойца на плац')
            imgui.Text(u8'/fnr [id] - вызвать бойца на работу')
            imgui.Text(u8'/cam - отыгровка камеры')
            imgui.Text(u8'/cl [id] - укороченная команда /clist')
            imgui.Text(u8'/loc [id] [секунды] - запросить местоположение')
            imgui.Text(u8'/aak - открыть Административный кодекс')
            imgui.Text(u8'/afp - открыть Федеральное постановление')
            imgui.Text(u8'/ayk - открыть Уголовный кодекс')
            imgui.Text(u8'/aarmy - открыть устав Армии') 
            imgui.Text(u8'/fak - поиск по Административному кодексу')
            imgui.Text(u8'/ffp - поиск по Федеральнопу постановлению')
            imgui.Text(u8'/fyk - поиск по Уголовному кодексу')
            imgui.Text(u8'/farmy - поиск по уставу Армии')        
        end
        if show == 11 then
            if imgui.Button(u8"Лог департамента",imgui.ImVec2(266, 20)) then
                show = 11
            end
            imgui.SameLine()
            if imgui.Button(u8"Лог рации",imgui.ImVec2(266, 20)) then
                show = 18
            end
            imgui.SameLine()
            if imgui.Button(u8"Лог SMS",imgui.ImVec2(266, 20)) then
                show = 19
            end
            imgui.Separator()
            imgui.CentrText(u8'Лог департамента:')
            imgui.CenterTextColoredRGB(u8('%s'):format(table.concat(departament, '\n')))
        end
        if show == 12 then
            local naprav = ""
            if getCharHeading(playerPed) >= 337.5 or getCharHeading(playerPed) <= 22.5 then naprav = u8"Северное" end
            if getCharHeading(playerPed) > 22.5 and getCharHeading(playerPed) <= 67.5 then naprav = u8"Северо-западное" end
            if getCharHeading(playerPed) > 67.5 and getCharHeading(playerPed) <= 112.5 then naprav = u8"Западное" end
            if getCharHeading(playerPed) > 112.5 and getCharHeading(playerPed) <= 157.5 then naprav = u8"Юго-западное" end
            if getCharHeading(playerPed) > 157.5 and getCharHeading(playerPed) <= 202.5 then naprav = u8"Южное" end
            if getCharHeading(playerPed) > 202.5 and getCharHeading(playerPed) <= 247.5 then naprav = u8"Юго-восточное" end
            if getCharHeading(playerPed) > 247.5 and getCharHeading(playerPed) <= 292.5 then naprav = u8"Восточное" end
            if getCharHeading(playerPed) > 292.5 and getCharHeading(playerPed) <= 337.5 then naprav = u8"Северо-восточное" end
            imgui.BeginChild("##commandlist", imgui.ImVec2(170 ,460), true)
            for k, v in pairs(commands) do
                if imgui.Selectable(u8(("%s. /%s##%s"):format(k, v.cmd, k)), vars.menuselect == k) then 
                    vars.menuselect     = k 
                    vars.cmdbuf.v       = u8(v.cmd) 
                    vars.cmdparams.v    = v.params
                    vars.cmdtext.v      = u8(v.text)
                    saveData(commands, "moonloader/config/Army-Tools/cmdbinder.json")
                end
            end
            imgui.EndChild()
            imgui.SameLine()
            imgui.BeginChild("##commandsetting", imgui.ImVec2(610, 460), true)
            for k, v in pairs(commands) do
                if vars.menuselect == k then
                    imgui.InputText(u8 "Введите саму команду", vars.cmdbuf)
                    imgui.InputInt(u8 "Введите кол-во пар-тров", vars.cmdparams, 0)
                    imgui.InputTextMultiline(u8 "##cmdtext", vars.cmdtext, imgui.ImVec2(678, 200))
                    imgui.TextWrapped(u8 "Ключи параметров: {param:1}, {param:2} и т.д (Использовать в тексте на месте параметра)\nКлюч задержки: {wait:кол-во миллисекунд} (Использовать на новой строке)")
                    if imgui.Button(u8 "Сохранить команду") then
                        sampUnregisterChatCommand(v.cmd)
                        v.cmd = u8:decode(vars.cmdbuf.v)
                        v.params = vars.cmdparams.v
                        v.text = u8:decode(vars.cmdtext.v)
                        saveData(commands, "moonloader/config/Army-Tools/cmdbinder.json")
                        registerCommandsBinder()
                        sampAddChatMessage(scriptname.. " | {FFFFFF}Команда сохранена", 0x7FFF00)
                    end
                    imgui.SameLine()
                    if imgui.Button(u8 "Удалить команду") then
                        imgui.OpenPopup(u8 "Удаление команды##"..k)
                    end
                    if imgui.BeginPopupModal(u8 "Удаление команды##"..k, _, imgui.WindowFlags.AlwaysAutoResize) then
                        imgui.SetCursorPosX(imgui.GetWindowWidth()/2 - imgui.CalcTextSize(u8 "Вы действительно хотите удалить команду?").x / 2)
                        imgui.Text(u8 "Вы действительно хотите удалить команду?")
                        if imgui.Button(u8 "Удалить##"..k, imgui.ImVec2(170, 20)) then
                            sampUnregisterChatCommand(v.cmd)
                            vars.menuselect     = 0
                            vars.cmdbuf.v       = ""
                            vars.cmdparams.v    = 0
                            vars.cmdtext.v      = ""
                            table.remove(commands, k)
                            saveData(commands, "moonloader/config/Army-Tools/cmdbinder.json")
                            registerCommandsBinder()
                            sampAddChatMessage(scriptname.. " | {FFFFFF}Команда удалена", 0x7FFF00)
                            imgui.CloseCurrentPopup()
                        end
                        imgui.SameLine()
                        if imgui.Button(u8 "Отмена##"..k, imgui.ImVec2(170, 20)) then
                            imgui.CloseCurrentPopup()
                        end
                        imgui.EndPopup()
                    end
                    imgui.SameLine()
                    local x,y,z = getCharCoordinates(PLAYER_PED)
                    if imgui.Button(u8 'Ключи', imgui.ImVec2(170, 20)) then imgui.OpenPopup('##bindkey') end
                    if imgui.BeginPopup('##bindkey') then
                        imgui.Text(u8 'Используйте ключи биндера для более удобного использования биндера')
                        imgui.Separator()
                        imgui.Text(u8 '{myid} - ID вашего персонажа | '..select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
                        imgui.Text(u8 '{myrpnick} - РП ник вашего персонажа | '..sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))):gsub('_', ' '))
                        imgui.Text(u8 '{targetid} - ID игрока на которого вы целитесь | '..targetid)
                        imgui.Text(u8 '{targetrpnick} - РП ник игрока на которого вы целитесь | '..sampGetPlayerNicknameForBinder(targetid):gsub('_', ' '))
                        imgui.Text(u8('{tag} - Ваш тэг | '..config.main.tar))
                        imgui.Text(u8 ('{kv} - Ваш текущий квадрат | '..kvadratb()))
                        imgui.Text(u8 '{rang} - Ваше звание | '..u8(rang))
                        imgui.Text(u8 '{time} - Текущее время | '..os.date('%H:%M:%S'))
                        imgui.Text(u8 '{data} - Текущяя дата | '..os.date('%d.%m.%Y'))
                        imgui.Text(u8 '{frak} - Ваша фракция | '..u8(frak))
                        imgui.Text(u8 '{naprav} - Направление | '..naprav)
                        imgui.Text(u8 '{location} - Локация | '..u8(calculateZone(x,y,z)))
                        imgui.Text(u8 '{dl} - ID авто, в котором вы сидите | '..mcid)
                        imgui.Text(u8 '{f6} - Отправить сообщение в чат через эмуляцию чата (использовать в самом начале)')
                        imgui.Text(u8 '{noe} - Оставить сообщение в полле ввода а не отправлять его в чат (использовать в самом начале)')
                        imgui.Text(u8 '{wait:sek} - Задержка между строками, где sek - кол-во миллисекунд. Пример: {wait:2000} - задержка 2 секунды. (использовать отдельно на новой строчке)')
                        imgui.Text(u8 '{screen} - Сделать скриншот экрана (использовать отдельно на новой строчке)')
                        imgui.EndPopup()
                    end
                end
            end
            imgui.EndChild()
            if imgui.Button(u8 "Добавить команду", imgui.ImVec2(170, 20)) then
                table.insert(commands, {cmd = "", params = 0, text = ""})
                saveData(commands, "moonloader/config/Army-Tools/cmdbinder.json")
            end
        end
        if show == 13 then
            if imadd.ToggleButton(u8'##infobar', infobarb) then
                config.main.infobar = infobarb.v
                saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json')
            end
            imgui.SameLine(); imgui.Text(u8'Использовать инфо-бар')
            if infobarb.v then
                imgui.Separator()
                imgui.Text(u8'Выберите элементы:')
                if imadd.ToggleButton(u8'##pinger', pingb) then
                    config.infobar.ping = pingb.v
                    saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json')
                end
                imgui.SameLine(); imgui.Text(u8'Пинг') imgui.SameLine(); 
                if imadd.ToggleButton(u8'##namebars', namebarb) then
                    config.infobar.namebar = namebarb.v
                    saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json')
                end
                imgui.SameLine(); imgui.Text(u8'Название скрипта')
                if imadd.ToggleButton(u8'##fps', FPSb) then
                    config.infobar.FPS = FPSb.v
                    saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json')
                end
                imgui.SameLine(); imgui.Text(u8'FPS') imgui.SameLine(); 
                if imadd.ToggleButton(u8'##health', healthb) then
                    config.infobar.health = healthb.v
                    saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json')
                end
                imgui.SameLine(); imgui.Text(u8'Здоровье')
                if imadd.ToggleButton(u8'##armour', armourb) then
                    config.infobar.armour = armourb.v
                    saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json')
                end
                imgui.SameLine(); imgui.Text(u8'Броня') imgui.SameLine();
                if imadd.ToggleButton(u8'##target', targetb) then
                    config.infobar.target = targetb.v
                    saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json')
                end
                imgui.SameLine(); imgui.Text(u8'Цель') imgui.SameLine();
                if imadd.ToggleButton(u8'##sektor', kvadrat) then
                    config.infobar.sektor = kvadrat.v
                    saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json')
                end
                imgui.SameLine(); imgui.Text(u8'Квадрат')
                if imadd.ToggleButton(u8'##location', locationb) then
                    config.infobar.location = locationb.v
                    saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json')
                end
                imgui.SameLine(); imgui.Text(u8'Улица') imgui.SameLine();
                if imadd.ToggleButton(u8'##direction', directionb) then
                    config.infobar.direction = directionb.v
                    saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json')
                end
                imgui.SameLine(); imgui.Text(u8'Направление') imgui.SameLine();
                if imadd.ToggleButton(u8'##time', timeb) then
                    config.infobar.time = timeb.v
                    saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json')
                end
                imgui.SameLine(); imgui.Text(u8'Время')
                if imgui.Button(u8 'Изменить местоположение') then
                    vzaimod.v = false
                    changetextpos = true
                end
                imgui.Separator()
                imgui.Text(u8'Внешний вид инфо-бара')
                if imgui.SliderFloat('##Round', sRound, 0.0, 10.0, u8"Скругление краёв: %.2f") then 
                    config.main.round = sRound.v 
                    saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json')
                end
                colorW = imgui.ImFloat4(imgui.ImColor(argbW):GetFloat4())
                if imgui.ColorEdit4(u8'Цвет фона', colorW, imgui.ColorEditFlags.NoInputs) then
                    argbW = imgui.ImColor.FromFloat4(colorW.v[1], colorW.v[2], colorW.v[3], colorW.v[4]):GetU32()
                    config.main.colorW = argbW
                    saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json')
                end
            end
            imgui.Separator()
            imgui.Text(u8'Внешний вид таргет-бара')
            if imgui.SliderFloat('##tRound', tRound, 0.0, 10.0, u8"Скругление краёв: %.2f") then 
                config.main.tround = tRound.v 
                saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json')
            end
            targetcolorW = imgui.ImFloat4(imgui.ImColor(targetargbW):GetFloat4())
            if imgui.ColorEdit4(u8'Цвет таргет-бара', targetcolorW, imgui.ColorEditFlags.NoInputs) then
                targetargbW = imgui.ImColor.FromFloat4(targetcolorW.v[1], targetcolorW.v[2], targetcolorW.v[3], targetcolorW.v[4]):GetU32()
                config.main.targetcolorW = targetargbW
                saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json')
            end
            
        end
        if show == 14 then
            local result, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
            if imadd.ToggleButton(u8'##autobpb', autobpb) then
                config.main.autobp = autobpb.v
                saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json')
            end
            imgui.SameLine(); imgui.Text(u8'Авто-БП')
            if autobpb.v then
                imgui.Separator()
                imgui.Text(u8'Выберите элементы:')
                if imadd.ToggleButton(u8'deagleb', deagleb) then
                    config.autobp.deagle = deagleb.v
                    saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json')
                end
                imgui.SameLine(); imgui.Text(u8'Desert Eagle')
                if imadd.ToggleButton(u8'shotb', shotb) then
                    config.autobp.shot = shotb.v
                    saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json')
                end
                imgui.SameLine(); imgui.Text(u8'Shotgun')
                if imadd.ToggleButton(u8'smgb', smgb) then
                    config.autobp.smg = smgb.v
                    saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json')
                end
                imgui.SameLine(); imgui.Text(u8'MP5')
                if imadd.ToggleButton(u8'm4', m4b) then
                    config.autobp.m4 = m4b.v
                    saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json')
                end
                imgui.SameLine(); imgui.Text(u8'M4')
                if imadd.ToggleButton(u8'rifleb', rifleb) then
                    config.autobp.rifle = rifleb.v
                    saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json')
                end
                imgui.SameLine(); imgui.Text(u8'Rifle')
                if imadd.ToggleButton(u8'armourb', armb) then
                    config.autobp.armour = armb.v
                    saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json')
                end
                imgui.SameLine(); imgui.Text(u8'Здоровье и бронежилет')
                if imadd.ToggleButton(u8'specb', specb) then
                    config.autobp.spec = specb.v
                    saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json')
                end
                imgui.SameLine(); imgui.Text(u8'Спец.оружие')
            end
        end
        if show == 15 then
            local result, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
            if imadd.ToggleButton(u8'РП отыгровка оружий', rpguns) then
                config.main.rpguns = rpguns.v
                saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json')
            end
            imgui.SameLine(); imgui.Text(u8'Отыгровка оружий')
            if config.main.rpguns then
                imgui.Separator()
                imgui.Text(u8'Выберите элементы:')
                if imadd.ToggleButton(u8'Desert Eagle', rpdeagle) then
                    config.rpguns.deagle = rpdeagle.v
                    saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json')
                end
                imgui.SameLine(); imgui.Text(u8'Desert Eagle')
                if imadd.ToggleButton(u8'Shotgun', rpshotgun) then
                    config.rpguns.shotgun = rpshotgun.v
                    saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json')
                end
                imgui.SameLine(); imgui.Text(u8'Shotgun')
                if imadd.ToggleButton(u8'MP5', rpmp5) then
                    config.rpguns.mp5 = rpmp5.v
                    saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json')
                end
                imgui.SameLine(); imgui.Text(u8'MP5')
                if imadd.ToggleButton(u8'M4', rpm4) then
                    config.rpguns.m4 = rpm4.v
                    saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json')
                end
                imgui.SameLine(); imgui.Text(u8'M4')
                if imadd.ToggleButton(u8'Rifle', rprifle) then
                    config.rpguns.rifle = rprifle.v
                    saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json')
                end
                imgui.SameLine(); imgui.Text(u8'Rifle')
            end
        end
        if show == 16 then
            if imadd.HotKey('##oopda', config_keys.oopda, tLastKeys, 100) then
                rkeys.changeHotKey(oopdabind, config_keys.oopda.v)
                ftext('Клавиша успешно изменена. Старое значение: '.. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. ' | Новое значение: '.. table.concat(rkeys.getKeysName(config_keys.oopda.v), " + "))
                saveData(config_keys, 'moonloader/config/fbitools/keys.json')
            end
            imgui.SameLine()
            imgui.Text(u8('Клавиша подтверждения'))
            if imadd.HotKey('##oopnet', config_keys.oopnet, tLastKeys, 100) then
                rkeys.changeHotKey(oopnetbind, config_keys.oopnet.v)
                ftext('Клавиша успешно изменена. Старое значение: '.. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. ' | Новое значение: '.. table.concat(rkeys.getKeysName(config_keys.oopnet.v), " + "))
                saveData(config_keys, 'moonloader/config/Army-Tools/keys.json')
            end
            imgui.SameLine()
            imgui.Text(u8('Клавиша отмены'))
            if imadd.HotKey('##cuff', config_keys.cuffkey, tLastKeys, 100) then
                rkeys.changeHotKey(cuffbind, config_keys.cuffkey.v)
                ftext('Клавиша успешно изменена. Старое значение: '.. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. ' | Новое значение: '.. table.concat(rkeys.getKeysName(config_keys.cuffkey.v), " + "))
                saveData(config_keys, 'moonloader/config/Army-Tools/keys.json')
            end
            imgui.SameLine()
            imgui.Text(u8('Связать игрока'))
            if imadd.HotKey('##uncuff', config_keys.uncuffkey, tLastKeys, 100) then
                rkeys.changeHotKey(uncuffbind, config_keys.uncuffkey.v)
                ftext('Клавиша успешно изменена. Старое значение: '.. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. ' | Новое значение: '.. table.concat(rkeys.getKeysName(config_keys.uncuffkey.v), " + "))
                saveData(config_keys, 'moonloader/config/Army-Tools/keys.json')
            end
            imgui.SameLine()
            imgui.Text(u8('Развязать игрока'))
            if imadd.HotKey('##follow', config_keys.followkey, tLastKeys, 100) then
                rkeys.changeHotKey(followbind, config_keys.followkey.v)
                ftext('Клавиша успешно изменена. Старое значение: '.. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. ' | Новое значение: '.. table.concat(rkeys.getKeysName(config_keys.followkey.v), " + "))
                saveData(config_keys, 'moonloader/config/Army-Tools/keys.json')
            end
            imgui.SameLine()
            imgui.Text(u8('Вести игрока за собой'))
            if imadd.HotKey('##siren', config_keys.sirenkey, tLastKeys, 100) then
                rkeys.changeHotKey(sirenbind, config_keys.sirenkey.v)
                ftext('Клавиша успешно изменена. Старое значение: '.. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. ' | Новое значение: '.. table.concat(rkeys.getKeysName(config_keys.sirenkey.v), " + "))
                saveData(config_keys, 'moonloader/config/Army-Tools/keys.json')
            end
            imgui.SameLine()
            imgui.Text(u8('Включить / выключить сирену на авто'))
        end
        if show == 18 then
            if imgui.Button(u8"Лог департамента",imgui.ImVec2(266, 20)) then
                show = 11
            end
            imgui.SameLine()
            if imgui.Button(u8"Лог рации",imgui.ImVec2(266, 20)) then
                show = 18
            end
            imgui.SameLine()
            if imgui.Button(u8"Лог SMS",imgui.ImVec2(266, 20)) then
                show = 19
            end 
            imgui.Separator()
            imgui.CentrText(u8'Лог рации:')
            imgui.CenterTextColoredRGB(u8('%s'):format(table.concat(radio, '\n')))
        end
        if show == 19 then
            if imgui.Button(u8"Лог департамента",imgui.ImVec2(266, 20)) then
                show = 11
            end
            imgui.SameLine()
            if imgui.Button(u8"Лог рации",imgui.ImVec2(266, 20)) then
                show = 18
            end
            imgui.SameLine()
            if imgui.Button(u8"Лог SMS",imgui.ImVec2(266, 20)) then
                show = 19
            end
            imgui.Separator()
            imgui.CentrText(u8'Лог SMS:')
            imgui.CenterTextColoredRGB(u8('%s'):format(table.concat(sms, '\n')))
        end
        imgui.EndChild()
        imgui.End()
    end
    if memw.v then
        colisinst = 0
        imgui.ShowCursor = true
        local pop
        local sw, sh = getScreenResolution()
        local imgui_RGBA = imgui.ImVec4(0.80, 0.00, 0.00, 1.00)
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(760, 330), imgui.Cond.FirstUseEver)
        imgui.Begin(u8(script.this.name..' | Список сотрудников [Всего: %s]'):format(#tMembers), memw, imgui.WindowFlags.NoResize)
        imgui.BeginChild('##1', imgui.ImVec2(760, 300))
        imgui.Columns(6, _)
        imgui.SetColumnWidth(-1, 210) imgui.Text(u8 'Ник игрока'); imgui.NextColumn()
        imgui.SetColumnWidth(-1, 190) imgui.Text(u8 'Должность');  imgui.NextColumn()
        imgui.SetColumnWidth(-1, 80) imgui.Text(u8 'Статус') imgui.NextColumn()
        imgui.SetColumnWidth(-1, 120) imgui.Text(u8 'Дата приема') imgui.NextColumn() 
        imgui.SetColumnWidth(-1, 70) imgui.Text(u8 'AFK') imgui.NextColumn() 
        imgui.SetColumnWidth(-1, 70) imgui.Text(u8 'Дистанция') imgui.NextColumn() 
        imgui.Separator()
        for _, v in ipairs(tMembers) do
            

            imgui.TextColored(imgui.ImVec4(getColor(v.id)), u8('%s [%s]'):format(v.nickname, v.id))
            if imgui.IsItemHovered() then
                imgui.BeginTooltip();
                imgui.PushTextWrapPos(450.0);
                imgui.TextColored(imgui.ImVec4(getColor(v.id)), u8("%s\nУровень: %s"):format(v.nickname, sampGetPlayerScore(v.id)))
                imgui.PopTextWrapPos();
                imgui.EndTooltip();
            end
            imgui.NextColumn()
            
            imgui.Text(('%s [%s]'):format(v.sRang, v.iRang))
            imgui.NextColumn()
            if v.status ~= u8("На работе") then
                imgui.TextColored(imgui.ImVec4(0.80, 0.00, 0.00, 1.00), v.status);
            else
                imgui.TextColored(imgui.ImVec4(0.00, 0.80, 0.00, 1.00), v.status);
            end
            imgui.NextColumn()
            imgui.Text(v.invite)
            imgui.NextColumn()
            if v.sec ~= 0 then
                if v.sec < 360 then 
                    imgui.TextColored(getColorForSeconds(v.sec), tostring(v.sec .. u8(' сек.')));
                else
                    imgui.TextColored(getColorForSeconds(v.sec), tostring("360+" .. u8(' сек.')));
                end
            else
                imgui.TextColored(imgui.ImVec4(0.00, 0.80, 0.00, 1.00), u8("Нет"));
            end
            imgui.NextColumn()
            local isinst, rasst = sampGetDistanceLocalPlayerToPlayerByPlayerId(v.id)
            local _, myid = sampGetPlayerIdByCharHandle(playerPed)
            if tonumber(v.id) == tonumber(myid) then
                imgui.Text(u8'Нет')
            else
                if isinst then
                    imgui.Text(u8(0.01*math.floor(100*rasst).. " м"))
                    colisinst = colisinst + 1
                else
                    imgui.Text(u8'Нет')
                end
            end
            imgui.NextColumn()
        end

        imgui.Columns(1)
        imgui.EndChild()
        imgui.End()
    end
    if targetbar.v then
        local sw, sh = getScreenResolution()
        local valid, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
        if valid then
            local result, id = sampGetPlayerIdByCharHandle(ped)
            if sampIsPlayerConnected(id) then
                local targetname = sampGetPlayerNickname(id)
                local targetscore = sampGetPlayerScore(id)
                local targethealth = sampGetPlayerHealth(id)
                local targetarmour = sampGetPlayerArmor(id)
                local targetfraction = sampGetFraktionBySkin(id)
                local style = imgui.GetStyle()
                local colors = style.Colors
                local clr = imgui.Col
                local ImVec4 = imgui.ImVec4
                targetargbW = config.main.targetcolorW
                imgui.PushStyleVar(imgui.StyleVar.WindowRounding, tRound.v) 
                imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, 100 - sh), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
                imgui.SetNextWindowSize(imgui.ImVec2(320, 90), imgui.Cond.FirstUseEver)
                imgui.PushStyleColor(clr.WindowBg, ImVec4(imgui.ImColor(targetargbW):GetFloat4()))
                imgui.Begin(u8"Target Bar", targetbar,imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar)
                imgui.CentrText(('%s [%s]'):format(targetname, id))
                imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 1.0, 1.0, 1))
                imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0.25, 0, 0, 1))
                imgui.PushStyleColor(imgui.Col.PlotHistogram, imgui.ImVec4(1, 0, 0, 1))
                imgui.ProgressBar(targethealth / 100, imgui.ImVec2(300, 15.0))
                imgui.PopStyleColor(3)
                imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 1.0, 1.0, 1))
                imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0.44, 0.44, 0.44, 1))
                imgui.PushStyleColor(imgui.Col.PlotHistogram, imgui.ImVec4(0.61, 0.61, 0.61, 1))
                imgui.ProgressBar(targetarmour / 100, imgui.ImVec2(300, 15.0))
                imgui.PopStyleColor(3)
                imgui.SetCursorPosX(55)
                imgui.Text((u8('Уровень: %d')):format(targetscore))
                imgui.SameLine()
                imgui.SetCursorPosX(180)
                imgui.Text(u8('Фракция: %s'):format(targetfraction))
                imgui.End()
                imgui.PopStyleVar()
                imgui.PopStyleColor(1)
            end
        end
    end
    if hud.v then
        imgui.SwitchContext()
        local style = imgui.GetStyle()
        local colors = style.Colors
        local clr = imgui.Col
        local ImVec4 = imgui.ImVec4
        _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
        local myname = sampGetPlayerNickname(myid)
        local myping = sampGetPlayerPing(myid)
        local phealth = sampGetPlayerHealth(myid)
        local parmour = sampGetPlayerArmor(myid)
        local myweapon = getCurrentCharWeapon(PLAYER_PED)
        local myweaponammo = getAmmoInCharWeapon(PLAYER_PED, myweapon)
        local valid, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
        local myweaponname = getweaponname(myweapon)
        local naprav = ""
        argbW = config.main.colorW
        if getCharHeading(playerPed) >= 337.5 or getCharHeading(playerPed) <= 22.5 then naprav = u8"Северное" end
        if getCharHeading(playerPed) > 22.5 and getCharHeading(playerPed) <= 67.5 then naprav = u8"Северо-западное" end
        if getCharHeading(playerPed) > 67.5 and getCharHeading(playerPed) <= 112.5 then naprav = u8"Западное" end
        if getCharHeading(playerPed) > 112.5 and getCharHeading(playerPed) <= 157.5 then naprav = u8"Юго-западное" end
        if getCharHeading(playerPed) > 157.5 and getCharHeading(playerPed) <= 202.5 then naprav = u8"Южное" end
        if getCharHeading(playerPed) > 202.5 and getCharHeading(playerPed) <= 247.5 then naprav = u8"Юго-восточное" end
        if getCharHeading(playerPed) > 247.5 and getCharHeading(playerPed) <= 292.5 then naprav = u8"Восточное" end
        if getCharHeading(playerPed) > 292.5 and getCharHeading(playerPed) <= 337.5 then naprav = u8"Северо-восточное" end
        imgui.PushStyleVar(imgui.StyleVar.WindowRounding, sRound.v)
        imgui.SetNextWindowPos(imgui.ImVec2(config.main.posX, config.main.posY), imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(config.main.widehud, 180), imgui.Cond.FirstUseEver)
        imgui.PushStyleColor(clr.WindowBg, ImVec4(imgui.ImColor(argbW):GetFloat4()))
        imgui.Begin(u8"Army Tools",hud,imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar)
        if config.infobar.namebar then 
            imgui.CentrText('Army Tools')
            imgui.Separator()
        end
        imgui.Text(fa.ICON_ID_CARD_O .. (u8" Информация:"))
        imgui.SameLine()
        imgui.TextColored(imgui.ImVec4(getColor(myid)), u8('%s [%s]'):format(myname, myid))
        if config.infobar.ping then
            imgui.SameLine()
            imgui.Text(string.format(u8"| Пинг: [%d]", myping))
        end
        if config.infobar.health then
            imgui.Text(string.format(fa.ICON_HEARTBEAT .. u8" Здоровье: [%d]", phealth))
        end
        if config.infobar.armour then
            if config.infobar.health then
                imgui.SameLine(); imgui.Text(string.format(u8"| Броня: [%d]", parmour))
            else
                imgui.Text(string.format(fa.ICON_HEARTBEAT.. u8" Броня: [%d]", parmour))
            end
        end
        if config.infobar.FPS then
            local fps = memory.getfloat(0xB7CB50, true)
            if config.infobar.health or config.infobar.armour then
                imgui.SameLine(); imgui.Text(string.format(u8"| FPS: %d", fps))
            else
                imgui.Text(string.format(u8"FPS: %d", fps))
            end
        end
        if getAmmoInClip() ~= 0 then
            imgui.Text(fa.ICON_BOMB .. (u8 " Оружие: %s [%s/%s]"):format(myweaponname, getAmmoInClip(), myweaponammo - getAmmoInClip()))
        else
            imgui.Text(fa.ICON_BOMB .. (u8 ' Оружие: %s'):format(myweaponname))
        end
        if isCharInAnyCar(PLAYER_PED) then
            local vHandle = storeCarCharIsInNoSave(PLAYER_PED)
            local result, vID = sampGetVehicleIdByCarHandle(vHandle)
            local vHP = getCarHealth(vHandle)
            local carspeed = getCarSpeed(vHandle)
            local speed = math.floor(carspeed)
            vehName = tCarsName[getCarModel(storeCarCharIsInNoSave(PLAYER_PED))-399]
            local ncspeed = math.floor(carspeed*2)
            imgui.Text((fa.ICON_CAR .. u8 ' Транспорт: %s [%s] | HP: %s | Скорость: %s'):format(vehName, vID, vHP, ncspeed))
        else
            imgui.Text(fa.ICON_CAR .. u8' Транспорт: Нет')
        end
        if config.infobar.target then
            if valid and not sampIsPlayerNpc(ped)  then 
                local result, id = sampGetPlayerIdByCharHandle(ped)
                if result then
                    local targetname = sampGetPlayerNickname(id)
                    local targetscore = sampGetPlayerScore(id)
                    imgui.Text((fa.ICON_CROSSHAIRS.. u8 ' Цель: %s [%s] | Уровень: %s'):format(targetname, id, targetscore))
                    
                else
                    imgui.Text(fa.ICON_CROSSHAIRS.. u8' Цель: Нет')
                end
            else
                imgui.Text(fa.ICON_CROSSHAIRS.. u8' Цель: Нет')
            end
        end
        if config.infobar.location then
            local x,y,z = getCharCoordinates(PLAYER_PED)
            imgui.Text((fa.ICON_MAP_MARKER.. u8'  %s'):format(calculateZone(x,y,z)))
        end
        if config.infobar.sektor then
            if config.infobar.location then
                imgui.SameLine(); imgui.Text((u8'| Квадрат: %s'):format(u8(kvadratb())))
            else
                imgui.Text(string.format(fa.ICON_MAP_MARKER.. u8" Квадрат: %s", u8(kvadratb())))
            end
        end
        if config.infobar.direction then
            imgui.Text((fa.ICON_COMPASS.. u8' %s направление'):format(naprav))
        end
        if config.infobar.time then
            imgui.Text(string.format(fa.ICON_CLOCK_O ..u8" Время: %s", os.date('%H:%M:%S | %d.%m.%Y')))
        end
        if imgui.IsMouseClicked(0) and changetextpos then
            changetextpos = false
            sampToggleCursor(false)
            vzaimod.v = true
            saveData(config, 'moonloader/config/Army-Tools/'..sampGetPlayerNickname(id)..'/'..sampGetPlayerNickname(id)..'.json')
        end
        imgui.End()
        imgui.PopStyleVar()
        imgui.PopStyleColor(1)
    end
end


function sampev.onSendChat(msg)
    count = 0;
    for S in msg:gmatch('#(%d+)') do
        count = count +1
        if not sampIsPlayerConnected(msg:gmatch('#(%d+)')) then return end
        msg = msg:gsub('#%d+', sampGetPlayerNickname(S):gsub('_', ' '))
    end
    for A in msg:gmatch('!(%d+)') do
        count = count +1
        if not sampIsPlayerConnected(msg:gmatch('!(%d+)')) then return end
        _, familys = sampGetPlayerNickname(A):match('(.+)_(.+)')
        msg = msg:gsub('!%d+', familys, 1)
    end

    if not S and count ~= 0 then return sampSendChat(msg,-1)
    elseif not A and count ~= 0 then return sampSendChat(msg,-1) end
end

function sampev.onSendCommand(msg)
    count = 0;
        for S in msg:gmatch('#(%d+)') do
        count = count +1
        if not sampIsPlayerConnected(msg:gmatch('#(%d+)')) then return end
        msg = msg:gsub('#%d+', sampGetPlayerNickname(S):gsub('_', ' '))
    end
    for A in msg:gmatch('!(%d+)') do
        count = count +1
        if not sampIsPlayerConnected(msg:gmatch('!(%d+)')) then return end
        _, familys = sampGetPlayerNickname(A):match('(.+)_(.+)')
        msg = msg:gsub('!%d+', familys, 1)
    end
    
    if not S and count ~= 0 then return sampSendChat(msg,-1)
    elseif not A and count ~= 0 then return sampSendChat(msg,-1) end
end

function sampev.onServerMessage(color, text)
    if text:find(' Материалы успешно доставлены! Материалов в вертолёте:') then unload = true end
    if text:find(' Материалы успешно разгружены! Материалов в вертолёте:') then unload = true end
    if text:find(' Отправляйтесь на корабль для загрузки материалов') and unload == false then
        opyatstat = true;
        postavkisfa = true;
        notf.addNotification(string.format('Приступаю к поставкам на ГС Army LV.\nСделать доклад?\n\nПодтвердить: '..table.concat(rkeys.getKeysName(config_keys.oopda.v))..'\nОтменить: '..table.concat(rkeys.getKeysName(config_keys.oopnet.v))), 10, 3) 
    end 
    if text:find(' Отправляйтесь на корабль, для загрузки материалов') and color == -86 and unload == false then
        opyatstat = true;
        postavkist = true;
        notf.addNotification(string.format('Приступаю к поставкам в порт.\nСделать доклад?\n\nПодтвердить: '..table.concat(rkeys.getKeysName(config_keys.oopda.v))..'\nОтменить: '..table.concat(rkeys.getKeysName(config_keys.oopnet.v))), 10, 3) 
    end 
    if text:find('Подсказка: Чтобы начать загрузку, используйте команду: /carm') then
        zaprfur_boat = true
        notf.addNotification(string.format('Доложить о взятии катера?\nСделать доклад?\n\nПодтвердить: '..table.concat(rkeys.getKeysName(config_keys.oopda.v))..'\nОтменить: '..table.concat(rkeys.getKeysName(config_keys.oopnet.v))), 10, 3) 
    end
    if text:find(' На складе .+: %d+/200000') then
        base, mats = text:match(' На складе (.+): (%d+)/200000')
        opyatstat = true;
        zaprfur = false
        notf.addNotification(string.format('Вы успешно доставили боеприпасы.\nСделать доклад?\n\nПодтвердить: '..table.concat(rkeys.getKeysName(config_keys.oopda.v))..'\nОтменить: '..table.concat(rkeys.getKeysName(config_keys.oopnet.v))), 10, 3) 
    end --На складе Зоны 51 60200/300000
    if text:find(' На складе .+ %d+ / 600000') then
        base, mats = text:match(' На складе (.+) (%d+) / 600000')
        opyatstat = true;
        zaprfur = true
        -- notf.addNotification(string.format('Подтвердить: F12 \nОтменить: F11'), 10, 2)
        notf.addNotification(string.format('Вы успешно доставили боеприпасы.\nСделать доклад?\n\nПодтвердить: '..table.concat(rkeys.getKeysName(config_keys.oopda.v))..'\nОтменить: '..table.concat(rkeys.getKeysName(config_keys.oopnet.v))), 10, 3) 
    end
    local myX, myY, myZ = getCharCoordinates(PLAYER_PED)
    if text:find(' Материалов: 30000/30000') and getDistanceBetweenCoords3d(myX, myY, myZ, -1898.2446,1489.7235,0.1915)<25 then
        opyatstat = true;
        loadmatssfa_podlodka = true
        notf.addNotification(string.format('Вы загрузили боеприпасы.\nСделать доклад?\n\nПодтвердить: '..table.concat(rkeys.getKeysName(config_keys.oopda.v))..'\nОтменить: '..table.concat(rkeys.getKeysName(config_keys.oopnet.v))), 10, 3) 
    end
    if text:find(' На складе Зоны 51 %d+/300000 материалов') then
        mats = text:match(' На складе Зоны 51 (%d+)/300000 материалов')
        opyatstat = true;
        loadstsfa = false
        zaprfursfa = true
        -- notf.addNotification(string.format('Подтвердить: F12 \nОтменить: F11'), 10, 2)
        notf.addNotification(string.format('Вы успешно доставили боеприпасы.\nСделать доклад?\n\nПодтвердить: '..table.concat(rkeys.getKeysName(config_keys.oopda.v))..'\nОтменить: '..table.concat(rkeys.getKeysName(config_keys.oopnet.v))), 10, 3) 
    end
    if text:find(' На складе Армия СФ: %d+/300000') then
        mats = text:match(' На складе Армия СФ: (%d+)/300000')
        opyatstat = true;
        zaprfursfa_boat = true
        -- notf.addNotification(string.format('Подтвердить: F12 \nОтменить: F11'), 10, 2)
        notf.addNotification(string.format('Вы успешно доставили боеприпасы.\nСделать доклад?\n\nПодтвердить: '..table.concat(rkeys.getKeysName(config_keys.oopda.v))..'\nОтменить: '..table.concat(rkeys.getKeysName(config_keys.oopnet.v))), 10, 3) 
    end
    if text:find('Доставьте материалы на Зону 51') then
        opyatstat = true;
        postavkisfa = false;
        postavkist = false;
        loadstsfa = true;
        -- notf.addNotification(string.format('Подтвердить: F12 \nОтменить: F11'), 10, 2)
        notf.addNotification(string.format('Вы загрузили боеприпасы.\nСделать доклад?\n\nПодтвердить: '..table.concat(rkeys.getKeysName(config_keys.oopda.v))..'\nОтменить: '..table.concat(rkeys.getKeysName(config_keys.oopnet.v))), 10, 3) 
    end
    if text:find('Доставьте материалы в LSA') then
        opyatstat = true;
        postavkist = false;
        loadst = true;
        -- notf.addNotification(string.format('Подтвердить: F12 \nОтменить: F11'), 10, 2)
        notf.addNotification(string.format('Вы загрузили боеприпасы.\nСделать доклад?\n\nПодтвердить: '..table.concat(rkeys.getKeysName(config_keys.oopda.v))..'\nОтменить: '..table.concat(rkeys.getKeysName(config_keys.oopnet.v))), 10, 3) 
    end
    if text:find('Рабочий день окончен') then
        fixbugabp = false
    end
    if text:find('Рабочий день начат') then
        if config.main.clistb then
            lua_thread.create(function()
                sampAddChatMessage(scriptname .. '| {FFFFFF}Значение клиста установлено на: ' .. config.main.clist, 0x7FFF00)
                sampSendChat('/clist '..tonumber(config.main.clist))
                workday = true
            end)   
        end
    end
    if status then
        if text:find("ID: %d+ | .+ | (.+): .+%[%d+%] %- %{......%}.+%{......%}") then
            if not text:find("AFK") then
                local id, invDate, nickname, sRang, iRang, status = text:match("ID: (%d+) | (.+) | (.+): (.+)%[(%d+)%] %- %{.+%}(.+)%{.+%}")
                table.insert(tMembers, Player:new(id, sRang, iRang, status, invDate, false, 0, nickname))
            else
                local id, invDate, nickname, sRang, iRang, status, sec = text:match("ID: (%d+) | (.+) | (.+): (.+)%[(%d+)%] %- %{.+%}(.+)%{.+%} | %{.+%}%[AFK%]: (%d+).+")
                table.insert(tMembers, Player:new(id, sRang, iRang, status, invDate, true, sec, nickname))
            end
            return false
        end
        if text:find("ID: %d+ | .+ | (.+): .+%[%d+%]") then
            if not text:find("AFK") then
                local id, invDate, nickname, sRang, iRang = text:match("ID: (%d+) | (.+) | (.+): (.+)%[(%d+)%]")
                table.insert(tMembers, Player:new(id, sRang, iRang, "Недоступно", invDate, false, 0, nickname))

            else
                local id, invDate, nickname, sRang, iRang, sec = text:match("ID: (%d+) | (.+) | (.+): (.+)%[(%d+)%] | %{.+%}%[AFK%]: (%d+).+")
                table.insert(tMembers, Player:new(id, sRang, iRang, "Недоступно", invDate, true, sec, nickname))
            end
            return false
        end
        if text:match('Всего: %d+ человек') then
            gotovo = true
            return false
        end
        if color == -1 then 
            return false
        end
        if color == 647175338 then
            return false
        end
    end
    if color == -8224086 then
        local colors = ("{%06X}"):format(bit.rshift(color, 8))
        table.insert(departament, os.date(colors.."[%H:%M:%S] ") .. text)
    end
    if color == -1920073984 and (text:match('.+ .+%: .+') or text:match('%(%( .+ .+%: .+ %)%)')) then
        local colors = ("{%06X}"):format(bit.rshift(color, 8))
        table.insert(radio, os.date(colors.."[%H:%M:%S] ") .. text)
    end
    if color == -65366 and (text:match('SMS%: .+. Отправитель%: .+') or text:match('SMS%: .+. Получатель%: .+')) then
        if text:match('SMS%: .+. Отправитель%: .+%[%d+%]') then smsid = text:match('SMS%: .+. Отправитель%: .+%[(%d+)%]') elseif text:match('SMS%: .+. Получатель%: .+%[%d+%]') then smstoid = text:match('SMS%: .+. Получатель%: .+%[(%d+)%]') end
        local colors = ("{%06X}"):format(bit.rshift(color, 8))
        table.insert(sms, os.date(colors.."[%H:%M:%S] ") .. text)
    end
    if text:find('{00AB06}Чтобы завести двигатель, нажмите клавишу {FFFFFF}"2"{00AB06} или введите команду {FFFFFF}"/en"') then
        if config.main.car then
            lua_thread.create(function()
                if isCharInAnyCar(PLAYER_PED) then
                    if not isCarEngineOn(storeCarCharIsInNoSave(PLAYER_PED)) then
                        setVirtualKeyDown(50, true)
                        wait(150)
                        setVirtualKeyDown(50, false)
                    end
                end
            end)
        end
    end
    if config.main.colorradio then
        -- {".. string.format("%X", bit.band(colorN,  0xFFFFFF)) .. "}"
        if text:find('_') and text:find(':') and text:find('%[') and text:find('%]') then
            if color == -1920073984 then
                local txL, nameF, nameS, txR = text:match('[^%S](.+)%s(%a+)_(%a+)%[%d+%]:%s*(.+)') --text:match('[^%S](.+)%s(%a+)_(%a+):%s*(.+)') --text:match("^(%S+)%s+(%g+):%s*(.+)")
                if txR ~= nil and txL ~= nil and nameS ~= nil then
                    local nameD = nameF .. "_" .. nameS
                    local id = findPlayerByName(nameD)
                    local colorN = sampGetPlayerColor(id)
                    sampAddChatMessage(txL .. " {".. string.format("%06X", bit.band(colorN,  0xFFFFFF)) .. "}" ..  nameF .. "_" .. nameS .. " [" .. id .."]:{8D8DFF} " .. txR , 0x8D8DFF)
                    return false
                end
            end
        end
        if text:find('_') and text:find(':') then
            if color == -1920073984 then
                local txL, nameF, nameS, txR = text:match('[^%S](.+)%s(%a+)_(%a+):%s*(.+)') --text:match('[^%S](.+)%s(%a+)_(%a+):%s*(.+)') --text:match("^(%S+)%s+(%g+):%s*(.+)")
                if txR ~= nil and txL ~= nil and nameS ~= nil then
                    local nameD = nameF .. "_" .. nameS
                    local id = findPlayerByName(nameD)
                    local colorN = sampGetPlayerColor(id)
                    if colorN == 4278752257 then sampAddChatMessage(txL .. " {089401}" ..  nameF .. "_" .. nameS .. " [" .. id .."]:{8D8DFF} " .. txR , 0x8D8DFF)
                    else sampAddChatMessage(txL .. " {".. string.format("%X", bit.band(colorN,  0xFFFFFF)) .. "}" ..  nameF .. "_" .. nameS .. " [" .. id .."]:{8D8DFF} " .. txR , 0x8D8DFF) end
                    return false
                end
            end
        end
        return {color, text}
    end
end

function sampev.onSendSpawn()
    if config.main.clistb and workday then
        lua_thread.create(function()
            wait(1400)
            sampAddChatMessage(scriptname .. '| {FFFFFF}Значение клиста установлено на: ' .. config.main.clist, 0x7FFF00)
            sampSendChat('/clist '..config.main.clist)
        end)
    end
end

function checkStats()
    while not sampIsLocalPlayerSpawned() do wait(0) end
    checkstat = true
    sampSendChat('/stats')
    local chtime = os.clock() + 10
    while chtime > os.clock() do wait(0) end
    local chtime = nil
    checkstat = false
    if rang == -1 and frak == -1 then
        frak = 'Нет'
        rang = 'Нет'
    end
end

function cam()
    if isCharInAnyCar(PLAYER_PED) then
        if isCharInModel(PLAYER_PED, 448) or isCharInModel(PLAYER_PED, 461) or isCharInModel(PLAYER_PED, 462) or isCharInModel(PLAYER_PED, 463) or isCharInModel(PLAYER_PED, 468) or isCharInModel(PLAYER_PED, 471) or isCharInModel(PLAYER_PED, 481) or isCharInModel(PLAYER_PED, 509) or isCharInModel(PLAYER_PED, 510) or isCharInModel(PLAYER_PED, 521) or isCharInModel(PLAYER_PED, 522) or isCharInModel(PLAYER_PED, 581) or isCharInModel(PLAYER_PED, 586) then
            lua_thread.create(function()
                sampSendChat('/do На груди закреплена боди-камера.')
                wait(2000)
                sampSendChat('/me протянул правую руку к боди-камере, затем нажатием на кнопку включил запись.')
                wait(2000)
                sampSendChat('/do Боди-камера начала снимать все происходящее.')
            end)
        else
            lua_thread.create(function()
                sampSendChat('/do На приборной панели закреплен видеорегистратор.')
                wait(2000)
                sampSendChat('/me протянул правую руку к регистратору, затем нажатием на кнопку включил запись.')
                wait(2000)
                sampSendChat('/do Видеорегистратор начал снимать все происходящее.')
            end)
        end
    else
        lua_thread.create(function()
            sampSendChat('/me незаметно поправив очки, включил запись скрытной камеры.')
            wait(2500)
            sampSendChat('/do Камера начала записывать все происходящее, сохраняя на жесткий диск.')
        end)
    end
end


function imgui.CentrText(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Text(text)
end

function saveData(table, path)
    if doesFileExist(path) then os.remove(path) end
    local sfa = io.open(path, "w")
    if sfa then
        sfa:write(encodeJson(table))
        sfa:close()
    end
end

function trg(pam)
    lua_thread.create(function()
        targetbar.v = true
    end)
end

function afp()
    lua_thread.create(function()
        vzaimod.v = true
        show=501
    end)
end

function ayk()
    lua_thread.create(function()
        vzaimod.v = true
        show=502
    end)
end

function aak()
    lua_thread.create(function()
        vzaimod.v = true
        show=503
    end)
end

function aarmy()
    lua_thread.create(function()
        vzaimod.v = true
        show=504
    end)
end

function csc()
    lua_thread.create(function()
        vzaimod.v = true
        show=2
    end)
end

function newscritp(pam)
    lua_thread.create(function()
        main_window_state.v = true
    end)
end

function cmd_lh(pam)
    lua_thread.create(function() vzaimod.v = true end)
end

function imgui.BeforeDrawFrame()
    if fa_font == nil then
        local font_config = imgui.ImFontConfig() -- to use 'imgui.ImFontConfig.new()' on error
        font_config.MergeMode = true
        fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fontawesome-webfont.ttf', 14.0, font_config, fa_glyph_ranges)
        fa_font_18 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 16.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) -- вместо 30 любой нужный размер
        fa_font_40 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 40.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) -- вместо 30 любой нужный размер
    end
end

function imgui.CenterTextColoredRGB(text)
    local width = imgui.GetWindowWidth()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4

    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end

    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImColor(r, g, b, a):GetVec4()
    end

    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local textsize = w:gsub('{.-}', '')
            local text_width = imgui.CalcTextSize(u8(textsize))
            imgui.SetCursorPosX( width / 2 - text_width .x / 2 )
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else
                imgui.Text(u8(w))
            end
        end
    end
    render_text(text)
end

function time()
    startTime = os.time()                                               -- "Точка отсчёта"
    connectingTime = 0
    while true do
        wait(1000)
        nowTime = os.date("%H:%M:%S", os.time())
        if sampGetGamestate() == 3 then                                 -- Игровой статус равен "Подключён к серверу" (Что бы онлайн считало только, когда, мы подключены к серверу)
            sesOnline.v = sesOnline.v + 1                               -- Онлайн за сессию без учёта АФК
            sesFull.v = os.time() - startTime                           -- Общий онлайн за сессию
            sesAfk.v = sesFull.v - sesOnline.v                          -- АФК за сессию

            online.onDay.online = online.onDay.online + 1                   -- Онлайн за день без учёта АФК
            online.onDay.full = dayFull.v + sesFull.v                       -- Общий онлайн за день
            online.onDay.afk = online.onDay.full - online.onDay.online          -- АФК за день

            online.onWeek.online = online.onWeek.online + 1                     -- Онлайн за неделю без учёта АФК
            online.onWeek.full = weekFull.v + sesFull.v                     -- Общий онлайн за неделю
            online.onWeek.afk = online.onWeek.full - online.onWeek.online       -- АФК за неделю

            local today = tonumber(os.date('%w', os.time()))
            online.myWeekOnline[today] = online.onDay.full

            connectingTime = 0
        else
            connectingTime = connectingTime + 1                         -- Вермя подключения к серверу
            startTime = startTime + 1                                   -- Смещение начала отсчета таймеров
        end
    end
end

function autoSave()
    while true do 
        wait(1000) -- сохранение каждые 60 секунд
        inicfg.save(online, "online.ini")
    end
end

function automarker()
    result2, x3, y3, z3 = getTargetBlipCoordinates()
    if result2 then
        if x3 ~= xM and y3 ~= yM then
            distance()
        end
    end
end

function number_week() -- получение номера недели в году
    local current_time = os.date'*t'
    local start_year = os.time{ year = current_time.year, day = 1, month = 1 }
    local week_day = ( os.date('%w', start_year) - 1 ) % 7
    return math.ceil((current_time.yday + week_day) / 7)
end


function getStrDate(unixTime)
    local tMonths = {'января', 'февраля', 'марта', 'апреля', 'мая', 'июня', 'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'}
    local day = tonumber(os.date('%d', unixTime))
    local month = tMonths[tonumber(os.date('%m', unixTime))]
    local weekday = tWeekdays[tonumber(os.date('%w', unixTime))]
    return string.format('%s, %s %s', weekday, day, month)
end

function get_clock(time)
    local timezone_offset = 86400 - os.date('%H', 0) * 3600
    if tonumber(time) >= 86400 then onDay = true else onDay = false end
    return os.date((onDay and math.floor(time / 86400)..'д ' or '')..'%H:%M:%S', time + timezone_offset)
end

function findPlayerByName(name)
    local _, mID = sampGetPlayerIdByCharHandle(PLAYER_PED)
    if tostring(name) == sampGetPlayerNickname(mID) then return mID end
    for i = 0, 999 do if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == tostring(name) then return i end end
    return -1
end

function sampGetPlayerIdByNickname(nick)
    local _, myid = sampGetPlayerIdByCharHandle(playerPed)
    if tostring(nick) == sampGetPlayerNickname(myid) then return myid end
    for i = 0, 999 do if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == tostring(nick) then return i end end
end

function sampev.onPlayerEnterVehicle(id, vehId, isP)
    if vehId == 225 or vehId == 226 or vehId == 227 then
        if not stopFlood[id] then
            local colorN = sampGetPlayerColor(id)
            if config.main.warnings then sampAddChatMessage(scriptname.. "| {".. string.format("%06X", bit.band(colorN,  0xFFFFFF)) .. "}"..sampGetPlayerNickname(id).."["..id.."] {19ff00}AP:"..sampGetPlayerArmor(id).." HP:"..sampGetPlayerHealth(id).." {FFFFFF}взял фуру из первого {FFFFFF}ангара.", 0x7FFF00) end
            stopFlood[id] = true
        end
    end
    if vehId == 228 or vehId == 229 or vehId == 230 then
        if not stopFlood[id] then
            local colorN = sampGetPlayerColor(id)
            if config.main.warnings then sampAddChatMessage(scriptname.. "| {".. string.format("%06X", bit.band(colorN,  0xFFFFFF)) .. "}"..sampGetPlayerNickname(id).."["..id.."] {19ff00}AP:"..sampGetPlayerArmor(id).." HP:"..sampGetPlayerHealth(id).." {FFFFFF}взял фуру из второго {FFFFFF}ангара.", 0x7FFF00) end
            stopFlood[id] = true
        end
    end
end

function r(pam)
    if #pam ~= 0 then
        if config.main.tarb then
            sampSendChat(string.format('/r %s %s', config.main.tar, pam))
        else
            sampSendChat(string.format('/r %s', pam))
        end
    else
        sampAddChatMessage(scriptname.. '{FFFFFF}Введите /r [текст]', 0x7CFC00)
    end
end

function f(pam)
    if #pam ~= 0 then
        if config.main.tarb then
            sampSendChat(string.format('/f %s %s', config.main.tar, pam))
        else
            sampSendChat(string.format('/f %s', pam))
        end
    else
        sampAddChatMessage(scriptname.. '{FFFFFF}Введите /f [текст]', 0x7CFC00)
    end
end

function getCompl()
    local t = {}
    if config.autobp.deagle then table.insert(t, 0) end
    if config.autobp.shot then  table.insert(t, 1) end
    if config.autobp.smg then table.insert(t, 2) end
    if config.autobp.m4 then table.insert(t, 3) end
    if config.autobp.rifle then table.insert(t, 4) end
    if config.autobp.armour then table.insert(t, 5) end
    if config.autobp.spec then table.insert(t, 6) end
    return t
end

function onHotKey(id, keys)
    local x,y,z = getCharCoordinates(PLAYER_PED)
    lua_thread.create(function()
        local sKeys = tostring(table.concat(keys, " "))
        for k, v in pairs(tBindList) do
            if sKeys == tostring(table.concat(v.v, " ")) then
                local tostr = tostring(v.text)
                if tostr:len() > 0 then
                    for line in tostr:gmatch('[^\r\n]+') do
                        if line:match("^{wait%:%d+}$") then
                            wait(line:match("^%{wait%:(%d+)}$"))
                        elseif line:match("^{screen}$") then
                            screen()
                        else
                            local bIsEnter = string.match(line, "^{noe}(.+)") ~= nil
                            local bIsF6 = string.match(line, "^{f6}(.+)") ~= nil
                            local x,y,z = getCharCoordinates(PLAYER_PED)
                            local naprav = ""
                            if getCharHeading(playerPed) >= 337.5 or getCharHeading(playerPed) <= 22.5 then naprav = "Северное" end
                            if getCharHeading(playerPed) > 22.5 and getCharHeading(playerPed) <= 67.5 then naprav = "Северо-западное" end
                            if getCharHeading(playerPed) > 67.5 and getCharHeading(playerPed) <= 112.5 then naprav = "Западное" end
                            if getCharHeading(playerPed) > 112.5 and getCharHeading(playerPed) <= 157.5 then naprav = "Юго-западное" end
                            if getCharHeading(playerPed) > 157.5 and getCharHeading(playerPed) <= 202.5 then naprav = "Южное" end
                            if getCharHeading(playerPed) > 202.5 and getCharHeading(playerPed) <= 247.5 then naprav = "Юго-восточное" end
                            if getCharHeading(playerPed) > 247.5 and getCharHeading(playerPed) <= 292.5 then naprav = "Восточное" end
                            if getCharHeading(playerPed) > 292.5 and getCharHeading(playerPed) <= 337.5 then naprav = "Северо-восточное" end
                            local keys = {
                                ["{f6}"] = "",
                                ["{noe}"] = "",
                                ["{myid}"] = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)),
                                ["{kv}"] = kvadratb(),
                                ["{tag}"] = config.main.tar,
                                ["{targetid}"] = targetid,
                                ["{naprav}"] = naprav,
                                ["{location}"] = calculateZone(x,y,z),
                                ["{targetrpnick}"] = sampGetPlayerNicknameForBinder(targetid):gsub('_', ' '),
                                ["{myrpnick}"] = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))):gsub("_", " "),
                                ["{rang}"] = rang,
                                ["{time}"] = os.date('%H:%M:%S'),
                                ["{data}"] = os.date('%d.%m.%Y'),
                                ["{frak}"] = frak,
                                ["{megafid}"] = gmegafid,
                                ["{dl}"] = mcid
                            }
                            for k1, v1 in pairs(keys) do
                                line = line:gsub(k1, v1)
                            end

                            if not bIsEnter then
                                if bIsF6 then
                                    sampProcessChatInput(line)
                                else
                                    sampSendChat(line)
                                end
                            else
                                sampSetChatInputText(line)
                                sampSetChatInputEnabled(true)
                            end
                        end
                    end
                end
            end
        end
    end)
end

if lrkeys then
    function rkeys.onHotKey(id, keys)
        if sampIsChatInputActive() or sampIsDialogActive() or isSampfuncsConsoleActive() then
            return false
        end
    end
end

function sampGetPlayerNicknameForBinder(nikkid)
    local nick = '-1'
    local nickid = tonumber(nikkid)
    if nickid ~= nil then
        if sampIsPlayerConnected(nickid) then
            nick = sampGetPlayerNickname(nickid)
        end
    end
    return nick
end


function strobes()
    while true do
        if isCharInAnyCar(PLAYER_PED) and not isCharInAnyBoat(PLAYER_PED) and not isCharInFlyingVehicle(PLAYER_PED) and not isCharOnAnyBike(PLAYER_PED) and not isCharInAnyTrain(PLAYER_PED) then
        local car = storeCarCharIsInNoSave(PLAYER_PED)
        if doesVehicleExist(car) then
            local veh_struct = getCarPointer(car) + 1440
            if isCarSirenOn(car) then
                callMethod(0x6C2100, veh_struct, 2, 1, 0, 1)
                callMethod(0x6C2100, veh_struct, 2, 1, 1, 0)
                wait(300)
                callMethod(0x6C2100, veh_struct, 2, 1, 0, 0)
                callMethod(0x6C2100, veh_struct, 2, 1, 1, 1)
            else
                callMethod(0x6C2100, veh_struct, 2, 1, 0, 0)
                callMethod(0x6C2100, veh_struct, 2, 1, 1, 0)
            end
        end
        end
        wait(300)
    end
end
function screen() local memory = require 'memory' memory.setuint8(sampGetBase() + 0x119CBC, 1) end

function setkv(pam)
    if #pam ~= 0 then
        kvadY, kvadX = string.match(pam, "(%A)-(%d+)")
        if kvadratb(kvadY) ~= nil and kvadX ~= nil and kvadY ~= nil and tonumber(kvadX) < 25 and tonumber(kvadX) > 0 then
            last = lcs
            coordX = kvadX * 250 - 3125
            coordY = (kvadratb1(kvadY) * 250 - 3125) * - 1
        end
    else
        sampAddChatMessage(scriptname.. '| {FFFFFF}Введите: /setkv [квадрат]', 0x7FFF00)
    end
end

function kvadratb()
    local KV = {
        [1] = "А",
        [2] = "Б",
        [3] = "В",
        [4] = "Г",
        [5] = "Д",
        [6] = "Ж",
        [7] = "З",
        [8] = "И",
        [9] = "К",
        [10] = "Л",
        [11] = "М",
        [12] = "Н",
        [13] = "О",
        [14] = "П",
        [15] = "Р",
        [16] = "С",
        [17] = "Т",
        [18] = "У",
        [19] = "Ф",
        [20] = "Х",
        [21] = "Ц",
        [22] = "Ч",
        [23] = "Ш",
        [24] = "Я",
    }
    local X, Y, Z = getCharCoordinates(playerPed)
    X = math.ceil((X + 3000) / 250)
    Y = math.ceil((Y * - 1 + 3000) / 250)
    Y = KV[Y]
    local KVX = (Y.."-"..X)
    return KVX
end

function kvadratb1(param)
    local KV = {
        ["А"] = 1,
        ["Б"] = 2,
        ["В"] = 3,
        ["Г"] = 4,
        ["Д"] = 5,
        ["Ж"] = 6,
        ["З"] = 7,
        ["И"] = 8,
        ["К"] = 9,
        ["Л"] = 10,
        ["М"] = 11,
        ["Н"] = 12,
        ["О"] = 13,
        ["П"] = 14,
        ["Р"] = 15,
        ["С"] = 16,
        ["Т"] = 17,
        ["У"] = 18,
        ["Ф"] = 19,
        ["Х"] = 20,
        ["Ц"] = 21,
        ["Ч"] = 22,
        ["Ш"] = 23,
        ["Я"] = 24,
        ["а"] = 1,
        ["б"] = 2,
        ["в"] = 3,
        ["г"] = 4,
        ["д"] = 5,
        ["ж"] = 6,
        ["з"] = 7,
        ["и"] = 8,
        ["к"] = 9,
        ["л"] = 10,
        ["м"] = 11,
        ["н"] = 12,
        ["о"] = 13,
        ["п"] = 14,
        ["р"] = 15,
        ["с"] = 16,
        ["т"] = 17,
        ["у"] = 18,
        ["ф"] = 19,
        ["х"] = 20,
        ["ц"] = 21,
        ["ч"] = 22,
        ["ш"] = 23,
        ["я"] = 24,
    }
    return KV[param]
end

function calculateZone(x, y, z)
    local streets = {{"Avispa Country Club", -2667.810, -302.135, -28.831, -2646.400, -262.320, 71.169},
    {"Easter Bay Airport", -1315.420, -405.388, 15.406, -1264.400, -209.543, 25.406},
    {"Avispa Country Club", -2550.040, -355.493, 0.000, -2470.040, -318.493, 39.700},
    {"Easter Bay Airport", -1490.330, -209.543, 15.406, -1264.400, -148.388, 25.406},
    {"Garcia", -2395.140, -222.589, -5.3, -2354.090, -204.792, 200.000},
    {"Shady Cabin", -1632.830, -2263.440, -3.0, -1601.330, -2231.790, 200.000},
    {"East Los Santos", 2381.680, -1494.030, -89.084, 2421.030, -1454.350, 110.916},
    {"LVA Freight Depot", 1236.630, 1163.410, -89.084, 1277.050, 1203.280, 110.916},
    {"Blackfield Intersection", 1277.050, 1044.690, -89.084, 1315.350, 1087.630, 110.916},
    {"Avispa Country Club", -2470.040, -355.493, 0.000, -2270.040, -318.493, 46.100},
    {"Temple", 1252.330, -926.999, -89.084, 1357.000, -910.170, 110.916},
    {"Unity Station", 1692.620, -1971.800, -20.492, 1812.620, -1932.800, 79.508},
    {"LVA Freight Depot", 1315.350, 1044.690, -89.084, 1375.600, 1087.630, 110.916},
    {"Los Flores", 2581.730, -1454.350, -89.084, 2632.830, -1393.420, 110.916},
    {"Starfish Casino", 2437.390, 1858.100, -39.084, 2495.090, 1970.850, 60.916},
    {"Easter Bay Chemicals", -1132.820, -787.391, 0.000, -956.476, -768.027, 200.000},
    {"Downtown Los Santos", 1370.850, -1170.870, -89.084, 1463.900, -1130.850, 110.916},
    {"Esplanade East", -1620.300, 1176.520, -4.5, -1580.010, 1274.260, 200.000},
    {"Market Station", 787.461, -1410.930, -34.126, 866.009, -1310.210, 65.874},
    {"Linden Station", 2811.250, 1229.590, -39.594, 2861.250, 1407.590, 60.406},
    {"Montgomery Intersection", 1582.440, 347.457, 0.000, 1664.620, 401.750, 200.000},
    {"Frederick Bridge", 2759.250, 296.501, 0.000, 2774.250, 594.757, 200.000},
    {"Yellow Bell Station", 1377.480, 2600.430, -21.926, 1492.450, 2687.360, 78.074},
    {"Downtown Los Santos", 1507.510, -1385.210, 110.916, 1582.550, -1325.310, 335.916},
    {"Jefferson", 2185.330, -1210.740, -89.084, 2281.450, -1154.590, 110.916},
    {"Mulholland", 1318.130, -910.170, -89.084, 1357.000, -768.027, 110.916},
    {"Avispa Country Club", -2361.510, -417.199, 0.000, -2270.040, -355.493, 200.000},
    {"Jefferson", 1996.910, -1449.670, -89.084, 2056.860, -1350.720, 110.916},
    {"Julius Thruway West", 1236.630, 2142.860, -89.084, 1297.470, 2243.230, 110.916},
    {"Jefferson", 2124.660, -1494.030, -89.084, 2266.210, -1449.670, 110.916},
    {"Julius Thruway North", 1848.400, 2478.490, -89.084, 1938.800, 2553.490, 110.916},
    {"Rodeo", 422.680, -1570.200, -89.084, 466.223, -1406.050, 110.916},
    {"Cranberry Station", -2007.830, 56.306, 0.000, -1922.000, 224.782, 100.000},
    {"Downtown Los Santos", 1391.050, -1026.330, -89.084, 1463.900, -926.999, 110.916},
    {"Redsands West", 1704.590, 2243.230, -89.084, 1777.390, 2342.830, 110.916},
    {"Little Mexico", 1758.900, -1722.260, -89.084, 1812.620, -1577.590, 110.916},
    {"Blackfield Intersection", 1375.600, 823.228, -89.084, 1457.390, 919.447, 110.916},
    {"Los Santos International", 1974.630, -2394.330, -39.084, 2089.000, -2256.590, 60.916},
    {"Beacon Hill", -399.633, -1075.520, -1.489, -319.033, -977.516, 198.511},
    {"Rodeo", 334.503, -1501.950, -89.084, 422.680, -1406.050, 110.916},
    {"Richman", 225.165, -1369.620, -89.084, 334.503, -1292.070, 110.916},
    {"Downtown Los Santos", 1724.760, -1250.900, -89.084, 1812.620, -1150.870, 110.916},
    {"The Strip", 2027.400, 1703.230, -89.084, 2137.400, 1783.230, 110.916},
    {"Downtown Los Santos", 1378.330, -1130.850, -89.084, 1463.900, -1026.330, 110.916},
    {"Blackfield Intersection", 1197.390, 1044.690, -89.084, 1277.050, 1163.390, 110.916},
    {"Conference Center", 1073.220, -1842.270, -89.084, 1323.900, -1804.210, 110.916},
    {"Montgomery", 1451.400, 347.457, -6.1, 1582.440, 420.802, 200.000},
    {"Foster Valley", -2270.040, -430.276, -1.2, -2178.690, -324.114, 200.000},
    {"Blackfield Chapel", 1325.600, 596.349, -89.084, 1375.600, 795.010, 110.916},
    {"Los Santos International", 2051.630, -2597.260, -39.084, 2152.450, -2394.330, 60.916},
    {"Mulholland", 1096.470, -910.170, -89.084, 1169.130, -768.027, 110.916},
    {"Yellow Bell Gol Course", 1457.460, 2723.230, -89.084, 1534.560, 2863.230, 110.916},
    {"The Strip", 2027.400, 1783.230, -89.084, 2162.390, 1863.230, 110.916},
    {"Jefferson", 2056.860, -1210.740, -89.084, 2185.330, -1126.320, 110.916},
    {"Mulholland", 952.604, -937.184, -89.084, 1096.470, -860.619, 110.916},
    {"Aldea Malvada", -1372.140, 2498.520, 0.000, -1277.590, 2615.350, 200.000},
    {"Las Colinas", 2126.860, -1126.320, -89.084, 2185.330, -934.489, 110.916},
    {"Las Colinas", 1994.330, -1100.820, -89.084, 2056.860, -920.815, 110.916},
    {"Richman", 647.557, -954.662, -89.084, 768.694, -860.619, 110.916},
    {"LVA Freight Depot", 1277.050, 1087.630, -89.084, 1375.600, 1203.280, 110.916},
    {"Julius Thruway North", 1377.390, 2433.230, -89.084, 1534.560, 2507.230, 110.916},
    {"Willowfield", 2201.820, -2095.000, -89.084, 2324.000, -1989.900, 110.916},
    {"Julius Thruway North", 1704.590, 2342.830, -89.084, 1848.400, 2433.230, 110.916},
    {"Temple", 1252.330, -1130.850, -89.084, 1378.330, -1026.330, 110.916},
    {"Little Mexico", 1701.900, -1842.270, -89.084, 1812.620, -1722.260, 110.916},
    {"Queens", -2411.220, 373.539, 0.000, -2253.540, 458.411, 200.000},
    {"Las Venturas Airport", 1515.810, 1586.400, -12.500, 1729.950, 1714.560, 87.500},
    {"Richman", 225.165, -1292.070, -89.084, 466.223, -1235.070, 110.916},
    {"Temple", 1252.330, -1026.330, -89.084, 1391.050, -926.999, 110.916},
    {"East Los Santos", 2266.260, -1494.030, -89.084, 2381.680, -1372.040, 110.916},
    {"Julius Thruway East", 2623.180, 943.235, -89.084, 2749.900, 1055.960, 110.916},
    {"Willowfield", 2541.700, -1941.400, -89.084, 2703.580, -1852.870, 110.916},
    {"Las Colinas", 2056.860, -1126.320, -89.084, 2126.860, -920.815, 110.916},
    {"Julius Thruway East", 2625.160, 2202.760, -89.084, 2685.160, 2442.550, 110.916},
    {"Rodeo", 225.165, -1501.950, -89.084, 334.503, -1369.620, 110.916},
    {"Las Brujas", -365.167, 2123.010, -3.0, -208.570, 2217.680, 200.000},
    {"Julius Thruway East", 2536.430, 2442.550, -89.084, 2685.160, 2542.550, 110.916},
    {"Rodeo", 334.503, -1406.050, -89.084, 466.223, -1292.070, 110.916},
    {"Vinewood", 647.557, -1227.280, -89.084, 787.461, -1118.280, 110.916},
    {"Rodeo", 422.680, -1684.650, -89.084, 558.099, -1570.200, 110.916},
    {"Julius Thruway North", 2498.210, 2542.550, -89.084, 2685.160, 2626.550, 110.916},
    {"Downtown Los Santos", 1724.760, -1430.870, -89.084, 1812.620, -1250.900, 110.916},
    {"Rodeo", 225.165, -1684.650, -89.084, 312.803, -1501.950, 110.916},
    {"Jefferson", 2056.860, -1449.670, -89.084, 2266.210, -1372.040, 110.916},
    {"Hampton Barns", 603.035, 264.312, 0.000, 761.994, 366.572, 200.000},
    {"Temple", 1096.470, -1130.840, -89.084, 1252.330, -1026.330, 110.916},
    {"Kincaid Bridge", -1087.930, 855.370, -89.084, -961.950, 986.281, 110.916},
    {"Verona Beach", 1046.150, -1722.260, -89.084, 1161.520, -1577.590, 110.916},
    {"Commerce", 1323.900, -1722.260, -89.084, 1440.900, -1577.590, 110.916},
    {"Mulholland", 1357.000, -926.999, -89.084, 1463.900, -768.027, 110.916},
    {"Rodeo", 466.223, -1570.200, -89.084, 558.099, -1385.070, 110.916},
    {"Mulholland", 911.802, -860.619, -89.084, 1096.470, -768.027, 110.916},
    {"Mulholland", 768.694, -954.662, -89.084, 952.604, -860.619, 110.916},
    {"Julius Thruway South", 2377.390, 788.894, -89.084, 2537.390, 897.901, 110.916},
    {"Idlewood", 1812.620, -1852.870, -89.084, 1971.660, -1742.310, 110.916},
    {"Ocean Docks", 2089.000, -2394.330, -89.084, 2201.820, -2235.840, 110.916},
    {"Commerce", 1370.850, -1577.590, -89.084, 1463.900, -1384.950, 110.916},
    {"Julius Thruway North", 2121.400, 2508.230, -89.084, 2237.400, 2663.170, 110.916},
    {"Temple", 1096.470, -1026.330, -89.084, 1252.330, -910.170, 110.916},
    {"Glen Park", 1812.620, -1449.670, -89.084, 1996.910, -1350.720, 110.916},
    {"Easter Bay Airport", -1242.980, -50.096, 0.000, -1213.910, 578.396, 200.000},
    {"Martin Bridge", -222.179, 293.324, 0.000, -122.126, 476.465, 200.000},
    {"The Strip", 2106.700, 1863.230, -89.084, 2162.390, 2202.760, 110.916},
    {"Willowfield", 2541.700, -2059.230, -89.084, 2703.580, -1941.400, 110.916},
    {"Marina", 807.922, -1577.590, -89.084, 926.922, -1416.250, 110.916},
    {"Las Venturas Airport", 1457.370, 1143.210, -89.084, 1777.400, 1203.280, 110.916},
    {"Idlewood", 1812.620, -1742.310, -89.084, 1951.660, -1602.310, 110.916},
    {"Esplanade East", -1580.010, 1025.980, -6.1, -1499.890, 1274.260, 200.000},
    {"Downtown Los Santos", 1370.850, -1384.950, -89.084, 1463.900, -1170.870, 110.916},
    {"The Mako Span", 1664.620, 401.750, 0.000, 1785.140, 567.203, 200.000},
    {"Rodeo", 312.803, -1684.650, -89.084, 422.680, -1501.950, 110.916},
    {"Pershing Square", 1440.900, -1722.260, -89.084, 1583.500, -1577.590, 110.916},
    {"Mulholland", 687.802, -860.619, -89.084, 911.802, -768.027, 110.916},
    {"Gant Bridge", -2741.070, 1490.470, -6.1, -2616.400, 1659.680, 200.000},
    {"Las Colinas", 2185.330, -1154.590, -89.084, 2281.450, -934.489, 110.916},
    {"Mulholland", 1169.130, -910.170, -89.084, 1318.130, -768.027, 110.916},
    {"Julius Thruway North", 1938.800, 2508.230, -89.084, 2121.400, 2624.230, 110.916},
    {"Commerce", 1667.960, -1577.590, -89.084, 1812.620, -1430.870, 110.916},
    {"Rodeo", 72.648, -1544.170, -89.084, 225.165, -1404.970, 110.916},
    {"Roca Escalante", 2536.430, 2202.760, -89.084, 2625.160, 2442.550, 110.916},
    {"Rodeo", 72.648, -1684.650, -89.084, 225.165, -1544.170, 110.916},
    {"Market", 952.663, -1310.210, -89.084, 1072.660, -1130.850, 110.916},
    {"Las Colinas", 2632.740, -1135.040, -89.084, 2747.740, -945.035, 110.916},
    {"Mulholland", 861.085, -674.885, -89.084, 1156.550, -600.896, 110.916},
    {"King's", -2253.540, 373.539, -9.1, -1993.280, 458.411, 200.000},
    {"Redsands East", 1848.400, 2342.830, -89.084, 2011.940, 2478.490, 110.916},
    {"Downtown", -1580.010, 744.267, -6.1, -1499.890, 1025.980, 200.000},
    {"Conference Center", 1046.150, -1804.210, -89.084, 1323.900, -1722.260, 110.916},
    {"Richman", 647.557, -1118.280, -89.084, 787.461, -954.662, 110.916},
    {"Ocean Flats", -2994.490, 277.411, -9.1, -2867.850, 458.411, 200.000},
    {"Greenglass College", 964.391, 930.890, -89.084, 1166.530, 1044.690, 110.916},
    {"Glen Park", 1812.620, -1100.820, -89.084, 1994.330, -973.380, 110.916},
    {"LVA Freight Depot", 1375.600, 919.447, -89.084, 1457.370, 1203.280, 110.916},
    {"Regular Tom", -405.770, 1712.860, -3.0, -276.719, 1892.750, 200.000},
    {"Verona Beach", 1161.520, -1722.260, -89.084, 1323.900, -1577.590, 110.916},
    {"East Los Santos", 2281.450, -1372.040, -89.084, 2381.680, -1135.040, 110.916},
    {"Caligula's Palace", 2137.400, 1703.230, -89.084, 2437.390, 1783.230, 110.916},
    {"Idlewood", 1951.660, -1742.310, -89.084, 2124.660, -1602.310, 110.916},
    {"Pilgrim", 2624.400, 1383.230, -89.084, 2685.160, 1783.230, 110.916},
    {"Idlewood", 2124.660, -1742.310, -89.084, 2222.560, -1494.030, 110.916},
    {"Queens", -2533.040, 458.411, 0.000, -2329.310, 578.396, 200.000},
    {"Downtown", -1871.720, 1176.420, -4.5, -1620.300, 1274.260, 200.000},
    {"Commerce", 1583.500, -1722.260, -89.084, 1758.900, -1577.590, 110.916},
    {"East Los Santos", 2381.680, -1454.350, -89.084, 2462.130, -1135.040, 110.916},
    {"Marina", 647.712, -1577.590, -89.084, 807.922, -1416.250, 110.916},
    {"Richman", 72.648, -1404.970, -89.084, 225.165, -1235.070, 110.916},
    {"Vinewood", 647.712, -1416.250, -89.084, 787.461, -1227.280, 110.916},
    {"East Los Santos", 2222.560, -1628.530, -89.084, 2421.030, -1494.030, 110.916},
    {"Rodeo", 558.099, -1684.650, -89.084, 647.522, -1384.930, 110.916},
    {"Easter Tunnel", -1709.710, -833.034, -1.5, -1446.010, -730.118, 200.000},
    {"Rodeo", 466.223, -1385.070, -89.084, 647.522, -1235.070, 110.916},
    {"Redsands East", 1817.390, 2202.760, -89.084, 2011.940, 2342.830, 110.916},
    {"The Clown's Pocket", 2162.390, 1783.230, -89.084, 2437.390, 1883.230, 110.916},
    {"Idlewood", 1971.660, -1852.870, -89.084, 2222.560, -1742.310, 110.916},
    {"Montgomery Intersection", 1546.650, 208.164, 0.000, 1745.830, 347.457, 200.000},
    {"Willowfield", 2089.000, -2235.840, -89.084, 2201.820, -1989.900, 110.916},
    {"Temple", 952.663, -1130.840, -89.084, 1096.470, -937.184, 110.916},
    {"Prickle Pine", 1848.400, 2553.490, -89.084, 1938.800, 2863.230, 110.916},
    {"Los Santos International", 1400.970, -2669.260, -39.084, 2189.820, -2597.260, 60.916},
    {"Garver Bridge", -1213.910, 950.022, -89.084, -1087.930, 1178.930, 110.916},
    {"Garver Bridge", -1339.890, 828.129, -89.084, -1213.910, 1057.040, 110.916},
    {"Kincaid Bridge", -1339.890, 599.218, -89.084, -1213.910, 828.129, 110.916},
    {"Kincaid Bridge", -1213.910, 721.111, -89.084, -1087.930, 950.022, 110.916},
    {"Verona Beach", 930.221, -2006.780, -89.084, 1073.220, -1804.210, 110.916},
    {"Verdant Bluffs", 1073.220, -2006.780, -89.084, 1249.620, -1842.270, 110.916},
    {"Vinewood", 787.461, -1130.840, -89.084, 952.604, -954.662, 110.916},
    {"Vinewood", 787.461, -1310.210, -89.084, 952.663, -1130.840, 110.916},
    {"Commerce", 1463.900, -1577.590, -89.084, 1667.960, -1430.870, 110.916},
    {"Market", 787.461, -1416.250, -89.084, 1072.660, -1310.210, 110.916},
    {"Rockshore West", 2377.390, 596.349, -89.084, 2537.390, 788.894, 110.916},
    {"Julius Thruway North", 2237.400, 2542.550, -89.084, 2498.210, 2663.170, 110.916},
    {"East Beach", 2632.830, -1668.130, -89.084, 2747.740, -1393.420, 110.916},
    {"Fallow Bridge", 434.341, 366.572, 0.000, 603.035, 555.680, 200.000},
    {"Willowfield", 2089.000, -1989.900, -89.084, 2324.000, -1852.870, 110.916},
    {"Chinatown", -2274.170, 578.396, -7.6, -2078.670, 744.170, 200.000},
    {"El Castillo del Diablo", -208.570, 2337.180, 0.000, 8.430, 2487.180, 200.000},
    {"Ocean Docks", 2324.000, -2145.100, -89.084, 2703.580, -2059.230, 110.916},
    {"Easter Bay Chemicals", -1132.820, -768.027, 0.000, -956.476, -578.118, 200.000},
    {"The Visage", 1817.390, 1703.230, -89.084, 2027.400, 1863.230, 110.916},
    {"Ocean Flats", -2994.490, -430.276, -1.2, -2831.890, -222.589, 200.000},
    {"Richman", 321.356, -860.619, -89.084, 687.802, -768.027, 110.916},
    {"Green Palms", 176.581, 1305.450, -3.0, 338.658, 1520.720, 200.000},
    {"Richman", 321.356, -768.027, -89.084, 700.794, -674.885, 110.916},
    {"Starfish Casino", 2162.390, 1883.230, -89.084, 2437.390, 2012.180, 110.916},
    {"East Beach", 2747.740, -1668.130, -89.084, 2959.350, -1498.620, 110.916},
    {"Jefferson", 2056.860, -1372.040, -89.084, 2281.450, -1210.740, 110.916},
    {"Downtown Los Santos", 1463.900, -1290.870, -89.084, 1724.760, -1150.870, 110.916},
    {"Downtown Los Santos", 1463.900, -1430.870, -89.084, 1724.760, -1290.870, 110.916},
    {"Garver Bridge", -1499.890, 696.442, -179.615, -1339.890, 925.353, 20.385},
    {"Julius Thruway South", 1457.390, 823.228, -89.084, 2377.390, 863.229, 110.916},
    {"East Los Santos", 2421.030, -1628.530, -89.084, 2632.830, -1454.350, 110.916},
    {"Greenglass College", 964.391, 1044.690, -89.084, 1197.390, 1203.220, 110.916},
    {"Las Colinas", 2747.740, -1120.040, -89.084, 2959.350, -945.035, 110.916},
    {"Mulholland", 737.573, -768.027, -89.084, 1142.290, -674.885, 110.916},
    {"Ocean Docks", 2201.820, -2730.880, -89.084, 2324.000, -2418.330, 110.916},
    {"East Los Santos", 2462.130, -1454.350, -89.084, 2581.730, -1135.040, 110.916},
    {"Ganton", 2222.560, -1722.330, -89.084, 2632.830, -1628.530, 110.916},
    {"Avispa Country Club", -2831.890, -430.276, -6.1, -2646.400, -222.589, 200.000},
    {"Willowfield", 1970.620, -2179.250, -89.084, 2089.000, -1852.870, 110.916},
    {"Esplanade North", -1982.320, 1274.260, -4.5, -1524.240, 1358.900, 200.000},
    {"The High Roller", 1817.390, 1283.230, -89.084, 2027.390, 1469.230, 110.916},
    {"Ocean Docks", 2201.820, -2418.330, -89.084, 2324.000, -2095.000, 110.916},
    {"Last Dime Motel", 1823.080, 596.349, -89.084, 1997.220, 823.228, 110.916},
    {"Bayside Marina", -2353.170, 2275.790, 0.000, -2153.170, 2475.790, 200.000},
    {"King's", -2329.310, 458.411, -7.6, -1993.280, 578.396, 200.000},
    {"El Corona", 1692.620, -2179.250, -89.084, 1812.620, -1842.270, 110.916},
    {"Blackfield Chapel", 1375.600, 596.349, -89.084, 1558.090, 823.228, 110.916},
    {"The Pink Swan", 1817.390, 1083.230, -89.084, 2027.390, 1283.230, 110.916},
    {"Julius Thruway West", 1197.390, 1163.390, -89.084, 1236.630, 2243.230, 110.916},
    {"Los Flores", 2581.730, -1393.420, -89.084, 2747.740, -1135.040, 110.916},
    {"The Visage", 1817.390, 1863.230, -89.084, 2106.700, 2011.830, 110.916},
    {"Prickle Pine", 1938.800, 2624.230, -89.084, 2121.400, 2861.550, 110.916},
    {"Verona Beach", 851.449, -1804.210, -89.084, 1046.150, -1577.590, 110.916},
    {"Robada Intersection", -1119.010, 1178.930, -89.084, -862.025, 1351.450, 110.916},
    {"Linden Side", 2749.900, 943.235, -89.084, 2923.390, 1198.990, 110.916},
    {"Ocean Docks", 2703.580, -2302.330, -89.084, 2959.350, -2126.900, 110.916},
    {"Willowfield", 2324.000, -2059.230, -89.084, 2541.700, -1852.870, 110.916},
    {"King's", -2411.220, 265.243, -9.1, -1993.280, 373.539, 200.000},
    {"Commerce", 1323.900, -1842.270, -89.084, 1701.900, -1722.260, 110.916},
    {"Mulholland", 1269.130, -768.027, -89.084, 1414.070, -452.425, 110.916},
    {"Marina", 647.712, -1804.210, -89.084, 851.449, -1577.590, 110.916},
    {"Battery Point", -2741.070, 1268.410, -4.5, -2533.040, 1490.470, 200.000},
    {"The Four Dragons Casino", 1817.390, 863.232, -89.084, 2027.390, 1083.230, 110.916},
    {"Blackfield", 964.391, 1203.220, -89.084, 1197.390, 1403.220, 110.916},
    {"Julius Thruway North", 1534.560, 2433.230, -89.084, 1848.400, 2583.230, 110.916},
    {"Yellow Bell Gol Course", 1117.400, 2723.230, -89.084, 1457.460, 2863.230, 110.916},
    {"Idlewood", 1812.620, -1602.310, -89.084, 2124.660, -1449.670, 110.916},
    {"Redsands West", 1297.470, 2142.860, -89.084, 1777.390, 2243.230, 110.916},
    {"Doherty", -2270.040, -324.114, -1.2, -1794.920, -222.589, 200.000},
    {"Hilltop Farm", 967.383, -450.390, -3.0, 1176.780, -217.900, 200.000},
    {"Las Barrancas", -926.130, 1398.730, -3.0, -719.234, 1634.690, 200.000},
    {"Pirates in Men's Pants", 1817.390, 1469.230, -89.084, 2027.400, 1703.230, 110.916},
    {"City Hall", -2867.850, 277.411, -9.1, -2593.440, 458.411, 200.000},
    {"Avispa Country Club", -2646.400, -355.493, 0.000, -2270.040, -222.589, 200.000},
    {"The Strip", 2027.400, 863.229, -89.084, 2087.390, 1703.230, 110.916},
    {"Hashbury", -2593.440, -222.589, -1.0, -2411.220, 54.722, 200.000},
    {"Los Santos International", 1852.000, -2394.330, -89.084, 2089.000, -2179.250, 110.916},
    {"Whitewood Estates", 1098.310, 1726.220, -89.084, 1197.390, 2243.230, 110.916},
    {"Sherman Reservoir", -789.737, 1659.680, -89.084, -599.505, 1929.410, 110.916},
    {"El Corona", 1812.620, -2179.250, -89.084, 1970.620, -1852.870, 110.916},
    {"Downtown", -1700.010, 744.267, -6.1, -1580.010, 1176.520, 200.000},
    {"Foster Valley", -2178.690, -1250.970, 0.000, -1794.920, -1115.580, 200.000},
    {"Las Payasadas", -354.332, 2580.360, 2.0, -133.625, 2816.820, 200.000},
    {"Valle Ocultado", -936.668, 2611.440, 2.0, -715.961, 2847.900, 200.000},
    {"Blackfield Intersection", 1166.530, 795.010, -89.084, 1375.600, 1044.690, 110.916},
    {"Ganton", 2222.560, -1852.870, -89.084, 2632.830, -1722.330, 110.916},
    {"Easter Bay Airport", -1213.910, -730.118, 0.000, -1132.820, -50.096, 200.000},
    {"Redsands East", 1817.390, 2011.830, -89.084, 2106.700, 2202.760, 110.916},
    {"Esplanade East", -1499.890, 578.396, -79.615, -1339.890, 1274.260, 20.385},
    {"Caligula's Palace", 2087.390, 1543.230, -89.084, 2437.390, 1703.230, 110.916},
    {"Royal Casino", 2087.390, 1383.230, -89.084, 2437.390, 1543.230, 110.916},
    {"Richman", 72.648, -1235.070, -89.084, 321.356, -1008.150, 110.916},
    {"Starfish Casino", 2437.390, 1783.230, -89.084, 2685.160, 2012.180, 110.916},
    {"Mulholland", 1281.130, -452.425, -89.084, 1641.130, -290.913, 110.916},
    {"Downtown", -1982.320, 744.170, -6.1, -1871.720, 1274.260, 200.000},
    {"Hankypanky Point", 2576.920, 62.158, 0.000, 2759.250, 385.503, 200.000},
    {"K.A.C.C. Military Fuels", 2498.210, 2626.550, -89.084, 2749.900, 2861.550, 110.916},
    {"Harry Gold Parkway", 1777.390, 863.232, -89.084, 1817.390, 2342.830, 110.916},
    {"Bayside Tunnel", -2290.190, 2548.290, -89.084, -1950.190, 2723.290, 110.916},
    {"Ocean Docks", 2324.000, -2302.330, -89.084, 2703.580, -2145.100, 110.916},
    {"Richman", 321.356, -1044.070, -89.084, 647.557, -860.619, 110.916},
    {"Randolph Industrial Estate", 1558.090, 596.349, -89.084, 1823.080, 823.235, 110.916},
    {"East Beach", 2632.830, -1852.870, -89.084, 2959.350, -1668.130, 110.916},
    {"Flint Water", -314.426, -753.874, -89.084, -106.339, -463.073, 110.916},
    {"Blueberry", 19.607, -404.136, 3.8, 349.607, -220.137, 200.000},
    {"Linden Station", 2749.900, 1198.990, -89.084, 2923.390, 1548.990, 110.916},
    {"Glen Park", 1812.620, -1350.720, -89.084, 2056.860, -1100.820, 110.916},
    {"Downtown", -1993.280, 265.243, -9.1, -1794.920, 578.396, 200.000},
    {"Redsands West", 1377.390, 2243.230, -89.084, 1704.590, 2433.230, 110.916},
    {"Richman", 321.356, -1235.070, -89.084, 647.522, -1044.070, 110.916},
    {"Gant Bridge", -2741.450, 1659.680, -6.1, -2616.400, 2175.150, 200.000},
    {"Lil' Probe Inn", -90.218, 1286.850, -3.0, 153.859, 1554.120, 200.000},
    {"Flint Intersection", -187.700, -1596.760, -89.084, 17.063, -1276.600, 110.916},
    {"Las Colinas", 2281.450, -1135.040, -89.084, 2632.740, -945.035, 110.916},
    {"Sobell Rail Yards", 2749.900, 1548.990, -89.084, 2923.390, 1937.250, 110.916},
    {"The Emerald Isle", 2011.940, 2202.760, -89.084, 2237.400, 2508.230, 110.916},
    {"El Castillo del Diablo", -208.570, 2123.010, -7.6, 114.033, 2337.180, 200.000},
    {"Santa Flora", -2741.070, 458.411, -7.6, -2533.040, 793.411, 200.000},
    {"Playa del Seville", 2703.580, -2126.900, -89.084, 2959.350, -1852.870, 110.916},
    {"Market", 926.922, -1577.590, -89.084, 1370.850, -1416.250, 110.916},
    {"Queens", -2593.440, 54.722, 0.000, -2411.220, 458.411, 200.000},
    {"Pilson Intersection", 1098.390, 2243.230, -89.084, 1377.390, 2507.230, 110.916},
    {"Spinybed", 2121.400, 2663.170, -89.084, 2498.210, 2861.550, 110.916},
    {"Pilgrim", 2437.390, 1383.230, -89.084, 2624.400, 1783.230, 110.916},
    {"Blackfield", 964.391, 1403.220, -89.084, 1197.390, 1726.220, 110.916},
    {"'The Big Ear'", -410.020, 1403.340, -3.0, -137.969, 1681.230, 200.000},
    {"Dillimore", 580.794, -674.885, -9.5, 861.085, -404.790, 200.000},
    {"El Quebrados", -1645.230, 2498.520, 0.000, -1372.140, 2777.850, 200.000},
    {"Esplanade North", -2533.040, 1358.900, -4.5, -1996.660, 1501.210, 200.000},
    {"Easter Bay Airport", -1499.890, -50.096, -1.0, -1242.980, 249.904, 200.000},
    {"Fisher's Lagoon", 1916.990, -233.323, -100.000, 2131.720, 13.800, 200.000},
    {"Mulholland", 1414.070, -768.027, -89.084, 1667.610, -452.425, 110.916},
    {"East Beach", 2747.740, -1498.620, -89.084, 2959.350, -1120.040, 110.916},
    {"San Andreas Sound", 2450.390, 385.503, -100.000, 2759.250, 562.349, 200.000},
    {"Shady Creeks", -2030.120, -2174.890, -6.1, -1820.640, -1771.660, 200.000},
    {"Market", 1072.660, -1416.250, -89.084, 1370.850, -1130.850, 110.916},
    {"Rockshore West", 1997.220, 596.349, -89.084, 2377.390, 823.228, 110.916},
    {"Prickle Pine", 1534.560, 2583.230, -89.084, 1848.400, 2863.230, 110.916},
    {"Easter Basin", -1794.920, -50.096, -1.04, -1499.890, 249.904, 200.000},
    {"Leafy Hollow", -1166.970, -1856.030, 0.000, -815.624, -1602.070, 200.000},
    {"LVA Freight Depot", 1457.390, 863.229, -89.084, 1777.400, 1143.210, 110.916},
    {"Prickle Pine", 1117.400, 2507.230, -89.084, 1534.560, 2723.230, 110.916},
    {"Blueberry", 104.534, -220.137, 2.3, 349.607, 152.236, 200.000},
    {"El Castillo del Diablo", -464.515, 2217.680, 0.000, -208.570, 2580.360, 200.000},
    {"Downtown", -2078.670, 578.396, -7.6, -1499.890, 744.267, 200.000},
    {"Rockshore East", 2537.390, 676.549, -89.084, 2902.350, 943.235, 110.916},
    {"San Fierro Bay", -2616.400, 1501.210, -3.0, -1996.660, 1659.680, 200.000},
    {"Paradiso", -2741.070, 793.411, -6.1, -2533.040, 1268.410, 200.000},
    {"The Camel's Toe", 2087.390, 1203.230, -89.084, 2640.400, 1383.230, 110.916},
    {"Old Venturas Strip", 2162.390, 2012.180, -89.084, 2685.160, 2202.760, 110.916},
    {"Juniper Hill", -2533.040, 578.396, -7.6, -2274.170, 968.369, 200.000},
    {"Juniper Hollow", -2533.040, 968.369, -6.1, -2274.170, 1358.900, 200.000},
    {"Roca Escalante", 2237.400, 2202.760, -89.084, 2536.430, 2542.550, 110.916},
    {"Julius Thruway East", 2685.160, 1055.960, -89.084, 2749.900, 2626.550, 110.916},
    {"Verona Beach", 647.712, -2173.290, -89.084, 930.221, -1804.210, 110.916},
    {"Foster Valley", -2178.690, -599.884, -1.2, -1794.920, -324.114, 200.000},
    {"Arco del Oeste", -901.129, 2221.860, 0.000, -592.090, 2571.970, 200.000},
    {"Fallen Tree", -792.254, -698.555, -5.3, -452.404, -380.043, 200.000},
    {"The Farm", -1209.670, -1317.100, 114.981, -908.161, -787.391, 251.981},
    {"The Sherman Dam", -968.772, 1929.410, -3.0, -481.126, 2155.260, 200.000},
    {"Esplanade North", -1996.660, 1358.900, -4.5, -1524.240, 1592.510, 200.000},
    {"Financial", -1871.720, 744.170, -6.1, -1701.300, 1176.420, 300.000},
    {"Garcia", -2411.220, -222.589, -1.14, -2173.040, 265.243, 200.000},
    {"Montgomery", 1119.510, 119.526, -3.0, 1451.400, 493.323, 200.000},
    {"Creek", 2749.900, 1937.250, -89.084, 2921.620, 2669.790, 110.916},
    {"Los Santos International", 1249.620, -2394.330, -89.084, 1852.000, -2179.250, 110.916},
    {"Santa Maria Beach", 72.648, -2173.290, -89.084, 342.648, -1684.650, 110.916},
    {"Mulholland Intersection", 1463.900, -1150.870, -89.084, 1812.620, -768.027, 110.916},
    {"Angel Pine", -2324.940, -2584.290, -6.1, -1964.220, -2212.110, 200.000},
    {"Verdant Meadows", 37.032, 2337.180, -3.0, 435.988, 2677.900, 200.000},
    {"Octane Springs", 338.658, 1228.510, 0.000, 664.308, 1655.050, 200.000},
    {"Come-A-Lot", 2087.390, 943.235, -89.084, 2623.180, 1203.230, 110.916},
    {"Redsands West", 1236.630, 1883.110, -89.084, 1777.390, 2142.860, 110.916},
    {"Santa Maria Beach", 342.648, -2173.290, -89.084, 647.712, -1684.650, 110.916},
    {"Verdant Bluffs", 1249.620, -2179.250, -89.084, 1692.620, -1842.270, 110.916},
    {"Las Venturas Airport", 1236.630, 1203.280, -89.084, 1457.370, 1883.110, 110.916},
    {"Flint Range", -594.191, -1648.550, 0.000, -187.700, -1276.600, 200.000},
    {"Verdant Bluffs", 930.221, -2488.420, -89.084, 1249.620, -2006.780, 110.916},
    {"Palomino Creek", 2160.220, -149.004, 0.000, 2576.920, 228.322, 200.000},
    {"Ocean Docks", 2373.770, -2697.090, -89.084, 2809.220, -2330.460, 110.916},
    {"Easter Bay Airport", -1213.910, -50.096, -4.5, -947.980, 578.396, 200.000},
    {"Whitewood Estates", 883.308, 1726.220, -89.084, 1098.310, 2507.230, 110.916},
    {"Calton Heights", -2274.170, 744.170, -6.1, -1982.320, 1358.900, 200.000},
    {"Easter Basin", -1794.920, 249.904, -9.1, -1242.980, 578.396, 200.000},
    {"Los Santos Inlet", -321.744, -2224.430, -89.084, 44.615, -1724.430, 110.916},
    {"Doherty", -2173.040, -222.589, -1.0, -1794.920, 265.243, 200.000},
    {"Mount Chiliad", -2178.690, -2189.910, -47.917, -2030.120, -1771.660, 576.083},
    {"Fort Carson", -376.233, 826.326, -3.0, 123.717, 1220.440, 200.000},
    {"Foster Valley", -2178.690, -1115.580, 0.000, -1794.920, -599.884, 200.000},
    {"Ocean Flats", -2994.490, -222.589, -1.0, -2593.440, 277.411, 200.000},
    {"Fern Ridge", 508.189, -139.259, 0.000, 1306.660, 119.526, 200.000},
    {"Bayside", -2741.070, 2175.150, 0.000, -2353.170, 2722.790, 200.000},
    {"Las Venturas Airport", 1457.370, 1203.280, -89.084, 1777.390, 1883.110, 110.916},
    {"Blueberry Acres", -319.676, -220.137, 0.000, 104.534, 293.324, 200.000},
    {"Palisades", -2994.490, 458.411, -6.1, -2741.070, 1339.610, 200.000},
    {"North Rock", 2285.370, -768.027, 0.000, 2770.590, -269.740, 200.000},
    {"Hunter Quarry", 337.244, 710.840, -115.239, 860.554, 1031.710, 203.761},
    {"Los Santos International", 1382.730, -2730.880, -89.084, 2201.820, -2394.330, 110.916},
    {"Missionary Hill", -2994.490, -811.276, 0.000, -2178.690, -430.276, 200.000},
    {"San Fierro Bay", -2616.400, 1659.680, -3.0, -1996.660, 2175.150, 200.000},
    {"Restricted Area", -91.586, 1655.050, -50.000, 421.234, 2123.010, 250.000},
    {"Mount Chiliad", -2997.470, -1115.580, -47.917, -2178.690, -971.913, 576.083},
    {"Mount Chiliad", -2178.690, -1771.660, -47.917, -1936.120, -1250.970, 576.083},
    {"Easter Bay Airport", -1794.920, -730.118, -3.0, -1213.910, -50.096, 200.000},
    {"The Panopticon", -947.980, -304.320, -1.1, -319.676, 327.071, 200.000},
    {"Shady Creeks", -1820.640, -2643.680, -8.0, -1226.780, -1771.660, 200.000},
    {"Back o Beyond", -1166.970, -2641.190, 0.000, -321.744, -1856.030, 200.000},
    {"Mount Chiliad", -2994.490, -2189.910, -47.917, -2178.690, -1115.580, 576.083},
    {"Tierra Robada", -1213.910, 596.349, -242.990, -480.539, 1659.680, 900.000},
    {"Flint County", -1213.910, -2892.970, -242.990, 44.615, -768.027, 900.000},
    {"Whetstone", -2997.470, -2892.970, -242.990, -1213.910, -1115.580, 900.000},
    {"Bone County", -480.539, 596.349, -242.990, 869.461, 2993.870, 900.000},
    {"Tierra Robada", -2997.470, 1659.680, -242.990, -480.539, 2993.870, 900.000},
    {"San Fierro", -2997.470, -1115.580, -242.990, -1213.910, 1659.680, 900.000},
    {"Las Venturas", 869.461, 596.349, -242.990, 2997.060, 2993.870, 900.000},
    {"Red County", -1213.910, -768.027, -242.990, 2997.060, 596.349, 900.000},
    {"Los Santos", 44.615, -2892.970, -242.990, 2997.060, -768.027, 900.000}}
    for i, v in ipairs(streets) do
        if (x >= v[2]) and (y >= v[3]) and (z >= v[4]) and (x <= v[5]) and (y <= v[6]) and (z <= v[7]) then
            return v[1]
        end
    end
    return "Неизвестно"
end

function registerCommandsBinder()
    for k, v in pairs(commands) do
        if sampIsChatCommandDefined(v.cmd) then sampUnregisterChatCommand(v.cmd) end
        sampRegisterChatCommand(v.cmd, function(pam)
            lua_thread.create(function()
                local params = string.split(pam, "%s", v.params)
                local cmdtext = v.text
                local paramtext = ""
                if #params < v.params then
                    for i = 1, v.params do
                        paramtext = paramtext .. "[параметр №"..i.."] "
                    end
                    sampAddChatMessage(scriptname.. "{FFFFFF}Введите: /"..v.cmd.." "..paramtext, 0x7FFF00)
                else
                    for line in cmdtext:gmatch('[^\r\n]+') do
                        if line:match("^{wait%:%d+}$") then
                            wait(line:match("^%{wait%:(%d+)}$"))
                        elseif line:match("^{screen}$") then
                            screen()
                        else
                            local bIsEnter = string.match(line, "^{noe}(.+)") ~= nil
                            local bIsF6 = string.match(line, "^{f6}(.+)") ~= nil
                            local x,y,z = getCharCoordinates(PLAYER_PED)
                            local naprav = ""
                            if getCharHeading(playerPed) >= 337.5 or getCharHeading(playerPed) <= 22.5 then naprav = "Северное" end
                            if getCharHeading(playerPed) > 22.5 and getCharHeading(playerPed) <= 67.5 then naprav = "Северо-западное" end
                            if getCharHeading(playerPed) > 67.5 and getCharHeading(playerPed) <= 112.5 then naprav = "Западное" end
                            if getCharHeading(playerPed) > 112.5 and getCharHeading(playerPed) <= 157.5 then naprav = "Юго-западное" end
                            if getCharHeading(playerPed) > 157.5 and getCharHeading(playerPed) <= 202.5 then naprav = "Южное" end
                            if getCharHeading(playerPed) > 202.5 and getCharHeading(playerPed) <= 247.5 then naprav = "Юго-восточное" end
                            if getCharHeading(playerPed) > 247.5 and getCharHeading(playerPed) <= 292.5 then naprav = "Восточное" end
                            if getCharHeading(playerPed) > 292.5 and getCharHeading(playerPed) <= 337.5 then naprav = "Северо-восточное" end
                            
                            local keys = {
                                ["{param:"..i.."}"] = params[i],
                                ["{f6}"] = "",
                                ["{noe}"] = "",
                                ["{myid}"] = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)),
                                ["{tag}"] = config.main.tar,
                                ["{kv}"] = kvadratb(),
                                ["{targetid}"] = targetid,
                                ["{naprav}"] = naprav,
                                ["{location}"] = calculateZone(x,y,z),
                                ["{targetrpnick}"] = sampGetPlayerNicknameForBinder(targetid):gsub('_', ' '),
                                ["{myrpnick}"] = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))):gsub("_", " "),
                                ["{rang}"] = rang,
                                ["{time}"] = os.date('%H:%M:%S'),
                                ["{data}"] = os.date('%d.%m.%Y'),
                                ["{frak}"] = frak,
                                ["{dl}"] = mcid
                            }
                            for k1, v1 in pairs(keys) do
                                line = line:gsub(k1, v1)
                            end
                            for i = 1, v.params do
                                keys["{param:"..i.."}"] = params[i]
                                line = line:gsub('{param:'..i..'}', keys["{param:"..i.."}"])
                            end

                            if not bIsEnter then
                                if bIsF6 then
                                    sampProcessChatInput(line)
                                else
                                    sampSendChat(line)
                                end
                            else
                                sampSetChatInputText(line)
                                sampSetChatInputEnabled(true)
                            end
                        end
                    end
                end
            end)
        end)
    end
end

function split(inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            t[i] = str
            i = i + 1
    end
    return t
end

function getAmmoInClip()
    local struct = getCharPointer(PLAYER_PED)
    local prisv = struct + 0x0718
    local prisv = memory.getint8(prisv, false)
    local prisv = prisv * 0x1C
    local prisv2 = struct + 0x5A0
    local prisv2 = prisv2 + prisv
    local prisv2 = prisv2 + 0x8
    local ammo = memory.getint32(prisv2, false)
    return ammo
end

function string.split(inputstr, sep, limit)
    if limit == nil then limit = 0 end
    if sep == nil then sep = "%s" end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        if i >= limit and limit > 0 then
            if t[i] == nil then
                t[i] = ""..str
            else
                t[i] = t[i]..sep..str
            end
        else
            t[i] = str
            i = i + 1
        end
    end
    return t
end 

function ntest()
        local mynick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
        setClipboardText(mynick:gsub("_", " "))
        notf.addNotification(sampGetPlayerNickname(mynick):gsub("_", " "), 10, 2)
        notf.addNotification(string.format('Вы успешно доставили боеприпасы.\n Сделать доклад?'), 10, 2)
end

function registerHotKey()
    oopdabind = rkeys.registerHotKey(config_keys.oopda.v, true, oopdakey)
    oopnetbind = rkeys.registerHotKey(config_keys.oopnet.v, true, oopnetkey)
    oopnetbind = rkeys.registerHotKey(config_keys.vzaimkey.v, true, vzaimk)
    cuffbind = rkeys.registerHotKey(config_keys.cuffkey.v, true, cuffk)
    followbind = rkeys.registerHotKey(config_keys.followkey.v, true, followk)
    uncuffbind = rkeys.registerHotKey(config_keys.uncuffkey.v, true, uncuffk)
    sirenbind = rkeys.registerHotKey(config_keys.sirenkey.v, true, sirenk)
end


function oopdakey()
    if napali then
        local myX, myY, myZ = getCharCoordinates(PLAYER_PED)
        napali = false
        notf.addNotification(string.format('Доклад выполнен.'), 10, 2)
        if frak == "LVA" then
            if(getDistanceBetweenCoords3d(myX, myY, myZ, 140.6645,1840.9218,17.6406) < 40) then  return sampSendChat(string.format("/r ".. config.main.tar .." SOS Ангар-1! Запрашиваю подкрепление!")) end--HANGAR-1
            if(getDistanceBetweenCoords3d(myX, myY, myZ, 288.9628,1973.2323,17.1793) < 55) then return sampSendChat(string.format("/r ".. config.main.tar .." SOS Ангар-2! Запрашиваю подкрепление!")) end--HANGAR_2
            if(getDistanceBetweenCoords3d(myX, myY, myZ, 345.8661,1928.4232,17.6665) < 40) then return sampSendChat(string.format("/r ".. config.main.tar .." SOS Главный Склад! Запрашиваю подкрепление!")) end--GS
            if(getDistanceBetweenCoords3d(myX, myY, myZ, 343.9599,1797.7920,18.3571) < 35) then return sampSendChat(string.format("/r ".. config.main.tar .." SOS КПП-2! Запрашиваю подкрепление!")) end--KPP-2
            if(getDistanceBetweenCoords3d(myX, myY, myZ, 135.0208,1940.1204,19.3037) < 40) then return sampSendChat(string.format("/r ".. config.main.tar .." SOS КПП-1! Запрашиваю подкрепление!")) end--KPP-1
            if(getDistanceBetweenCoords3d(myX, myY, myZ, 213.0892,1913.8396,17.6406) < 35) then return sampSendChat(string.format("/r ".. config.main.tar .." SOS Плац! Запрашиваю подкрепление!")) end--plac
            if(getDistanceBetweenCoords3d(myX, myY, myZ, 236.7430,1821.7272,17.6481) < 40) then return sampSendChat(string.format("/r ".. config.main.tar .." SOS Хамеры! Запрашиваю подкрепление!")) end--гаражи
            if(getDistanceBetweenCoords3d(myX, myY, myZ, 232.1107,1970.2271,17.6646) < 30) then return sampSendChat(string.format("/r ".. config.main.tar .." SOS ВП! Запрашиваю подкрепление!")) end--ВП
        end
        if frak == "SFA" then
            if(getDistanceBetweenCoords3d(myX, myY, myZ, -1290.4391, 501.9360, 18.2344) < 15 or getDistanceBetweenCoords3d(myX, myY, myZ, -1345.8871, 508.6448, 18.2344) < 15 or getDistanceBetweenCoords3d(myX, myY, myZ, -1432.8151, 502.3309, 18.2294) < 15) then  return sampSendChat(string.format("/r ".. config.main.tar .." SOS Палуба! Запрашиваю подкрепление!")) end--HANGAR-1
            if(getDistanceBetweenCoords3d(myX, myY, myZ, -1334.9775, 477.4629, 9.0644) < 30) then return sampSendChat(string.format("/r ".. config.main.tar .." SOS Трап! Запрашиваю подкрепление!")) end--HANGAR_2
            if(getDistanceBetweenCoords3d(myX, myY, myZ, -1394.4912, 390.0138, 15.7105) < 100) then return sampSendChat(string.format("/r ".. config.main.tar .." SOS Доки! Запрашиваю подкрепление!")) end--GS
            if(getDistanceBetweenCoords3d(myX, myY, myZ, -1528.6237, 475.8205, 7.1875) < 35) then return sampSendChat(string.format("/r ".. config.main.tar .." SOS КПП! Запрашиваю подкрепление!")) end--KPP-2
            if(getDistanceBetweenCoords3d(myX, myY, myZ, -1424.8307, 499.0334, 3.0391) < 40) then return sampSendChat(string.format("/r ".. config.main.tar .." SOS Трюм корабля! Запрашиваю подкрепление!")) end--KPP-1
            if(getDistanceBetweenCoords3d(myX, myY, myZ, -1672.0392, 261.6066, 7.1875) < 35) then return sampSendChat(string.format("/r ".. config.main.tar .." SOS Дозор! Запрашиваю подкрепление!")) end--plac
            if(getDistanceBetweenCoords3d(myX, myY, myZ, -1276.3689, 459.0302, 7.1875) < 35) then return sampSendChat(string.format("/r ".. config.main.tar .." SOS Парковка! Запрашиваю подкрепление!")) end--plac
            if(getDistanceBetweenCoords3d(myX, myY, myZ, 1528.0614,1476.6326,10.9627) < 15) then return sampSendChat(string.format("/r ".. config.main.tar .." SOS Казарма! Запрашиваю подкрепление!")) end--plac
            if(getDistanceBetweenCoords3d(myX, myY, myZ, -1325.9626,499.3327,27.8561) < 5) then return sampSendChat(string.format("/r ".. config.main.tar .." SOS Рубка! Запрашиваю подкрепление!")) end--plac
        end
        if(getDistanceBetweenCoords3d(myX, myY, myZ, 2759.3892,-2448.5608,13.5241) < 220) then return sampSendChat(string.format("/r ".. config.main.tar .." SOS Порт ЛС! Запрашиваю подкрепление!")) end--ВП
        return sampSendChat(string.format("/r ".. config.main.tar .." SOS в " .. kvadratb() .. "! Запрашиваю подкрепление!"))
    end
    if zaprfur then
        local idcar =  select(2, sampGetVehicleIdByCarHandle(storeCarCharIsInNoSave(PLAYER_PED)))
        zaprfur = false
        notf.addNotification(string.format('Доклад выполнен.'), 10, 2) --678 679
        if idcar == 225 or idcar == 226 or idcar == 227 then sampSendChat(string.format("/r ".. config.main.tar .." Взял фуру из A-1.")) end
        if idcar == 228 or idcar == 229 or idcar == 230 then sampSendChat(string.format("/r ".. config.main.tar .." Взял фуру из A-2.")) end
        if idcar == 678 or idcar == 679 or idcar == 55 or idcar == 56 or idcar == 57 or idcar == 677 then sampSendChat(string.format("/r ".. config.main.tar .." Борт №".. myid .. " Приступаю к поставкам на ГС Army SF. Направляюсь к подлодке.")) end
    end
    if zaprfur_boat then 
        local idcar =  select(2, sampGetVehicleIdByCarHandle(storeCarCharIsInNoSave(PLAYER_PED)))
        zaprfur_boat = false
        notf.addNotification(string.format('Доклад выполнен.'), 10, 2) --678 679
        if idcar == 678 or idcar == 679 or idcar == 55 or idcar == 56 or idcar == 57 or idcar == 677 then sampSendChat(string.format("/r ".. config.main.tar .." Борт №".. myid .. " Приступаю к поставкам на ГС Army SF. Направляюсь к подлодке.")) end
    end
    if opyatstat then
        if postavkisfa == true then 
            postavkisfa = false
            opyatstat = false
            local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
            return sampSendChat(string.format("/r ".. config.main.tar .." Борт №".. myid .. " Приступаю к поставкам на ГС Army LV. Направляюсь на сухогруз."))
        end
        if postavkist == true then 
            postavkist = false
            opyatstat = false
            return sampSendChat(string.format("/r ".. config.main.tar .." Приступаю к поставкам на LSA. Направляюсь на сухогруз."))
        end
        if loadst == true then 
            loadst = false
            opyatstat = false
            return sampSendChat(string.format("/r ".. config.main.tar .." Загрузился на сухогрузе. Направляюсь в порт."))
        end
        if loadstsfa == true then 
            loadstsfa = false
            opyatstat = false
            local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
            return sampSendChat(string.format("/r ".. config.main.tar .." Борт №" .. myid .. ". Загрузился на сухогрузе. Направляюсь в Army LV."))
        end
        if loadmatssfa_podlodka then 
            opyatstat = false;
            loadmatssfa_podlodka = false
            return sampSendChat(string.format("/r ".. config.main.tar .." Борт №" .. myid .. ". Загрузился на подлодке. Направляюсь на базу."))
        end
        if zaprfursfa_boat == true then
            opyatstat = false;
            zaprfursfa_boat = false
            local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
            unload = false
            return sampSendChat(string.format("/r ".. config.main.tar .." Борт №" .. myid .. ". Разгрузился на ГС Army SF %.1f/300.", mats/1000))
        end
        if zaprfursfa == true then
            zaprfursfa = false
            local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
            unload = false
            return sampSendChat(string.format("/r ".. config.main.tar .." Борт №" .. myid .. ". Разгрузился на ГС Army LV %.1f/300.", mats/1000))
        end
        if base == 'LSA' then sampSendChat(string.format("/r ".. config.main.tar .." Разгрузился в %s. Склад: %.1f/600", base, mats/1000)) unload = false
        else sampSendChat(string.format("/r ".. config.main.tar .." Разгрузился в %s. Склад: %.1f/200", base, mats/1000)) end
        opyatstat = false
    end
end

function oopnetkey()
    if napali then return notf.addNotification(string.format('Вы отменили доклад.'), 10, 2) end
    if opyatstat then
        opyatstat = false
        unload = false
        notf.addNotification(string.format('Вы отменили доклад.'), 10, 2)
    end
    if zaprfur then notf.addNotification(string.format('Вы отменили доклад.'), 10, 2) zaprfur = false end
    if zaprfur_boat then notf.addNotification(string.format('Вы отменили доклад.'), 10, 2) zaprfur_boat = false end
    if loadmatssfa_podlodka then notf.addNotification(string.format('Вы отменили доклад.'), 10, 2) loadmatssfa_podlodka = false end
end

function blg(pam)
    local id, frack, pric = pam:match('(%d+) (%a+) (.+)')
    if id and frack and pric and sampIsPlayerConnected(id) then
        name = sampGetPlayerNickname(id)
        rpname = name:gsub('_', ' ')
        sampSendChat(string.format("/d %s, благодарю %s за %s. Цените", frack, rpname, pric))
    else
        sampAddChatMessage(scriptname.. '| {FFFFFF}Введите: /blag [id] [Фракция] [Причина]', 0x7FFF00)
    end
end

function mon(pam)
    local monitoring = tonumber(pam)
    if monitoring ~= nil and monitoring == 1 then
        deleteCheckpoint(checkpoint)
        local x,y,z = getCharCoordinates(PLAYER_PED)
        local result, text = Search3Dtext(x,y,z, 400, "Склад")
        if text ~= nil and result == true and text:find('Склад') then
            local temp = split(text, "\n")
            for k, val in pairs(temp) do
                monikQuant[k] = val
            end
            if monikQuant[6] == nil then
            else
                monikQuantNum = {}
                for i = 1, table.getn(monikQuant) do
                    number1, number2, monikQuantNum[i] = string.match(monikQuant[i],"(%d+)[^%d]+(%d+)[^%d]+(%d+)")
                    monikQuantNum[i] = monikQuantNum[i]/1000
                end
                sampAddChatMessage(scriptname.. "| {FFFFFF}Мониторинг: LSPD - "..monikQuantNum[1].." | SFPD - "..monikQuantNum[2].." | LVPD - "..monikQuantNum[3].." | FBI - "..monikQuantNum[6].."", 0x7FFF00)
            end
        else
            sampAddChatMessage(scriptname.. "| {FFFFFF}Вы должны находиться на территории Army LV", 0x7FFF00)
        end
    end
    if monitoring == 2 then
        deleteCheckpoint(checkpoint)
        local x,y,z = getCharCoordinates(PLAYER_PED)
        local result, text = Search3Dtext(x,y,z, 400, "Склад")
        if text ~= nil and result == true and text:find('Склад') then
            local temp = split(text, "\n")
            for k, val in pairs(temp) do
                monikQuant[k] = val
            end
            if monikQuant[6] == nil then
            else
                monikQuantNum = {}
                for i = 1, table.getn(monikQuant) do
                    number1, number2, monikQuantNum[i] = string.match(monikQuant[i],"(%d+)[^%d]+(%d+)[^%d]+(%d+)")
                    monikQuantNum[i] = monikQuantNum[i]/1000
                end
                sampSendChat(("/r %s Мониторинг: LSPD - "..monikQuantNum[1].." | SFPD - "..monikQuantNum[2].." | LVPD - "..monikQuantNum[3].." | FBI - "..monikQuantNum[6]..""):format(config.main.tar))
            end
        else
            sampAddChatMessage(scriptname.. "| {FFFFFF}Вы должны находиться на территории Army LV", 0x7FFF00)
        end
    end
end

function patch_samp_time_set(enable)
    if enable and default == nil then
        default = readMemory(sampGetBase() + 0x9C0A0, 4, true)
        writeMemory(sampGetBase() + 0x9C0A0, 4, 0x000008C2, true)
    elseif enable == false and default ~= nil then
        writeMemory(sampGetBase() + 0x9C0A0, 4, default, true)
        default = nil
    end
end

function clearchat()
    local memory = require "memory"
    memory.fill(sampGetChatInfoPtr() + 306, 0x0, 25200)
    memory.write(sampGetChatInfoPtr() + 306, 25562, 4, 0x0)
    memory.write(sampGetChatInfoPtr() + 0x63DA, 1, 1)
    sampAddChatMessage(scriptname.. "| {FFFFFF}Чат успешно очищен!", 0x7FFF00)
end

function stweather(param)
    local weather = tonumber(param)
    if weather ~= nil and weather >= 0 and weather <= 45 then
        forceWeatherNow(weather)
        sampAddChatMessage(scriptname..'| {FFFFFF}Погода установлена. Значение: '..weather, 0x7FFF00)
    else
        sampAddChatMessage(scriptname.. '| {FFFFFF}Погода не указана. Диапазон значений от 0 до 45.', 0x7FFF00)
    end
end

function sttime(param)
    local hour = tonumber(param)
    if hour ~= nil and hour >= 0 and hour <= 23 then
        time = hour
        patch_samp_time_set(true)
        if time then
            setTimeOfDay(time, 0)
            sampAddChatMessage(scriptname.. '| {FFFFFF}Время успешно установлено. Значение: '..time, 0x7FFF00)
        end
    else
        sampAddChatMessage(scriptname.. '| {FFFFFF}Время указано неверно. Диапазон значений от 0 до 23.', 0x7FFF00)
        patch_samp_time_set(false)
        time = nil
    end
end

function fmask()
    lua_thread.create(function()
        local maskF
        maskF = 0
        sampSendChat('/me достал с кармана маску')
        wait(1000)
        sampSendChat('/items')
        wait(1000)
        for i=2000,2900 do
            local model, _, _, _, _, _, _ = sampTextdrawGetModelRotationZoomVehColor(i)
            if maskF == 0 then
                if model == 19038 or model == 19036 or model == 18919 or model == 18912 or model == 18913 or model == 18914 or model == 18915 or model == 18916 or model == 18917 or model == 18918 or model == 18911 or model == 18920 or model == 19037 then sampSendClickTextdraw(i) maskF = 1 end
            end
        end 
        wait(500)
        sampSetCurrentDialogListItem(1)
        sampCloseCurrentDialogWithButton(1) 
        sampSendClickTextdraw(463)
    end)
end

function imask()
    lua_thread.create(function()
        local maskF
        maskF = 0
        sampSendChat('/me достал с кармана маску')
        wait(1000)
        sampSendChat('/items')
        wait(1000)
        for i=2000,2900 do
            local model, _, _, _, _, _, _ = sampTextdrawGetModelRotationZoomVehColor(i)
            if maskF == 0 then
                if model == 19038 or model == 19036 or model == 18919 or model == 18912 or model == 18913 or model == 18914 or model == 18915 or model == 18916 or model == 18917 or model == 18918 or model == 18911 or model == 18920 or model == 19037 then sampSendClickTextdraw(i) maskF = 1 end
            end
        end 
        wait(500)
        sampSetCurrentDialogListItem(1)
        sampCloseCurrentDialogWithButton(1) 
        sampSendClickTextdraw(463)
        wait(500)
        sampSendChat('/mask')
        wait(1000)
        sampSendChat('/clist 0')
        wait(1000)
        sampSendChat('/do Маска на лице, опозновательных знаков нет, личность не опознать.')
    end)
end



function dmb()
    lua_thread.create(function()
        if sampIsDialogActive() then
            if sampIsDialogClientside() then
                tMembers = {}
                status = true
                sampSendChat('/members')
                while not gotovo do wait(0) end
                memw.v = true
                gotovo = false
                status = false
            end
        else
            tMembers = {}
            status = true
            sampSendChat('/members')
            while not gotovo do wait(0) end
            memw.v = true
            gotovo = false
            status = false
        end
    end)
end

function Search3Dtext(x, y, z, radius, patern)
    local text = ""
    local color = 0
    local posX = 0.0
    local posY = 0.0
    local posZ = 0.0
    local distance = 0.0
    local ignoreWalls = false
    local player = -1
    local vehicle = -1
    local result = false

    for id = 0, 2048 do
        if sampIs3dTextDefined(id) then
            local text2, color2, posX2, posY2, posZ2, distance2, ignoreWalls2, player2, vehicle2 = sampGet3dTextInfoById(id)
            if getDistanceBetweenCoords3d(x, y, z, posX2, posY2, posZ2) < radius then
                if string.len(patern) ~= 0 then
                    if string.match(text2, patern) ~= nil then result = true end
                else
                    result = false
                end
                if result then
                    text = text2
                    color = color2
                    posX = posX2
                    posY = posY2
                    posZ = posZ2
                    distance = distance2
                    ignoreWalls = ignoreWalls2
                    player = player2
                    vehicle = vehicle2
                    radius = getDistanceBetweenCoords3d(x, y, z, posX, posY, posZ)
                end
            end
        end
    end
    return result, text, color, posX, posY, posZ, distance, ignoreWalls, player, vehicle
end

function Player:new(id, sRang, iRang, status, invite, afk, sec, nick, dist)
    local obj = {
        id = id,
        nickname = nick,
        iRang = tonumber(iRang),
        sRang = u8(sRang),
        status = u8(status),
        invite = invite,
        afk = afk,
        sec = tonumber(sec),
        dist = tonumber(getDistanceToPlayer(id))
    }

    setmetatable(obj, self)
    self.__index = self

    return obj
end

function sampGetDistanceLocalPlayerToPlayerByPlayerId(playerId)
    local playerId = tonumber(playerId, 10)
    if not playerId then return end
    local res, han = sampGetCharHandleBySampPlayerId(playerId)
    if res then
        local x, y, z = getCharCoordinates(playerPed)
        local xx, yy, zz = getCharCoordinates(han)
        return true, getDistanceBetweenCoords3d(x, y, z, xx, yy, zz)
    end
    return false
end

local russian_characters = {
    [168] = 'Ё', [184] = 'ё', [192] = 'А', [193] = 'Б', [194] = 'В', [195] = 'Г', [196] = 'Д', [197] = 'Е', [198] = 'Ж', [199] = 'З', [200] = 'И', [201] = 'Й', [202] = 'К', [203] = 'Л', [204] = 'М', [205] = 'Н', [206] = 'О', [207] = 'П', [208] = 'Р', [209] = 'С', [210] = 'Т', [211] = 'У', [212] = 'Ф', [213] = 'Х', [214] = 'Ц', [215] = 'Ч', [216] = 'Ш', [217] = 'Щ', [218] = 'Ъ', [219] = 'Ы', [220] = 'Ь', [221] = 'Э', [222] = 'Ю', [223] = 'Я', [224] = 'а', [225] = 'б', [226] = 'в', [227] = 'г', [228] = 'д', [229] = 'е', [230] = 'ж', [231] = 'з', [232] = 'и', [233] = 'й', [234] = 'к', [235] = 'л', [236] = 'м', [237] = 'н', [238] = 'о', [239] = 'п', [240] = 'р', [241] = 'с', [242] = 'т', [243] = 'у', [244] = 'ф', [245] = 'х', [246] = 'ц', [247] = 'ч', [248] = 'ш', [249] = 'щ', [250] = 'ъ', [251] = 'ы', [252] = 'ь', [253] = 'э', [254] = 'ю', [255] = 'я',
}
function string.rlower(s)
    s = s:lower()
    local strlen = s:len()
    if strlen == 0 then return s end
    s = s:lower()
    local output = ''
    for i = 1, strlen do
        local ch = s:byte(i)
        if ch >= 192 and ch <= 223 then
            output = output .. russian_characters[ch + 32]
        elseif ch == 168 then
            output = output .. russian_characters[184]
        else
            output = output .. string.char(ch)
        end
    end
    return output
end
function string.rupper(s)
    s = s:upper()
    local strlen = s:len()
    if strlen == 0 then return s end
    s = s:upper()
    local output = ''
    for i = 1, strlen do
        local ch = s:byte(i)
        if ch >= 224 and ch <= 255 then
            output = output .. russian_characters[ch - 32]
        elseif ch == 184 then
            output = output .. russian_characters[168]
        else
            output = output .. string.char(ch)
        end
    end
    return output
end


function getColorForSeconds(sec)
    if sec > 0 and sec <= 50 then
        return imgui.ImVec4(1, 1, 0, 1)
    elseif sec > 50 and sec <= 100 then
        return imgui.ImVec4(1, 159/255, 32/255, 1)
    elseif sec > 100 and sec <= 200 then
        return imgui.ImVec4(1, 93/255, 24/255, 1)
    elseif sec > 200 and sec <= 300 then
        return imgui.ImVec4(1, 43/255, 43/255, 1)
    elseif sec > 300 then
        return imgui.ImVec4(1, 0, 0, 1)
    end
end

function getColor(ID)
    PlayerColor = sampGetPlayerColor(ID)
    a, r, g, b = explode_argb(PlayerColor)
    return r/255, g/255, b/255, 1
end

function explode_argb(argb)
    local a = bit.band(bit.rshift(argb, 24), 0xFF)
    local r = bit.band(bit.rshift(argb, 16), 0xFF)
    local g = bit.band(bit.rshift(argb, 8), 0xFF)
    local b = bit.band(argb, 0xFF)
    return a, r, g, b
end

function getDistanceToPlayer(playerId)
    if sampIsPlayerConnected(playerId) then
        local result, ped = sampGetCharHandleBySampPlayerId(playerId)
        if result and doesCharExist(ped) and not sampIsPlayerNpc(ped)  then
            local myX, myY, myZ = getCharCoordinates(playerPed)
            local playerX, playerY, playerZ = getCharCoordinates(ped)
            return getDistanceBetweenCoords3d(myX, myY, myZ, playerX, playerY, playerZ)
        end
    end
    return nil
end

function sampGetFraktionBySkin(id)
    local skin = 0
    local t = u8'Нет'
        local result, ped = sampGetCharHandleBySampPlayerId(id)
        if result then
            skin = getCharModel(ped)
        else
            skin = getCharModel(PLAYER_PED)
        end
        if skin == 102 or skin == 103 or skin == 104 or skin == 195 or skin == 21 then t = 'Ballas Gang' end
        if skin == 105 or skin == 106 or skin == 107 or skin == 269 or skin == 270 or skin == 271 or skin == 86 or skin == 149 or skin == 297 then t = 'Grove Gang' end
        if skin == 108 or skin == 109 or skin == 110 or skin == 190 or skin == 47 then t = 'Vagos Gang' end
        if skin == 114 or skin == 115 or skin == 116 or skin == 48 or skin == 44 or skin == 41 or skin == 292 then t = 'Aztec Gang' end
        if skin == 173 or skin == 174 or skin == 175 or skin == 193 or skin == 226 or skin == 30 or skin == 119 then t = 'Rifa Gang' end
        if skin == 191 or skin == 252 or skin == 287 or skin == 61 or skin == 179 or skin == 255 then t = 'Army' end
        if skin == 57 or skin == 98 or skin == 147 or skin == 150 or skin == 187 or skin == 216 then t = u8'Мэрия' end
        if skin == 59 or skin == 172 or skin == 189 or skin == 240 then t = u8'Автошкола' end
        if skin == 201 or skin == 247 or skin == 248 or skin == 254 or skin == 248 or skin == 298 then t = u8'Байкеры' end
        if skin == 272 or skin == 112 or skin == 125 or skin == 214 or skin == 111  or skin == 126 then t = u8'Русская мафия' end
        if skin == 113 or skin == 124 or skin == 214 or skin == 223 then t = 'La Cosa Nostra' end
        if skin == 120 or skin == 123 or skin == 169 or skin == 186 then t = 'Yakuza' end
        if skin == 211 or skin == 217 or skin == 250 or skin == 261 then t = 'News' end
        if skin == 70 or skin == 219 or skin == 274 or skin == 275 or skin == 276 or skin == 70 then t = u8'Медики' end
        if skin == 286 or skin == 141 or skin == 163 or skin == 164 or skin == 165 or skin == 166 then t = 'FBI' end
        if skin == 280 or skin == 265 or skin == 266 or skin == 267 or skin == 281 or skin == 282 or skin == 288 or skin == 284 or skin == 285 or skin == 304 or skin == 305 or skin == 306 or skin == 307 or skin == 309 or skin == 283 or skin == 303 then t = u8'Полиция' end
    return t
end

function ftext(text)
    sampAddChatMessage((' %s | {ffffff}%s'):format(script.this.name, text),0x7FFF00)
end

function siAssitDansWagon()
    local isCharInCarByType = isCharInModel(PLAYER_PED, 433) -- check si Player est assit dans VehID
    local myX, myY, myZ = getCharCoordinates(PLAYER_PED)
    if isCharInCarByType and vientDeRentrer then
        if (getDistanceBetweenCoords3d(myX, myY, myZ, 279.5797,1990.1761,17.6406)<25 or getDistanceBetweenCoords3d(myX, myY, myZ, 137.9600,1837.0286,17.6406)<25 ) and vientDeRentrer then
            vientDeRentrer = false
            zaprfur = true
            notf.addNotification(string.format('Сделать доклад о взятии фуры?\n\nПодтвердить: '..table.concat(rkeys.getKeysName(config_keys.oopda.v))..'\nОтменить: '..table.concat(rkeys.getKeysName(config_keys.oopnet.v))), 10, 3) 
        else vientDeRentrer = false end
    elseif not isCharInCarByType and not vientDeRentrer then
        vientDeRentrer = true
    else end
end

function copyrpsnick(pam)
    local id = pam:match('(%d+)')
    if id and sampIsPlayerConnected(id) then
            name = sampGetPlayerNickname(id)
            rpname = name:gsub('_', ' ')
            _, family = name:match('(.+)_(.+)')
            setClipboardText(family)
            notf.addNotification('Вы скопировали фамилию игрока: '.. rpname, 5, 2)
    else notf.addNotification('Не корректный ID.', 10, 3)end
end

function copyrpnick(pam)
    local id = pam:match('(%d+)')
    if id and sampIsPlayerConnected(id) then
            name = sampGetPlayerNickname(id)
            rpname = name:gsub('_', ' ')
            setClipboardText(rpname)
            notf.addNotification('Вы скопировали РП-ник игрока: '.. rpname, 5, 2)
    else notf.addNotification('Не корректный ID.', 10, 3)end
end

function showudost()
    lua_thread.create(function()
        local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
        local myname = sampGetPlayerNickname(myid)
        rpname = myname:gsub('_', ' ')
        sampSendChat('/me достал с нагрудного кармана удостоверение и показал человеку напротив')
        wait(1000)
        sampSendChat('/do В удостоверении: ' .. rpname .. ' '.. rang .. ' ' .. frak .. ', '.. config.udost.vzvod ..', '.. config.udost.dolzn..'.')
        wait(1000)
        sampSendChat('/me закрыв убрал его обратно')
        notf.addNotification('Вы показали удостоверение', 10, 2)
    end)
end 

function imgui.VerticalSeparator()
    local p = imgui.GetCursorScreenPos()
    imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x, p.y + imgui.GetContentRegionMax().y), imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.Separator]))
end

function SOS()
    lua_thread.create(function()
        wait(5000)
        if napadenie == true and napali == true then 
            napadenie = false
            napali = false
        end
        if napadenie == true and napali == false then 
            napadenie = false
        end
    end)
end

function sampev.onSendTakeDamage(playerId, damage, weapon, bodypart)
    if config.main.auto_SOS then
        if playerId ~= "" and playerId ~= nil and sampIsPlayerConnected(playerId) then
            if napadenie == false then
                napal = sampGetPlayerNickname(playerId)
                napadenie = true
                napali = true;
                notf.addNotification(string.format('На вас напали!('.. napal ..')\nОбъявить SOS?Подтвердить: '..table.concat(rkeys.getKeysName(config_keys.oopda.v))..'\nОтменить: '..table.concat(rkeys.getKeysName(config_keys.oopnet.v))), 10, 3) 
                SOS()
            end
        end
    end
end

function fyk(pam)
    if #pam ~= 0 then
        local f = io.open('moonloader\\Army-Tools\\yk.txt')
        for line in f:lines() do
            if string.find(line, pam) or string.rlower(line):find(pam) or string.rupper(line):find(pam) then
                sampAddChatMessage(scriptname.. u8'| {FFFFFF} '..line, 0x7FFF00)
            end
        end
        f:close()
    else
        sampAddChatMessage(scriptname.. "| {FFFFFF}Введите: /fyk [Текст]", 0x7FFF00) 
    end
end

function rinvite(param)
    local id = tonumber(param);
    lua_thread.create(function()
        if sampIsPlayerConnected(id) then
            sampSendChat(string.format('/me %s все нужные документы на имя %s после %s форму', config.main.male and 'подписал' or 'подписала', sampGetPlayerNickname(id):gsub("_", " "), config.main.male and 'передал' or 'передала'))
            wait(1400)
            sampSendChat(string.format('/invite %d', tonumber(id)))
        end
    end)
end

function runinvite(param)
    local id, reason = param:match('(%d+) (.+)')
    lua_thread.create(function()
        if sampIsPlayerConnected(id) then
            sampSendChat(string.format('/me держа в руках контракт на имя %s %s печать "Расторгнут"', config.main.male and 'поставил' or 'поставила', sampGetPlayerNickname(id):gsub("_", " ")))
            wait(1400)
            sampSendChat(string.format('/uninvite %d %s', tonumber(id), reason))
            wait(1400)
            sampSendChat(string.format('/r %s %s уволен из армии по причине: %s', config.main.tar, sampGetPlayerNickname(id):gsub("_", " "), reason))
        end
    end)
end

function roffgiverank(param)
    local name, rang = param:match('(.+) (%d+)')
    lua_thread.create(function()
        sampSendChat(string.format('/me открыв планшет %s дело на имя %s. %s пункт "Звание"', config.main.male and 'нашёл' or 'нашла', name:gsub("_", " "), config.main.male and 'Изменил' or 'Изменила'))
        wait(1400)
        sampSendChat(string.format('/offgiverank %s %d', name, tonumber(rang)))
    end)
end

function roffuninvite(param)
    local name, rang = param:match('(.+) (.+)')
    lua_thread.create(function()
        sampSendChat(string.format('/me открыв планшет %s дело на имя %s %s его', config.main.male and 'нашёл' or 'нашла', name:gsub("_", " "), config.main.male and 'удалил' or 'удалила'))
        wait(1400)
        sampSendChat(string.format('/b /offuninvite %s %s', name, rang))
    end)
end

function clistm(param)
    if param ~= nil or param >= 0 or param <= 33 then
        sampSendChat('/clist '..param)
    end
end

function farmy(pam)
    if #pam ~= 0 then
        local f = io.open('moonloader\\Army-Tools\\army.txt')
        for line in f:lines() do
            if string.find(line, pam) or string.rlower(line):find(pam) or string.rupper(line):find(pam) then
                sampAddChatMessage(scriptname.. u8'| {FFFFFF} '..line, 0x7FFF00)
            end
        end
        f:close()
    else
        sampAddChatMessage(scriptname.. "| {FFFFFF}Введите: /farmy [Текст]", 0x7FFF00)
    end
end

function fak(pam)
    if #pam ~= 0 then
        local f = io.open('moonloader\\Army-Tools\\ak.txt')
        for line in f:lines() do
            if string.find(line, pam) or string.rlower(line):find(pam) or string.rupper(line):find(pam) then
                sampAddChatMessage(scriptname.. u8'| {FFFFFF} '..line, 0x7FFF00)
            end
        end
        f:close()
    else
        sampAddChatMessage(scriptname.. "| {FFFFFF}Введите: /fak [Текст]", 0x7FFF00)
    end
end

function vigovor(pam)
    local id, VIGreason = pam:match('(%d+) (.+)')
    if id and VIGreason and sampIsPlayerConnected(id) then
        sampSendChat(string.format("/r %s %s получает выговор за %s ", config.main.tar, sampGetPlayerNickname(id):gsub('_', ' '), VIGreason))
    else
        sampAddChatMessage(scriptname.. '| {FFFFFF}Введите: /vig [id] [причина]', 0x7FFF00)
    end
end

function vzaimk()
    local valid, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
    if valid and doesCharExist(ped) then
        local result, id = sampGetPlayerIdByCharHandle(ped)
        ID_sec = id
        --targetid = id
        if result then
            gmegafhandle = ped
            gmegafid = id
            gmegaflvl = sampGetPlayerScore(id)
            gmegaffrak = sampGetFraktionBySkin(id)
            if config.main.new_style then lua_thread.create(function() vzaim_new.v = true end)
            else submenus_show(pkmmenu(id), "{9966cc}"..script.this.name.." {ffffff}| "..sampGetPlayerNickname(id).." ["..id.."] ") end
        end
    end
end


function naryad(pam)
    local id, typenar, krug, narreason = pam:match('(%d+) (%d+) (%d+) (.+)')
    if id and narreason and typenar and krug and sampIsPlayerConnected(id) then
        if tonumber(typenar) == 1 then  typeVIG1 = "части" elseif tonumber(typenar) == 2 then  typeVIG1 = "ГС" end
        if tonumber(krug) < 5 then kr = "круга" elseif tonumber(krug) == 1 then kr = "круг" elseif tonumber(krug) > 4 then kr = "кругов"end 
        name = sampGetPlayerNickname(id)
        rpname = name:gsub('_', ' ')
        sampSendChat(string.format("/r %s %s получает наряд %s %s вокруг %s за %s ", config.main.tar, rpname, krug, kr, typeVIG1, narreason))
    else
        sampAddChatMessage(scriptname.. '| {FFFFFF}Введите: /nar [id] [1-Часть/2-ГС] [Круги] [причина]', 0x7FFF00)
    end
end

function loc(pam)
    local id, sec = pam:match('(%d+) (%d+)')
    if id and sec and sampIsPlayerConnected(id) then
        name = sampGetPlayerNickname(id)
        rpname = name:gsub('_', ' ')
        sampSendChat(string.format("/r %s %s ваше местоположение? На ответ %s секунд", config.main.tar, rpname, sec))
    else
        sampAddChatMessage(scriptname.. '| {FFFFFF}Введите: /loc [id] [кол-во секунд]', 0x7FFF00)
    end
end

function plc(pam)
    local id, sec = pam:match('(%d+) (%d+)')
    if id and sec and sampIsPlayerConnected(id) then
        name = sampGetPlayerNickname(id)
        rpname = name:gsub('_', ' ')
        local second = tonumber(sec)
        local min = ""
        if second == 1 then min = "минута" end
        if second >= 5 then min = "минут" end
        if second == 2 then min = "минуты" end
        if second == 3 then min = "минуты" end
        sampSendChat(string.format("/r %s %s на плац. РВП: %s %s", config.main.tar, rpname, second, min))
    else
        sampAddChatMessage(scriptname.. '| {FFFFFF}Введите: /plc [id] [кол-во минут]', 0x7FFF00)
    end
end

function fnr(pam)
    local id = pam:match('(%d+)')
    if id and sampIsPlayerConnected(id) then
        name = sampGetPlayerNickname(id)
        rpname = name:gsub('_', ' ')
        sampSendChat(('/sms %s На работу'):format(tonumber(id)))
    else
        sampAddChatMessage(scriptname.. '| {FFFFFF}Введите: /fnr [id]', 0x7FFF00)
    end
end

function getClosestPlayerId()
    local closestId = -1
    mydist = 30
    local x, y, z = getCharCoordinates(PLAYER_PED)
    for i = 0, 999 do
        local streamed, pedID = sampGetCharHandleBySampPlayerId(i)
        if streamed and getCharHealth(pedID) > 0 and not sampIsPlayerPaused(pedID) then
            local xi, yi, zi = getCharCoordinates(pedID)
            local dist = getDistanceBetweenCoords3d(x, y, z, xi, yi, zi)
            if dist <= mydist then
                mydist = dist
                closestId = i
            end
        end
    end
    return closestId
end


function submenus_show(menu, caption, select_button, close_button, back_button)
    select_button, close_button, back_button = select_button or '»', close_button or 'x', back_button or '«'
    prev_menus = {}
    function display(menu, id, caption)
        local string_list = {}
        for i, v in ipairs(menu) do
            table.insert(string_list, type(v.submenu) == 'table' and v.title .. ' »' or v.title)
        end
        sampShowDialog(id, caption, table.concat(string_list, '\n'), select_button, (#prev_menus > 0) and back_button or close_button, sf.DIALOG_STYLE_LIST)
        repeat
            wait(0)
            local result, button, list = sampHasDialogRespond(id)
            if result then
                if button == 1 and list ~= -1 then
                    local item = menu[list + 1]
                    if type(item.submenu) == 'table' then
                        table.insert(prev_menus, {menu = menu, caption = caption})
                        if type(item.onclick) == 'function' then
                            item.onclick(menu, list + 1, item.submenu)
                        end
                        return display(item.submenu, id + 1, item.submenu.title and item.submenu.title or item.title)
                    elseif type(item.onclick) == 'function' then
                        local result = item.onclick(menu, list + 1)
                        if not result then return result end
                        return display(menu, id, caption)
                    end
                else
                    if #prev_menus > 0 then
                        local prev_menu = prev_menus[#prev_menus]
                        prev_menus[#prev_menus] = nil
                        return display(prev_menu.menu, id - 1, prev_menu.caption)
                    end
                    return false
                end
            end
        until result
    end
    return display(menu, 31337, caption or menu.title)
end


function ffp(pam)
    if #pam ~= 0 then
        local f = io.open('moonloader\\Army-Tools\\fp.txt')
        for line in f:lines() do
            if string.find(line, pam) or string.rlower(line):find(pam) or string.rupper(line):find(pam) then
                sampAddChatMessage(' '..line, -1)
            end
        end
        f:close()
    else
        ftext('Введите /ffp [текст]')
    end
end


function pkmmenu(id)
    return
    {
        {
            title = '{ffffff}» Принять',
            onclick = function()
                if sampIsPlayerConnected(id) then
                    sampSendChat(string.format('/me %s все нужные документы на имя %s после %s форму', config.main.male and 'подписал' or 'подписала', sampGetPlayerNickname(id):gsub("_", " "), config.main.male and 'передал' or 'передала'))
                    wait(1400)
                    sampSendChat(string.format('/invite %d', tonumber(id)))
                end
            end
        },
        {
            title = '{ffffff}» Уволить',
            onclick = function()
                sampShowDialog(2038, "Ввод текста", "Укажите причину", "ОК", "Отмена", DIALOG_STYLE_INPUT)
                while sampIsDialogActive(6406) do wait(100) end
                local result, button, _, input = sampHasDialogRespond(2038)
                if button == 1 and input ~= nil then
                    if sampIsPlayerConnected(id) then
                        sampSendChat(string.format('/me держа в руках контракт на имя %s %s печать "Расторгнут"', config.main.male and 'поставил' or 'поставила', sampGetPlayerNickname(id):gsub("_", " ")))
                        wait(1400)
                        sampSendChat(string.format('/uninvite %d %s', tonumber(id), input))
                        wait(1400)
                        sampSendChat(string.format('/r %s %s уволен из армии по причине: %s', config.main.tar, sampGetPlayerNickname(id):gsub("_", " "), input))
                    end
                end
            end
        },
        {
            title = '{ffffff}» Одобрить перевод',
            onclick = function()
                sampShowDialog(2038, "Ввод текста", "Укажите фракцию (например SFPD)", "ОК", "Отмена", DIALOG_STYLE_INPUT)
                while sampIsDialogActive(6406) do wait(100) end
                local result, button, _, input = sampHasDialogRespond(2038)
                if button == 1 and input ~= nil then
                    if sampIsPlayerConnected(id) then
                        local result, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
                        sampSendChat(string.format('/me держа в руках рапорт на имя %s %s "Перевод одобрен"', config.main.male and 'расписался' or 'расписалась', sampGetPlayerNickname(id):gsub("_", " ")))
                        wait(1400)
                        sampSendChat(string.format('/do В рапорте: Я, %s %s, одобряю %s перевод в %s.', rang, sampGetPlayerNickname(myid):gsub("_", " "), sampGetPlayerNickname(id):gsub("_", " "), input))
                    end
                end
            end
        },
        {
            title = "{ffffff}» Повысит/Понизить",
            onclick = function()
                sampShowDialog(2038, "Ввод текста", "Укажите порядковый ранг (цифра)", "ОК", "Отмена", DIALOG_STYLE_INPUT)
                while sampIsDialogActive(6406) do wait(100) end
                local result, button, _, input = sampHasDialogRespond(2038)
                if button == 1 and input ~= nil then
                    if sampIsPlayerConnected(id) then
                        sampSendChat(string.format('/giverank %d %d', tonumber(id), tonumber(input)))
                        wait(1000)
                        sampSendChat(string.format("/me %s %s новые погоны", config.main.male and 'передал' or 'передала', sampGetPlayerNickname(id):gsub("_", " ")))
                    end
                end
            end
        }
    }
end

function cuffk()
    local valid, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
    if valid then
        result, targetid = sampGetPlayerIdByCharHandle(ped)
        if result then
            lua_thread.create(function()
                sampSendChat(string.format('/me %s стяжки с разгрузки', config.main.male and 'снял' or 'сняла'))
                wait(1400)
                sampSendChat('/tie '..targetid)
            end)
        end
    else
        local closeid = getClosestPlayerId()
        if closeid ~= -1 then 
            local result, closehandle = sampGetCharHandleBySampPlayerId(closeid)
            if doesCharExist(closehandle) then
                lua_thread.create(function()
                    sampSendChat(string.format('/me %s стяжки с разгрузки', config.main.male and 'снял' or 'сняла'))
                    wait(1400)
                    sampSendChat('/tie '..closeid)
                end)
            end
        end
    end
end

function uncuffk()
    local valid, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
    if valid then
        local result, targetid = sampGetPlayerIdByCharHandle(ped)
        if result then
            lua_thread.create(function()
                sampSendChat(string.format('/me %s стяжки с человека напротив', config.main.male and 'снял' or 'сняла'))
                wait(1400)
                sampSendChat('/untie '..targetid)
            end)
        end
    else
        local closeid = getClosestPlayerId()
        if sampIsPlayerConnected(closeid) then
            if closeid ~= -1 then
                local result, closehandle = sampGetCharHandleBySampPlayerId(closeid)
                if doesCharExist(closehandle) then
                    lua_thread.create(function()
                        sampSendChat(string.format('/me %s стяжки с человека напротив', config.main.male and 'снял' or 'сняла'))
                        wait(1400)
                        sampSendChat('/untie '..closeid)
                    end)
                end
            end
        end
    end
end

function followk()
    local valid, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
    if valid then
        result, targetid = sampGetPlayerIdByCharHandle(ped)
        if result then
            lua_thread.create(function()
                sampSendChat(string.format('/me %s за стяжки, после чего %s за собой человека', config.main.male and 'схватил' or 'схватила', config.main.male and 'повел' or 'повела'))
                wait(1400)
                sampSendChat('/follow '..targetid)
            end)
        end
    else
        local closeid = getClosestPlayerId()
        if closeid ~= -1 then 
            local result, closehandle = sampGetCharHandleBySampPlayerId(closeid)
            if doesCharExist(closehandle) then
                lua_thread.create(function()
                    sampSendChat(string.format('/me %s за стяжки, после чего %s за собой человека', config.main.male and 'схватил' or 'схватила', config.main.male and 'повел' or 'повела'))
                    wait(1400)
                    sampSendChat('/follow '.. closeid)
                end)
            end
        end
    end
end

function sirenk() 
    if isCharInAnyCar(PLAYER_PED) then
        local car = storeCarCharIsInNoSave(PLAYER_PED)
        switchCarSiren(car, not isCarSirenOn(car))
    end
end

function getLocalPlayerId()
    local _, id = sampGetPlayerIdByCharHandle(playerPed)
    return id
end


function bolLS()
    lua_thread.create(function()
        sampSendDialogResponse(8011, 1, 3, _)
        wait(200)
        sampSetCurrentDialogListItem(12)
        sampCloseCurrentDialogWithButton(1) 
        wait(200)  
        sampSetCurrentDialogListItem(5)
        wait(200)
        sampCloseCurrentDialogWithButton(1)
        wait(200) 
        sampCloseCurrentDialogWithButton(0)      
    end)
end

function DownloadPNG()
    print('{7CFC00}Army Tools | {FFFFFF}Проверка оболочки, подождите.', 0x7CFC00)
    local status = 0
    local folders = {"main_window", "dop_menu", "dop_menu/grey"}
    local files = {'Уволить.png', 'Связать.png', 'Развязать.png', 'Принять.png', 'Перевод.png', 'Звание.png', 'Закрыть.png', 'logo-army-tools.png', 'Main.jpg'}
    local photos = {'Binders1', 'Binders2', 'CB(active)', 'CB(none)', 'DB(active)', 'DB(none)', 'Main_menu1', 'Main_menu2', 'Plan1', 'Plan2', 'add', 'background', 'block', 'close_window', 'command_bind', 'delete', 'gos(active)', 'gos(none)', 'key', 'keyboard', 'logs(active)', 'logs(none)', 'main_set(active)', 'main_set(nact)', 'online(active)', 'online(none)', 'red_left', 'save', 'shp(active)', 'shp(nact)', 'tol'}
    local dopsmn = {'invite_grey', 'rang_grey', 'tie_grey', 'transport_grey', 'uninvite_grey', 'untie_grey'}
    for k, v in pairs(folders) do if not doesDirectoryExist('moonloader/Army-Tools/png/'..v) then createDirectory('moonloader/Army-Tools/png/'..v) end end
    for k, v in pairs(files) do 
        if not doesFileExist('moonloader/Army-Tools/png/'..v) then
            downloadUrlToFile('https://raw.githubusercontent.com/alekseyrulew/Army-Tools/main/png/'..v, 'moonloader/Army-Tools/png/'..v, function(id, status, p1, p2) 
            end)
        end
    end
    for k, v in pairs(photos) do
        if not doesFileExist('moonloader/Army-Tools/png/main_window/'..v..".png") then
            downloadUrlToFile('https://raw.githubusercontent.com/alekseyrulew/Army-Tools/main/png/main_window/'..v..".png", 'moonloader/Army-Tools/png/main_window/'..v..".png", function(id, status, p1, p2) 
            end)
        end
    end
    for k, v in pairs(dopsmn) do
        if not doesFileExist('moonloader/Army-Tools/png/dop_menu/grey/'..v..".png") then
            downloadUrlToFile('https://raw.githubusercontent.com/alekseyrulew/Army-Tools/main/png/dop_menu/grey/'..v..".png", 'moonloader/Army-Tools/png/dop_menu/grey/'..v..".png", function(id, status, p1, p2) 
            end)
        end
    end
    if not doesFileExist('moonloader/Army-Tools/png/dop_menu/closed.png') then
        downloadUrlToFile('https://raw.githubusercontent.com/alekseyrulew/Army-Tools/main/png/dop_menu/closed.png', 'moonloader/Army-Tools/png/dop_menu/closed.png', function(id, status, p1, p2) 
            if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                sampAddChatMessage(scriptname.. ' | {FFFFFF}Оболочка успешно подгружена. Перезапуск скрипта!',0x7FFF00)
                thisScript():reload()
            end
        end)
    end
end