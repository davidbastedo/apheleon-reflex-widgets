require "base/internal/ui/reflexcore"

apheleon_InputList =
{
    previousState = {};
    buttonHistory = {};
};
registerWidget("apheleon_InputList");

-- We need this function to copy the list of current button states 
--  so we can compare the last frame to the current frame to check for any changes
function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end


function wasButtonPressedDown(past, current)
    if (past == false and current == true) then
        --consolePrint("it was pressed")
        return true;
    else
        return false;
    end
end

function wasButtonPressedUp(past, current)
    if (past == true and current == false) then
        --consolePrint("it was lifted")
        return true;
    else
        return false;
    end
end

-- Take in the last frame and the current frame, and add any button changes to the buttonHistory list
function comparePastAndCurrentButtonStates(past, current, buttonHistory)
    --consolePrint("----")
    for k, v in pairs(current) do
        --consolePrint("k: " .. k .. " v: " .. tostring(v))`
        if(wasButtonPressedDown(past[k], v)) then
            --consolePrint(k.." was pressed down!!!")
            table.insert(buttonHistory, "down_"..k)
        end
        if(wasButtonPressedUp(past[k], v)) then
            --consolePrint(k.." was pressed up!!!")
            table.insert(buttonHistory, "up_"..k)
        end
    end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function apheleon_InputList:draw()

    -- Early out if HUD shouldn't be shown.
    if not shouldShowHUD() then return end;

    -- Find the current player's buttons 
    self.currentState = getPlayer().buttons


    nvgFontSize(90)
    nvgText(0, 0, "CurrentJumpState: "..tostring(self.currentState.jump));
    nvgText(0, -100, "PreviousJumpState: "..tostring(self.previousState.jump));


    -- if (self.currentState.jump or self.previousState.jump) then
    --     consolePrint("----BEGIN----")
    --     consolePrint("CurrentJumpState: "..tostring(self.currentState.jump))
    --     consolePrint("PreviousJumpState: "..tostring(self.previousState.jump))
    --     consolePrint("----END----")
    -- end

    nvgText(0, -200, "Pressed?: "..tostring(wasButtonPressedDown(self.previousState.jump, self.currentState.jump)));

    wasButtonPressedUp(self.previousState.jump, self.currentState.jump)


    -- for key,value in pairs(self.previousState) do consolePrint(key); end
    -- consolePrint("--")

    comparePastAndCurrentButtonStates(self.previousState, self.currentState, self.buttonHistory)

    self.previousState = shallowcopy(self.currentState)

    --table.insert(self.buttonHistory, "test");
    for k, v in pairs(self.buttonHistory) do
        consolePrint("k: " .. k .. " v: " .. v)
    end

end
