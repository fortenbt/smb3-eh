-----------------------------------------------------------------------
-- Lua script for displaying "countdown" boxes to assist with
-- jumping on the required frame to achieve EarlyHammer
--
-- Created By: orangeexpo, August 9, 2018
-- For use with the TAS "orange-nodeath-eh-v0.5.fm2"
-----------------------------------------------------------------------

-- Allows you to adjust how many frames between each box being filled in
local countdown_delay = 45

local goodframe_2_1 = 17821 -- 688 lag, 289 ingame clock, 18212 end of level lag frame
local goodframe_2_2 = 19725 -- 773 lag, 285 ingame clock, 20207 end of level lag frame
local goodframe_2_f = 22672 -- 872 lag, 277 ingame clock, 23079 end of level lag frame

local screen_width  = 0x10 --256 pixels, 16 blocks
local screen_height = 0x0F --240 pixels, 15 blocks

-- Allows you to adjust how many boxes to display on screen
local nboxes = 9

-- Allows you to adjust how big the boxes are
local box_size = 20
local space_size = 5
local box_y = 20

--
-- Shouldn't have to change anything under here
--

local floorhalf = math.floor(nboxes/2)

local box_colors = {}

function init_box_colors()
    for i=1, nboxes, 1 do
        box_colors[i] = "#ffffff80"
    end
end

function display_boxes()
    local x_mid = ((screen_width*16)/2) + 8
    local box1_x = x_mid - (box_size*0.5) - ((box_size+space_size)*floorhalf)
    for i=0, nboxes-1, 1 do
        local x = box1_x+(i*(box_size+space_size))
        local b = {x, box_y, x + box_size, box_y + box_size, box_colors[i+1], "white"}
        gui.drawrect(unpack(b))
    end
end

function update_box_colors(frame, curr)
    -- Turn the middle box green on 'frame'
    -- First and last boxes are paired, and so on until the middle one
    -- Threshold for the first box is 'frame' - (floorhalf*countdown_delay)
    if curr < (frame - (floorhalf*countdown_delay)) or curr > (frame + 180) then
        init_box_colors()
        return false
    end
    for i=1, floorhalf+1, 1 do
        if curr >= (frame - ((floorhalf-(i-1))*countdown_delay)) then
            box_colors[i] = "green"
            box_colors[nboxes-(i-1)] = "green"
        end
    end
    return true
end

function doit()
    curr = emu.framecount()
    if update_box_colors(goodframe_2_1, curr) then
        -- do nothing
    elseif update_box_colors(goodframe_2_2, curr) then
        -- do nothing
    elseif update_box_colors(goodframe_2_f, curr) then
        -- do nothing
--    elseif update_box_colors(goodframe_ph, curr) then
--        -- do nothing
    end

    display_boxes()
end


function preframe_calculations()
    doit()
end


init_box_colors()
gui.register(preframe_calculations)
