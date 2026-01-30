-- QuestProgressSound/Chat.lua

local _, QPS = ...
local L = QPS.L

local PREFIX = "|cff00ff00[QPS]|r "

function QPS:Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. msg)
end

local function GetQuestTitle(questID)
    local title = C_QuestLog.GetTitleForQuestID(questID)
    if not title and QuestUtils_GetQuestName then
        title = QuestUtils_GetQuestName(questID)
    end
    return title or L["Unknown Quest"] .. " (ID: " .. questID .. ")"
end

function QPS:PrintQuestProgress(questID, fulfilled, required)
    local title = GetQuestTitle(questID)
    self:Print(L["Quest Progress Chat"]:format(
        title,
        fulfilled,
        required
    ))
end

function QPS:PrintQuestComplete(questID)
    local title = GetQuestTitle(questID)
    self:Print(L["Quest Complete Chat"]:format(title))
end

function QPS:PrintGroupQuestProgress(sender, questID, fulfilled, required)
    local title = GetQuestTitle(questID)
    
    self:Print(L["Group Progress Chat"]:format(
        sender,
        title,
        fulfilled or 0,
        required or 0
    ))
end

function QPS:PrintGroupQuestComplete(sender, questID, fulfilled, required)
    local title = GetQuestTitle(questID)
    
    self:Print(L["Group Complete Chat"]:format(sender, title))
end
