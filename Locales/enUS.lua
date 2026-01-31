-- QuestProgressSound Locale - enUS (English, default)

local L = LibStub("AceLocale-3.0"):NewLocale("QuestProgressSound", "enUS", true)

if not L then return end

-- General
L["QuestProgressSound"] = "QuestProgressSound"
L["Loaded successfully"] = "Loaded successfully (v%s)"
L["Profile reset"] = "Profile has been reset to default values."

-- Main Config Panel
L["Config Subtitle"] = "Configure sounds for quest progress and completion."
L["Sound Play"] = "Play sound"
L["Sound Select"] = "Select sound"
L["Please select sound"] = "Please select sound"
L["None"] = "None"

-- Own Quests Section
L["Own Quests"] = "Own Quests"
L["Quest Progress"] = "Quest Progress:"
L["Quest Progress Enable"] = "Enable/Disable sound when you make progress in a quest."
L["Quest Completion"] = "Quest Completion:"
L["Quest Completion Enable"] = "Enable/Disable sound when you complete all objectives of a quest."

-- Chat Notifications
L["Chat Notification"] = "Chat notification"
L["Chat Notification Progress Tooltip"] = "Show quest progress in chat"
L["Chat Notification Complete Tooltip"] = "Show quest completion in chat"
L["Chat Notification Group Progress Tooltip"] = "Show group progress in chat"
L["Chat Notification Group Complete Tooltip"] = "Show group completion in chat"

-- Group Quests Section
L["Group Quests"] = "Group Quests"
L["Group Progress Enable"] = "Enable/Disable sound when a group member reports quest progress."
L["Group Completion Enable"] = "Enable/Disable sound when a group member completes a quest."
L["Communication Settings"] = "Communication Settings:"
L["Only In Group"] = "Only in group"
L["Only In Group Tooltip"] = "Send messages only in groups, not in raids"

-- Profile Management
L["Profile Management"] = "Profile Management"
L["Profile Subtitle"] = "Manage different profiles for your settings."
L["Current Profile"] = "Current Profile:"
L["Switch Profile"] = "Switch profile:"
L["New Profile"] = "Create new profile:"
L["Create"] = "Create"
L["Copy From Profile"] = "Copy from profile:"
L["Select Profile"] = "Select profile..."
L["Delete Profile"] = "Delete profile:"
L["Reset Profile Button"] = "Reset current profile"
L["Default"] = "Default"
L["No profiles available"] = "No profiles available"

-- Chat Messages
L["Quest Progress Chat"] = "Quest progress: %s (%d / %d)"
L["Quest Complete Chat"] = "Quest completed: %s"
L["Unknown Quest"] = "Unknown Quest"
L["Group Progress Chat"] = "%s: Quest progress: %s (%d / %d)"
L["Group Complete Chat"] = "%s: Quest completed: %s"
