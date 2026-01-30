-- QuestProgressSound/Config.lua

local _, QPS = ...
local L = QPS.L

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

    local text = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    text:SetPoint("BOTTOMLEFT", dd, "TOPLEFT", 16, 3)
    text:SetText(label)

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
        UIDropDownMenu_SetSelectedValue(dd, current or "")

        -- Den aktuell selektierten Namen als Text anzeigen
        if current and current ~= "" then
            UIDropDownMenu_SetText(dd, current)
        else
            UIDropDownMenu_SetText(dd, L["Please select sound"])
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
    
    -- Scroll Frame für bessere Übersicht
    local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -20)
    scrollFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -30, 10)
    
    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(scrollFrame:GetWidth(), 1)
    scrollFrame:SetScrollChild(scrollChild)
    
    local yOffset = -10
    
    -- ==============================================
    -- BEREICH: EIGENE QUESTS
    -- ==============================================
    
    local selfHeader = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    selfHeader:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 10, yOffset)
    selfHeader:SetText(L["Own Quests"])
    selfHeader:SetTextColor(0.4, 0.78, 1.0)
    yOffset = yOffset - 30
    
    -- Trennlinie
    local selfSeparator = scrollChild:CreateTexture(nil, "ARTWORK")
    selfSeparator:SetHeight(1)
    selfSeparator:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 10, yOffset)
    selfSeparator:SetPoint("TOPRIGHT", scrollChild, "TOPRIGHT", -10, yOffset)
    selfSeparator:SetColorTexture(0.3, 0.3, 0.3, 0.8)
    yOffset = yOffset - 15
    
    -- Eigener Fortschritt
    local selfProgressLabel = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    selfProgressLabel:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 20, yOffset)
    selfProgressLabel:SetText(L["Quest Progress"])
    selfProgressLabel:SetTextColor(1, 0.82, 0)
    yOffset = yOffset - 25
    
    self.ui.selfProgressCheck = CreateCheckButton(
        scrollChild,
        L["Sound Play"],
        L["Quest Progress Enable"],
        30,
        yOffset,
        function() return QPS.db.profile.enableSelfProgressSound end,
        function(value) QPS.db.profile.enableSelfProgressSound = value end
    )
    yOffset = yOffset - 30

    self.ui.selfProgressDrop = CreateSoundDropDown(
        scrollChild,
        L["Sound Select"],
        40,
        yOffset,
        function() return QPS.db.profile.sounds.selfProgress end,
        function(value) QPS.db.profile.sounds.selfProgress = value end
    )
    yOffset = yOffset - 55
    
    -- Eigener Abschluss
    local selfCompleteLabel = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    selfCompleteLabel:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 20, yOffset)
    selfCompleteLabel:SetText(L["Quest Completion"])
    selfCompleteLabel:SetTextColor(1, 0.82, 0)
    yOffset = yOffset - 25
    
    self.ui.selfCompleteCheck = CreateCheckButton(
        scrollChild,
        L["Sound Play"],
        L["Quest Completion Enable"],
        30,
        yOffset,
        function() return QPS.db.profile.enableSelfCompleteSound end,
        function(value) QPS.db.profile.enableSelfCompleteSound = value end
    )
    yOffset = yOffset - 30

    self.ui.selfCompleteDrop = CreateSoundDropDown(
        scrollChild,
        L["Sound Select"],
        40,
        yOffset,
        function() return QPS.db.profile.sounds.selfComplete end,
        function(value) QPS.db.profile.sounds.selfComplete = value end
    )
    yOffset = yOffset - 75
    
    -- ==============================================
    -- BEREICH: GRUPPENQUESTS
    -- ==============================================
    
    local groupHeader = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    groupHeader:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 10, yOffset)
    groupHeader:SetText(L["Group Quests"])
    groupHeader:SetTextColor(0.4, 0.78, 1.0)
    yOffset = yOffset - 30
    
    -- Trennlinie
    local groupSeparator = scrollChild:CreateTexture(nil, "ARTWORK")
    groupSeparator:SetHeight(1)
    groupSeparator:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 10, yOffset)
    groupSeparator:SetPoint("TOPRIGHT", scrollChild, "TOPRIGHT", -10, yOffset)
    groupSeparator:SetColorTexture(0.3, 0.3, 0.3, 0.8)
    yOffset = yOffset - 15
    
    -- Gruppenfortschritt
    local groupProgressLabel = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    groupProgressLabel:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 20, yOffset)
    groupProgressLabel:SetText(L["Quest Progress"])
    groupProgressLabel:SetTextColor(1, 0.82, 0)
    yOffset = yOffset - 25
    
    self.ui.groupProgressCheck = CreateCheckButton(
        scrollChild,
        L["Sound Play"],
        L["Group Progress Enable"],
        30,
        yOffset,
        function() return QPS.db.profile.enableGroupProgressSound end,
        function(value) QPS.db.profile.enableGroupProgressSound = value end
    )
    yOffset = yOffset - 30

    self.ui.groupProgressDrop = CreateSoundDropDown(
        scrollChild,
        L["Sound Select"],
        40,
        yOffset,
        function() return QPS.db.profile.sounds.groupProgress end,
        function(value) QPS.db.profile.sounds.groupProgress = value end
    )
    yOffset = yOffset - 55
    
    -- Gruppenabschluss
    local groupCompleteLabel = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    groupCompleteLabel:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 20, yOffset)
    groupCompleteLabel:SetText(L["Quest Completion"])
    groupCompleteLabel:SetTextColor(1, 0.82, 0)
    yOffset = yOffset - 25
    
    self.ui.groupCompleteCheck = CreateCheckButton(
        scrollChild,
        L["Sound Play"],
        L["Group Completion Enable"],
        30,
        yOffset,
        function() return QPS.db.profile.enableGroupCompleteSound end,
        function(value) QPS.db.profile.enableGroupCompleteSound = value end
    )
    yOffset = yOffset - 30

    self.ui.groupCompleteDrop = CreateSoundDropDown(
        scrollChild,
        L["Sound Select"],
        40,
        yOffset,
        function() return QPS.db.profile.sounds.groupComplete end,
        function(value) QPS.db.profile.sounds.groupComplete = value end
    )
    yOffset = yOffset - 55
    
    -- Scroll Child Höhe anpassen
    scrollChild:SetHeight(math.abs(yOffset) + 50)

    panel.refresh = function()
        if not QPS.db then return end
        if QPS.ui.selfProgressCheck then QPS.ui.selfProgressCheck:SetFromDB() end
        if QPS.ui.selfCompleteCheck then QPS.ui.selfCompleteCheck:SetFromDB() end
        if QPS.ui.groupProgressCheck then QPS.ui.groupProgressCheck:SetFromDB() end
        if QPS.ui.groupCompleteCheck then QPS.ui.groupCompleteCheck:SetFromDB() end

        if QPS.ui.selfProgressDrop then QPS.ui.selfProgressDrop:RefreshFromDB() end
        if QPS.ui.selfCompleteDrop then QPS.ui.selfCompleteDrop:RefreshFromDB() end
        if QPS.ui.groupProgressDrop then QPS.ui.groupProgressDrop:RefreshFromDB() end
        if QPS.ui.groupCompleteDrop then QPS.ui.groupCompleteDrop:RefreshFromDB() end
    end

    -- Direkt einmal beim Erzeugen aus DB in die UI schreiben
    panel:refresh()

    -- Beim Öffnen der Einstellungen nochmal syncen
    panel:SetScript("OnShow", panel.refresh)

    -- Registrierung im modernen Settings-Framework
    if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
        local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
        category.ID = panel.name
        Settings.RegisterAddOnCategory(category)
    end

    self.optionsPanel = panel
    
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
    
    -- Register subcategory
    if Settings and Settings.RegisterCanvasLayoutSubcategory then
        local category = Settings.GetCategory("QuestProgressSound")
        if category then
            local subcategory = Settings.RegisterCanvasLayoutSubcategory(category, profilePanel, profilePanel.name)
            subcategory.ID = "QuestProgressSound_" .. profilePanel.name
        end
    end
    
    self.profilePanel = profilePanel
end
