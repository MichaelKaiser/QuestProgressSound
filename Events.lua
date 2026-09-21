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

    local isNowComplete = C_QuestLog.IsComplete(questID)
    local cached = self.questCache[questID]

    -- Initialisierung: pro Questziel einzeln merken, kein Vergleich beim ersten Mal
    if not cached then
        cached = { objectives = {}, isComplete = isNowComplete }
        for i, obj in ipairs(objectives) do
            cached.objectives[i] = {
                fulfilled = obj.numFulfilled or 0,
                required  = obj.numRequired or 0,
            }
        end
        self.questCache[questID] = cached
        return
    end

    local wasComplete = cached.isComplete

    -- ✅ Completion hat Priorität
    if isNowComplete and not wasComplete then
        self:PlayConfiguredSound("selfComplete")

        local totalFulfilled, totalRequired = 0, 0
        for _, obj in ipairs(objectives) do
            if obj.numFulfilled and obj.numRequired then
                totalFulfilled = totalFulfilled + obj.numFulfilled
                totalRequired  = totalRequired  + obj.numRequired
            end
        end

        QPS:PrintQuestComplete(questID)
        QPS:SendComplete(questID, totalFulfilled, totalRequired)

    else
        -- ✅ Fortschritt wird pro Questziel einzeln erkannt und gemeldet
        for i, obj in ipairs(objectives) do
            if obj.numFulfilled and obj.numRequired then
                local cachedObj = cached.objectives[i]
                local previousFulfilled = cachedObj and cachedObj.fulfilled or 0

                if obj.numFulfilled > previousFulfilled then
                    self:PlayConfiguredSound("selfProgress")

                    QPS:PrintQuestProgress(questID, obj.text, obj.numFulfilled, obj.numRequired)
                    QPS:SendProgress(questID, obj.text, obj.numFulfilled, obj.numRequired)
                end
            end
        end
    end

    -- Cache aktualisieren
    cached.isComplete = isNowComplete
    for i, obj in ipairs(objectives) do
        cached.objectives[i] = {
            fulfilled = obj.numFulfilled or 0,
            required  = obj.numRequired or 0,
        }
    end
end


-- -------------------------------------------------------
-- Quest Completion
-- -------------------------------------------------------

function QPS:HandleQuestRemoved(questID)
    if self.questCache[questID] then
        self.questCache[questID] = nil
    end
end

