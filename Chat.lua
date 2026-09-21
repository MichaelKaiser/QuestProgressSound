-- QuestProgressSound/Chat.lua

local _, QPS = ...

local fallbackMessages = {
    enUS = {
        ["Quest Progress Chat"] = "Quest progress %s: %s (%s / %s)",
        ["Quest Complete Chat"] = "Quest completed: %s",
        ["Unknown Quest"] = "Unknown Quest",
        ["Group Progress Chat"] = "%s Quest progress %s: %s (%s / %s)",
        ["Group Complete Chat"] = "%s Quest completed %s",
    },
    deDE = {
        ["Quest Progress Chat"] = "Questfortschritt %s: %s (%s / %s)",
        ["Quest Complete Chat"] = "Quest abgeschlossen: %s",
        ["Unknown Quest"] = "Unbekannte Quest",
        ["Group Progress Chat"] = "%s Questfortschritt %s: %s (%s / %s)",
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

local QUEST_TITLE_COLOR = "00ff00"

-- WoW-Chat kennt kein echtes Fett, daher wird helles Grün als Annäherung verwendet
local function WrapColor(text, hexColor)
    return string.format("|cff%s%s|r", hexColor, text)
end

-- Interpoliert Rot -> Orange -> Gelb -> Grün je nach Fortschrittsverhältnis (0..1)
local function GetProgressColor(ratio)
    ratio = math.max(0, math.min(1, ratio or 0))

    local stops = {
        { 0.00, 255, 0,   0 },
        { 0.33, 255, 165, 0 },
        { 0.66, 255, 255, 0 },
        { 1.00, 0,   255, 0 },
    }

    for i = 1, #stops - 1 do
        local a, b = stops[i], stops[i + 1]
        if ratio >= a[1] and ratio <= b[1] then
            local t = (b[1] - a[1] > 0) and (ratio - a[1]) / (b[1] - a[1]) or 0
            local r  = a[2] + (b[2] - a[2]) * t
            local g  = a[3] + (b[3] - a[3]) * t
            local bl = a[4] + (b[4] - a[4]) * t
            return string.format("%02x%02x%02x", r, g, bl)
        end
    end

    return "ffffff"
end

-- Entfernt die von Blizzard bereits in obj.text eingebettete Zählung (z.B. ": 3/6")
local function StripObjectiveCount(text)
    if type(text) ~= "string" then return text end
    return (text:gsub("%s*:?%s*%d+%s*/%s*%d+%s*$", ""))
end

function QPS:PrintQuestProgress(questID, objectiveText, fulfilled, required)
    if not isNotificationEnabled("chatProgress") then return end
    local title = WrapColor(GetQuestTitle(questID), QUEST_TITLE_COLOR)

    local ratio = (required and required > 0) and (fulfilled / required) or 0
    local progressColor = GetProgressColor(ratio)
    local cleanObjective = StripObjectiveCount(objectiveText) or ""

    self:Print(GetMessage("Quest Progress Chat"):format(
        title,
        WrapColor(cleanObjective, progressColor),
        WrapColor(tostring(fulfilled), progressColor),
        WrapColor(tostring(required), progressColor)
    ))
end

function QPS:PrintQuestComplete(questID)
    if not isNotificationEnabled("chatComplete") then return end
    local title = WrapColor(GetQuestTitle(questID), QUEST_TITLE_COLOR)
    self:Print(GetMessage("Quest Complete Chat"):format(title))
end

function QPS:PrintGroupQuestProgress(sender, questID, objectiveText, fulfilled, required)
    if not isNotificationEnabled("chatGroupProgress") then return end
    local title = WrapColor(GetQuestTitle(questID), QUEST_TITLE_COLOR)

    local ratio = (required and required > 0) and (fulfilled / required) or 0
    local progressColor = GetProgressColor(ratio)
    local cleanObjective = StripObjectiveCount(objectiveText) or ""

    self:Print(GetMessage("Group Progress Chat"):format(
        sender,
        title,
        WrapColor(cleanObjective, progressColor),
        WrapColor(tostring(fulfilled or 0), progressColor),
        WrapColor(tostring(required or 0), progressColor)
    ))
end

function QPS:PrintGroupQuestComplete(sender, questID, fulfilled, required)
    if not isNotificationEnabled("chatGroupComplete") then return end

    local title = WrapColor(GetQuestTitle(questID), QUEST_TITLE_COLOR)
    
    self:Print(GetMessage("Group Complete Chat"):format(sender, title))
end
