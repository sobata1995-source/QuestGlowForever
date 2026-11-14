local sparkleCVar = "outlineModeShowLootEffectWhenDisabled"
local outlineCVar = "graphicsOutlineMode"
local settings

local function Notify(message)
    print("|cffffd36aQuestGlow Forever:|r " .. message)
end

local function SetValue(name, value)
    if C_CVar.GetCVar(name) == value then
        return true
    end
    local ok = pcall(C_CVar.SetCVar, name, value)
    return ok and C_CVar.GetCVar(name) == value
end

local function EnableSparkles()
    local sparkle = C_CVar.GetCVar(sparkleCVar)
    local outline = C_CVar.GetCVar(outlineCVar)
    if not sparkle or not outline then
        return false
    end

    if not settings.previous then
        settings.previous = { sparkle = sparkle, outline = outline }
    end

    return SetValue(sparkleCVar, "1") and SetValue(outlineCVar, "0")
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function()
    QuestGlowForeverDB = QuestGlowForeverDB or {}
    settings = QuestGlowForeverDB

    if settings.enabled ~= false and not EnableSparkles() then
        Notify("Could not apply the sparkle settings.")
    end
end)

SLASH_QUESTGLOWFOREVER1 = "/questglow"
SlashCmdList.QUESTGLOWFOREVER = function(input)
    local command = input:lower():match("^%s*(.-)%s*$")
    if command == "on" then
        settings.enabled = true
        if EnableSparkles() then
            Notify("Sparkle settings applied. Restart WoW if the effect has not updated.")
        else
            Notify("Could not apply the sparkle settings.")
        end
    elseif command == "off" then
        settings.enabled = false
        local previous = settings.previous
        if previous then
            local sparkleRestored = SetValue(sparkleCVar, previous.sparkle)
            local outlineRestored = SetValue(outlineCVar, previous.outline)
            if not sparkleRestored or not outlineRestored then
                Notify("Could not restore all settings. Run /questglow off to retry.")
                return
            end
            settings.previous = nil
        end
        Notify("Disabled. Restart WoW to refresh the effect.")
    else
        Notify("Use /questglow on or /questglow off.")
    end
end
