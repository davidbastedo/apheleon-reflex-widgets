require "base/internal/ui/reflexcore"

-- maximum number of historical key presses to save
maxListLength =  10

apheleon_InputList =
{
    previousState = {};
    buttonHistory = {};
    ---maxListLength = 10
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
function comparePastAndCurrentButtonStates(past, current)

    listOfButtonChanges = {};

    --consolePrint("----")
    for k, v in pairs(current) do
        --consolePrint("k: " .. k .. " v: " .. tostring(v))
        if(wasButtonPressedDown(past[k], v)) then
            --consolePrint(k.." was pressed down!!!")
            table.insert(listOfButtonChanges, "down_"..k)
        end
        if(wasButtonPressedUp(past[k], v)) then
            --consolePrint(k.." was pressed up!!!")
            table.insert(listOfButtonChanges, "up_"..k)
        end
    end

    return listOfButtonChanges;
end

function joinTables(t1, t2)
    for k,v in ipairs(t2) do
        table.insert(t1, v)
    end 
 
    -- trim the table until it is the maximum length
    while (#t1 > maxListLength) do
        table.remove(t1,1)
    end

    return t1
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function apheleon_InputList:draw()

    -- Early out if HUD shouldn't be shown.
    if not shouldShowHUD() then return end;

    -- Find the current player's buttons 
    self.currentState = getPlayer().buttons


    nvgFontSize(50)

    -- if (self.currentState.jump or self.previousState.jump) then
    --     consolePrint("----BEGIN----")
    --     consolePrint("CurrentJumpState: "..tostring(self.currentState.jump))
    --     consolePrint("PreviousJumpState: "..tostring(self.previousState.jump))
    --     consolePrint("----END----")
    -- end


    wasButtonPressedUp(self.previousState.jump, self.currentState.jump)


    -- for key,value in pairs(self.previousState) do consolePrint(key); end
    -- consolePrint("--")


    -- generate a list of keys pressed or lifted since the last frame
    listOfButtonChanges = comparePastAndCurrentButtonStates(self.previousState, self.currentState)

    -- add the list of recent key presses to the global list of key presses
    self.buttonHistory = joinTables(self.buttonHistory, listOfButtonChanges)


    -- DEBUGGING
    consolePrint("---DEBUGGING---")
    for k, v in pairs(self.buttonHistory) do
        consolePrint("k: " .. tostring(k) .. "  v: " .. tostring(v))
    end

    myString = '';
    for k, v in pairs(self.buttonHistory) do
        myString = myString.." "..tostring(v).." "
    end
    nvgText(-600, -200, myString);





    -- TODO: Draw the list of items on the hud

    -- This must be at the end of the script
    self.previousState = shallowcopy(self.currentState)

end
