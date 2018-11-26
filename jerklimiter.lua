require "include/protoplug"

--Hi!
--This is Axel's Jerk Limiter
--Its properties are not as interesting as I'd hoped.
--The final result is that lowering the jerk lowpasses the signal
--If unmitigated, the jerk limitation will create massive
--oscillations that get lower and more overpowering as you travel
--down the range. The posfall, speedfall, and accelfall parameters
--are useful in removing this effect, but all decrease volume.
--Additionally, the system is very delicate - changing the range
--of values will most likely cause problems with most parameters.
--I've tried a whole lot of stuff to make this more interesting,
--but it has boiled down to a weird lowpass.
--I've tested whether it has any de-noising properties (which I
--had both expected and hoped for) but it doesn't seem to.

local position1 = 0
local position2 = 0
local speed1 = 0
local speed2 = 0
local accel1 = 0
local accel2 = 0
local maxAccel = 1
local maxSpeed = 1
local minSpeed = 0
local jerk = 0.01
local channels = {}
local posFall = 1
local speedFall = 0.2
local accelFall = 0.2

function clamp(i)

    -- Since speed can now be positive or negative, the min speed leaves a strange gap. This needs to be explored.
    if i ~= 0 then
        if(math.abs(i) > maxSpeed) then i = maxSpeed * i/math.abs(i) end
        if(math.abs(i) < minSpeed) then i = minSpeed * i/math.abs(i) end
    end
    return i
end

function accclamp(i)
    if i ~= 0 then
        if(math.abs(i) > maxAccel) then i = maxAccel * i/math.abs(i) end
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
        accel = accel1
    else
        position = position2
        speed = speed2
        accel = accel2
        --print("oho!")
    end
    for i=0, blocksize do
        local dif = s[i] - position
        dif = clamp(dif)
        local dif2 = dif - speed
        dif2 = accclamp(dif2)
        local dif3 = dif2 - accel
        
        -- if the difference between the current position and the desired destination is different than the speed
            -- change the speed according to the acceleration
        -- if the difference between the current speed and the desired speed is different than the acceleration
            -- change the acceleration according to the jerk
        -- if the difference between the current acceleration and the desired acceleration is different than the jerk
            -- change the jerk based on the jerkrate

        if (dif3 ~= nil) then
            accel = accel + jerk * dif3
            accel = accel * accelFall
        end
        speed = speed + accel
        speed = speed * speedFall
        position = position + speed
        position = position * posFall
        if (position > 1) then
            position = 1
            --speed = speed * 0.5
        end
        if (position < -1) then
            position = -1
            --speed = speed * 0.5
        end
        s[i] = position
    end
        
        
    if self == channels[1] then
        position1 = position
        speed1 = speed
        accel1 = accel
    else
        position2 = position
        speed2 = speed
        accel2 = accel
    end
end

plugin.manageParams {
    {
        name = "Jerk";
        min = 0.00001;
        max = 1;
        changed = function(val) jerk = val; end
    };
	{
		name = "MaxAcceleration";
		min = 0.00001;
		max = 1;
		changed = function(val) maxAccel = val; end
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
	{
	    name = "Position Fall Factor";
	    min = 0.001;
	    max = 1;
	    changed = function(val) posFall = val; end
	};
	{
	    name = "Speed Fall Factor";
	    min = 0.001;
	    max = 1;
	    changed = function(val) speedFall = val; end
	};
	{
	    name = "Acceleration Fall Factor";
	    min = 0.001;
	    max = 1;
	    changed = function(val) accelFall = val; end
	};
}