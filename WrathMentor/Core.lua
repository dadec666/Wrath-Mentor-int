-- Wrath Mentor - Core (v2.15.3 Interactive Edition)
-- Client: WoW 3.3.5a (Interface 30300). Lua 5.1, no modern APIs.

WrathMentor = WrathMentor or {}
local WM = WrathMentor

WM.version = "2.15.3"
WM.raids = {}        -- raids[id] = { id, name, zones, bosses, src }
WM.raidOrder = {}    -- display order
WM.nameIndex = {}    -- lowercase NPC name -> boss entry
WM.selected = nil    -- boss currently shown in the main window
WM.collapsed = {}    -- session-based collapsed raids

local DEFAULTS = {
    role = "ALL",                -- ALL | TANK | HEAL | DPS
    size = 25,                   -- 10 or 25
    theme = "classic",           -- "classic" | "dark"
    quickRole = "TLDR",          -- TLDR | TANK | HEAL | DPS
    quick = true,                -- popup when you target a boss
    quickRaidOnly = true,        -- only show the popup inside raid instances
    quickHideAfterCombat = true, -- hide the popup when combat ends
    quickScale = 1.0,            -- popup size
    modelsEnabled = true,        -- 3D creature model preview
    announce = false,            -- post TL;DR in chat when targeting a boss
    announceRaidOnly = true,     -- only announce inside raids
    sendContent = "strategy",    -- strategy | hard | tldr
    mainScale = 1.0,             -- tactics window size
    mainAlpha = 1.0,             -- window opacity
    mainWidth = 760,             -- tactics window width
    mainHeight = 500,            -- tactics window height
    minimap = { hide = false, angle = 225 },
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
-- Data registration & Tactics Overlay
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

function WM:RegisterTactics(raidId, data)
    local raid = self.raids[raidId]
    if not raid or not data then return end
    for _, boss in ipairs(raid.bosses) do
        local t = data[boss.name] or (boss.displayName and data[boss.displayName])
        if t then
            if t.tldr then boss.tldr = t.tldr end
            if t.start then boss.start = t.start end
            if t.general then boss.general = t.general end
            if t.tank then boss.tank = t.tank end
            if t.heal then boss.heal = t.heal end
            if t.dps then boss.dps = t.dps end
            if t.hard then boss.hard = t.hard end
            if t.abilities and boss.abilities then
                for i, abTrans in ipairs(t.abilities) do
                    local matched = false
                    if abTrans.name then
                        for _, orig in ipairs(boss.abilities) do
                            if orig.name and lower(orig.name) == lower(abTrans.name) then
                                orig.desc = abTrans.desc or orig.desc
                                matched = true
                                break
                            end
                        end
                    end
                    if not matched and boss.abilities[i] then
                        boss.abilities[i].desc = abTrans.desc or boss.abilities[i].desc
                    end
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

function WM:BossLink(boss)
    local data = "addon:WrathMentor:" .. boss.raidId .. ":" .. boss.index
    local bName = boss.displayName or boss.name
    return "|cff71d5ff|H" .. data .. "|h[" .. string.format(self.L["Open %s guide"], bName) .. "]|h|r"
end

function WM:BossFromLink(link)
    local raidId, index = string.match(link or "", "^addon:WrathMentor:([^:]+):(%d+)$")
    if not raidId then return nil end
    local raid = self.raids[raidId]
    if not raid then return nil end
    return raid.bosses[tonumber(index)]
end

function WM:Init()
    WrathMentorDB = WrathMentorDB or {}
    CopyDefaults(DEFAULTS, WrathMentorDB)
    if WrathMentorDB.size ~= 10 and WrathMentorDB.size ~= 25 then WrathMentorDB.size = 25 end
    self.db = WrathMentorDB
    self.collapsed = {}
    for _, id in ipairs(self.raidOrder) do self.collapsed[id] = true end
    self:Print(string.format(self.L["v%s loaded. Type /wm to open, /wm help for commands."], self.version))
end

function WM:ResetOptions()
    local d = DEFAULTS
    self.db.quick = d.quick
    self.db.quickRaidOnly = d.quickRaidOnly
    self.db.quickHideAfterCombat = d.quickHideAfterCombat
    self.db.quickScale = d.quickScale
    self.db.mainScale = d.mainScale
    self.db.mainAlpha = d.mainAlpha
    self.db.theme = d.theme
    self.db.quickRole = d.quickRole
    self.db.announce = d.announce
    self.db.announceRaidOnly = d.announceRaidOnly
    self.db.sendContent = d.sendContent
    self.db.minimap.hide = d.minimap.hide
    self.db.minimap.angle = d.minimap.angle
    self:ApplySettings()
end

------------------------------------------------------------------
-- Lookups & 3D Model Helpers
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

function WM:TargetIsBoss(boss)
    if not boss or not UnitExists("target") or UnitIsPlayer("target") then return false end
    local name = lower(UnitName("target") or "")
    if name == "" then return false end
    if name == lower(boss.name) or (boss.displayName and name == lower(boss.displayName)) then return true end
    if boss.aliases then
        for _, a in ipairs(boss.aliases) do
            if name == lower(a) or (self.L[a] and name == lower(self.L[a])) then return true end
        end
    end
    return false
end

------------------------------------------------------------------
-- Spell Links, Tag Parser & Tokenizer
------------------------------------------------------------------
local FALLBACK_ICON = "Interface\\Icons\\INV_Misc_QuestionMark"

function WM:ResolveSpell(ab)
    if not ab then return nil end
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

function WM:SafeSpellLink(spellID)
    spellID = tonumber(spellID)
    if not spellID then return nil end
    local name = GetSpellInfo(spellID)
    if not name or name == "" then return nil, nil end
    local link = GetSpellLink and GetSpellLink(spellID)
    if link and link ~= "" then return link, name end
    link = string.format("|cff71d5ff|Hspell:%d|h[%s]|h|r", spellID, name)
    return link, name
end

function WM:FormatSpellTags(text, mode)
    if type(text) ~= "string" or text == "" then return text end
    return (string.gsub(text, "{spell:(%d+)}", function(idStr)
        local id = tonumber(idStr)
        local link, name = WM:SafeSpellLink(id)
        if mode == "plain" then
            return name and ("[" .. name .. "]") or ("[Spell " .. idStr .. "]")
        elseif mode == "chat" then
            return link or (name and ("[" .. name .. "]")) or ("[Spell " .. idStr .. "]")
        else
            return name and ("|cff71d5ff[" .. name .. "]|r") or ("[Spell " .. idStr .. "]")
        end
    end))
end

-- Splits prose lines into tokens for the interactive inline word-by-word UI renderer
function WM:TokenizeLine(line, boss)
    local tokens = {}
    if not line or line == "" then return tokens end
    line = self:Expand(line, "raw")

    local lastPos = 1
    while true do
        local s, e, spellIdStr = string.find(line, "{spell:(%d+)}", lastPos)
        if not s then
            local remainder = string.sub(line, lastPos)
            for w in string.gmatch(remainder, "%S+") do
                tokens[#tokens + 1] = { text = w }
            end
            break
        end

        if s > lastPos then
            local preText = string.sub(line, lastPos, s - 1)
            for w in string.gmatch(preText, "%S+") do
                tokens[#tokens + 1] = { text = w }
            end
        end

        local spellId = tonumber(spellIdStr)
        local link, spellName = WM:SafeSpellLink(spellId)
        local abMatch = nil
        if boss and boss.abilities then
            for _, ab in ipairs(boss.abilities) do
                local ids = ab.ids or (ab.id and { ab.id })
                if ids then
                    for _, id in ipairs(ids) do
                        if id == spellId then
                            abMatch = ab
                            break
                        end
                    end
                end
                if abMatch then break end
            end
        end
        if not abMatch then
            abMatch = { spell = spellId, name = spellName or ("Spell " .. spellIdStr), checked = true, icon = select(3, GetSpellInfo(spellId)) }
        end

        tokens[#tokens + 1] = {
            text = "[" .. (spellName or ("Spell " .. spellIdStr)) .. "]",
            ability = abMatch,
        }
        lastPos = e + 1
    end
    return tokens
end

function WM:PreloadBossSpells(boss)
    if not boss then return end
    if boss.abilities then
        for _, ab in ipairs(boss.abilities) do self:ResolveSpell(ab) end
    end
    local function scan(lines)
        if not lines then return end
        for _, l in ipairs(lines) do
            for id in string.gmatch(l, "{spell:(%d+)}") do GetSpellInfo(tonumber(id)) end
        end
    end
    if boss.tldr then
        for id in string.gmatch(boss.tldr, "{spell:(%d+)}") do GetSpellInfo(tonumber(id)) end
    end
    scan(boss.start)
    scan(boss.general)
    scan(boss.tank)
    scan(boss.heal)
    scan(boss.dps)
    scan(boss.hard)
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
-- 10 / 25 man text expansion
------------------------------------------------------------------
function WM:GetSize()
    return (self.db and self.db.size) or 25
end

function WM:Expand(line, mode)
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
    if mode ~= "raw" then
        line = self:FormatSpellTags(line, mode or "ui")
    end
    return line
end

function WM:ExpandList(list, mode)
    local out = {}
    if list then
        for _, l in ipairs(list) do
            local e = self:Expand(l, mode)
            if e and e ~= "" then out[#out + 1] = e end
        end
    end
    return out
end

------------------------------------------------------------------
-- Plain text version of a boss (Copy view)
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
        add(self.L["TL;DR: "] .. (self:Expand(boss.tldr, "plain") or boss.tldr))
    end
    section(self.L["HOW TO START THE FIGHT"], self:ExpandList(boss.start, "plain"))
    section(self.L["STRATEGY"], self:ExpandList(boss.general, "plain"))
    if role == "ALL" or role == "TANK" then section(self.L["TANKS"], self:ExpandList(boss.tank, "plain")) end
    if role == "ALL" or role == "HEAL" then section(self.L["HEALERS"], self:ExpandList(boss.heal, "plain")) end
    if role == "ALL" or role == "DPS" then section("DPS", self:ExpandList(boss.dps, "plain")) end

    if boss.abilities and #boss.abilities > 0 then
        local plain, statuses = {}, {}
        for _, ab in ipairs(boss.abilities) do
            if ab.kind == "buff" or ab.kind == "debuff" then
                statuses[#statuses + 1] = ab
            else
                plain[#plain + 1] = ab
            end
        end
        if #plain > 0 then
            add("")
            add(self.L["BOSS ABILITIES"])
            for _, ab in ipairs(plain) do
                local abName = ab.resolvedName or self.L[ab.name] or ab.name
                add("- " .. abName .. ": " .. (self:Expand(ab.desc, "plain") or ""))
            end
        end
        if #statuses > 0 then
            add("")
            add(self.L["BUFFS & DEBUFFS"])
            for _, ab in ipairs(statuses) do
                local abName = ab.resolvedName or self.L[ab.name] or ab.name
                local kindLabel = string.upper(self.L[ab.kind] or ab.kind)
                add("- " .. abName .. " (" .. kindLabel .. "): " .. (self:Expand(ab.desc, "plain") or ""))
            end
        end
    end

    section(self.L["HARD MODE / HEROIC"], self:ExpandList(boss.hard, "plain"))
    return table.concat(out, "\n")
end

------------------------------------------------------------------
-- Quick popup text & Announcements
------------------------------------------------------------------
function WM:GetQuickText(boss)
    if not boss then return "" end
    local qRole = (self.db and self.db.quickRole) or "TLDR"
    if qRole == "TANK" and boss.tank and #boss.tank > 0 then
        local list = self:ExpandList(boss.tank, "ui")
        if #list > 0 then
            local out = {}
            for _, s in ipairs(list) do out[#out + 1] = "• " .. s end
            return table.concat(out, "\n")
        end
    elseif qRole == "HEAL" and boss.heal and #boss.heal > 0 then
        local list = self:ExpandList(boss.heal, "ui")
        if #list > 0 then
            local out = {}
            for _, s in ipairs(list) do out[#out + 1] = "• " .. s end
            return table.concat(out, "\n")
        end
    elseif qRole == "DPS" and boss.dps and #boss.dps > 0 then
        local list = self:ExpandList(boss.dps, "ui")
        if #list > 0 then
            local out = {}
            for _, s in ipairs(list) do out[#out + 1] = "• " .. s end
            return table.concat(out, "\n")
        end
    end
    return self:Expand(boss.tldr, "ui") or boss.tldr or ""
end

function WM:AnnounceBoss(boss)
    if not boss then return end
    local tldrText = self:Expand(boss.tldr, "chat") or boss.tldr or ""
    local bName = boss.displayName or boss.name
    local msg = "|cff33ccffWrath Mentor:|r |cffffd100" .. bName .. "|r - " .. tldrText .. "  " .. self:BossLink(boss)
    DEFAULT_CHAT_FRAME:AddMessage(msg)
end

------------------------------------------------------------------
-- Sending to chat (Configurable Content & Safe Hyperlinks)
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

local function StripNonLinkColors(s)
    local links = {}
    s = string.gsub(s, "(|c%x%x%x%x%x%x%x%x|H.-|h.-|h|r)", function(link)
        links[#links + 1] = link
        return "\001LINK" .. #links .. "\002"
    end)
    s = string.gsub(s, "|c%x%x%x%x%x%x%x%x", "")
    s = string.gsub(s, "|r", "")
    s = string.gsub(s, "\001LINK(%d+)\002", function(idx)
        return links[tonumber(idx)] or ""
    end)
    return s
end

local function SplitMessage(text, maxlen)
    maxlen = maxlen or 240
    local parts = {}
    while string.len(text) > maxlen do
        local ranges = {}
        local init = 1
        while true do
            local s, e = string.find(text, "|c%x%x%x%x%x%x%x%x|H.-|h.-|h|r", init)
            if not s then break end
            ranges[#ranges + 1] = { s = s, e = e }
            init = e + 1
        end

        local cut = maxlen
        for _, r in ipairs(ranges) do
            if cut >= r.s and cut <= r.e then
                cut = r.s - 1
                break
            end
        end

        local spaceCut = cut
        while spaceCut > 1 and string.sub(text, spaceCut, spaceCut) ~= " " do
            for _, r in ipairs(ranges) do
                if spaceCut >= r.s and spaceCut <= r.e then
                    spaceCut = r.s
                    break
                end
            end
            spaceCut = spaceCut - 1
        end

        if spaceCut > 1 then cut = spaceCut end
        if cut <= 1 then cut = maxlen end

        local part = string.sub(text, 1, cut)
        parts[#parts + 1] = string.gsub(part, "%s+$", "")
        text = string.gsub(string.sub(text, cut + 1), "^%s+", "")
    end
    if text ~= "" then parts[#parts + 1] = text end
    return parts
end

function WM:Send(boss, channel)
    if not boss then
        self:Print(self.L["No boss selected."])
        return
    end
    self:PreloadBossSpells(boss)

    if not channel then
        if GetNumRaidMembers() > 0 then
            channel = "RAID"
        elseif GetNumPartyMembers() > 0 then
            channel = "PARTY"
        end
    end

    local mode = self.db.sendContent or "strategy"
    local bossName = boss.displayName or boss.name
    local sizeStr = string.format(self.L["%d-man"], self:GetSize())
    local lines = {}

    if mode == "tldr" then
        lines[#lines + 1] = "[Mentor] " .. bossName .. " (" .. sizeStr .. ") - " .. self.L["TL;DR"]
        lines[#lines + 1] = self:Expand(boss.tldr, "chat") or boss.tldr or ""
    else
        local heading = (mode == "hard") and self.L["Hard Mode"] or self.L["Strategy"]
        local content = (mode == "hard") and boss.hard or boss.general
        lines[#lines + 1] = "[Mentor] " .. bossName .. " (" .. sizeStr .. ") - " .. heading
        for _, s in ipairs(self:ExpandList(content, "chat")) do
            if string.sub(s, 1, 3) == "## " then
                lines[#lines + 1] = "-- " .. string.sub(s, 4) .. " --"
            else
                lines[#lines + 1] = "- " .. s
            end
        end
    end

    if not channel then
        for _, l in ipairs(lines) do self:Print(l) end
        return
    end
    for _, l in ipairs(lines) do
        local cleanLine = StripNonLinkColors(l)
        for _, part in ipairs(SplitMessage(cleanLine, 240)) do
            queue[#queue + 1] = { text = part, chan = channel }
        end
    end
    qf:Show()
end

------------------------------------------------------------------
-- Hyperlink Clicks for Addon Links
------------------------------------------------------------------
local function HandleWrathMentorLink(link)
    local boss = WM:BossFromLink(link)
    if boss then WM:ShowMain(boss) end
end

if hooksecurefunc then
    if ChatFrame_OnHyperlinkShow then
        hooksecurefunc("ChatFrame_OnHyperlinkShow", function(chatFrame, link, text, button)
            HandleWrathMentorLink(link)
        end)
    end
    if ChatEdit_InsertLink then
        hooksecurefunc("ChatEdit_InsertLink", function(link)
            HandleWrathMentorLink(link)
        end)
    end
    hooksecurefunc("SetItemRef", function(link, text, button, chatFrame)
        HandleWrathMentorLink(link)
    end)
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
        self:Print(self.L["/wm models - toggle the 3D Model view on or off"])
        self:Print(self.L["/wm announce - toggle the chat announcement when you target a boss"])
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
    elseif cmd == "announce" then
        self.db.announce = not self.db.announce
        local state = self.db.announce and self.L["enabled"] or self.L["disabled"]
        self:Print(string.format(self.L["Chat announcement %s."], state))
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
        self.db.mainScale = DEFAULTS.mainScale
        self.db.mainAlpha = DEFAULTS.mainAlpha
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
-- Events & Combat Tracking
------------------------------------------------------------------
WM.combatShown = {}

function WM:InCombat()
    return self.inCombat or (UnitAffectingCombat("player") and true or false)
end

function WM:OnEnterCombat()
    self.inCombat = true
    self.combatShown = {}
    if ui.quick and ui.quick:IsShown() and ui.quick.boss then
        self.combatShown[self:BossKey(ui.quick.boss)] = true
    end
end

function WM:OnLeaveCombat()
    self.inCombat = false
    self.combatShown = {}
    if not self.db then return end
    if self.db.quickHideAfterCombat then
        self:HideQuick()
    elseif not self:FindBossByUnit("target") then
        self:HideQuick()
    end
end

function WM:PopupAllowed()
    if not self.db.quick then return false end
    local inInstance, instanceType = IsInInstance()
    if not inInstance then return false end
    if self.db.quickRaidOnly and instanceType ~= "raid" then return false end
    return true
end

function WM:AnnounceAllowed()
    if not self.db.announce then return false end
    local inInstance, instanceType = IsInInstance()
    if not inInstance then return false end
    if self.db.announceRaidOnly and instanceType ~= "raid" then return false end
    return true
end

function WM:OnTarget()
    if not self.db then return end
    if self.ui and self.ui.main and self.ui.main:IsShown() then
        self:RefreshModel()
    end
    local boss = self:FindBossByUnit("target")
    if not boss then
        if not self:InCombat() then self:HideQuick() end
        return
    end

    local key = self:BossKey(boss)
    if self:PopupAllowed() then
        if self:InCombat() then
            if not self.combatShown[key] then
                self.combatShown[key] = true
                self:ShowQuick(boss)
            end
        else
            self:ShowQuick(boss)
        end
    end

    if self:AnnounceAllowed() then
        if not self.combatShown["ann:" .. key] then
            self.combatShown["ann:" .. key] = true
            self:AnnounceBoss(boss)
        end
    end
end

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
