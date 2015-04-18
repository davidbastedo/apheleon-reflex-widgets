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

    local gaugeMin = 0 -- not used currently
    local gauge180DegMark = 700 -- this is used to 'scale' how fast the gauge needle moves
    local startingGaugeAngle = 40 -- where does the needle start?

    -- Colors
    local textColor = Color(255,255,255,255);

    local gaugeBackgroundColor = Color(0,0,0,120);
    local gaugeBackgroundCenterColor = Color(255,0,0,100);
    local gaugeLineColor = Color(255,255,255,255);
    local gaugeEdgeColor = Color(255,255,255,80);

    local gaugeTickColor = Color(255,255,255,200);

    -- Draw guage background
    nvgBeginPath();
    nvgCircle(circleCenterX, circleCenterY, circleRadius)
    nvgFillColor(gaugeBackgroundColor);
    nvgFill();

    -- Draw gauge edge
    -- nvgStrokeColor(gaugeEdgeColor)
    -- nvgStrokeWidth(3)
    -- nvgStroke()

    --Draw gauge inner circle
    nvgBeginPath();
    nvgCircle(circleCenterX, circleCenterY, circleRadius / 5)
    nvgFillColor(gaugeBackgroundCenterColor);
    nvgFill();

    -- Draw gauge center circle point
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

    -- Draw gauge tick circle at each 100 ups
    tickDegreesMax = 180 + (startingGaugeAngle * 2)
    tickSpeedMax = (tickDegreesMax * gauge180DegMark) / 180

    for i=0, tickSpeedMax, 100 do
        tickDegree = i * 180 / gauge180DegMark
        tickx = circleRadius * -math.cos(degreesToRadians(tickDegree - startingGaugeAngle)) + circleCenterX
        ticky = circleRadius * -math.sin(degreesToRadians(tickDegree - startingGaugeAngle)) + circleCenterY

        nvgBeginPath();
        nvgCircle(tickx, ticky, circleRadius / 30)
        nvgFillColor(gaugeTickColor);
        nvgFill();
    end

    -- Text
    nvgFontSize(fontSize);
    nvgFontFace("TitilliumWeb-Bold");
    nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE);
    nvgFontBlur(0);
    nvgFillColor(textColor);
    nvgText(0, 50, speed .. "ups");




end
