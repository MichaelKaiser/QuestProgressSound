-- QuestProgressSound/Chat.lua

local _, QPS = ...

local fallbackMessages = {
    enUS = {
        ["Quest Progress Chat"] = "Quest progress: %s (%d / %d)",
        ["Quest Complete Chat"] = "Quest completed: %s",
        ["Unknown Quest"] = "Unknown Quest",
        ["Group Progress Chat"] = "%s: Quest progress: %s (%d / %d)",
        ["Group Complete Chat"] = "%s: Quest completed: %s",
    },
    deDE = {
        ["Quest Progress Chat"] = "Questfortschritt: %s (%d / %d)",
        ["Quest Complete Chat"] = "Quest abgeschlossen: %s",
        ["Unknown Quest"] = "Unbekannte Quest",
        ["Group Progress Chat"] = "%s: Questfortschritt: %s (%d / %d)",
        ["Group Complete Chat"] = "%s: Quest abgeschlossen: %s",
    },
}

local function GetChatLocale()
    local locale = QPS.L
    if type(locale) == "table" and next(locale) ~= nil then
        return locale
    end

    if LibStub then
        local AceLocale = LibStub("AceLocale-3.0", true)
        if AceLocale then
            local freshLocale = AceLocale:GetLocale("QuestProgressSound", true)
            if type(freshLocale) == "table" and next(freshLocale) ~= nil then
                QPS.L = freshLocale
                return freshLocale
            end
        end
    end

    return {}
end

local function GetMessage(key)
    local locale = GetChatLocale()
    local message = locale[key]
    if type(message) == "string" then
        return message
    end

    local fallbackLocale = GetLocale and GetLocale() or "enUS"
    local fallback = fallbackMessages[fallbackLocale] or fallbackMessages.enUS
    return fallback[key] or key
end

local PREFIX = "|cff00ff00[QPS]|r "

function QPS:Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. msg)
end

local function isNotificationEnabled(kind)
    if not QPS.db or not QPS.db.profile or not QPS.db.profile.notifications then return false end

    local value = QPS.db.profile.notifications[kind]
    if value == false then return false end

    return true
end

local function GetQuestTitle(questID)
    local title = C_QuestLog.GetTitleForQuestID(questID)
    if not title and QuestUtils_GetQuestName then
        title = QuestUtils_GetQuestName(questID)
    end
    return title or GetMessage("Unknown Quest") .. " (ID: " .. questID .. ")"
end

function QPS:PrintQuestProgress(questID, fulfilled, required)
    if not isNotificationEnabled("chatProgress") then return end
    local title = GetQuestTitle(questID)
    self:Print(GetMessage("Quest Progress Chat"):format(
        title,
        fulfilled,
        required
    ))
end

function QPS:PrintQuestComplete(questID)
    if not isNotificationEnabled("chatComplete") then return end
    local title = GetQuestTitle(questID)
    self:Print(GetMessage("Quest Complete Chat"):format(title))
end

function QPS:PrintGroupQuestProgress(sender, questID, fulfilled, required)
    if not isNotificationEnabled("chatGroupProgress") then return end
    local title = GetQuestTitle(questID)
    
    self:Print(GetMessage("Group Progress Chat"):format(
        sender,
        title,
        fulfilled or 0,
        required or 0
    ))
end

function QPS:PrintGroupQuestComplete(sender, questID, fulfilled, required)
    if not isNotificationEnabled("chatGroupComplete") then return end

    local title = GetQuestTitle(questID)
    
    self:Print(GetMessage("Group Complete Chat"):format(sender, title))
end
