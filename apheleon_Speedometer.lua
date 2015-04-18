require "base/internal/ui/reflexcore"

apheleon_Speedometer =
{
};
registerWidget("apheleon_Speedometer");


function degreesToRadians(angle)
    return angle * (math.pi / 180)
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function apheleon_Speedometer:draw()
 
    -- Early out if HUD shouldn't be shown.
    if not shouldShowHUD() then return end;


    -- Find player 
    local player = getPlayer()
    local speed = math.ceil(player.speed)

    --speed = 700
    -- Helpers

    local fontSize = 40;
    local frameX = 0;
    local frameY = 0;
    local frameWidth = 140
    local frameHeight = fontSize


    local circleCenterX = 0
    local circleCenterY = 0
    local circleRadius = 100

    -- Widget Config

    local gaugeMin = 0
    local gauge180DegMark = 700
    local startingGaugeAngle = 0

    -- Colors
    local gaugeBackgroundColor = Color(0,0,0,120);
    local gaugeLineColor = Color(255,255,255,255);
    local textColor = Color(255,255,255,255);

    -- Guage background
    nvgBeginPath();
    nvgCircle(circleCenterX, circleCenterY, circleRadius)
    nvgFillColor(gaugeBackgroundColor);
    nvgFill();

    -- Draw gauge center circle
    nvgBeginPath();
    nvgCircle(circleCenterX, circleCenterY, circleRadius / 15)
    nvgFillColor(gaugeLineColor);
    nvgFill();



    -- Calculate the line positioning as you change speeds in degrees
    speedDegrees = speed * 180 / gauge180DegMark

    linex = circleRadius * -math.cos(degreesToRadians(speedDegrees - startingGaugeAngle)) + circleCenterX
    liney = circleRadius * -math.sin(degreesToRadians(speedDegrees - startingGaugeAngle)) + circleCenterY

    -- Draw the gauage line
    nvgBeginPath();
    nvgMoveTo(circleCenterX, circleCenterY);
    nvgLineTo(linex, liney);
    nvgStrokeColor(gaugeLineColor);
    nvgStrokeWidth(5)
    nvgStroke();


    -- Text
    nvgFontSize(fontSize);
    nvgFontFace("TitilliumWeb-Bold");
    nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE);
    nvgFontBlur(0);
    nvgFillColor(textColor);
    nvgText(0, 50, speed .. "ups");




end
