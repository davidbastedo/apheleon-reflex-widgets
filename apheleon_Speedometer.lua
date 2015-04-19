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

    local gaugeMinUPS = 0 -- TODO: not used currently
    local gaugeMaxUPS = 900 -- this is used to 'scale' how fast the gauge needle moves
    local startingGaugeAngle = 40 -- where does the needle start?
    local totalGaugeAngle = 180 + 2*(startingGaugeAngle)

    -- Colors
    local textColor = Color(255,255,255,255);

    local gaugeBackgroundColor = Color(0,0,0,120);
    local gaugeBackgroundCenterColor = Color(255,0,0,100);
    local gaugeLineColor = Color(255,255,255,255);
    --local gaugeEdgeColor = Color(255,255,255,80);
    local gaugeEdgeColor = Color(0,0,0,255);

    local gaugeTickColor = Color(255,255,255,40);

    -- Draw guage background
    nvgBeginPath();
    nvgCircle(circleCenterX, circleCenterY, circleRadius)
    nvgFillColor(gaugeBackgroundColor);
    nvgFill();

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

    -- Calculate the needle positioning as you change speeds in degrees
    speedDegrees = speed * totalGaugeAngle / gaugeMaxUPS

    linex = circleRadius * 0.9 * -math.cos(degreesToRadians(speedDegrees - startingGaugeAngle)) + circleCenterX
    liney = circleRadius * 0.9 * -math.sin(degreesToRadians(speedDegrees - startingGaugeAngle)) + circleCenterY

    -- Draw the gauage needle line
    nvgBeginPath();
    nvgMoveTo(circleCenterX, circleCenterY);
    nvgLineTo(linex, liney);
    nvgStrokeColor(gaugeLineColor);
    nvgStrokeWidth(5)
    nvgStroke();

    -- Draw gauge tick line at the edge at each 100 ups
    for i=0, gaugeMaxUPS, 100 do
        tickDegree = i * totalGaugeAngle / gaugeMaxUPS
        tick_outer_x = circleRadius * -math.cos(degreesToRadians(tickDegree - startingGaugeAngle)) + circleCenterX
        tick_outer_y = circleRadius * -math.sin(degreesToRadians(tickDegree - startingGaugeAngle)) + circleCenterY

        tick_inner_x = circleRadius * 0.8 * -math.cos(degreesToRadians(tickDegree - startingGaugeAngle)) + circleCenterX
        tick_inner_y = circleRadius * 0.8 * -math.sin(degreesToRadians(tickDegree - startingGaugeAngle)) + circleCenterY

        nvgBeginPath();
        nvgMoveTo(tick_outer_x, tick_outer_y);
        nvgLineTo(tick_inner_x, tick_inner_y);
        nvgStrokeColor(gaugeTickColor);
        nvgStrokeWidth(5)
        nvgStroke();
    end

    -- UPS Text output
    nvgFontSize(fontSize);
    nvgFontFace("TitilliumWeb-Bold");
    nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE);
    nvgFontBlur(0);
    nvgFillColor(textColor);
    nvgText(0, 50, speed .. "ups");

    -- Draw gauge edge
    nvgBeginPath();
    nvgCircle(circleCenterX, circleCenterY, circleRadius)
    nvgStrokeColor(gaugeEdgeColor)
    nvgStrokeWidth(3)
    nvgStroke()


end
