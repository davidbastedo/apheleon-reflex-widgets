require "base/internal/ui/reflexcore"

apheleon_PickupTimers =
{
};
registerWidget("apheleon_PickupTimers");

--------------------------------------------------------------------------------


local function sortByTimeRemaining(a, b)
	-- sort by timeUntilRespawn
	if a.timeUntilRespawn ~= b.timeUntilRespawn then
		return a.timeUntilRespawn < b.timeUntilRespawn;
	end

	-- otherwise, sort by timeUntilRespawn (so we don't get random sorting if two items have same timeUntilRespawn)
	return a.timeUntilRespawn < b.timeUntilRespawn;
end

--------------------------------------------------------------------------------
function apheleon_PickupTimers:draw()
	
    -- Early out if HUD shouldn't be shown.
    if not shouldShowHUD() then return end;

    local translucency = 192;
	
   	-- Find player
	local player = getPlayer();

	-- count pickups
	local pickupCount = 0;
	for k, v in pairs(pickupTimers) do
		pickupCount = pickupCount + 1;
	end

	--consolePrint(type(pickupTimers[1].timeUntilRespawn))

	-- David's sort of pickupTimers
	--table.sort(pickupTimers, sortByTimeRemaining);

    local spaceCount = pickupCount - 1;
    
    -- Options
    local timerWidth = 100;
    local timerHeight = 30;
    local timerSpacing = 5; -- 0 or -1 to remove spacing
    
    -- Helpers
    local rackHeight = (timerHeight * pickupCount) + (timerSpacing * spaceCount);
    local rackTop = -(rackHeight / 2);
    local timerX = 0;
    local timerY = rackTop;

    -- iterate pickups
	for i = 1, pickupCount do
		local pickup = pickupTimers[i];
    
	    local backgroundColor = Color(0,0,0,65)
        
        -- Frame background

        nvgBeginPath();
        nvgRect(timerX,timerY,timerWidth,timerHeight);
        nvgFillColor(backgroundColor);
        nvgFill();

        -- Icon
	    local iconRadius = timerHeight * 0.40;
        local iconX = timerX + iconRadius + 5;
        local iconY = timerY + (timerHeight / 2);
        local iconColor = Color(255,255,255);
        local iconSvg = "internal/ui/icons/armor";
		if pickup.type == PICKUP_TYPE_ARMOR50 then
			iconColor = Color(0,255,0);
		elseif pickup.type == PICKUP_TYPE_ARMOR100 then
			iconColor = Color(255,255,0);
		elseif pickup.type == PICKUP_TYPE_ARMOR150 then
			iconColor = Color(255,0,0);
		elseif pickup.type == PICKUP_TYPE_HEALTH100 then
			iconSvg = "internal/ui/icons/health";
			iconColor = Color(60,80,255);
		elseif pickup.type == PICKUP_TYPE_POWERUPCARNAGE then
			iconSvg = "internal/ui/icons/carnage";
			iconColor = Color(255,120,128);			
		end
      
        -- TODO: tint based on pickup type
        local svgName = "internal/ui/icons/armor";
		nvgFillColor(iconColor);
	 	nvgSvg(iconSvg, iconX, iconY, iconRadius);

        -- Time
		local t = FormatTime(pickup.timeUntilRespawn);
        local timeX = timerX + (timerWidth / 2) + iconRadius;
        local time = t.seconds + 60 * t.minutes;

		if time == 0 then
			--time = "-";
		end

		if not pickup.canSpawn then
			time = "held";
		end

        nvgFontSize(30);
        nvgFontFace("TitilliumWeb-Bold");
	    nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_TOP);

	    nvgFontBlur(0);
	    nvgFillColor(Color(255,255,255));
	    nvgText(timeX, timerY, time);
        
        timerY = timerY + timerHeight + timerSpacing;

		if pickup.type == PICKUP_TYPE_ARMOR150 then

		    local timeRemaining = pickup.timeUntilRespawn / 1000

	        -- consolePrint(timeRemaining)

			-- White background
		    nvgBeginPath();
		    nvgCircle(0, 0, 25 - 2)
		    nvgFillColor(Color(255,255,255,200)); 
		    nvgFill();



		    nvgBeginPath();
		    nvgCircle(0, 0, 25 - timeRemaining)
		    nvgFillColor(Color(255,0,0,200)); 

		    nvgStrokeColor(Color(0,0,0,200));
		    nvgStrokeWidth(3);
		    nvgStroke();

		    nvgFill();
	    end


		if pickup.type == PICKUP_TYPE_ARMOR100 then

		    local timeRemaining = pickup.timeUntilRespawn / 1000

	        -- consolePrint(timeRemaining)

			-- White background`
		    nvgBeginPath();
		    nvgCircle(100, 0, 25 - 2)
		    nvgFillColor(Color(255,255,255,200)); 
		    nvgFill();



		    nvgBeginPath();
		    nvgCircle(100, 0, 25 - timeRemaining)
		    nvgFillColor(Color(255,255,0,200)); 

		    nvgStrokeColor(Color(0,0,0,200));
		    nvgStrokeWidth(3);
		    nvgStroke();

		    nvgFill();
	    end

    end
end
