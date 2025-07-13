-- This script swaps between Piopow and Dungies when holding SELECT + START
-- Also stores/recovers Dungies' hiscores between runs
-- Tested with fceux 2.6.6 in a Mac M2 and a Raspi4B w/RaspiOS
--
-- Missing you,
-- nitram
--

local TRIGGER_TIME = 5 * 60  -- 5 seconds * 60 frames per second
local BLINK_TIME = 90
local BLINK_PERIOD = 10

-- For Dungies with SHA256 = 1450504a57c9bc2925ef8b45d18fbf5c63e23a8f737c4dd98aa0872560970b5e
local DUNGIES_HISCORE_ADDR = 0x030c

local current = "Piopow"
local swap_to = "Dungies"

local dungies_hiscore = {0,0,0,0,0,0}
local held_frames = 0

local function dungies_save_hiscore()
    local file = io.open("dungies_hiscore", "wb")
    for i = 1, 6 do
        local byte = memory.readbyte(DUNGIES_HISCORE_ADDR + i - 1)
        file:write(string.char(byte))
    end
    file:close()
end

local function dungies_load_hiscore()
    local file = io.open("dungies_hiscore", "rb")
    if not file then return end
    for i = 1, 6 do
        local byte = file:read(1):byte()
        memory.writebyte(DUNGIES_HISCORE_ADDR + i - 1, byte)
        dungies_hiscore[i] = byte
    end
    file:close()
end

local function dungies_frame() 
    -- One second after rom load, after hiscore is zeroed, load the hiscore from
    -- file and write to RAM. After that, detect any new changes to the hiscore
    -- and write them to a file.
    local frame = emu.framecount()
    if frame == 60 then
        dungies_load_hiscore()
    elseif frame > 60 then 
        local do_save = false
        for i = 1, 6 do
            local byte = memory.readbyte(0x030c + i - 1)
            if dungies_hiscore[i] ~= byte then
                do_save = true
            end
            dungies_hiscore[i] = byte
        end
        if do_save then
            dungies_save_hiscore()
        end
    end
end

function game_swap_frame() 
    local input = joypad.get(1)
    -- When select and start are pressed, show a message box for some seconds
    -- and, if buttons are note released, swap the game ROM.
    if input["select"] and input["start"] then
        held_frames = held_frames + 1
        local blink = held_frames > TRIGGER_TIME - BLINK_TIME and math.floor(held_frames / BLINK_PERIOD) % 2 == 1
        local bgcolor = blink and "black" or "purple"
        local fgcolor = blink and "green" or "white"
        local y = math.min(20, held_frames-24)
        gui.rect(10, y-6, 246, y+22, bgcolor, fgcolor)
        gui.text(16, y, "Mantene SELECT + START por cinco segundos", fgcolor, "clear")
        gui.text(16, y+10, "para cambiar al juego " .. swap_to, fgcolor, "clear")
        if held_frames == TRIGGER_TIME then
            temp = current
            current = swap_to
            swap_to = temp 
            emu.loadrom(current .. ".nes")
        end
    else
        held_frames = 0  -- reset if keys released
    end
end


while true do
    if current == "Dungies" then
        dungies_frame();
    end
    game_swap_frame();

    -- gui.text(10, 50, "hiscore: "..dungies_hiscore[1]..dungies_hiscore[2]..dungies_hiscore[3]..dungies_hiscore[4]..dungies_hiscore[5]..dungies_hiscore[6])
    -- gui.text(10, 60, "frame: "..emu.framecount())

    emu.frameadvance()
end
