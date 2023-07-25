local players = {}
local titleFont = CreateFont("TitleFont")
local bg = frame:CreateTexture(nil, "BACKGROUND")
local titleBg = frame:CreateTexture(nil, "BACKGROUND")
local frame = CreateFrame("Frame", "GankSinatraKosFrame", UIParent)
local kosEditBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
local button = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
local addButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
local removeButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
local cancelButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
local reloadButton = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")

GankSinatraKos_RedList = GankSinatraKos_RedList or { }

frame:SetSize(220, 350)
frame:SetPoint("CENTER")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:SetUserPlaced(true)
frame:SetClampedToScreen(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "GankSinatraKos" then
        for _, name in ipairs(GankSinatraKos_RedList) do
            print(name)
        end
    end
end)

frame:RegisterEvent("ADDON_LOADED")

bg:SetAllPoints(true)
bg:SetTexture(0, 0, 0, 0.5)
frame.bg = bg

frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
frame.title:SetPoint("TOP", frame, "TOP", 0, -10)
frame.title:SetText("Gank Sinatra KoS!")
frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.text:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -35)
frame.text:SetText("Players in Combat Log:")
frame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
frame:SetBackdropColor(0.1, 0.1, 0.1, 0.8)

titleFont:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
frame.title:SetFontObject(titleFont)

titleBg:SetTexture(0, 0, 0, 0.5)
titleBg:SetGradientAlpha("VERTICAL", 0.8, 0.8, 0.8, 0.5, 0.6, 0.6, 0.6, 0.5)
titleBg:SetPoint("TOPLEFT", frame.title, "TOPLEFT", -10, 10)
titleBg:SetPoint("BOTTOMRIGHT", frame.title, "BOTTOMRIGHT", 10, -10)

frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        if not GankSinatraKos_RedList then
            GankSinatraKos_RedList = { "Glintana", "Sunseek" }
        end
    end
end)

local function UpdateUI()
    local names = ""
    local currentTime = GetTime()
    local offset = -30

    for playerName, lastActionTime in pairs(players) do
        if currentTime - lastActionTime <= 10 then
            if table.concat(GankSinatraKos_RedList, " "):find(playerName) then
                names = names .. "|cFFFF0000" .. playerName .. "|r\n"
                offset = offset - 25
            end
        else
            players[playerName] = nil
        end
    end

    frame.text:SetText("Players in Combat Log:\n" .. names)
end

local function OnCombatLogEvent(_, _, subEvent, eventName, sourceName, playerName)
    local status, err = pcall(function()
        if eventName and playerName ~= UnitName("player") then
            players[playerName] = GetTime()
            UpdateUI()
        end
    end)

    if not status then
    end
end

frame:SetScript("OnEvent", OnCombatLogEvent)
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT")
frame.closeButton = closeButton

SLASH_KOS1 = "/kos"
SlashCmdList["KOS"] = function(msg)
    local command, playerName = strsplit(" ", msg)
    if playerName then
        playerName = strupper(strsub(playerName, 1, 1)) .. strlower(strsub(playerName, 2))
    end
    if command == "add" and playerName then
        table.insert(redList, playerName)
        print(playerName .. " added to KOS list.")
    elseif command == "remove" and playerName then
        for i, name in ipairs(redList) do
            if name == playerName then
                table.remove(redList, i)
                print(playerName .. " removed from KOS list.")
                return
            end
        end
        print(playerName .. " not found in KOS list.")
    elseif command == "show" then
        frame:Show()
    elseif command == "list" then
        local kosList = GankSinatraKos_RedList
        if #kosList > 0 then
            print("Current KOS list:")
            local output = "KOS List: "
            for i, playerName in ipairs(kosList) do
                output = output .. i .. ". " .. playerName .. " "
            end
            print(output)
        else
            print("KOS List is empty.")
        end

    elseif command == "clear" then
        wipe(redList)
        print("KOS list cleared.")
    elseif command == "help" then
        print("Gank Sinatra KoS is an addon that lets you keep track of players you want to target in PvP.")
        print("You can add players to your KOS (Kill On Sight) list, and their names will be highlighted in your combat log.")
        print("Commands:")
        print("/kos add [playerName] - adds a player to your KOS list")
        print("/kos remove [playerName] - removes a player from your KOS list")
        print("/kos show - shows the KOS frame")
        print("/kos list - shows the current KOS list")
        print("/kos clear - clears the KOS list")
    end
end

addButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 10, 10)
addButton:SetSize(60, 30)
addButton:SetText("Add")

removeButton:SetPoint("LEFT", addButton, "RIGHT", 10, 0)
removeButton:SetSize(60, 30)
removeButton:SetText("Remove")

cancelButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 10)
cancelButton:SetSize(60, 30)
cancelButton:SetText("Cancel")
cancelButton:Hide()

cancelButton:SetScript("OnClick", function()
    kosEditBox:Hide()
    kosEditBox:SetText("")
    addButton:SetText("Add")
    removeButton:SetText("Remove")
    cancelButton:Hide()
end)

kosEditBox:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 10, 50)
kosEditBox:SetSize(120, 30)
kosEditBox:Hide()

cancelButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 50)
cancelButton:SetSize(60, 30)
cancelButton:SetText("Cancel")
cancelButton:Hide()
cancelButton:SetScript("OnClick", function()
    kosEditBox:Hide()
    kosEditBox:SetText("")
    addButton:SetText("Add")
    removeButton:SetText("Remove")
    cancelButton:Hide()
end)

addButton:SetScript("OnClick", function()
    if kosEditBox:IsShown() then
        local playerName = kosEditBox:GetText()
        playerName = strupper(strsub(playerName, 1, 1)) .. strlower(strsub(playerName, 2))
        table.insert(GankSinatraKos_RedList, playerName)
        kosEditBox:SetText("")
        kosEditBox:Hide()
        addButton:SetText("Add")
        cancelButton:Hide()
        print(playerName .. " added to KOS list.")
    else
        kosEditBox:Show()
        addButton:SetText("Confirm")
        cancelButton:Show()
    end
end)

removeButton:SetScript("OnClick", function()
    if kosEditBox:IsShown() then
        local playerName = kosEditBox:GetText()
        playerName = strupper(strsub(playerName, 1, 1)) .. strlower(strsub(playerName, 2))
        for i, name in ipairs(GankSinatraKos_RedList) do
            if name == playerName then
                table.remove(GankSinatraKos_RedList, i)
                kosEditBox:SetText("")
                kosEditBox:Hide()
                removeButton:SetText("Remove")
                cancelButton:Hide()
                print(playerName .. " removed from KOS list.")
                return
            end
        end
        print(playerName .. " not found in KOS list.")
    else
        kosEditBox:Show()
        removeButton:SetText("Confirm")
        cancelButton:Show()
    end
end)

showKosButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
showKosButton:SetPoint("LEFT", removeButton, "RIGHT", 10, 0)
showKosButton:SetSize(60, 30)
showKosButton:SetText("KoS List")
showKosButton:SetScript("OnClick", function()
    local kosList = GankSinatraKos_RedList
    if #kosList > 0 then
        local output = "KOS List: "
        for i, playerName in ipairs(kosList) do
            output = output .. i .. ". " .. playerName .. " "
        end
        print(output)
    else
        print("KOS List is empty.")
    end
end)

button:SetSize(120, 30)
button:SetPoint("CENTER", frame, "BOTTOM", 0, -15)

button:SetText("Yell KOS!")

button:SetScript("OnClick", function()
    local names = ""
    local currentTime = GetTime()

    for playerName, lastActionTime in pairs(players) do
        if currentTime - lastActionTime <= 10 then
            if table.concat(GankSinatraKos_RedList, " "):find(playerName) then
                names = names .. playerName .. " "
            end
        else
            players[playerName] = nil
        end
    end

    if names ~= "" then
        -- Yell the names
        SendChatMessage("Enemies " .. names .. "are in sight!", "YELL")
        print("Yelled KOS player names: " .. names)
    else
        print("No KOS players in sight.")
    end
end)

reloadButton:SetSize(60, 20)
reloadButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -10, 18)

reloadButton:SetText("Reload")

reloadButton:SetScript("OnClick", function()
    ReloadUI()
end)
