-- QuestProgressSound/Comm.lua

local _, QPS = ...

QPS.commPrefix = "QPS"

-- -------------------------------------------------------
-- Initialisierung
-- -------------------------------------------------------

function QPS:InitComm()
    C_ChatInfo.RegisterAddonMessagePrefix(self.commPrefix)
end

-- -------------------------------------------------------
-- Senden
-- -------------------------------------------------------

function QPS:SendProgress(questID, fulfilled, required)
    if not IsInGroup() then return end

    local msg = string.format(
        "PROGRESS;%d;%d;%d",
        questID,
        fulfilled,
        required
    )

    self:SendCommMessage(msg)
end

function QPS:SendComplete(questID, fulfilled, required)
    if not IsInGroup() then return end

    local msg = string.format(
        "COMPLETE;%d;%d;%d",
        questID,
        fulfilled,
        required
    )

    self:SendCommMessage(msg)
end

function QPS:SendCommMessage(msg)
    local channel

    if IsInRaid() then
        channel = "RAID"
    else
        channel = "PARTY"
    end

    C_ChatInfo.SendAddonMessage(self.commPrefix, msg, channel)
end

-- -------------------------------------------------------
-- Empfangen
-- -------------------------------------------------------

function QPS:HandleComm(prefix, msg, channel, sender)
    if prefix ~= self.commPrefix then return end

    local playerName = UnitName("player")
    local shortSender = Ambiguate(sender, "short")

    -- Eigene Nachrichten ignorieren
    if shortSender == playerName then
        return
    end

    local msgType, questID, fulfilled, required =
        strsplit(";", msg)

    questID   = tonumber(questID)
    fulfilled = tonumber(fulfilled)
    required  = tonumber(required)

    if not questID then return end

    if msgType == "PROGRESS" then
        QPS:OnGroupQuestProgress(shortSender, questID, fulfilled, required)

    elseif msgType == "COMPLETE" then
        QPS:OnGroupQuestComplete(shortSender, questID, fulfilled, required)
    end
end

-- -------------------------------------------------------
-- Group Quest Progress Handling
-- -------------------------------------------------------

function QPS:OnGroupQuestProgress(sender, questID, fulfilled, required)
    -- Sound für Gruppenfortschritt
    if self.db.profile.enableGroupProgressSound then
        self:PlayConfiguredSound("groupProgress")
    end

    -- Chat-Ausgabe – aktuell immer an, später per Config schaltbar
    self:PrintGroupQuestProgress(sender, questID, fulfilled, required)
end

function QPS:OnGroupQuestComplete(sender, questID, fulfilled, required)
    if self.db.profile.enableGroupCompleteSound then
        self:PlayConfiguredSound("groupComplete")
    end

    self:PrintGroupQuestComplete(sender, questID, fulfilled, required)
end
