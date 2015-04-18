require "base/internal/ui/reflexcore"

apheleon_TimerTimeline =
{
};
registerWidget("apheleon_TimerTimeline");

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


function apheleon_TimerTimeline:draw()
	
    -- Early out if HUD shouldn't be shown.
    if not shouldShowHUD() then return end;

    local translucency = 192;
	
   	-- Find player
	local player = getPlayer();

	-- count pickups
	local pickupCount = #pickupTimers;
    

    -- Options

    -- local timerSpacing = 5; -- 0 or -1 to remove spacing -- this is legacy
    
    -- Helpers
    -- local timerX = 0; --update
    -- local timerY = 0; -- update


    -- Timeline History Duration (how far back in time do we show icons?)
    local timelineDuration = 30 -- num of historical seconds to show in the timeline

	-- Frame Size
	local frameHeight = 50
	local frameWidth = 500

	-- Frame Positiion
	local frameLeft = 0
	local frameTop = 0

	-- Timeline Positioning and Size
	local timelineTop = frameTop + (frameHeight / 2);
	local timelineLeft = frameLeft;
	local timelineRight = frameLeft + frameWidth;
	local timelineWidth = frameWidth;

	-- Draw the timeline frame
    local frameBackgroundColor = Color(0,0,0,45)
    nvgBeginPath();
    nvgRect(frameLeft,frameTop,frameWidth,frameHeight);
    nvgFillColor(frameBackgroundColor);
    nvgFill();

    -- Draw the timeline line stroke
    -- TODO

	local pickedUpItemsX = frameLeft -40
	local pickedUpItemsY = timelineTop
--=========================

	-- Adds number labels for items that appear multiple times on the map


    -- Build out a count of the number of each items on the map
    itemTypeCounter = {}
    for k, v in pairs(pickupTimers) do
    	if itemTypeCounter[v.type] == nil then
    		itemTypeCounter[v.type] = 1
		else
			itemTypeCounter[v.type] = itemTypeCounter[v.type] + 1
		end
    end

    -- This removes any records where there is only one item on the map.
    for k, v in pairs(itemTypeCounter) do
    	--consolePrint("k: " .. k .. " v: " .. v)
    	if v == 1 then
    		itemTypeCounter[k] = nil
    	end
    end

    -- This adds a new "label" element to the pickup items that show up multiple times on a map

    nextItemLabel = 1;

    for ik, iv in pairs(itemTypeCounter) do 
    	--consolePrint(iv) 
    	for pk, pv in pairs(pickupTimers) do
    		--consolePrint(pv.timeUntilRespawn) 
    		if (pv.type == ik and nextItemLabel <= iv) then
    			-- consolePrint("pickupTimer index is: " .. pk)
    			-- consolePrint("nextItemLabel is: " .. nextItemLabel)
    			-- consolePrint("itemTypeCounter value is: " .. iv)
   				-- consolePrint("Item Type: " .. pv.type .. "   " .. "Respawn Time: " .. pv.timeUntilRespawn)

   				pv.label = nextItemLabel
   				--consolePrint("Item Label: " .. pv.label)
   				nextItemLabel = nextItemLabel + 1;
			if (nextItemLabel > iv) then
				nextItemLabel = 1
			end
    		end
    	end 
    end 



	--============================

	--Create a list of custom item labels to help differentiate between duplicate items

	customItemLabels = {};
	customItemLabels["cpm3"..PICKUP_TYPE_ARMOR100..1] = "LG";
	customItemLabels["cpm3"..PICKUP_TYPE_ARMOR100..2] = "Rail";
	customItemLabels["cpm22"..PICKUP_TYPE_ARMOR50..1] = "RL";
	customItemLabels["cpm22"..PICKUP_TYPE_ARMOR50..2] = "GL";

	function mapItemLabel(map, itemtype, itemlabel)
		if not (customItemLabels[map..itemtype..itemlabel] == nil) then
			return customItemLabels[map..itemtype..itemlabel]
		else
			return itemlabel
		end
	end

	--=======================
    -- iterate pickups
	for i = 1, pickupCount do
		local pickup = pickupTimers[i];
    
		local timeUntilRespawn = pickup.timeUntilRespawn

		-- Configure the item icons and color

	    local iconRadius = 20; -- update this?

	    -- scaledTimerLocation gives a 0.0 to 1.0 number of how close the item is to spawning
	    --  along the timelineDuration (e.g. 40 seconds wide)

		local scaledTimerLocation = timeUntilRespawn / (timelineDuration * 1000)

		-- this stretches item positining to match the configured timelineWidth
		local iconX = scaledTimerLocation * timelineWidth

        local iconY = timelineTop;
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

			-- when mega is held set color to light blue and position at the 30 sec mark 
			if not pickup.canSpawn then
				iconColor = Color(150,161,255);
				iconX = timelineWidth * 30000 / (timelineDuration * 1000)
				pickup.label = "HELD"
			end

		elseif pickup.type == PICKUP_TYPE_POWERUPCARNAGE then
			iconSvg = "internal/ui/icons/carnage";
			iconColor = Color(255,120,128);			
		end
      

		-- Draw the icons of items that are taken 

	    if pickup.timeUntilRespawn > 0 or not pickup.canSpawn then

			nvgFillColor(iconColor);
		    nvgSvg(iconSvg, iconX, iconY, iconRadius);

	    	-- Show label text below the icons
		    if (pickup.label) then
		    	pickup.label = mapItemLabel(world.mapName, pickup.type, pickup.label)
				nvgFontSize(25);
			    nvgFillColor(Color(255,255,255));
			    nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE);
			    nvgText(iconX, iconY + 35, pickup.label);
			end

			function round(num, idp)
				local mult = 10^(idp or 0)
				return math.floor(num * mult + 0.5) / mult
			end


			-- TODO: Only show timer for the upcoming item
			if (pickup.timeUntilRespawn < 5000 and pickup.canSpawn) then
				nvgFontSize(25);
			    nvgFillColor(Color(255,255,255));
			    nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE);

			    --time = math.floor(( (pickup.timeUntilRespawn / 1000) * 10.5 )/ 10)


			    time = round(pickup.timeUntilRespawn / 1000, 1)
			    nvgText(iconX, iconY - 35, time);
			end

		end


  --       -- Time
		-- local t = FormatTime(pickup.timeUntilRespawn);
  --       local timeX = timerX + (timerWidth / 2) + iconRadius;
  --       local time = t.seconds + 60 * t.minutes;

		-- if time == 0 then
		-- 	time = "-";
		-- end

		-- if not pickup.canSpawn then
		-- 	time = "held";
		-- end

  --       nvgFontSize(30);
  --       nvgFontFace("TitilliumWeb-Bold");
	 --    nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_TOP);

	 --    nvgFontBlur(0);
	 --    nvgFillColor(Color(255,255,255));
	 --    nvgText(timeX, timerY, time);
        
  --       timerY = timerY + timerHeight + timerSpacing;
    end
end
