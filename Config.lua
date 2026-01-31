-- QuestProgressSound/Config.lua

local _, QPS = ...
local L = LibStub("AceLocale-3.0"):GetLocale("QuestProgressSound")

local AceDBOptions = LibStub and LibStub("AceDBOptions-3.0", true)

QPS.ui = QPS.ui or {}

local function GetSortedSoundList()
    local LSM = QPS.LSM
    local names = {}

    if LSM then
        -- LSM:List("sound") gibt bereits eine sequentielle String-Liste zurück
        local list = LSM:List("sound")

        -- Flache Kopie, falls LSM intern was Spezielles macht
        for i = 1, #list do
            names[i] = list[i]
        end

        table.sort(names, function(a, b)
            return tostring(a) < tostring(b)
        end)
    else
        -- Fallback, falls LibSharedMedia noch nicht geladen ist
        names = {
            "QPS: Quest Progress",
            "QPS: Quest Complete",
        }
    end

    return names
end

local function CreateCheckButton(parent, label, tooltip, x, y, getFunc, setFunc)
    local cb = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
    cb:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    cb.Text:SetText(label)
    if tooltip then
        cb.tooltipText = label
        cb.tooltipRequirement = tooltip
    end
    cb:SetScript("OnClick", function(self)
        setFunc(self:GetChecked())
    end)
    cb.SetFromDB = function(self)
        self:SetChecked(getFunc())
    end
    return cb
end

local function CreateSoundDropDown(parent, label, x, y, getFunc, setFunc)
    local dd = CreateFrame("Frame", nil, parent, "UIDropDownMenuTemplate")
    dd:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)

    -- Nur Label anzeigen wenn vorhanden
    if label then
        local text = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        text:SetPoint("BOTTOMLEFT", dd, "TOPLEFT", 16, 3)
        text:SetText(label)
    end

    local function Initialize(self, level)
        local sounds = GetSortedSoundList()
        local selected = UIDropDownMenu_GetSelectedValue(dd)

        for _, soundName in ipairs(sounds) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = soundName
            info.value = soundName
            info.checked = (soundName == selected)
            info.func = function(btn)
                UIDropDownMenu_SetSelectedValue(dd, btn.value)
                setFunc(btn.value)
                -- Vorschau
                QPS:PlayArbitrarySound(btn.value)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end

    dd.RefreshFromDB = function()
        local current = getFunc()
        UIDropDownMenu_Initialize(dd, Initialize)
        UIDropDownMenu_SetWidth(dd, 220)
        UIDropDownMenu_SetSelectedValue(dd, current or "None")

        -- Den aktuell selektierten Namen als Text anzeigen
        if current and current ~= "" then
            UIDropDownMenu_SetText(dd, current)
        else
            UIDropDownMenu_SetText(dd, "None")
        end
    end

    return dd
end


function QPS:CreateOptionsPanel()
    if self.optionsPanel then return end

    -- Sicherstellen, dass die DB existiert
    if not self.db then
        -- falls aus irgendeinem Grund InitializeSavedVariables noch nicht lief
        if self.InitializeSavedVariables then
            self:InitializeSavedVariables()
        end
    end

    local panel = CreateFrame("Frame", "QuestProgressSoundOptionsPanel")
    panel.name = "QuestProgressSound"

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText(L["QuestProgressSound"])

    local subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subtitle:SetText(L["Config Subtitle"])
    
    local yOffset = -60
    
    -- ==============================================
    -- BEREICH: EIGENE QUESTS
    -- ==============================================
    
    local selfHeader = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    selfHeader:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, yOffset)
    selfHeader:SetText(L["Own Quests"])
    selfHeader:SetTextColor(0.4, 0.78, 1.0)
    yOffset = yOffset - 30
    
    -- Trennlinie
    local selfSeparator = panel:CreateTexture(nil, "ARTWORK")
    selfSeparator:SetHeight(1)
    selfSeparator:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, yOffset)
    selfSeparator:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -16, yOffset)
    selfSeparator:SetColorTexture(0.3, 0.3, 0.3, 0.8)
    yOffset = yOffset - 20
    
    -- Eigener Fortschritt - Horizontal Layout
    local selfProgressLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    selfProgressLabel:SetPoint("TOPLEFT", panel, "TOPLEFT", 26, yOffset - 2)
    selfProgressLabel:SetText(L["Quest Progress"])
    selfProgressLabel:SetTextColor(1, 0.82, 0)
    
    self.ui.selfProgressDrop = CreateSoundDropDown(
        panel,
        nil,  -- Kein Label, da bereits links
        160,
        yOffset,
        function() return QPS.db.profile.sounds.selfProgress end,
        function(value) QPS.db.profile.sounds.selfProgress = value end
    )
    
    self.ui.chatProgressCheck = CreateCheckButton(
        panel,
        L["Chat Notification"] or "Chat-Benachrichtigung",
        L["Chat Notification Progress Tooltip"] or "Quest-Fortschritt im Chat anzeigen",
        430,
        yOffset - 2,
        function() return QPS.db.profile.notifications.chatProgress end,
        function(value) QPS.db.profile.notifications.chatProgress = value end
    )
    yOffset = yOffset - 50
    
    -- Eigener Abschluss - Horizontal Layout
    local selfCompleteLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    selfCompleteLabel:SetPoint("TOPLEFT", panel, "TOPLEFT", 26, yOffset - 2)
    selfCompleteLabel:SetText(L["Quest Completion"])
    selfCompleteLabel:SetTextColor(1, 0.82, 0)
    
    self.ui.selfCompleteDrop = CreateSoundDropDown(
        panel,
        nil,  -- Kein Label, da bereits links
        160,
        yOffset,
        function() return QPS.db.profile.sounds.selfComplete end,
        function(value) QPS.db.profile.sounds.selfComplete = value end
    )
    
    self.ui.chatCompleteCheck = CreateCheckButton(
        panel,
        L["Chat Notification"] or "Chat-Benachrichtigung",
        L["Chat Notification Complete Tooltip"] or "Quest-Abschluss im Chat anzeigen",
        430,
        yOffset - 2,
        function() return QPS.db.profile.notifications.chatComplete end,
        function(value) QPS.db.profile.notifications.chatComplete = value end
    )
    yOffset = yOffset - 60
    
    -- ==============================================
    -- BEREICH: GRUPPENQUESTS
    -- ==============================================
    
    local groupHeader = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    groupHeader:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, yOffset)
    groupHeader:SetText(L["Group Quests"])
    groupHeader:SetTextColor(0.4, 0.78, 1.0)
    yOffset = yOffset - 30
    
    -- Trennlinie
    local groupSeparator = panel:CreateTexture(nil, "ARTWORK")
    groupSeparator:SetHeight(1)
    groupSeparator:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, yOffset)
    groupSeparator:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -16, yOffset)
    groupSeparator:SetColorTexture(0.3, 0.3, 0.3, 0.8)
    yOffset = yOffset - 20
    
    -- Nur in Gruppe - erste Zeile
    self.ui.onlyInGroupCheck = CreateCheckButton(
        panel,
        L["Only In Group"] or "Nur in Gruppe",
        L["Only In Group Tooltip"] or "Sendet Nachrichten nur in Gruppen, nicht in Raids",
        26,
        yOffset,
        function() return QPS.db.profile.onlyInGroup end,
        function(value) QPS.db.profile.onlyInGroup = value end
    )
    yOffset = yOffset - 40
    
    -- Gruppenfortschritt - Horizontal Layout
    local groupProgressLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    groupProgressLabel:SetPoint("TOPLEFT", panel, "TOPLEFT", 26, yOffset - 2)
    groupProgressLabel:SetText(L["Quest Progress"])
    groupProgressLabel:SetTextColor(1, 0.82, 0)
    
    self.ui.groupProgressDrop = CreateSoundDropDown(
        panel,
        nil,  -- Kein Label, da bereits links
        160,
        yOffset,
        function() return QPS.db.profile.sounds.groupProgress end,
        function(value) QPS.db.profile.sounds.groupProgress = value end
    )
    
    self.ui.chatGroupProgressCheck = CreateCheckButton(
        panel,
        L["Chat Notification"] or "Chat-Benachrichtigung",
        L["Chat Notification Group Progress Tooltip"] or "Gruppen-Fortschritt im Chat anzeigen",
        430,
        yOffset - 2,
        function() return QPS.db.profile.notifications.chatGroupProgress end,
        function(value) QPS.db.profile.notifications.chatGroupProgress = value end
    )
    yOffset = yOffset - 50
    
    -- Gruppenabschluss - Horizontal Layout
    local groupCompleteLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    groupCompleteLabel:SetPoint("TOPLEFT", panel, "TOPLEFT", 26, yOffset - 2)
    groupCompleteLabel:SetText(L["Quest Completion"])
    groupCompleteLabel:SetTextColor(1, 0.82, 0)
    
    self.ui.groupCompleteDrop = CreateSoundDropDown(
        panel,
        nil,  -- Kein Label, da bereits links
        160,
        yOffset,
        function() return QPS.db.profile.sounds.groupComplete end,
        function(value) QPS.db.profile.sounds.groupComplete = value end
    )
    
    self.ui.chatGroupCompleteCheck = CreateCheckButton(
        panel,
        L["Chat Notification"] or "Chat-Benachrichtigung",
        L["Chat Notification Group Complete Tooltip"] or "Gruppen-Abschluss im Chat anzeigen",
        430,
        yOffset - 2,
        function() return QPS.db.profile.notifications.chatGroupComplete end,
        function(value) QPS.db.profile.notifications.chatGroupComplete = value end
    )

    panel.refresh = function()
        if not QPS.db then return end
        
        if QPS.ui.chatProgressCheck then QPS.ui.chatProgressCheck:SetFromDB() end
        if QPS.ui.chatCompleteCheck then QPS.ui.chatCompleteCheck:SetFromDB() end
        if QPS.ui.chatGroupProgressCheck then QPS.ui.chatGroupProgressCheck:SetFromDB() end
        if QPS.ui.chatGroupCompleteCheck then QPS.ui.chatGroupCompleteCheck:SetFromDB() end
        if QPS.ui.onlyInGroupCheck then QPS.ui.onlyInGroupCheck:SetFromDB() end

        if QPS.ui.selfProgressDrop then QPS.ui.selfProgressDrop:RefreshFromDB() end
        if QPS.ui.selfCompleteDrop then QPS.ui.selfCompleteDrop:RefreshFromDB() end
        if QPS.ui.groupProgressDrop then QPS.ui.groupProgressDrop:RefreshFromDB() end
        if QPS.ui.groupCompleteDrop then QPS.ui.groupCompleteDrop:RefreshFromDB() end
    end

    -- Direkt einmal beim Erzeugen aus DB in die UI schreiben
    panel:refresh()

    -- Beim Öffnen der Einstellungen nochmal syncen
    panel:SetScript("OnShow", panel.refresh)

    self.optionsPanel = panel
    
    -- Registrierung im Settings-Framework
    local registered = false
    local mainCategory = nil
    
    -- Versuche moderne API (11.0+)
    if Settings and Settings.RegisterCanvasLayoutCategory then
        local success, result = pcall(function()
            local category, layout = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
            if Settings.RegisterAddOnCategory then
                Settings.RegisterAddOnCategory(category)
            end
            return category
        end)
        
        if success and result then
            registered = true
            mainCategory = result
            self.mainCategory = result
            QPS:Print("Panel registered via modern Settings API")
        else
            QPS:Print("Modern API failed: " .. tostring(result))
        end
    end
    
    -- Fallback auf alte API (Classic/pre-11.0)
    if not registered then
        if InterfaceOptions_AddCategory then
            InterfaceOptions_AddCategory(panel)
            registered = true
            QPS:Print("Panel registered via legacy InterfaceOptions API")
        end
    end
    
    if not registered then
        QPS:Print("WARNING: Could not register options panel!")
    end
    
    -- Add Profile Management Panel
    self:CreateProfilePanel()
end

function QPS:CreateProfilePanel()
    if not AceDBOptions or not self.db then return end
    
    local profilePanel = CreateFrame("Frame", "QuestProgressSoundProfilePanel")
    profilePanel.name = "Profile"
    profilePanel.parent = "QuestProgressSound"
    
    local title = profilePanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText(L["Profile Management"])
    
    local subtitle = profilePanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subtitle:SetText(L["Profile Subtitle"])
    
    local startY = -60
    local lineHeight = 40
    
    -- Current Profile Display
    local currentLabel = profilePanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    currentLabel:SetPoint("TOPLEFT", 16, startY)
    currentLabel:SetText(L["Current Profile"])
    
    local currentValue = profilePanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    currentValue:SetPoint("LEFT", currentLabel, "RIGHT", 8, 0)
    profilePanel.currentValue = currentValue
    
    -- Profile Dropdown (Select/Switch)
    local profileDD = CreateFrame("Frame", nil, profilePanel, "UIDropDownMenuTemplate")
    profileDD:SetPoint("TOPLEFT", 16, startY - lineHeight)
    
    local ddLabel = profilePanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    ddLabel:SetPoint("BOTTOMLEFT", profileDD, "TOPLEFT", 16, 3)
    ddLabel:SetText(L["Switch Profile"])
    
    local function InitializeProfileDropdown(self, level)
        local profiles = {}
        if QPS.db.profiles then
            for profileKey in pairs(QPS.db.profiles) do
                table.insert(profiles, profileKey)
            end
        end
        table.sort(profiles)
        
        local current = QPS.db:GetCurrentProfile()
        
        for _, profileKey in ipairs(profiles) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = profileKey
            info.value = profileKey
            info.checked = (profileKey == current)
            info.func = function(btn)
                QPS.db:SetProfile(btn.value)
                UIDropDownMenu_SetSelectedValue(profileDD, btn.value)
                profilePanel:refresh()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end
    
    profileDD.RefreshFromDB = function()
        local current = QPS.db:GetCurrentProfile()
        UIDropDownMenu_Initialize(profileDD, InitializeProfileDropdown)
        UIDropDownMenu_SetWidth(profileDD, 220)
        UIDropDownMenu_SetSelectedValue(profileDD, current or L["Default"])
        UIDropDownMenu_SetText(profileDD, current or L["Default"])
    end
    
    -- New Profile Input
    local newProfileLabel = profilePanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    newProfileLabel:SetPoint("TOPLEFT", 16, startY - lineHeight * 2 - 10)
    newProfileLabel:SetText(L["New Profile"])
    
    local newProfileBox = CreateFrame("EditBox", nil, profilePanel, "InputBoxTemplate")
    newProfileBox:SetSize(200, 20)
    newProfileBox:SetPoint("TOPLEFT", newProfileLabel, "BOTTOMLEFT", 8, -8)
    newProfileBox:SetAutoFocus(false)
    
    local newProfileBtn = CreateFrame("Button", nil, profilePanel, "UIPanelButtonTemplate")
    newProfileBtn:SetSize(100, 22)
    newProfileBtn:SetPoint("LEFT", newProfileBox, "RIGHT", 8, 0)
    newProfileBtn:SetText(L["Create"])
    newProfileBtn:SetScript("OnClick", function()
        local name = newProfileBox:GetText()
        if name and name ~= "" then
            QPS.db:SetProfile(name)
            newProfileBox:SetText("")
            profilePanel:refresh()
        end
    end)
    
    -- Copy From Profile Dropdown
    local copyDD = CreateFrame("Frame", nil, profilePanel, "UIDropDownMenuTemplate")
    copyDD:SetPoint("TOPLEFT", 16, startY - lineHeight * 3 - 50)
    
    local copyLabel = profilePanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    copyLabel:SetPoint("BOTTOMLEFT", copyDD, "TOPLEFT", 16, 3)
    copyLabel:SetText(L["Copy From Profile"])
    
    local function InitializeCopyDropdown(self, level)
        local profiles = {}
        local current = QPS.db:GetCurrentProfile()
        
        if QPS.db.profiles then
            for profileKey in pairs(QPS.db.profiles) do
                if profileKey ~= current then
                    table.insert(profiles, profileKey)
                end
            end
        end
        table.sort(profiles)
        
        for _, profileKey in ipairs(profiles) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = profileKey
            info.value = profileKey
            info.func = function(btn)
                QPS.db:CopyProfile(btn.value)
                profilePanel:refresh()
            end
            UIDropDownMenu_AddButton(info, level)
        end
        
        if #profiles == 0 then
            local info = UIDropDownMenu_CreateInfo()
            info.text = L["No profiles available"]
            info.disabled = true
            UIDropDownMenu_AddButton(info, level)
        end
    end
    
    copyDD.RefreshFromDB = function()
        UIDropDownMenu_Initialize(copyDD, InitializeCopyDropdown)
        UIDropDownMenu_SetWidth(copyDD, 220)
        UIDropDownMenu_SetText(copyDD, L["Select Profile"])
    end
    
    -- Delete Profile Dropdown
    local deleteDD = CreateFrame("Frame", nil, profilePanel, "UIDropDownMenuTemplate")
    deleteDD:SetPoint("TOPLEFT", 16, startY - lineHeight * 4 - 80)
    
    local deleteLabel = profilePanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    deleteLabel:SetPoint("BOTTOMLEFT", deleteDD, "TOPLEFT", 16, 3)
    deleteLabel:SetText(L["Delete Profile"])
    
    local function InitializeDeleteDropdown(self, level)
        local profiles = {}
        local current = QPS.db:GetCurrentProfile()
        
        if QPS.db.profiles then
            for profileKey in pairs(QPS.db.profiles) do
                if profileKey ~= current then
                    table.insert(profiles, profileKey)
                end
            end
        end
        table.sort(profiles)
        
        for _, profileKey in ipairs(profiles) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = profileKey
            info.value = profileKey
            info.func = function(btn)
                QPS.db:DeleteProfile(btn.value, false)
                profilePanel:refresh()
            end
            UIDropDownMenu_AddButton(info, level)
        end
        
        if #profiles == 0 then
            local info = UIDropDownMenu_CreateInfo()
            info.text = L["No profiles available"]
            info.disabled = true
            UIDropDownMenu_AddButton(info, level)
        end
    end
    
    deleteDD.RefreshFromDB = function()
        UIDropDownMenu_Initialize(deleteDD, InitializeDeleteDropdown)
        UIDropDownMenu_SetWidth(deleteDD, 220)
        UIDropDownMenu_SetText(deleteDD, L["Select Profile"])
    end
    
    -- Reset Profile Button
    local resetBtn = CreateFrame("Button", nil, profilePanel, "UIPanelButtonTemplate")
    resetBtn:SetSize(200, 22)
    resetBtn:SetPoint("TOPLEFT", 16, startY - lineHeight * 5 - 110)
    resetBtn:SetText(L["Reset Profile Button"])
    resetBtn:SetScript("OnClick", function()
        QPS.db:ResetProfile()
        QPS:Print(L["Profile reset"])
        profilePanel:refresh()
        -- Refresh main panel
        if QPS.optionsPanel and QPS.optionsPanel.refresh then
            QPS.optionsPanel:refresh()
        end
    end)
    
    profilePanel.refresh = function()
        if not QPS.db then return end
        
        local current = QPS.db:GetCurrentProfile()
        if profilePanel.currentValue then
            profilePanel.currentValue:SetText(current or L["Default"])
        end
        
        if profileDD and profileDD.RefreshFromDB then
            profileDD:RefreshFromDB()
        end
        if copyDD and copyDD.RefreshFromDB then
            copyDD:RefreshFromDB()
        end
        if deleteDD and deleteDD.RefreshFromDB then
            deleteDD:RefreshFromDB()
        end
    end
    
    profilePanel:SetScript("OnShow", profilePanel.refresh)
    profilePanel:refresh()
    
    self.profilePanel = profilePanel
    
    -- Register subcategory
    local subRegistered = false
    
    -- Versuche moderne API (11.0+)
    if Settings and Settings.RegisterCanvasLayoutSubcategory and self.mainCategory then
        local success, result = pcall(function()
            local subcategory, layout = Settings.RegisterCanvasLayoutSubcategory(self.mainCategory, profilePanel, profilePanel.name)
            return subcategory
        end)
        
        if success and result then
            subRegistered = true
            QPS:Print("Profile panel registered as subcategory")
        else
            QPS:Print("Subcategory registration failed: " .. tostring(result))
        end
    end
    
    -- Fallback auf alte API
    if not subRegistered then
        if InterfaceOptions_AddCategory then
            InterfaceOptions_AddCategory(profilePanel)
            subRegistered = true
            QPS:Print("Profile panel registered via legacy API")
        end
    end
    
    if not subRegistered then
        QPS:Print("WARNING: Could not register profile panel!")
    end
end
