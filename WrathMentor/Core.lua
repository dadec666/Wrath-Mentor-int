-- Wrath Mentor - Core (v2)
-- Client: WoW 3.3.5a (Interface 30300). Lua 5.1, no modern APIs.

WrathMentor = WrathMentor or {}
local WM = WrathMentor

WM.version = "2.2.4"
WM.raids = {}        -- raids[id] = { id, name, zones, bosses, src }
WM.raidOrder = {}    -- display order
WM.nameIndex = {}    -- lowercase NPC name -> boss entry
WM.selected = nil    -- boss currently shown in the main window

local DEFAULTS = {
    role = "ALL",                -- ALL | TANK | HEAL | DPS
    size = 25,                   -- 10 or 25
    theme = "classic",           -- "classic" (Blizzard Dialog по умолчанию) | "dark" (Flat/Dark)
    quickRole = "TLDR",          -- TLDR | TANK | HEAL | DPS
    quick = true,                -- popup when you target a boss
    quickRaidOnly = true,        -- only show the popup inside raid instances
    quickHideAfterCombat = true, -- hide the popup when combat ends
    quickScale = 1.0,            -- popup size
    mainScale = 1.0,             -- tactics window size
    mainWidth = 760,             -- tactics window width
    mainHeight = 500,            -- tactics window height
    minimap = { hide = false, angle = 225 },
    collapsed = {},              -- collapsed raids in the list
    notes = {},                  -- personal notes
}
WM.DEFAULTS = DEFAULTS

local ROLE_KEY = { TANK = "tank", HEAL = "heal", DPS = "dps" }

local function lower(s)
    s = s or ""
    if strlower then return strlower(s) end
    return string.lower(s)
end

------------------------------------------------------------------
-- Data registration
------------------------------------------------------------------
function WM:AddRaid(id, name, zones, bosses, src)
    local localizedRaidName = self.L[name] or name
    local raid = {
        id = id,
        name = localizedRaidName,
        rawName = name,
        zones = zones or {},
        bosses = bosses,
        src = src
    }
    self.raids[id] = raid
    table.insert(self.raidOrder, id)

    for _, z in ipairs(zones or {}) do
        local locZ = self.L[z]
        if locZ and locZ ~= z then
            table.insert(raid.zones, locZ)
        end
    end

    for i, boss in ipairs(bosses) do
        boss.raidId = id
        boss.index = i
        boss.displayName = self.L[boss.name] or boss.name
        self.nameIndex[lower(boss.name)] = boss
        if boss.displayName ~= boss.name then
            self.nameIndex[lower(boss.displayName)] = boss
        end
        if boss.aliases then
            for _, alias in ipairs(boss.aliases) do
                self.nameIndex[lower(alias)] = boss
                local locAlias = self.L[alias]
                if locAlias and locAlias ~= alias then
                    self.nameIndex[lower(locAlias)] = boss
                end
            end
        end
    end
end

function WM:BossKey(boss)
    return boss.raidId .. ":" .. boss.name
end

function WM:Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ccffWrath Mentor:|r " .. tostring(msg))
end

------------------------------------------------------------------
-- Saved variables
------------------------------------------------------------------
local function CopyDefaults(src, dst)
    for k, v in pairs(src) do
        if type(v) == "table" then
            if type(dst[k]) ~= "table" then dst[k] = {} end
            CopyDefaults(v, dst[k])
        elseif dst[k] == nil then
            dst[k] = v
        end
    end
end

function WM:Init()
    WrathMentorDB = WrathMentorDB or {}
    CopyDefaults(DEFAULTS, WrathMentorDB)
    if WrathMentorDB.size ~= 10 and WrathMentorDB.size ~= 25 then WrathMentorDB.size = 25 end
    self.db = WrathMentorDB
    self:Print(string.format(self.L["v%s loaded. Type /wm to open, /wm help for commands."], self.version))
end

function WM:ResetOptions()
    local d = DEFAULTS
    self.db.quick = d.quick
    self.db.quickRaidOnly = d.quickRaidOnly
    self.db.quickHideAfterCombat = d.quickHideAfterCombat
    self.db.quickScale = d.quickScale
    self.db.mainScale = d.mainScale
    self.db.theme = d.theme
    self.db.quickRole = d.quickRole
    self.db.minimap.hide = d.minimap.hide
    self.db.minimap.angle = d.minimap.angle
    self:ApplySettings()
end

------------------------------------------------------------------
-- Lookups
------------------------------------------------------------------
function WM:GetZoneRaid()
    local zone = GetRealZoneText()
    if not zone or zone == "" then return nil end
    for _, id in ipairs(self.raidOrder) do
        local raid = self.raids[id]
        for _, z in ipairs(raid.zones) do
            if z == zone then return raid end
        end
    end
    return nil
end

function WM:FindBossByUnit(unit)
    if not UnitExists(unit) or UnitIsPlayer(unit) then return nil end
    if not IsInInstance() then return nil end
    local name = UnitName(unit)
    if not name then return nil end
    return self.nameIndex[lower(name)]
end

function WM:FindBoss(query)
    query = lower(query)
    if query == "" then return nil end
    if self.nameIndex[query] then return self.nameIndex[query] end
    for _, id in ipairs(self.raidOrder) do
        for _, boss in ipairs(self.raids[id].bosses) do
            if string.find(lower(boss.name), query, 1, true) then return boss end
            if boss.displayName and string.find(lower(boss.displayName), query, 1, true) then return boss end
            if boss.aliases then
                for _, a in ipairs(boss.aliases) do
                    if string.find(lower(a), query, 1, true) then return boss end
                    local locA = self.L[a]
                    if locA and string.find(lower(locA), query, 1, true) then return boss end
                end
            end
        end
    end
    return nil
end

------------------------------------------------------------------
-- 10 / 25 man text expansion
------------------------------------------------------------------
function WM:GetSize()
    return (self.db and self.db.size) or 25
end

function WM:Expand(line)
    if type(line) ~= "string" then return nil end
    local size = self:GetSize()
    local tag, rest = string.match(line, "^%[(%d+)%]%s*(.*)$")
    if tag then
        if tonumber(tag) ~= size then return nil end
        line = rest
    end
    line = string.gsub(line, "#{([^/}]*)/([^}]*)}", function(a, b)
        if size == 10 then return a end
        return b
    end)
    return line
end

function WM:ExpandList(list)
    local out = {}
    if list then
        for _, l in ipairs(list) do
            local e = self:Expand(l)
            if e and e ~= "" then out[#out + 1] = e end
        end
    end
    return out
end

------------------------------------------------------------------
-- Spell links
------------------------------------------------------------------
local FALLBACK_ICON = "Interface\\Icons\\INV_Misc_QuestionMark"

function WM:ResolveSpell(ab)
    if ab.checked then return ab.spell end
    ab.checked = true
    local ids = ab.ids
    if not ids and ab.id then ids = { ab.id } end
    if not ids or not GetSpellInfo then return nil end

    local locName = self.L[ab.name]
    for _, id in ipairs(ids) do
        local n, _, icon = GetSpellInfo(id)
        if n and (lower(n) == lower(ab.name) or (locName and lower(n) == lower(locName))) then
            ab.spell = id
            ab.icon = icon
            ab.resolvedName = n
            return id
        end
    end

    for _, id in ipairs(ids) do
        local n, _, icon = GetSpellInfo(id)
        if n and n ~= "" then
            ab.spell = id
            ab.icon = icon
            ab.resolvedName = n
            return id
        end
    end
    return nil
end

function WM:SpellLink(ab)
    local id = self:ResolveSpell(ab)
    if not id then return nil end
    local name = ab.resolvedName or self.L[ab.name] or ab.name
    return "|cff71d5ff|Hspell:" .. id .. "|h[" .. name .. "]|h|r"
end

function WM:GetSpellIcon(ab)
    self:ResolveSpell(ab)
    return ab.icon or FALLBACK_ICON
end

function WM:CheckLinks()
    local total, linked, missing = 0, 0, {}
    for _, id in ipairs(self.raidOrder) do
        for _, boss in ipairs(self.raids[id].bosses) do
            for _, ab in ipairs(boss.abilities or {}) do
                total = total + 1
                if self:ResolveSpell(ab) then
                    linked = linked + 1
                else
                    missing[#missing + 1] = (boss.displayName or boss.name) .. ": " .. (ab.resolvedName or self.L[ab.name] or ab.name)
                end
            end
        end
    end
    return total, linked, missing
end

------------------------------------------------------------------
-- Plain text version of a boss
------------------------------------------------------------------
function WM:BuildPlainText(boss)
    local raid = self.raids[boss.raidId]
    local role = self.db.role
    local out = {}
    local function add(s) out[#out + 1] = s end
    local function section(title, lines)
        if not lines or #lines == 0 then return end
        add("")
        add(string.upper(title))
        for _, s in ipairs(lines) do
            if string.sub(s, 1, 3) == "## " then
                add("")
                add(string.sub(s, 4) .. ":")
            else
                add("- " .. s)
            end
        end
    end
    local bossName = boss.displayName or boss.name
    local raidName = raid and raid.name or ""
    local sizeStr = string.format(self.L["%d-man"], self:GetSize())

    add(bossName .. " - " .. raidName .. " (" .. sizeStr .. ")")
    if boss.tldr then
        add("")
        add(self.L["TL;DR: "] .. (self:Expand(boss.tldr) or boss.tldr))
    end
    section(self.L["HOW TO START THE FIGHT"], self:ExpandList(boss.start))
    section(self.L["STRATEGY"], self:ExpandList(boss.general))
    if role == "ALL" or role == "TANK" then section(self.L["TANKS"], self:ExpandList(boss.tank)) end
    if role == "ALL" or role == "HEAL" then section(self.L["HEALERS"], self:ExpandList(boss.heal)) end
    if role == "ALL" or role == "DPS" then section("DPS", self:ExpandList(boss.dps)) end
    if boss.abilities and #boss.abilities > 0 then
        add("")
        add(self.L["BOSS ABILITIES"])
        for _, ab in ipairs(boss.abilities) do
            local abName = ab.resolvedName or self.L[ab.name] or ab.name
            add("- " .. abName .. ": " .. (self:Expand(ab.desc) or ""))
        end
    end
    section(self.L["HARD MODE / HEROIC"], self:ExpandList(boss.hard))
    return table.concat(out, "\n")
end

------------------------------------------------------------------
-- Quick popup text
------------------------------------------------------------------
function WM:GetQuickText(boss)
    if not boss then return "" end
    local qRole = (self.db and self.db.quickRole) or "TLDR"
    if qRole == "TANK" and boss.tank and #boss.tank > 0 then
        local list = self:ExpandList(boss.tank)
        if #list > 0 then
            local out = {}
            for _, s in ipairs(list) do out[#out + 1] = "• " .. s end
            return table.concat(out, "\n")
        end
    elseif qRole == "HEAL" and boss.heal and #boss.heal > 0 then
        local list = self:ExpandList(boss.heal)
        if #list > 0 then
            local out = {}
            for _, s in ipairs(list) do out[#out + 1] = "• " .. s end
            return table.concat(out, "\n")
        end
    elseif qRole == "DPS" and boss.dps and #boss.dps > 0 then
        local list = self:ExpandList(boss.dps)
        if #list > 0 then
            local out = {}
            for _, s in ipairs(list) do out[#out + 1] = "• " .. s end
            return table.concat(out, "\n")
        end
    end
    return self:Expand(boss.tldr) or boss.tldr or ""
end

------------------------------------------------------------------
-- Sending to chat
------------------------------------------------------------------
local queue, acc = {}, 0
local qf = CreateFrame("Frame")
qf:Hide()
qf:SetScript("OnUpdate", function(self, elapsed)
    acc = acc + elapsed
    if acc >= 0.6 then
        acc = 0
        local item = table.remove(queue, 1)
        if item then SendChatMessage(item.text, item.chan) end
        if #queue == 0 then self:Hide() end
    end
end)

local function SplitMessage(text, maxlen)
    local parts = {}
    while string.len(text) > maxlen do
        local cut = maxlen
        while cut > 1 and string.sub(text, cut, cut) ~= " " do cut = cut - 1 end
        if cut <= 1 then cut = maxlen end
        parts[#parts + 1] = string.sub(text, 1, cut)
        text = string.sub(text, cut + 1)
    end
    if text ~= "" then parts[#parts + 1] = text end
    return parts
end

local function StripColors(s)
    s = string.gsub(s, "|c%x%x%x%x%x%x%x%x", "")
    s = string.gsub(s, "|r", "")
    return s
end

function WM:Send(boss, channel)
    if not boss then
        self:Print(self.L["No boss selected."])
        return
    end
    if not channel then
        if GetNumRaidMembers() > 0 then
            channel = "RAID"
        elseif GetNumPartyMembers() > 0 then
            channel = "PARTY"
        end
    end

    local bossName = boss.displayName or boss.name
    local sizeStr = string.format(self.L["%d-man"], self:GetSize())
    local lines = {}
    lines[#lines + 1] = "[Mentor] " .. bossName .. " (" .. sizeStr .. ") - " .. self.L["Strategy"]
    for _, s in ipairs(self:ExpandList(boss.general)) do
        if string.sub(s, 1, 3) == "## " then
            lines[#lines + 1] = "-- " .. string.sub(s, 4) .. " --"
        else
            lines[#lines + 1] = "- " .. s
        end
    end

    if not channel then
        for _, l in ipairs(lines) do self:Print(l) end
        return
    end
    for _, l in ipairs(lines) do
        for _, part in ipairs(SplitMessage(StripColors(l), 240)) do
            queue[#queue + 1] = { text = part, chan = channel }
        end
    end
    qf:Show()
end

------------------------------------------------------------------
-- Slash commands
------------------------------------------------------------------
function WM:HandleSlash(msg)
    msg = msg or ""
    local cmd, rest = string.match(msg, "^(%S*)%s*(.-)$")
    cmd = lower(cmd)
    rest = rest or ""

    if cmd == "" then
        self:ToggleMain()
    elseif cmd == "help" or cmd == "?" then
        self:Print(self.L["Commands:"])
        self:Print(self.L["/wm - open or close the window"])
        self:Print(self.L["/wm <boss name> - open a boss (partial names work, e.g. /wm lich)"])
        self:Print(self.L["/wm role all|tank|heal|dps - set your role filter"])
        self:Print(self.L["/wm size 10|25 - choose the raid size the tactics are written for"])
        self:Print(self.L["/wm notes - open or close the personal notes box"])
        self:Print(self.L["/wm quick - toggle the TL;DR popup when you target a boss (shows once per fight)"])
        self:Print(self.L["/wm config - open the settings panel (includes the window size slider)"])
        self:Print(self.L["/wm minimap - show or hide the minimap button"])
        self:Print(self.L["/wm send [raid|party|say] - send the selected boss's STRATEGY section to chat"])
        self:Print(self.L["/wm checklinks - report how many ability links this client can resolve"])
        self:Print(self.L["/wm reset - reset window positions"])
    elseif cmd == "quick" then
        self.db.quick = not self.db.quick
        local state = self.db.quick and self.L["enabled"] or self.L["disabled"]
        self:Print(string.format(self.L["Boss popup %s."], state))
        if not self.db.quick then self:HideQuick() end
        self:RefreshOptions()
    elseif cmd == "config" or cmd == "options" or cmd == "settings" then
        self:OpenOptions()
    elseif cmd == "minimap" then
        self.db.minimap.hide = not self.db.minimap.hide
        self:UpdateMinimapButton()
        self:RefreshOptions()
        local state = self.db.minimap.hide and self.L["hidden. Use /wm minimap to bring it back."] or self.L["shown."]
        self:Print(string.format(self.L["Minimap button %s."], state))
    elseif cmd == "role" then
        local r = string.upper(rest)
        if r == "HEALER" then r = "HEAL" end
        if r == "ALL" or r == "TANK" or r == "HEAL" or r == "DPS" then
            self:SetRole(r)
            local roleDisplay = ({ ALL = self.L["All"], TANK = self.L["Tank"], HEAL = self.L["Healer"], DPS = self.L["DPS"] })[r]
            self:Print(string.format(self.L["Role filter: %s"], roleDisplay))
        else
            self:Print(self.L["Use: /wm role all|tank|heal|dps"])
        end
    elseif cmd == "size" then
        local n = tonumber(rest)
        if n == 10 or n == 25 then
            self:SetSize(n)
            self:Print(string.format(self.L["Tactics now written for %s-man."], n))
        else
            self:Print(self.L["Use: /wm size 10  or  /wm size 25"])
        end
    elseif cmd == "notes" then
        if not self.ui.main or not self.ui.main:IsShown() then self:ShowMain() end
        self:ToggleNotes()
    elseif cmd == "checklinks" then
        local total, linked, missing = self:CheckLinks()
        self:Print(string.format(self.L["%d of %d abilities resolved to clickable spell links on this client."], linked, total))
        if #missing > 0 then
            self:Print(string.format(self.L["Shown as plain text (no matching spell ID): %d"], #missing))
            for i = 1, math.min(#missing, 8) do self:Print("  " .. missing[i]) end
        end
    elseif cmd == "send" then
        local chan = string.upper(rest)
        if chan == "" then chan = nil end
        if chan and chan ~= "RAID" and chan ~= "PARTY" and chan ~= "SAY" then
            self:Print(self.L["Channel must be raid, party or say."])
            return
        end
        local boss = self.selected or self.quickBoss or self:FindBossByUnit("target")
        self:Send(boss, chan)
    elseif cmd == "reset" then
        self.db.mainPos = nil
        self.db.quickPos = nil
        self.db.minimap.angle = DEFAULTS.minimap.angle
        self.db.mainWidth = DEFAULTS.mainWidth
        self.db.mainHeight = DEFAULTS.mainHeight
        self.db.theme = DEFAULTS.theme
        self:ResetPositions()
        self:Print(self.L["Positions and window size reset."])
    else
        local boss = self:FindBoss(msg)
        if boss then
            self:ShowMain(boss)
        else
            self:Print(string.format(self.L["No boss found for '%s'. Try /wm help."], msg))
        end
    end
end

SLASH_WRATHMENTOR1 = "/wm"
SLASH_WRATHMENTOR2 = "/wrathmentor"
SLASH_WRATHMENTOR3 = "/mentor"
SlashCmdList["WRATHMENTOR"] = function(msg) WM:HandleSlash(msg) end

------------------------------------------------------------------
-- Events
------------------------------------------------------------------
local ev = CreateFrame("Frame")
ev:RegisterEvent("ADDON_LOADED")
ev:RegisterEvent("PLAYER_TARGET_CHANGED")
ev:RegisterEvent("PLAYER_REGEN_ENABLED")
ev:RegisterEvent("PLAYER_REGEN_DISABLED")
ev:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 == "WrathMentor" then
            WM:Init()
            WM:SetupUI()
        end
    elseif event == "PLAYER_TARGET_CHANGED" then
        WM:OnTarget()
    elseif event == "PLAYER_REGEN_DISABLED" then
        WM:OnEnterCombat()
    elseif event == "PLAYER_REGEN_ENABLED" then
        WM:OnLeaveCombat()
    end
end)
