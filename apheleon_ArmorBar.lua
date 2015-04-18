require "base/internal/ui/reflexcore"

apheleon_ArmorBar =
{
};
registerWidget("apheleon_ArmorBar");

-- smoothedHealth += (currentHealth - oldHealth) * deltaTime

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function apheleon_ArmorBar:draw()

    -- Early out if HUD shouldn't be shown.
    if not shouldShowHUD() then return end;

	local player = getPlayer();

    -- player.armor = 30 -- for testing

    -- Options
    local showFrame = true;
    local showIcon = false;
    local flatBar = false;
    local colorNumber = false;
    local colorIcon = false;
    
    -- Size and spacing
    local frameWidth = 460;
    local frameHeight = 105;
    local framePadding = 5;
    local numberSpacing = 100;
    local iconSpacing;

    if showIcon then iconSpacing = 40
    else iconSpacing = 0;
    end
	
    -- Colors
    local frameColor = Color(0,0,0,128);
    local barAlpha = 220;
	local barBgAlpha = 40;
    local iconAlpha = 32;

    local barColor;
    if player.armorProtection == 0 then barColor = Color(2,167,46, barAlpha) end
    if player.armorProtection == 1 then barColor = Color(255,176,14, barAlpha) end
    if player.armorProtection == 2 then barColor = Color(236,0,0, barAlpha) end

    local barBackgroundColor;    
    if player.armorProtection == 0 then barBackgroundColor = Color(14,53,9, barBgAlpha) end
    if player.armorProtection == 1 then barBackgroundColor = Color(122,111,50, barBgAlpha) end
    if player.armorProtection == 2 then barBackgroundColor = Color(141,30,10, barBgAlpha) end    

    -- Helpers
    local frameLeft = 0;
    local frameTop = -frameHeight;
    local frameRight = frameWidth;
    local frameBottom = 0;
 
    local barLeft = frameLeft + iconSpacing + numberSpacing
    local barTop = frameTop + framePadding;
    local barRight = frameRight - framePadding;
    local barBottom = frameBottom - framePadding;

    local barWidth = frameWidth - numberSpacing - framePadding - iconSpacing;
    local barHeight = ( frameHeight - (framePadding * 3) ) / 2; --updated

    local UpperBarTop = frameTop + framePadding;
    local LowerBarTop = frameTop + framePadding + barHeight + framePadding;

    local UpperBarBottom = frameBottom - framePadding - barHeight - framePadding;
    local LowerBarBottom = frameBottom - framePadding;

    local fontX = barLeft - (numberSpacing / 2);
    local fontY = -(frameHeight / 2);
    local fontSize = frameHeight * .75;
 
    if player.armorProtection == 0 then fillWidth = math.min((barWidth / 100) * player.armor, barWidth);
    elseif player.armorProtection == 1 then fillWidth = math.min((barWidth / 150) * player.armor, barWidth);
    elseif player.armorProtection == 2 then fillWidth = (barWidth / 200) * player.armor;
    end

    -- Frame
    if showFrame then
        nvgBeginPath();
        nvgRoundedRect(frameRight, frameBottom, -frameWidth, -frameHeight, 5);
        nvgFillColor(frameColor); 
        nvgFill();
    end

    -- Background transparent color
    -- nvgBeginPath();
    -- nvgRect(barRight, barBottom , -barWidth, -barHeight);
    -- nvgFillColor(barBackgroundColor); 
    -- nvgFill();
    
    -- Original Armor Bar
 --    nvgBeginPath();
 --    nvgRect(barLeft, barBottom, fillWidth, -barHeight);
	-- nvgFillColor(barColor); 
	-- nvgFill();
    

    local UpperArmorBarWidth;
    local LowerArmorBarWidth;
    if player.armor > 100 then 
        UpperArmorBarWidth = barWidth;
        LowerArmorBarWidth = (barWidth / 100) * (player.armor - 100);
    else
        UpperArmorBarWidth = (barWidth / 100) * player.armor
        LowerArmorBarWidth = 0
    end

    -- Upper Armor Bar

    if UpperArmorBarWidth > 0 then
        nvgBeginPath();
        nvgRect(barRight, UpperBarBottom, -UpperArmorBarWidth, -barHeight);
        -- nvgRect(x, y, w, h)
        nvgFillColor(barColor); 
        nvgFill();
    end

    -- Lower Armor Bar
    if LowerArmorBarWidth > 0 then

        nvgBeginPath();
        nvgRect(barRight, LowerBarBottom, -LowerArmorBarWidth, -barHeight);
        --nvgRect(x, y, w, h)
        nvgFillColor(barColor); 
        nvgFill();
    end


    -- Shading
    if flatBar == false then
    
        -- nvgBeginPath();
        -- nvgRect(barLeft, barTop, barWidth, barHeight);
        -- nvgFillLinearGradient(barLeft, barTop, barLeft, barBottom, Color(255,255,255,30), Color(255,255,255,0))
        -- nvgFill();
    
        -- nvgBeginPath();
        -- nvgMoveTo(barLeft, barTop);
        -- nvgLineTo(barRight, barTop);
        -- nvgStrokeWidth(1)
        -- nvgStrokeColor(Color(255,255,255,60));
        -- nvgStroke();
    
        -- upper bar bevel overlay
        nvgBeginPath();
        nvgRect(barLeft, UpperBarTop, barWidth, barHeight / 2);         --nvgRect(x, y, w, h)
        nvgFillLinearGradient(barLeft, UpperBarTop, barLeft, UpperBarBottom - (barHeight / 2) , Color(255,255,255,40), Color(255,255,255,0))
        -- nvgFillLinearGradient(startx, starty, endx, endy, startcol, endcol)
        nvgFill();

        -- lower bar bevel overlay
        nvgBeginPath();
        nvgRect(barLeft, LowerBarTop, barWidth, barHeight / 2);
        nvgFillLinearGradient(barLeft, LowerBarTop, barLeft, LowerBarBottom - (barHeight / 2), Color(255,255,255,40), Color(255,255,255,0))
        nvgFill();

        -- upper bar 1 px edge on top
        nvgBeginPath();
        nvgMoveTo(barLeft, UpperBarTop);
        nvgLineTo(barRight, UpperBarTop);
        nvgStrokeWidth(1)
        nvgStrokeColor(Color(255,255,255,60));
        nvgStroke();
    
        -- lower bar 1 px edge on top
        nvgBeginPath();
        nvgMoveTo(barLeft, LowerBarTop);
        nvgLineTo(barRight, LowerBarTop);
        nvgStrokeWidth(1)
        nvgStrokeColor(Color(255,255,255,60));
        nvgStroke();

    end
          
    -- Draw numbers
    local fontColor;
    
    if colorNumber then fontColor = barColor
    else fontColor = Color(230,230,230);
    end
    
    nvgFontSize(fontSize);
	nvgFontFace(FONT_HUD);
	nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE);
    
    if not colorNumber then -- Don't glow if the numbers are colored (looks crappy)
    
	    if player.armor <= 30 then
        nvgFontBlur(10);
        nvgFillColor(Color(200, 64, 64));
	    nvgText(fontX, fontY, player.armor);
        end
	       
    end
    
	nvgFontBlur(0);
	nvgFillColor(fontColor);
	nvgText(fontX, fontY, player.armor);
    
    -- Draw icon
    
    if showIcon then
        local iconX = (iconSpacing / 2) + framePadding;
        local iconY = -(frameHeight / 2);
        local iconSize = (barHeight / 2) * 0.9;
        local iconColor;
    
        if colorIcon then iconColor = barColor
        else iconColor = Color(230,230,230, iconAlpha);
        end
    
		nvgFillColor(iconColor);
        nvgSvg("internal/ui/icons/armor", iconX, iconY, iconSize);
    end

    -- Debug position
    --nvgBeginPath();
	--nvgRect(fontX, fontY, 3, 3);
	--nvgFillColor(Color(255, 255, 0, 255));
	--nvgFill();
    
    
end
