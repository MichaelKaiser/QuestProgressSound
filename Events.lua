-- QuestProgressSound/Events.lua

local _, QPS = ...

-- Zwischenspeicher für Queststände
QPS.questCache = {}

-- Event Registration
QPS.frame:RegisterEvent("QUEST_LOG_UPDATE")
QPS.frame:RegisterEvent("QUEST_REMOVED")
QPS.frame:RegisterEvent("CHAT_MSG_ADDON")

QPS.frame:HookScript("OnEvent", function(self, event, ...)
    if event == "QUEST_LOG_UPDATE" then
        QPS:HandleQuestLogUpdate()
    elseif event == "QUEST_REMOVED" then
        local questID = ...
        QPS:HandleQuestRemoved(questID)
    elseif event == "CHAT_MSG_ADDON" then
        local prefix, msg, channel, sender = ...
        QPS:HandleComm(prefix, msg, channel, sender)
    end
end)

-- -------------------------------------------------------
-- Quest Progress Tracking
-- -------------------------------------------------------

function QPS:HandleQuestLogUpdate()
    local numEntries = C_QuestLog.GetNumQuestLogEntries()

    for i = 1, numEntries do
        local info = C_QuestLog.GetInfo(i)

        if info and not info.isHeader and info.questID then
            self:CheckQuestProgress(info.questID)
        end
    end
end

function QPS:CheckQuestProgress(questID)
    local objectives = C_QuestLog.GetQuestObjectives(questID)
    if not objectives then return end

    local totalFulfilled = 0
    local totalRequired = 0

    for _, obj in ipairs(objectives) do
        if obj.numFulfilled and obj.numRequired then
            totalFulfilled = totalFulfilled + obj.numFulfilled
            totalRequired  = totalRequired  + obj.numRequired
        end
    end

    local isNowComplete = C_QuestLog.IsComplete(questID)

    local cached = self.questCache[questID]

    -- Initialisierung
    if not cached then
        self.questCache[questID] = {
            fulfilled = totalFulfilled,
            required  = totalRequired,
            isComplete = isNowComplete
        }
        return
    end

    local previousFulfilled = cached.fulfilled
    local wasComplete = cached.isComplete

    -- ✅ Completion hat Priorität
    if isNowComplete and not wasComplete then
        self:PlayConfiguredSound("selfComplete")

        QPS:PrintQuestComplete(questID)
        QPS:SendComplete(questID, totalFulfilled, totalRequired)

    -- ✅ Fortschritt bei JEDEM Zähleranstieg
    elseif totalFulfilled > previousFulfilled then
        self:PlayConfiguredSound("selfProgress")

        QPS:PrintQuestProgress(questID, totalFulfilled, totalRequired)
        QPS:SendProgress(questID, totalFulfilled, totalRequired)
    end

    -- Cache aktualisieren
    cached.fulfilled = totalFulfilled
    cached.isComplete = isNowComplete
end


-- -------------------------------------------------------
-- Quest Completion
-- -------------------------------------------------------

function QPS:HandleQuestRemoved(questID)
    if self.questCache[questID] then
        self.questCache[questID] = nil
    end
end

