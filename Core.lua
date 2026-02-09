-- QuestProgressSound/Core.lua

local ADDON_NAME, QPS = ...

local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
local AceDB = LibStub and LibStub("AceDB-3.0", true)
local AceLocale = LibStub and LibStub("AceLocale-3.0", true)
local L = AceLocale and AceLocale:GetLocale("QuestProgressSound", true) or {}

-- Fallback metatable for missing translations
if not getmetatable(L) then
    setmetatable(L, {
        __index = function(t, k)
            return k
        end
    })
end

QPS.LSM = LSM
QPS.L = L

QPS.name = ADDON_NAME
QPS.version = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version")

-- Default Settings (AceDB profile structure)
QPS.defaults = {
    profile = {
        onlyInGroup = true,

        sounds = {
            selfProgress  = "QPS: More Work",
            selfComplete  = "QPS: Job's Done",
            groupProgress = "QPS: More Work",
            groupComplete = "QPS: Job's Done",
        },
        notifications = {
            chatProgress       = true,
            chatComplete       = true,
            chatGroupProgress  = true,
            chatGroupComplete  = true,
        },
    }
}

-- Event Frame
QPS.frame = CreateFrame("Frame")
QPS.frame:RegisterEvent("ADDON_LOADED")
QPS.frame:RegisterEvent("PLAYER_LOGIN")

-- Throttling für Sound-Wiedergabe (2 Sekunden pro Ereignistyp)
QPS.lastSoundTime = {} -- Tabelle für Zeitstempel pro kind
QPS.soundThrottle = 2

QPS.frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == ADDON_NAME then
            QPS:InitializeSavedVariables()
        end
    elseif event == "PLAYER_LOGIN" then
        QPS:OnPlayerLogin()
    end
end)

-- -------------------------------------------------------
-- Helper Functions (must be defined before use)
-- -------------------------------------------------------

local function MigrateSoundConfig(self)
    local s = self.db.profile.sounds

    local function ensure(field, defaultKey)
        local v = s[field]

        -- Alte numerische Konfiguration oder nil → auf unseren Default setzen
        if type(v) ~= "string" then
            s[field] = defaultKey
        end
    end

    ensure("selfProgress",  "QPS: More Work")
    ensure("selfComplete",  "QPS: Job's Done")
    ensure("groupProgress", "QPS: More Work")
    ensure("groupComplete", "QPS: Job's Done")
    
    -- Migration für notifications
    if not self.db.profile.notifications then
        self.db.profile.notifications = {}
    end
    
    local n = self.db.profile.notifications
    local function ensureNotification(field, defaultValue)
        if n[field] == nil then
            n[field] = defaultValue
        end
    end
    
    ensureNotification("chatProgress", true)
    ensureNotification("chatComplete", true)
    ensureNotification("chatGroupProgress", true)
    ensureNotification("chatGroupComplete", true)
    
    -- Migration für onlyInGroup
    if self.db.profile.onlyInGroup == nil then
        self.db.profile.onlyInGroup = true
    end
end

local function RegisterDefaultSounds(self)
    if not self.LSM then return end

    local basePath = "Interface\\AddOns\\QuestProgressSound\\media\\"

    -- Pfad-basiert: LibSharedMedia liefert später eine Datei-URL zurück
    self.LSM:Register("sound", "QPS: More Work", basePath .. "schaffe.ogg")
    self.LSM:Register("sound", "QPS: Job's Done", basePath .. "feierabend.ogg")
end

-- -------------------------------------------------------
-- Initialization Functions
-- -------------------------------------------------------

function QPS:InitializeSavedVariables()
    if not AceDB then
        self:Print("ERROR: AceDB-3.0 not loaded!")
        return
    end
    
    -- Initialize AceDB with profile support
    self.db = AceDB:New("QuestProgressSoundDB", self.defaults, true)
    
    -- Migrate old character-specific settings if they exist
    if self.db.profile.sounds then
        MigrateSoundConfig(self)
    end
    
    RegisterDefaultSounds(self)
end


function QPS:OnPlayerLogin()
    local msg = L and L["Loaded successfully"] or "Loaded successfully (v%s)"
    if msg and type(msg) == "string" then
        self:Print(msg:format(tostring(self.version)))
    end
    
    if not self.LSM and C_AddOns and C_AddOns.LoadAddOn then
        local loaded = C_AddOns.LoadAddOn("LibSharedMedia-3.0")
        if loaded and LibStub then
            self.LSM = LibStub("LibSharedMedia-3.0", true)
            self:Print("LibSharedMedia loaded successfully")
        end
    end
    
    RegisterDefaultSounds(self)
    self:InitComm()
    self:CreateOptionsPanel()
end

-- Spielt einen konfigurierten Sound anhand des Feldnamens in db.sounds
function QPS:PlayConfiguredSound(kind)
    if not self.db or not self.db.profile or not self.db.profile.sounds then return end

    -- Throttling: Prüfe, ob seit dem letzten Sound dieses Typs genug Zeit vergangen ist
    local currentTime = GetTime()
    local lastTime = self.lastSoundTime[kind] or 0
    if (currentTime - lastTime) < self.soundThrottle then
        return -- Sound-Wiedergabe überspringen
    end

    local value = self.db.profile.sounds[kind]
    if not value or value == "" or value == "None" then return end

    -- LSM-Sound per Name
    if self.LSM and type(value) == "string" then
        local media = self.LSM:Fetch("sound", value, true)
        if media then
            if type(media) == "number" then
                -- SoundKitID
                PlaySound(media, "Master")
            else
                -- Dateipfad
                PlaySoundFile(media, "Master")
            end
            -- Zeitstempel aktualisieren nach erfolgreicher Wiedergabe
            self.lastSoundTime[kind] = currentTime
            return
        end
    end

    -- Fallback: falls noch eine alte numerische ID im Profil stehen sollte
    if type(value) == "number" then
        PlaySound(value, "Master")
        -- Zeitstempel aktualisieren nach erfolgreicher Wiedergabe
        self.lastSoundTime[kind] = currentTime
    end
end

-- Für Vorschau im Optionsmenü (roh-Wert aus DropDown)
function QPS:PlayArbitrarySound(value)
    if not value then return end

    if self.LSM and type(value) == "string" then
        local media = self.LSM:Fetch("sound", value, true)
        if media then
            if type(media) == "number" then
                PlaySound(media, "Master")
            else
                PlaySoundFile(media, "Master")
            end
            return
        end
    end

    if type(value) == "number" then
        PlaySound(value, "Master")
    end
end
