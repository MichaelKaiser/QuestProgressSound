-- QuestProgressSound/Core.lua

local ADDON_NAME, QPS = ...

local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
local AceDB = LibStub and LibStub("AceDB-3.0", true)
local L = LibStub and LibStub("AceLocale-3.0"):GetLocale("QuestProgressSound")

QPS.LSM = LSM
QPS.L = L

QPS.name = ADDON_NAME
QPS.version = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version")

-- Default Settings (AceDB profile structure)
QPS.defaults = {
    profile = {
        enableSelfProgressSound = true,
        enableSelfCompleteSound = true,
        enableGroupProgressSound = true,
        enableGroupCompleteSound = true,

        sounds = {
            selfProgress  = "QPS: More Work",
            selfComplete  = "QPS: Job's Done",
            groupProgress = "QPS: More Work",
            groupComplete = "QPS: Job's Done",
        }
    }
}

-- Event Frame
QPS.frame = CreateFrame("Frame")
QPS.frame:RegisterEvent("ADDON_LOADED")
QPS.frame:RegisterEvent("PLAYER_LOGIN")

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

function QPS:InitializeSavedVariables()
    if not AceDB then
        self:Print("ERROR: AceDB-3.0 not loaded!")
        return
    end
    
    -- Initialize AceDB with profile support
    self.db = AceDB:New("QuestProgressSoundDB", self.defaults, true)
    
    -- Migrate old character-specific settings if they exist
    if self.db.profile.sounds then
        self:MigrateSoundConfig()
    end
    
    self:RegisterDefaultSounds()
end

function QPS:MigrateSoundConfig()
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
end

function QPS:RegisterDefaultSounds()
    if not self.LSM then return end

    local basePath = "Interface\\AddOns\\QuestProgressSound\\media\\"

    -- Pfad-basiert: LibSharedMedia liefert später eine Datei-URL zurück
    self.LSM:Register("sound", "QPS: More Work", basePath .. "schaffe.ogg")
    self.LSM:Register("sound", "QPS: Job's Done", basePath .. "feierabend.ogg")
end


function QPS:OnPlayerLogin()
    self:Print(L["Loaded successfully"]:format(tostring(self.version)))
    if not self.LSM and C_AddOns and C_AddOns.LoadAddOn then
        local loaded = C_AddOns.LoadAddOn("LibSharedMedia-3.0")
        if loaded and LibStub then
            self.LSM = LibStub("LibSharedMedia-3.0", true)
            self:Print("LibSharedMedia loaded successfully")
        end
    end
    
    self:RegisterDefaultSounds()
    self:InitComm()
    self:CreateOptionsPanel()
end

-- Spielt einen konfigurierten Sound anhand des Feldnamens in db.sounds
function QPS:PlayConfiguredSound(kind)
    if not self.db or not self.db.profile or not self.db.profile.sounds then return end

    local value = self.db.profile.sounds[kind]
    if not value then return end

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
            return
        end
    end

    -- Fallback: falls noch eine alte numerische ID im Profil stehen sollte
    if type(value) == "number" then
        PlaySound(value, "Master")
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
