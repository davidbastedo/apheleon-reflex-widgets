require "base/internal/ui/reflexcore"

apheleon_TimerTimeline =
{
};
registerWidget("apheleon_TimerTimeline");


local PickupVis = {};
PickupVis[PICKUP_TYPE_ARMOR50] = {};
PickupVis[PICKUP_TYPE_ARMOR50].svg = "internal/ui/icons/armor";
PickupVis[PICKUP_TYPE_ARMOR50].color = Color(0,255,0);
PickupVis[PICKUP_TYPE_ARMOR100] = {};
PickupVis[PICKUP_TYPE_ARMOR100].svg = "internal/ui/icons/armor";
PickupVis[PICKUP_TYPE_ARMOR100].color = Color(255,255,0);
PickupVis[PICKUP_TYPE_ARMOR150] = {};
PickupVis[PICKUP_TYPE_ARMOR150].svg = "internal/ui/icons/armor";
PickupVis[PICKUP_TYPE_ARMOR150].color = Color(255,0,0);
PickupVis[PICKUP_TYPE_HEALTH100] = {};
PickupVis[PICKUP_TYPE_HEALTH100].svg = "internal/ui/icons/health";
PickupVis[PICKUP_TYPE_HEALTH100].color = Color(60,80,255);
PickupVis[PICKUP_TYPE_POWERUPCARNAGE] = {};
PickupVis[PICKUP_TYPE_POWERUPCARNAGE].svg = "internal/ui/icons/carnage";
PickupVis[PICKUP_TYPE_POWERUPCARNAGE].color = Color(255,120,128);

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- Create a list of custom item labels to help differentiate between duplicate items

customItemLabels = {};
customItemLabels["cpm3"..PICKUP_TYPE_ARMOR100..1] = "Rail";
customItemLabels["cpm3"..PICKUP_TYPE_ARMOR100..2] = "LG";
customItemLabels["cpm22"..PICKUP_TYPE_ARMOR50..1] = "GL";
customItemLabels["cpm22"..PICKUP_TYPE_ARMOR50..2] = "RL";
customItemLabels["dp5"..PICKUP_TYPE_ARMOR100..1] = "Plasma";
customItemLabels["dp5"..PICKUP_TYPE_ARMOR100..2] = "Tele";

function mapItemLabel(map, itemtype, itemlabel)
	if not (customItemLabels[map:lower()..itemtype..itemlabel] == nil) then
		return customItemLabels[map:lower()..itemtype..itemlabel]
	else
		return itemlabel
	end
end

function apheleon_TimerTimeline:draw()

	-- Sort the items to hopefully make the label maker more consistent
	--  i noticed in 33.4 that the order of the items in pickupTimers changed. 
	--  sort logic:  sort by armor - mega - carnage

	--table.sort(pickupTimers, function(a,b) return a.type<b.type end)

	table.sort(pickupTimers, function(a,b) if a.type >= 60 or b.type >=60 then return a.type < b.type; elseif (a.type >= 50 and a.type < 60) or (b.type >= 50 and b.type < 60) then return a.type > b.type;		else return a.type < b.type;		end;			end)

    -- Early out if HUD shouldn't be shown.
    if not shouldShowHUD() then return end;

    local translucency = 192;
	
   	-- Find player
	local player = getPlayer();

	-- count pickups
	local pickupCount = #pickupTimers;
    
    -- Timeline History Duration
	-- num of historical seconds to show in the timeline
    local timelineDuration = 30


	-- Frame Size
	local frameHeight = 50
	local frameWidth = 500

	-- Frame Positiion
	local frameLeft = -frameWidth / 2
	--local frameLeft = 0
	local frameTop = 0
	local frameBottom = frameTop + frameHeight

	-- Timeline Positioning and Size
	local timelineTop = frameTop + (frameHeight / 2);
	local timelineLeft = frameLeft;
	local timelineRight = frameLeft + frameWidth;

	local timelineWidth = frameWidth;

	-- Spawn Box Positioning and Size
	local spawnBoxEntryWidth = 13
	local spawnBoxRight = frameLeft - 25;
	local spawnBoxPadding = 4

	-- Draw the timeline frame
    local frameBackgroundColor = Color(0,0,0,90)
    nvgBeginPath();
    nvgRoundedRect(frameLeft ,frameTop,frameWidth,frameHeight,0);
    nvgFillColor(frameBackgroundColor);
    nvgFill();

    -- Draw the timeline dividing line strokes
    -- TODO: Order the ietms based on when they spawned
    for i=5, timelineDuration-1, 5 do
		markerX = timelineWidth * i / (timelineDuration)
		markerX = markerX + timelineLeft

		nvgStrokeColor(Color(255,255,255, 200));
		nvgStrokeWidth(2)

		nvgBeginPath();
		nvgMoveTo(markerX, frameTop);
		nvgLineTo(markerX, frameTop + (frameHeight / 4));
		nvgStroke();

		nvgBeginPath();
		nvgMoveTo(markerX, frameBottom);
		nvgLineTo(markerX, frameBottom - (frameHeight / 4));
		nvgStroke();
    end


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

	--======================
	-- Fnd the next upcoming item
	--   why: for use when determing what item to show the time for in the timeline
	--   logic: for the item that is coming up next, set nextUp = true

	small = nil;

	for i=1, #pickupTimers do
		if (small == nil and pickupTimers[i].timeUntilRespawn > 0) then
			small = pickupTimers[i]
		end
		if (small ~= nil) then
			if (pickupTimers[i].timeUntilRespawn > 0 and pickupTimers[i].timeUntilRespawn < small.timeUntilRespawn) then
				small = pickupTimers[i]
			end
		end
	end

	if (small ~= nil) then
		small.nextUp = true;
	end

	--=======================
    -- iterate pickups for rendering
	for i = 1, pickupCount do
		local pickup = pickupTimers[i];
		local vis = PickupVis[pickup.type];
	    if vis ~= nil then
			local timeUntilRespawn = pickup.timeUntilRespawn

			-- Don't draw items that will show up off of the timeline range, e.g. carnage
			if pickup.timeUntilRespawn > timelineDuration * 1000 then break end;

			-- Configure the item icons and color

		    local iconRadius = 20; -- update this?

		    -- scaledTimerLocation gives a 0.0 to 1.0 number of how close the item is to spawning
		    --  along the timelineDuration (e.g. 40 seconds wide)

			local scaledTimerLocation = timeUntilRespawn / (timelineDuration * 1000)

			-- this stretches item positining to match the configured timelineWidth
			local iconX = scaledTimerLocation * timelineWidth
			iconX = iconX + timelineLeft

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
				if not pickup.canSpawn and timelineDuration >= 30  then
					iconColor = Color(150,161,255);
					iconX = ( timelineWidth * 30000 / (timelineDuration * 1000) ) + timelineLeft
					pickup.label = "HELD"
				end

			elseif pickup.type == PICKUP_TYPE_POWERUPCARNAGE then
				iconSvg = "internal/ui/icons/carnage";
				iconColor = Color(255,120,128);			
			end
	      
			-- Draw the icons of items that are taken 
		    if pickup.timeUntilRespawn > 0 or not pickup.canSpawn then

				nvgFillColor(iconColor);

				-- Make the icons get bigger every second for the last 5 seconds
				if ( pickup.nextUp == true and (
						(pickup.timeUntilRespawn < 5100 and pickup.timeUntilRespawn > 4900)
						or (pickup.timeUntilRespawn < 4100 and pickup.timeUntilRespawn > 3900)
						or (pickup.timeUntilRespawn < 3100 and pickup.timeUntilRespawn > 2900)
						or (pickup.timeUntilRespawn < 2100 and pickup.timeUntilRespawn > 1900)
						or (pickup.timeUntilRespawn < 1100 and pickup.timeUntilRespawn > 900) 
						or (pickup.timeUntilRespawn < 200) 
						)
					) then
					iconRadius = iconRadius + 10
				end

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
					return string.format("%." .. (idp or 0) .. "f", num)
				end

				-- Only show timer for the next upcoming item at all times
				--  show integers for time > 5
				--  show first decimal for time < 5
				if (pickup.canSpawn and pickup.nextUp == true) then
					nvgFontSize(25);
				    nvgFillColor(Color(255,255,255));
				    nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE);
				    if (pickup.timeUntilRespawn < 5000) then
				    	nvgFillColor(Color(255,70,70));
				    	time = round(pickup.timeUntilRespawn / 1000, 1)
				    else
				    	time = round(pickup.timeUntilRespawn / 1000, 0)
				    end
				    nvgText(iconX, iconY - 35, time);
				end
			end

			-- Draw list of items that are spawned
			if pickup.timeUntilRespawn == 0 and pickup.canSpawn then

				-- Draw black drop shaddow
			    nvgBeginPath();
			    nvgRoundedRect(spawnBoxRight - spawnBoxEntryWidth + 2,frameTop + 2,spawnBoxEntryWidth,frameHeight,0);
			    nvgFillColor(Color(0,0,0));
			    nvgFill();
			    --spawnBoxRight = spawnBoxRight - spawnBoxPadding - spawnBoxEntryWidth

			    -- Draw color bars for each spawned item
			    nvgBeginPath();
			    nvgRoundedRect(spawnBoxRight - spawnBoxEntryWidth,frameTop,spawnBoxEntryWidth,frameHeight,0);
			    nvgFillColor(iconColor);
			    nvgFill();
			    spawnBoxRight = spawnBoxRight - spawnBoxPadding - spawnBoxEntryWidth
			end
		end
	end
end