-- QuestProgressSound/Comm.lua

local _, QPS = ...

local commPrefix = "QPS"

-- -------------------------------------------------------
-- Initialisierung
-- -------------------------------------------------------

function QPS:InitComm()
    C_ChatInfo.RegisterAddonMessagePrefix(commPrefix)
end

-- -------------------------------------------------------
-- Senden
-- -------------------------------------------------------

function QPS:SendProgress(questID, fulfilled, required)
    if not IsInGroup() then return end
    
    -- Nur in Gruppe senden, wenn die Option aktiviert ist
    if self.db and self.db.profile.onlyInGroup then
        if IsInRaid() then return end
    end

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
    
    -- Nur in Gruppe senden, wenn die Option aktiviert ist
    if self.db and self.db.profile.onlyInGroup then
        if IsInRaid() then return end
    end

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

    C_ChatInfo.SendAddonMessage(commPrefix, msg, channel)
end

-- -------------------------------------------------------
-- Empfangen
-- -------------------------------------------------------

function QPS:HandleComm(prefix, msg, channel, sender)
    if prefix ~= commPrefix then return end

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
    self:PlayConfiguredSound("groupProgress")

    -- Chat-Ausgabe
    self:PrintGroupQuestProgress(sender, questID, fulfilled, required)
end

function QPS:OnGroupQuestComplete(sender, questID, fulfilled, required)
    self:PlayConfiguredSound("groupComplete")

    self:PrintGroupQuestComplete(sender, questID, fulfilled, required)
end
