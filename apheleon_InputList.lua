require "base/internal/ui/reflexcore"

apheleon_InputList =
{
    userData = {};
    previousState = {};
    buttonHistory = {};
};
registerWidget("apheleon_InputList");

function apheleon_InputList:initialize()
    -- load data stored in engine
    self.userData = loadUserData();
    
    -- ensure it has what we need
    CheckSetDefaultValue(self, "userData", "table", {});
    CheckSetDefaultValue(self.userData, "maxListLength", "number", 20);
    CheckSetDefaultValue(self.userData, "showButtonsLifted", "boolean", true);
    CheckSetDefaultValue(self.userData, "iconSize", "number", 20);
end


local ButtonIcon = {};
ButtonIcon["down_forward"] = {};
ButtonIcon["down_forward"].svg = "internal/ui/icons/InputListIcons/forward";
ButtonIcon["down_forward"].color = Color(255,255,255);
ButtonIcon["up_forward"] = {};
ButtonIcon["up_forward"].svg = "internal/ui/icons/InputListIcons/forward";
ButtonIcon["up_forward"].color = Color(255,255,255,40);

ButtonIcon["down_left"] = {};
ButtonIcon["down_left"].svg = "internal/ui/icons/InputListIcons/left";
ButtonIcon["down_left"].color = Color(255,255,255)
ButtonIcon["up_left"] = {};
ButtonIcon["up_left"].svg = "internal/ui/icons/InputListIcons/left";
ButtonIcon["up_left"].color = Color(255,255,255,40);

ButtonIcon["down_right"] = {};
ButtonIcon["down_right"].svg = "internal/ui/icons/InputListIcons/right";
ButtonIcon["down_right"].color = Color(255,255,255)
ButtonIcon["up_right"] = {};
ButtonIcon["up_right"].svg = "internal/ui/icons/InputListIcons/right";
ButtonIcon["up_right"].color = Color(255,255,255,40)

ButtonIcon["down_back"] = {};
ButtonIcon["down_back"].svg = "internal/ui/icons/InputListIcons/back";
ButtonIcon["down_back"].color = Color(255,255,255)
ButtonIcon["up_back"] = {};
ButtonIcon["up_back"].svg = "internal/ui/icons/InputListIcons/back";
ButtonIcon["up_back"].color = Color(255,255,255,40)

ButtonIcon["down_jump"] = {};
ButtonIcon["down_jump"].svg = "internal/ui/icons/InputListIcons/jump";
ButtonIcon["down_jump"].color = Color(200,255,200)
ButtonIcon["up_jump"] = {};
ButtonIcon["up_jump"].svg = "internal/ui/icons/InputListIcons/jump";
ButtonIcon["up_jump"].color = Color(200,255,200,40)

ButtonIcon["down_attack"] = {};
ButtonIcon["down_attack"].svg = "internal/ui/icons/InputListIcons/attack";
ButtonIcon["down_attack"].color = Color(255,200,200)
ButtonIcon["up_attack"] = {};
ButtonIcon["up_attack"].svg = "internal/ui/icons/InputListIcons/attack";
ButtonIcon["up_attack"].color = Color(255,200,200,40)

-- We need this function to copy the list of current button states to a backup
--  so we can compare the last frame to the current frame to check for any input changes
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
        return true;
    else
        return false;
    end
end

function wasButtonPressedUp(past, current)
    if (apheleon_InputList.userData.showButtonsLifted == false) then
        return false
    end
    if (past == true and current == false) then
        return true;
    else
        return false;
    end
end

-- Take in the last frame and the current frame, and return a single list of button changes
function comparePastAndCurrentButtonStates(past, current)
    listOfButtonChanges = {};
    for k, v in pairs(current) do
        if(wasButtonPressedDown(past[k], v)) then
            table.insert(listOfButtonChanges, "down_"..k)
        end
        if(wasButtonPressedUp(past[k], v)) then
            table.insert(listOfButtonChanges, "up_"..k)
        end
    end

    return listOfButtonChanges;
end

-- Take in two tables, merge them, and return a single table
function joinTables(t1, t2)
    for k,v in ipairs(t2) do
        table.insert(t1, v)
    end 
 
    -- trim the table until it is the maximum length
    while (#t1 > apheleon_InputList.userData.maxListLength) do
        table.remove(t1,1)
    end

    return t1
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function apheleon_InputList:draw()

    -- Early out if HUD shouldn't be shown.
    if not shouldShowHUD() then return end;

    -- UI Helpers
    local inputListPadding = 5
    local inputIconSize = self.userData.iconSize

    -- Find the current player's buttons 
    self.currentState = getPlayer().buttons

    -- generate a list of keys pressed or lifted since the last frame
    listOfButtonChanges = comparePastAndCurrentButtonStates(self.previousState, self.currentState)

    -- add the list of recent key presses to the global list of key presses
    self.buttonHistory = joinTables(self.buttonHistory, listOfButtonChanges)

    local iconX = 0
    local iconY = 0
    for k, v in pairs(self.buttonHistory) do
        local iconColor = ButtonIcon[v].color;
        local iconSvg = ButtonIcon[v].svg;
        iconX = (k - 1) * (inputIconSize * 2) + inputListPadding * (k - 1)
        nvgFillColor(iconColor);
        nvgSvg(iconSvg, iconX, iconY, inputIconSize);
    end

    -- This must be at the end of the script
    self.previousState = shallowcopy(self.currentState)

end


function apheleon_InputList:drawOptions(x,y)

    local user = self.userData

    uiLabel("Number of key presses shown", x, y);
    user.maxListLength = clampTo2Decimal(uiEditBox(user.maxListLength, x + 290, y, 80))
    y = y + 40;

    user.showButtonsLifted = uiCheckBox(user.showButtonsLifted, "Show icons when a button is lifted", x, y);
    y = y + 40;

    uiLabel("Icon size", x, y);
    user.iconSize = clampTo2Decimal(uiEditBox(user.iconSize, x + 290, y, 80))
    y = y + 40;

    saveUserData(user)
end