require "include/protoplug"

--Hi!
--This is Axel's Speed Limiter.
--It distorts the signal pretty powerfully
--and crushes down the highs. Something to
--note is that it, like normal distortion,
--is much more effective on louder signals
--but for different reasons.

local position1 = 0
local position2 = 0
local speed = 0.01
local channels = {}

function stereoFx.Channel:init()
    table.insert(channels, self)
end

stereoFx.init()

function stereoFx.Channel:processBlock(s, blocksize)
    if self == channels[1] then
        --print("aha!")
        position = position1
    else
        position = position2
        --print("oho!")
    end
    for i=0, blocksize do
        if math.abs(position - s[i]) < speed then
            position = s[i]
        elseif position > s[i] then
            position = position - speed
        else
            position = position + speed
        end
        s[i] = position
    end
    if self == channels[1] then
        position1 = position
    else
        position2 = position
    end
end

plugin.manageParams {
	{
		name = "Speed";
		min = 0.0001;
		max = 0.1;
		changed = function(val) speed = val; end
	};
}