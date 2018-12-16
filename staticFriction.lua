require "include/protoplug"

--Hi!
--This is Axel's Acceleration Limiter - Nasty Edition
--This effect is a followup to the Speed Limiter,
--and sounds very similar as it distorts in the
--same way. However, it is capable of adapting to
--changes in frequency in a way that the previous
--was intentionally not capable of.
--The min speed here creates some extremely strange
--outcomes in that it creates a band of speeds that
--are not usable, allowing you to make some tortured
--waves.

local position1 = 0
local position2 = 0
local speed1 = 0.01
local speed2 = 0.01
local accel = 0.01
local maxSpeed = 1
local minSpeed = 0
local lasti = 0
local sft = 0
local sfc = 0
local frictiOn = false
local channels = {}

function clamp(i)
    -- Since speed can now be positive or negative, the min speed leaves a strange gap. This needs to be explored.
    if i ~= 0 then
        if(math.abs(i) > maxSpeed) then i = maxSpeed * i/math.abs(i) end
        if(math.abs(i) < minSpeed) then i = minSpeed * i/math.abs(i) end
    end
    return i
end

function stereoFx.Channel:init()
    table.insert(channels, self)
end

stereoFx.init()

function stereoFx.Channel:processBlock(s, blocksize)
    if self == channels[1] then
        --print("aha!")
        position = position1
        speed = speed1
    else
        position = position2
        speed = speed2
        --print("oho!")
    end
    for i=0, blocksize do
        local dif = s[i] - position
        local dif2 = dif - speed
        
        if(frictiOn == false and math.abs(s[i]) < math.abs(lasti) and math.abs(s[i]) > sft) then
            frictiOn = true
        elseif(math.abs(s[i]) < sfc) then
            frictiOn = false
        end
        
        if(frictiOn) then
            speed = 0
        else
            speed = speed + accel * dif2
        end
        speed = speed * fc
        
        position = position + clamp(speed)
        s[i] = position
        lasti = s[i]
    end
    if self == channels[1] then
        position1 = position
        speed1 = speed
    else
        position2 = position
        speed2 = speed
    end
end

plugin.manageParams {
	{
		name = "Acceleration";
		min = 0.00001;
		max = 1;
		changed = function(val) accel = val; end
	};
	{
	    name = "Max Speed";
	    min = 0.00001;
	    max = 1;
	    changed = function(val) maxSpeed = val; end
	};
	{
	    name = "Min Speed";
	    min = 0;
	    max = 1;
	    changed = function(val) minSpeed = val; end
	};
	{
	    name = "Fric Coeff";
	    min = 0;
	    max = 1;
	    changed = function(val) fc = val; end
	};
	{
	    name = "Stat Fric Thresh";
	    min = 0;
	    max = 1;
	    changed = function(val) sft = val; end
	};
	{
	    name = "Stat Fric Coeff";
	    min = 0;
	    max = 1;
	    changed = function(val) sfc = val; end
	};
}