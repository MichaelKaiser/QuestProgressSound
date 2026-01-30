--- **AceLocale-3.0** manages localization in addons, allowing for multiple locale to be registered with fallback to the base locale for untranslated strings.
-- @class file
-- @name AceLocale-3.0
-- @release $Id: AceLocale-3.0.lua 1304 2023-05-19 19:50:10Z nevcairiel $
local MAJOR, MINOR = "AceLocale-3.0", 6

local AceLocale, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

if not AceLocale then return end -- No upgrade needed

-- Lua APIs
local assert, tostring, error = assert, tostring, error
local getmetatable, setmetatable, rawset, rawget = getmetatable, setmetatable, rawset, rawget

-- WoW APIs
local GetLocale = GetLocale

-- AceLocale mt
local LOCALE_MT = {
	__index = function(self, key)
		rawset(self, key, key)
		return key
	end,
}

-- AceLocale upvalue
local locales = AceLocale.locales or {}
AceLocale.locales = locales

local appName_mt = {
	__index = function(self, appName)
		local base_locale = {}
		rawset(self, appName, base_locale)
		return base_locale
	end,
}

setmetatable(locales, appName_mt)

--- Register a new locale (or update an existing one) for the specified application.
-- :NewLocale will return a table you can fill your locale into, or nil if the locale isn't needed for the players
-- game locale.
-- @paramsig application, locale[, isDefault[, silent]]
-- @param application Unique name of addon / module
-- @param locale Name of the locale to register, e.g. "enUS", "deDE", etc.
-- @param isDefault If this is the default locale being registered (your addon is written in this language, generally enUS)
-- @param silent If true, the locale will not issue a warning for missing keys. Must be set on the first locale registered. If set to "raw", nils will be returned for unknown keys (no metatable used).
-- @usage
-- -- enUS.lua
-- local L = LibStub("AceLocale-3.0"):NewLocale("TestLocale", "enUS", true)
-- L["string1"] = true
--
-- -- deDE.lua
-- local L = LibStub("AceLocale-3.0"):NewLocale("TestLocale", "deDE")
-- if not L then return end
-- L["string1"] = "Zeichenkette1"
-- @return Locale Table to add localizations to, or nil if the current locale is not required.
function AceLocale:NewLocale(application, locale, isDefault, silent)
	-- MUST supply at least application and locale
	if not application or not locale then
		error("Usage: NewLocale(application, locale[, isDefault[, silent]])")
	end

	local app = locales[application]

	if silent ~= "raw" then
		-- This metatable is used on all locales except the "raw" locale.
		-- It returns the key if the value doesn't exist, which saves a lot of checks for nil all over the code
		setmetatable(app, LOCALE_MT)
	end

	-- Only allow a given locale to be registered once
	if app[locale] then return end

	local tbl = {}

	-- Are we the current locale?
	if locale == GetLocale() then
		-- We are the current locale, return the locale table
		app.baseLocale = tbl
		tbl.silent = silent
		rawset(app, locale, tbl)
		return tbl

	-- Not the current locale, but if we are the default, provide a base
	elseif isDefault then
		app.baseLocale = tbl
		rawset(app, locale, tbl)
		tbl.silent = silent
		return tbl
	end

	-- Not the current locale and not the default locale
	-- Store it for completion purposes only
	rawset(app, locale, tbl)
end

--- Returns localizations for the current locale (or default locale if translations are missing).
-- Errors if nothing is registered (spank developer, not just a missing translation)
-- @param application Unique name of addon / module
-- @param silent If true, the locale is optional, silently return nil if it's not found (defaults to false, optional)
-- @return The locale table for the current language.
function AceLocale:GetLocale(application, silent)
	if not application then
		error("Usage: GetLocale(application[, silent])", 2)
	end

	local app = locales[application]

	if silent and not app.baseLocale then
		return
	end

	if not app.baseLocale then
		error("Usage: GetLocale(application[, silent]): 'application' - No locales registered for '" .. tostring(application) .. "'", 2)
	end

	return app.baseLocale
end
