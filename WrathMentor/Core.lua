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
    size = 25,                   -- 10 or 25 (which raid size the text is written for)
    quick = true,                -- popup when you target a boss
    quickRaidOnly = true,        -- only show the popup inside raid instances
    quickHideAfterCombat = true, -- hide the popup when combat ends
    quickScale = 1.0,            -- popup size
    mainScale = 1.0,             -- tactics window size (UI scale slider)
    mainWidth = 760,             -- tactics window width (drag-to-resize corner)
    mainHeight = 500,            -- tactics window height (drag-to-resize corner)
    minimap = { hide = false, angle = 225 },
    collapsed = {},              -- collapsed raids in the list
    notes = {},                  -- personal notes, keyed by "<raid>:<boss name>"
}
WM.DEFAULTS = DEFAULTS

local ROLE_KEY = { TANK = "tank", HEAL = "heal", DPS = "dps" }
local ROLE_NAME = { ALL = "All", TANK = "Tank", HEAL = "Healer", DPS = "DPS" }

local function lower(s) return string.lower(s or "") end

------------------------------------------------------------------
-- Data registration (called by the Data_*.lua files)
------------------------------------------------------------------
function WM:AddRaid(id, name, zones, bosses, src)
    local raid = { id = id, name = name, zones = zones or {}, bosses = bosses, src = src }
    self.raids[id] = raid
    table.insert(self.raidOrder, id)
    for i, boss in ipairs(bosses) do
        boss.raidId = id
        boss.index = i
        self.nameIndex[lower(boss.name)] = boss
        if boss.aliases then
            for _, alias in ipairs(boss.aliases) do
                self.nameIndex[lower(alias)] = boss
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
    self:Print("v" .. self.version .. " loaded. Type /wm to open, /wm help for commands.")
end

-- Restore every option to its default (positions, role, size and notes are left alone)
function WM:ResetOptions()
    local d = DEFAULTS
    self.db.quick = d.quick
    self.db.quickRaidOnly = d.quickRaidOnly
    self.db.quickHideAfterCombat = d.quickHideAfterCombat
    self.db.quickScale = d.quickScale
    self.db.mainScale = d.mainScale
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
            if boss.aliases then
                for _, a in ipairs(boss.aliases) do
                    if string.find(lower(a), query, 1, true) then return boss end
                end
            end
        end
    end
    return nil
end

------------------------------------------------------------------
-- 10 / 25 man text expansion
--   "[10] text"   -> shown only when 10-man is selected
--   "[25] text"   -> shown only when 25-man is selected
--   "#{a/b}"      -> "a" in 10-man, "b" in 25-man
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
-- Spell links. An ability only becomes a clickable link when the
-- client itself confirms that the spell ID has the expected name,
-- so a wrong ID can never show the wrong tooltip.
------------------------------------------------------------------
local FALLBACK_ICON = "Interface\\Icons\\INV_Misc_QuestionMark"

function WM:ResolveSpell(ab)
    if ab.checked then return ab.spell end
    ab.checked = true
    local ids = ab.ids
    if not ids and ab.id then ids = { ab.id } end
    if not ids or not GetSpellInfo then return nil end
    for _, id in ipairs(ids) do
        local n, _, icon = GetSpellInfo(id)
        if n and lower(n) == lower(ab.name) then
            ab.spell = id
            ab.icon = icon
            return id
        end
    end
    return nil
end

function WM:SpellLink(ab)
    local id = self:ResolveSpell(ab)
    if not id then return nil end
    return "|cff71d5ff|Hspell:" .. id .. "|h[" .. ab.name .. "]|h|r"
end

-- The icon next to an ability row: the real spell icon once resolved, a
-- generic question-mark icon otherwise (never a wrong or made-up icon).
function WM:GetSpellIcon(ab)
    self:ResolveSpell(ab)
    return ab.icon or FALLBACK_ICON
end

-- Counts how many abilities the client could link (for /wm checklinks)
function WM:CheckLinks()
    local total, linked, missing = 0, 0, {}
    for _, id in ipairs(self.raidOrder) do
        for _, boss in ipairs(self.raids[id].bosses) do
            for _, ab in ipairs(boss.abilities or {}) do
                total = total + 1
                if self:ResolveSpell(ab) then
                    linked = linked + 1
                else
                    missing[#missing + 1] = boss.name .. ": " .. ab.name
                end
            end
        end
    end
    return total, linked, missing
end

------------------------------------------------------------------
-- Plain text version of a boss (used by the Copy view: no colours, no links)
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
    add(boss.name .. " - " .. (raid and raid.name or "") .. " (" .. self:GetSize() .. "-man)")
    if boss.tldr then
        add("")
        add("TL;DR: " .. (self:Expand(boss.tldr) or boss.tldr))
    end
    section("How to start the fight", self:ExpandList(boss.start))
    section("Strategy", self:ExpandList(boss.general))
    if role == "ALL" or role == "TANK" then section("Tanks", self:ExpandList(boss.tank)) end
    if role == "ALL" or role == "HEAL" then section("Healers", self:ExpandList(boss.heal)) end
    if role == "ALL" or role == "DPS" then section("DPS", self:ExpandList(boss.dps)) end
    if boss.abilities and #boss.abilities > 0 then
        add("")
        add("BOSS ABILITIES")
        for _, ab in ipairs(boss.abilities) do
            add("- " .. ab.name .. ": " .. (self:Expand(ab.desc) or ""))
        end
    end
    section("Hard mode / Heroic", self:ExpandList(boss.hard))
    return table.concat(out, "\n")
end

------------------------------------------------------------------
-- Quick popup text
------------------------------------------------------------------
local COLOR = { grey = "|cff9d9d9d" }

-- The popup shows only the TL;DR (in the selected 10/25-man version)
function WM:GetQuickText(boss)
    return self:Expand(boss.tldr) or boss.tldr or ""
end

------------------------------------------------------------------
-- Sending to chat (throttled: one line every 0.6s)
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
        self:Print("No boss selected.")
        return
    end
    if not channel then
        if GetNumRaidMembers() > 0 then
            channel = "RAID"
        elseif GetNumPartyMembers() > 0 then
            channel = "PARTY"
        end
    end

    -- Only the STRATEGY section is sent (no TL;DR, start, role tips, abilities or hard mode)
    local lines = {}
    lines[#lines + 1] = "[Mentor] " .. boss.name .. " (" .. self:GetSize() .. "-man) - Strategy"
    for _, s in ipairs(self:ExpandList(boss.general)) do
        if string.sub(s, 1, 3) == "## " then
            lines[#lines + 1] = "-- " .. string.sub(s, 4) .. " --"
        else
            lines[#lines + 1] = "- " .. s
        end
    end

    if not channel then
        -- Solo: just print it locally
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
        self:Print("Commands:")
        self:Print("/wm - open or close the window")
        self:Print("/wm <boss name> - open a boss (partial names work, e.g. /wm lich)")
        self:Print("/wm role all|tank|heal|dps - set your role filter")
        self:Print("/wm size 10|25 - choose the raid size the tactics are written for")
        self:Print("/wm notes - open or close the personal notes box")
        self:Print("/wm quick - toggle the TL;DR popup when you target a boss (shows once per fight)")
        self:Print("/wm config - open the settings panel (includes the window size slider)")
        self:Print("/wm minimap - show or hide the minimap button")
        self:Print("/wm send [raid|party|say] - send the selected boss's STRATEGY section to chat")
        self:Print("/wm checklinks - report how many ability links this client can resolve")
        self:Print("/wm reset - reset window positions")
    elseif cmd == "quick" then
        self.db.quick = not self.db.quick
        self:Print("Boss popup " .. (self.db.quick and "enabled." or "disabled."))
        if not self.db.quick then self:HideQuick() end
        self:RefreshOptions()
    elseif cmd == "config" or cmd == "options" or cmd == "settings" then
        self:OpenOptions()
    elseif cmd == "minimap" then
        self.db.minimap.hide = not self.db.minimap.hide
        self:UpdateMinimapButton()
        self:RefreshOptions()
        self:Print("Minimap button " .. (self.db.minimap.hide and "hidden. Use /wm minimap to bring it back." or "shown."))
    elseif cmd == "role" then
        local r = string.upper(rest)
        if r == "HEALER" then r = "HEAL" end
        if r == "ALL" or r == "TANK" or r == "HEAL" or r == "DPS" then
            self:SetRole(r)
            self:Print("Role filter: " .. ROLE_NAME[r])
        else
            self:Print("Use: /wm role all|tank|heal|dps")
        end
    elseif cmd == "size" then
        local n = tonumber(rest)
        if n == 10 or n == 25 then
            self:SetSize(n)
            self:Print("Tactics now written for " .. n .. "-man.")
        else
            self:Print("Use: /wm size 10  or  /wm size 25")
        end
    elseif cmd == "notes" then
        if not self.ui.main or not self.ui.main:IsShown() then self:ShowMain() end
        self:ToggleNotes()
    elseif cmd == "checklinks" then
        local total, linked, missing = self:CheckLinks()
        self:Print(linked .. " of " .. total .. " abilities resolved to clickable spell links on this client.")
        if #missing > 0 then
            self:Print("Shown as plain text (no matching spell ID): " .. #missing)
            for i = 1, math.min(#missing, 8) do self:Print("  " .. missing[i]) end
        end
    elseif cmd == "send" then
        local chan = string.upper(rest)
        if chan == "" then chan = nil end
        if chan and chan ~= "RAID" and chan ~= "PARTY" and chan ~= "SAY" then
            self:Print("Channel must be raid, party or say.")
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
        self:ResetPositions()
        self:Print("Positions and window size reset.")
    else
        local boss = self:FindBoss(msg)
        if boss then
            self:ShowMain(boss)
        else
            self:Print("No boss found for '" .. msg .. "'. Try /wm help.")
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
