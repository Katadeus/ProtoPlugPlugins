require "include/protoplug"

--Hi!
--This is Axel's Acceleration Limiter.
--This effect is a followup to the Speed Limiter,
--and sounds very similar as it distorts in the
--same way. However, it is capable of adapting to
--changes in frequency in a way that the previous
--was intentionally not capable of.
--My initial plan was to eventually create a jerk
--limiter, but I don't really feel like it.

local position1 = 0
local position2 = 0
local speed1 = 0.01
local speed2 = 0.01
local accel = 0.01
local maxSpeed = 1
local minSpeed = 0
local channels = {}

function clamp(i)
    if(i > maxSpeed) then i = maxSpeed end
    if(i < minSpeed) then i = minSpeed end
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
        local dif = math.abs(position - s[i])
        local dif2 = math.abs(speed - dif)
        if dif < speed then
            if dif2 < accel then
                speed = dif
            elseif speed > dif then
                speed = speed - accel
            else
                speed = speed + accel
            end
            speed = clamp(speed)
            position = s[i]
        elseif position > s[i] then
            if dif2 < accel then
                speed = dif
            elseif speed > dif then
                speed = speed - accel
            else
                speed = speed + accel
            end
            speed = clamp(speed)
            position = position - speed
        else
            if dif2 < accel then
                speed = dif
            elseif speed > dif then
                speed = speed - accel
            else
                speed = speed + accel
            end
            speed = clamp(speed)
            position = position + speed
        end
        s[i] = position
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
		max = 0.1;
		changed = function(val) accel = val; end
	};
	{
	    name = "Max Speed";
	    min = 0;
	    max = 1;
	    changed = function(val) maxSpeed = val; end
	};
	{
	    name = "Min Speed";
	    min = 0;
	    max = 1;
	    changed = function(val) minSpeed = val; end
	};
}