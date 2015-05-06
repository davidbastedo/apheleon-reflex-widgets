require "base/internal/ui/reflexcore"

apheleon_HealthBar =
{
    timer = 0;
    direction  = 1;
};
registerWidget("apheleon_HealthBar");


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function apheleon_HealthBar:draw()
 
    timeLoopDuration = .25

    if self.timer >= timeLoopDuration then  
        self.direction = -1                 
    elseif self.timer <= 0 then
        self.direction = 1
    end

    self.timer = self.timer + (deltaTime * self.direction);

    -- Early out if HUD shouldn't be shown.
    if not shouldShowHUD() then return end;

    -- Find player 
    local player = getPlayer();

    -- player.health = 20 -- for testing

    -- Options
    local showFrame = true;
    local showIcon = false;
    local flatBar = false; -- fix this later
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
    local flashingBarAlpha = lerp(0,barAlpha,self.timer / timeLoopDuration)
	local barBgAlpha = 40;
    local iconAlpha = 32;

    local barColor;
    if player.health > 100 then barColor = Color(16,116,217, barAlpha) end
    if player.health <= 100 then barColor = Color(2,167,46, barAlpha) end
    if player.health <= 80 then barColor = Color(255,176,14, barAlpha) end
    if player.health <= 30 then barColor = Color(236,0,0, flashingBarAlpha) end

    local barBackgroundColor;    
    if player.health > 100 then barBackgroundColor = Color(10,68,127, barBgAlpha) end
    if player.health <= 100 then barBackgroundColor = Color(14,53,9, barBgAlpha) end
    if player.health <= 80 then barBackgroundColor = Color(105,67,4, barBgAlpha) end
    if player.health <= 30 then barBackgroundColor = Color(141,30,10, barBgAlpha) end    

    -- Helpers
    local frameLeft = -frameWidth;
    local frameTop = -frameHeight;
    local frameRight = 0;
    local frameBottom = 0;

    local barWidth = frameWidth - numberSpacing - framePadding - iconSpacing;
    local barHeight = ( frameHeight - (framePadding * 3) ) / 2;
 
    local barLeft = frameLeft + framePadding;
    local barRight = frameRight - numberSpacing - iconSpacing;

    local UpperBarTop = frameTop + framePadding;
    local LowerBarTop = frameTop + framePadding + barHeight + framePadding;


    local barBottom = frameBottom - framePadding;
    local UpperBarBottom = frameBottom - framePadding - barHeight - framePadding;
    local LowerBarBottom = frameBottom - framePadding;


    local fontX = barRight + (numberSpacing / 2);
    local fontY = -(frameHeight / 2);
    local fontSize = frameHeight * .75;
 

    local fillWidth;
    if player.health > 100 then fillWidth = (barWidth / 100) * (player.health - 100);
    else fillWidth = (barWidth / 100) * player.health; end

    -- Black Frame
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

    -- Health Bar 

    local UpperHealthBarWidth;
    local LowerHealthBarWidth;

    if player.health > 100 then 
        UpperHealthBarWidth = barWidth;
        LowerHealthBarWidth = (barWidth / 100) * (player.health - 100);
    else
        UpperHealthBarWidth = (barWidth / 100) * player.health
        LowerHealthBarWidth = 0
    end

    -- Upper Health Bar
    if UpperHealthBarWidth > 0 then
        nvgBeginPath();
        nvgRect(barRight, UpperBarBottom, -UpperHealthBarWidth, -barHeight);
        -- nvgRect(x, y, w, h)
        nvgFillColor(barColor); 
        nvgFill();
    end

    -- Lower Health Bar
    if LowerHealthBarWidth > 0 then

        nvgBeginPath();
        nvgRect(barRight, LowerBarBottom, -LowerHealthBarWidth, -barHeight);
        --nvgRect(x, y, w, h)
        nvgFillColor(barColor); 
        nvgFill();
    end

    -- Shading
    if flatBar == false then

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

        if player.health > 100 then
            nvgFontBlur(10);
            nvgFillColor(Color(64, 64, 200));
            nvgText(fontX, fontY, player.health);
     
        elseif player.health <= 30 then
            nvgFontBlur(10);
            nvgFillColor(Color(200, 64, 64));
            nvgText(fontX, fontY, player.health);
        end

    end
    
    nvgFontBlur(0);
    nvgFillColor(fontColor);
    nvgText(fontX, fontY, player.health);

    -- Draw icon
    
    if showIcon then
        local iconX = -(iconSpacing / 2) - framePadding;
        local iconY = -(frameHeight / 2);
        local iconSize = (barHeight / 2) * 0.9;
        local iconColor;

        if colorIcon then iconColor = barColor
        else iconColor = Color(230,230,230, iconAlpha);
        end

		nvgFillColor(iconColor);
        nvgSvg("internal/ui/icons/health", iconX, iconY, iconSize)
    end

    -- Debug position
 --    nvgBeginPath();
 -- nvgRect(fontX, fontY, 3, 3);
 -- nvgFillColor(Color(255, 255, 0, 255));
 -- nvgFill();
    
    end
