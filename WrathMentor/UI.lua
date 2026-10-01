-- Wrath Mentor - Modern UI (v3 Card-Based, Micro-Send, Markers, Segments & Modern HUD)
local WM = WrathMentor

local ROW_H = 18
local LIST_W = 206
local DETAIL_W = 480
local SOLID = "Interface\\Buttons\\WHITE8X8"

local ui = {
    rows = {},
    roleButtons = {},
    sizeButtons = {},
    tabButtons = {},
    anchorButtons = {},
    quickRoleButtons = {},
    sendContentButtons = {},
    sectionOffsets = {},
    cardPool = {},
    fsPool = {},
    abPool = {},
    buffPool = {},
    wordPool = {},
    wordBtnPool = {},
    iconPool = {},
    optChecks = {},
    skinnedButtons = {},
    skinnedScrollBars = {},
    skinnedCheckboxes = {},
    activeTab = "tactics",
}
WM.ui = ui

local ROLES = {
    { "ALL", "All", 46 },
    { "TANK", "Tank", 50 },
    { "HEAL", "Healer", 56 },
    { "DPS", "DPS", 46 },
}

local TABS = {
    { key = "tactics",   label = "Tactics",   w = 80 },
    { key = "abilities", label = "Abilities", w = 96 },
    { key = "notes",     label = "Notes",     w = 74 },
}

local ANCHORS = {
    { key = "start", label = "Start", w = 54 },
    { key = "strat", label = "Strategy", w = 66 },
    { key = "roles", label = "Roles", w = 52 },
    { key = "hard",  label = "Hard mode", w = 72 },
}

local QUICK_ROLES = {
    { key = "TLDR", label = "TL;DR", w = 54 },
    { key = "TANK", label = "Tank",  w = 48 },
    { key = "HEAL", label = "Healer", w = 56 },
    { key = "DPS",  label = "DPS",   w = 44 },
}

local RAID_TARGET_COORDS = {
    { 0.00, 0.25, 0.00, 0.25 }, -- 1: Star
    { 0.25, 0.50, 0.00, 0.25 }, -- 2: Circle
    { 0.50, 0.75, 0.00, 0.25 }, -- 3: Diamond
    { 0.75, 1.00, 0.00, 0.25 }, -- 4: Triangle
    { 0.00, 0.25, 0.25, 0.50 }, -- 5: Moon
    { 0.25, 0.50, 0.25, 0.50 }, -- 6: Square
    { 0.50, 0.75, 0.25, 0.50 }, -- 7: Cross
    { 0.75, 1.00, 0.25, 0.50 }, -- 8: Skull
}

local BACKDROP_CLASSIC = {
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 },
}

local BACKDROP_FLAT_DARK = {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
}

local BACKDROP_BUTTON_DARK = {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 10,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
}

local BACKDROP_SEGMENT_CONTAINER = {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 10,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
}

local BACKDROP_CARD = {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 10,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
}

local C = {
    title = "|cffffd100",
    tldr = "|cff33ff99",
    start = "|cffffa040",
    strat = "|cffffd100",
    tank = "|cff5aa7ff",
    heal = "|cff4cff4c",
    dps = "|cffff6a4c",
    abil = "|cffd7a8ff",
    buffdebuff = "|cff8fd8ff",
    buff = "|cff33ff99",
    debuff = "|cffff7070",
    hard = "|cffff7070",
    grey = "|cff9d9d9d",
    white = "|cffffffff",
    sub = "|cff8fd8ff",
}

local function lower(s)
    s = s or ""
    if strlower then return strlower(s) end
    return string.lower(s)
end

------------------------------------------------------------------
-- Helpers & Position Storage
------------------------------------------------------------------
local function SavePos(frame, key)
    local point, _, relPoint, x, y = frame:GetPoint()
    WM.db[key] = { point, relPoint, x, y }
end

local function RestorePos(frame, key, point, relPoint, x, y)
    frame:ClearAllPoints()
    local p = WM.db and WM.db[key]
    if p then
        frame:SetPoint(p[1], UIParent, p[2], p[3], p[4])
    else
        frame:SetPoint(point, UIParent, relPoint, x, y)
    end
end

local function EnableWheel(sf)
    sf:EnableMouseWheel(true)
    sf:SetScript("OnMouseWheel", function(self, delta)
        local cur = self:GetVerticalScroll()
        local max = self:GetVerticalScrollRange()
        local new = cur - delta * 36
        if new < 0 then new = 0 end
        if new > max then new = max end
        self:SetVerticalScroll(new)
    end)
end

------------------------------------------------------------------
-- Skinning & Segment Visual Engine
------------------------------------------------------------------
local function UpdateSegmentButtonVisual(btn, isSelected)
    if not btn then return end
    local isDark = (WM.db and WM.db.theme == "dark")
    btn:SetBackdrop(BACKDROP_SEGMENT_CONTAINER)
    local fs = btn.text

    if isSelected then
        if isDark then
            btn:SetBackdropColor(0.20, 0.45, 0.85, 0.95)
            btn:SetBackdropBorderColor(0.38, 0.68, 1.0, 1)
        else
            btn:SetBackdropColor(0.18, 0.40, 0.75, 0.95)
            btn:SetBackdropBorderColor(0.30, 0.60, 0.95, 1)
        end
        if fs then fs:SetTextColor(1, 1, 1) end
    else
        btn:SetBackdropColor(0, 0, 0, 0)
        btn:SetBackdropBorderColor(0, 0, 0, 0)
        if fs then fs:SetTextColor(0.70, 0.72, 0.80) end
    end
end

local function CreateSegmentBtn(name, parent, w, h, text, onClick)
    local b = CreateFrame("Button", name, parent)
    b:SetWidth(w)
    b:SetHeight(h)
    b:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    b.text = b:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    b.text:SetPoint("CENTER", b, "CENTER", 0, 0)
    b.text:SetText(text)
    b:SetScript("OnClick", onClick)
    return b
end

local function RegisterButton(btn)
    ui.skinnedButtons[#ui.skinnedButtons + 1] = btn
    btn:HookScript("OnEnter", function(self)
        if WM.db and WM.db.theme == "dark" and self:IsEnabled() == 1 then
            self:SetBackdropBorderColor(1, 0.82, 0, 1)
        end
    end)
    btn:HookScript("OnLeave", function(self)
        if WM.db and WM.db.theme == "dark" and self:IsEnabled() == 1 then
            self:SetBackdropBorderColor(0.32, 0.35, 0.45, 1)
        end
    end)
end

local function UpdateButtonVisual(btn)
    local isDark = (WM.db and WM.db.theme == "dark")
    local nt, pt, dt, ht = btn:GetNormalTexture(), btn:GetPushedTexture(), btn:GetDisabledTexture(), btn:GetHighlightTexture()
    if isDark then
        if nt then nt:SetAlpha(0) end
        if pt then pt:SetAlpha(0) end
        if dt then dt:SetAlpha(0) end
        if ht then
            ht:SetTexture(1, 1, 1, 0.12)
            ht:SetAllPoints(btn)
        end
        btn:SetBackdrop(BACKDROP_BUTTON_DARK)
        if btn:IsEnabled() == 1 then
            btn:SetBackdropColor(0.12, 0.14, 0.18, 0.95)
            btn:SetBackdropBorderColor(0.32, 0.35, 0.45, 1)
        else
            btn:SetBackdropColor(0.18, 0.38, 0.65, 0.95)
            btn:SetBackdropBorderColor(0.40, 0.70, 1.0, 1)
        end
    else
        if nt then nt:SetAlpha(1) end
        if pt then pt:SetAlpha(1) end
        if dt then dt:SetAlpha(1) end
        if ht then
            ht:SetTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
            ht:SetTexCoord(0, 1, 0, 1)
        end
        btn:SetBackdrop(nil)
    end
end

local function RegisterScrollBar(sf, isLeftList)
    ui.skinnedScrollBars[#ui.skinnedScrollBars + 1] = { sf = sf, isLeft = isLeftList }
    local name = sf:GetName()
    if not name then return end
    local sb = _G[name .. "ScrollBar"]
    if not sb then return end
    sb.up = _G[name .. "ScrollBarScrollUpButton"]
    sb.down = _G[name .. "ScrollBarScrollDownButton"]
    local track = sb:CreateTexture(nil, "BACKGROUND")
    track:SetAllPoints(sb)
    track:SetTexture(SOLID)
    track:Hide()
    sb.track = track
end

local function UpdateScrollBarVisual(entry)
    local isDark = (WM.db and WM.db.theme == "dark")
    local sf, isLeft = entry.sf, entry.isLeft
    local name = sf:GetName()
    if not name then return end
    local sb = _G[name .. "ScrollBar"]
    if not sb then return end
    local thumb = sb:GetThumbTexture()

    if isDark then
        if sb.up then sb.up:Hide(); sb.up:SetAlpha(0); sb.up:EnableMouse(false); sb.up.Show = sb.up.Hide end
        if sb.down then sb.down:Hide(); sb.down:SetAlpha(0); sb.down:EnableMouse(false); sb.down.Show = sb.down.Hide end
        sb:ClearAllPoints()
        sb:SetPoint("TOPLEFT", sf, "TOPRIGHT", isLeft and 2 or 4, 0)
        sb:SetPoint("BOTTOMLEFT", sf, "BOTTOMRIGHT", isLeft and 2 or 4, 0)
        sb:SetWidth(6)
        if sb.track then sb.track:Show(); sb.track:SetVertexColor(0.06, 0.07, 0.10, 0.6) end
        if thumb then
            thumb:SetTexture(SOLID)
            thumb:SetVertexColor(0.35, 0.55, 0.85, 0.85)
            thumb:SetWidth(6)
            thumb:SetHeight(28)
        end
    else
        if sb.up then sb.up.Show = nil; sb.up:SetAlpha(1); sb.up:EnableMouse(true); sb.up:Show() end
        if sb.down then sb.down.Show = nil; sb.down:SetAlpha(1); sb.down:EnableMouse(true); sb.down.Show() end
        sb:ClearAllPoints()
        sb:SetPoint("TOPLEFT", sf, "TOPRIGHT", 6, -16)
        sb:SetPoint("BOTTOMLEFT", sf, "BOTTOMRIGHT", 6, 16)
        sb:SetWidth(16)
        if sb.track then sb.track:Hide() end
        if thumb then
            thumb:SetTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
            thumb:SetVertexColor(1, 1, 1, 1)
            thumb:SetWidth(18)
            thumb:SetHeight(24)
            thumb:SetTexCoord(0.2, 0.8, 0.125, 0.875)
        end
    end
end

local function RegisterCheckbox(cb) ui.skinnedCheckboxes[#ui.skinnedCheckboxes + 1] = cb end
local function UpdateCheckboxVisual(cb)
    local isDark = (WM.db and WM.db.theme == "dark")
    local normal, pushed = cb:GetNormalTexture(), cb:GetPushedTexture()
    if isDark then
        if normal then normal:SetAlpha(0) end
        if pushed then pushed:SetAlpha(0) end
        cb:SetBackdrop(BACKDROP_BUTTON_DARK)
        cb:SetBackdropColor(0.12, 0.14, 0.18, 0.95)
        cb:SetBackdropBorderColor(0.32, 0.35, 0.45, 1)
    else
        if normal then normal:SetAlpha(1) end
        if pushed then pushed:SetAlpha(1) end
        cb:SetBackdrop(nil)
    end
end

function WM:ApplyTheme()
    local isDark = (self.db and self.db.theme == "dark")
    local backdrop = isDark and BACKDROP_FLAT_DARK or BACKDROP_CLASSIC

    if ui.main then
        ui.main:SetBackdrop(backdrop)
        if isDark then
            ui.main:SetBackdropColor(0.08, 0.09, 0.12, 0.96)
            ui.main:SetBackdropBorderColor(0.25, 0.28, 0.38, 1)
            if ui.main.separator then ui.main.separator:Show() end
        else
            ui.main:SetBackdropColor(1, 1, 1, 1)
            ui.main:SetBackdropBorderColor(1, 1, 1, 1)
            if ui.main.separator then ui.main.separator:Hide() end
        end
    end

    local segContainers = { ui.roleSegment, ui.sizeSegment, ui.tabSegment, ui.quickRoleSegment }
    for _, sc in ipairs(segContainers) do
        if sc then
            sc:SetBackdrop(BACKDROP_SEGMENT_CONTAINER)
            if isDark then
                sc:SetBackdropColor(0.05, 0.06, 0.08, 0.85)
                sc:SetBackdropBorderColor(0.20, 0.23, 0.32, 0.90)
            else
                sc:SetBackdropColor(0, 0, 0, 0.45)
                sc:SetBackdropBorderColor(0.40, 0.40, 0.40, 0.80)
            end
        end
    end

    if ui.searchBox then
        if isDark then
            ui.searchBox:SetBackdrop(BACKDROP_BUTTON_DARK)
            ui.searchBox:SetBackdropColor(0.05, 0.06, 0.08, 0.95)
            ui.searchBox:SetBackdropBorderColor(0.25, 0.28, 0.38, 1)
        else
            ui.searchBox:SetBackdrop(BACKDROP_FLAT_DARK)
            ui.searchBox:SetBackdropColor(0, 0, 0, 0.6)
            ui.searchBox:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
        end
    end

    if ui.notesInnerBox then
        if isDark then
            ui.notesInnerBox:SetBackdrop(BACKDROP_BUTTON_DARK)
            ui.notesInnerBox:SetBackdropColor(0.05, 0.06, 0.08, 0.95)
            ui.notesInnerBox:SetBackdropBorderColor(0.25, 0.28, 0.38, 1)
        else
            ui.notesInnerBox:SetBackdrop(BACKDROP_FLAT_DARK)
            ui.notesInnerBox:SetBackdropColor(0, 0, 0, 0.4)
            ui.notesInnerBox:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
        end
    end

    if ui.quick then
        ui.quick:SetBackdrop(backdrop)
        if isDark then
            ui.quick:SetBackdropColor(0.06, 0.07, 0.10, 0.94)
            ui.quick:SetBackdropBorderColor(0.25, 0.28, 0.38, 1)
        else
            ui.quick:SetBackdropColor(0, 0, 0, 0.88)
            ui.quick:SetBackdropBorderColor(1, 1, 1, 1)
        end
    end

    for _, card in ipairs(ui.cardPool) do
        card:SetBackdrop(BACKDROP_CARD)
        if isDark then
            card:SetBackdropColor(0.06, 0.07, 0.10, 0.80)
            card:SetBackdropBorderColor(0.18, 0.21, 0.29, 0.85)
        else
            card:SetBackdropColor(0, 0, 0, 0.38)
            card:SetBackdropBorderColor(0.35, 0.35, 0.35, 0.6)
        end
    end

    for _, btn in ipairs(ui.skinnedButtons) do UpdateButtonVisual(btn) end
    for _, entry in ipairs(ui.skinnedScrollBars) do UpdateScrollBarVisual(entry) end
    for _, cb in ipairs(ui.skinnedCheckboxes) do UpdateCheckboxVisual(cb) end

    for k, b in pairs(ui.roleButtons) do UpdateSegmentButtonVisual(b, k == self.db.role) end
    for s, b in pairs(ui.sizeButtons) do UpdateSegmentButtonVisual(b, s == self:GetSize()) end
    for k, b in pairs(ui.tabButtons) do UpdateSegmentButtonVisual(b, k == ui.activeTab) end
    for k, b in pairs(ui.quickRoleButtons) do UpdateSegmentButtonVisual(b, k == (self.db.quickRole or "TLDR")) end
end

------------------------------------------------------------------
-- Sidebar List & Live Search Filter
------------------------------------------------------------------
local function RowClick(self)
    local d = self.data
    if not d then return end
    if d.raid then
        WM.collapsed[d.raid.id] = not WM.collapsed[d.raid.id]
        WM:RefreshList()
    else
        WM:SelectBoss(d.boss)
    end
end

local function CreateRow(i)
    local btn = CreateFrame("Button", nil, ui.listChild)
    btn:SetWidth(LIST_W)
    btn:SetHeight(ROW_H)
    btn:SetPoint("TOPLEFT", ui.listChild, "TOPLEFT", 0, -(i - 1) * ROW_H)
    btn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    btn.sel = btn:CreateTexture(nil, "BACKGROUND")
    btn.sel:SetAllPoints(btn)
    btn.sel:SetTexture(1, 0.82, 0, 0.18)
    btn.sel:Hide()
    btn.text = btn:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    btn.text:SetJustifyH("LEFT")
    btn.text:SetWidth(LIST_W - 14)
    btn:SetScript("OnClick", RowClick)
    return btn
end

function WM:RefreshList()
    if not ui.main then return end
    local q = lower(WM.searchQuery or "")
    local rows = {}

    for _, id in ipairs(self.raidOrder) do
        local raid = self.raids[id]
        local matchingBosses = {}
        for _, boss in ipairs(raid.bosses) do
            if q == "" then
                matchingBosses[#matchingBosses + 1] = boss
            else
                local bName = lower(boss.displayName or boss.name)
                local rawName = lower(boss.name)
                local matched = string.find(bName, q, 1, true) or string.find(rawName, q, 1, true)
                if not matched and boss.aliases then
                    for _, a in ipairs(boss.aliases) do
                        if string.find(lower(a), q, 1, true) then matched = true; break end
                    end
                end
                if matched then
                    matchingBosses[#matchingBosses + 1] = boss
                end
            end
        end

        if #matchingBosses > 0 then
            local isCollapsed = (q == "") and self.collapsed[id]
            rows[#rows + 1] = { raid = raid, matchCount = #matchingBosses }
            if not isCollapsed then
                for _, boss in ipairs(matchingBosses) do
                    rows[#rows + 1] = { boss = boss }
                end
            end
        end
    end

    for i, data in ipairs(rows) do
        local btn = ui.rows[i]
        if not btn then
            btn = CreateRow(i)
            ui.rows[i] = btn
        end
        btn.data = data
        btn.text:ClearAllPoints()
        if data.raid then
            local mark = ((q == "") and self.collapsed[data.raid.id]) and "+ " or "- "
            btn.text:SetPoint("LEFT", btn, "LEFT", 2, 0)
            btn.text:SetText(mark .. data.raid.name)
            btn.text:SetTextColor(1, 0.82, 0)
            btn.sel:Hide()
        else
            btn.text:SetPoint("LEFT", btn, "LEFT", 14, 0)
            btn.text:SetText(data.boss.displayName or data.boss.name)
            if self.db.notes[self:BossKey(data.boss)] then
                btn.text:SetTextColor(0.55, 0.85, 1)
            else
                btn.text:SetTextColor(0.9, 0.9, 0.9)
            end
            if data.boss == self.selected then btn.sel:Show() else btn.sel:Hide() end
        end
        btn:Show()
    end

    for i = #rows + 1, #ui.rows do ui.rows[i]:Hide() end
    ui.listChild:SetHeight(math.max(#rows * ROW_H, 10))
end

------------------------------------------------------------------
-- Ability Tooltip & Click Handlers
------------------------------------------------------------------
local function AbilityEnter(self)
    local ab = self.ab
    if not ab then return end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    local link = WM:SpellLink(ab)
    local id = WM:ResolveSpell(ab)
    if link then
        GameTooltip:SetHyperlink(link)
    elseif id then
        GameTooltip:SetHyperlink("spell:" .. id)
    else
        local name = ab.resolvedName or WM.L[ab.name] or ab.name
        GameTooltip:AddLine(name, 1, 1, 1)
    end
    GameTooltip:Show()
end

local function AbilityLeave() GameTooltip:Hide() end

local function AbilityClick(self, button)
    local ab = self.ab
    if not ab then return end
    local link = WM:SpellLink(ab)
    if not link then return end
    if IsModifiedClick and IsModifiedClick("CHATLINK") and ChatEdit_InsertLink and ChatEdit_InsertLink(link) then
        return
    end
    if SetItemRef then SetItemRef("spell:" .. ab.spell, link, button or "LeftButton") end
end

------------------------------------------------------------------
-- Dynamic Object Pools
------------------------------------------------------------------
local function GetRaidIcon(i)
    local tex = ui.iconPool[i]
    if not tex then
        tex = ui.detailChild:CreateTexture(nil, "OVERLAY")
        tex:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
        tex:SetWidth(15)
        tex:SetHeight(15)
        ui.iconPool[i] = tex
    end
    return tex
end

local function GetCard(i)
    local card = ui.cardPool[i]
    if not card then
        card = CreateFrame("Frame", nil, ui.detailChild)
        card:SetFrameLevel(ui.detailChild:GetFrameLevel() + 1)
        card:SetBackdrop(BACKDROP_CARD)

        local title = card:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        title:SetPoint("TOPLEFT", card, "TOPLEFT", 10, -8)
        title:SetJustifyH("LEFT")
        card.title = title

        local sendBtn = CreateFrame("Button", nil, card, "UIPanelButtonTemplate")
        sendBtn:SetWidth(50)
        sendBtn:SetHeight(18)
        sendBtn:SetPoint("TOPRIGHT", card, "TOPRIGHT", -8, -5)
        sendBtn:SetText(WM.L["To chat"] or "В чат")
        sendBtn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:AddLine(WM.L["Send this section to chat"] or "Отправить этот раздел в чат")
            GameTooltip:AddLine(WM.L["Sends only this phase or role without spamming the entire guide."] or "Отправляет только эту фазу или роль.", 1, 1, 1)
            GameTooltip:Show()
        end)
        sendBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
        RegisterButton(sendBtn)
        card.sendBtn = sendBtn

        ui.cardPool[i] = card
    end
    return card
end

local function GetFS(i)
    local fs = ui.fsPool[i]
    if not fs then
        fs = ui.detailChild:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        fs:SetJustifyH("LEFT")
        fs:SetJustifyV("TOP")
        ui.fsPool[i] = fs
    end
    return fs
end

local function GetWordFS(i)
    local fs = ui.wordPool[i]
    if not fs then
        fs = ui.detailChild:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        fs:SetJustifyH("LEFT")
        ui.wordPool[i] = fs
    end
    return fs
end

local function GetWordBtn(i)
    local row = ui.wordBtnPool[i]
    if not row then
        local btn = CreateFrame("Button", nil, ui.detailChild)
        btn:SetFrameLevel(ui.detailChild:GetFrameLevel() + 3)
        btn:SetHeight(15)
        btn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
        local txt = btn:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        txt:SetPoint("LEFT", btn, "LEFT", 0, 0)
        txt:SetJustifyH("LEFT")
        btn.text = txt
        btn:SetScript("OnEnter", AbilityEnter)
        btn:SetScript("OnLeave", AbilityLeave)
        btn:SetScript("OnClick", AbilityClick)
        row = { btn = btn }
        ui.wordBtnPool[i] = row
    end
    return row
end

local function CreateAbRow(parent)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetHeight(18)
    btn:SetWidth(DETAIL_W - 8)
    btn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    local icon = btn:CreateTexture(nil, "ARTWORK")
    icon:SetWidth(18)
    icon:SetHeight(18)
    icon:SetPoint("LEFT", btn, "LEFT", 0, 0)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    local row = { icon = icon }
    btn.text = btn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    btn.text:SetPoint("LEFT", icon, "RIGHT", 6, 0)
    btn.text:SetJustifyH("LEFT")
    btn:SetScript("OnEnter", AbilityEnter)
    btn:SetScript("OnLeave", AbilityLeave)
    btn:SetScript("OnClick", AbilityClick)
    row.btn = btn
    row.desc = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    row.desc:SetJustifyH("LEFT")
    row.desc:SetJustifyV("TOP")
    return row
end

local function GetAbRow(i)
    local row = ui.abPool[i]
    if not row then
        row = CreateAbRow(ui.abilitiesChild)
        ui.abPool[i] = row
    end
    return row
end

local function GetBuffRow(i)
    local row = ui.buffPool[i]
    if not row then
        row = CreateAbRow(ui.abilitiesChild)
        ui.buffPool[i] = row
    end
    return row
end

------------------------------------------------------------------
-- Tab Controller & Anchors
------------------------------------------------------------------
function WM:SetTab(tabKey)
    if ui.activeTab == "notes" and ui.notesDirty then
        self:SaveNotes(true)
    end
    ui.activeTab = tabKey

    for k, btn in pairs(ui.tabButtons) do
        UpdateSegmentButtonVisual(btn, k == tabKey)
    end

    if ui.copyMode then self:SetCopyMode(false) end

    if ui.detailScroll then ui.detailScroll:Hide() end
    if ui.abilitiesScroll then ui.abilitiesScroll:Hide() end
    if ui.notesFrame then ui.notesFrame:Hide() end

    if tabKey == "tactics" then
        if ui.detailScroll then ui.detailScroll:Show() end
        if ui.anchorContainer then ui.anchorContainer:Show() end
        self:RefreshDetail()
    elseif tabKey == "abilities" then
        if ui.abilitiesScroll then ui.abilitiesScroll:Show() end
        if ui.anchorContainer then ui.anchorContainer:Hide() end
        self:RefreshAbilitiesTab()
    elseif tabKey == "notes" then
        if ui.notesFrame then ui.notesFrame:Show() end
        if ui.anchorContainer then ui.anchorContainer:Hide() end
        self:LoadNotes()
    end
end

function WM:ScrollToSection(key)
    if ui.activeTab ~= "tactics" or not ui.detailScroll then return end
    local offset = ui.sectionOffsets[key]
    if offset then
        local target = math.max(0, offset - 4)
        local max = ui.detailScroll:GetVerticalScrollRange() or 0
        if target > max then target = max end
        ui.detailScroll:SetVerticalScroll(target)
    end
end

------------------------------------------------------------------
-- Content Renderers: Card-Based Tactics Tab
------------------------------------------------------------------
function WM:RefreshDetail()
    if not ui.main or ui.activeTab ~= "tactics" then return end

    for key, b in pairs(ui.roleButtons) do UpdateSegmentButtonVisual(b, key == self.db.role) end
    for key, b in pairs(ui.sizeButtons) do UpdateSegmentButtonVisual(b, key == self:GetSize()) end

    ui.sectionOffsets = {}
    local boss = self.selected
    local usedCard, usedFS, usedWord, usedWordBtn, usedIcon = 0, 0, 0, 0, 0
    local y = 2
    local dw = (ui.detailScroll and ui.detailScroll:GetWidth()) or DETAIL_W
    if not dw or dw <= 0 then dw = DETAIL_W end
    local cardW = dw - 12

    local WORD_GAP, LINE_H, BULLET_INDENT = 4, 15, 14
    local function measureWidth(str)
        ui.measureFS:SetText(str)
        return ui.measureFS:GetStringWidth() or 0
    end

    local function flowLine(line, startX, startY)
        local maxW = cardW - 20
        local x = startX + BULLET_INDENT
        local curY = startY

        usedWord = usedWord + 1
        local dashFS = GetWordFS(usedWord)
        dashFS:SetFontObject(GameFontHighlight)
        dashFS:ClearAllPoints()
        dashFS:SetPoint("TOPLEFT", ui.detailChild, "TOPLEFT", startX + 4, -curY)
        dashFS:SetText("•")
        dashFS:Show()

        local tokens = WM:TokenizeLine(line, boss)
        for _, tok in ipairs(tokens) do
            local w = tok.raidTarget and 16 or measureWidth(tok.text)
            if x > (startX + BULLET_INDENT) and (x + w) > (startX + maxW) then
                x = startX + BULLET_INDENT
                curY = curY + LINE_H
            end

            if tok.raidTarget then
                usedIcon = usedIcon + 1
                local ico = GetRaidIcon(usedIcon)
                local coords = RAID_TARGET_COORDS[tok.raidTarget]
                ico:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
                ico:ClearAllPoints()
                ico:SetPoint("TOPLEFT", ui.detailChild, "TOPLEFT", x, -curY)
                ico:Show()
            elseif tok.ability then
                usedWordBtn = usedWordBtn + 1
                local row = GetWordBtn(usedWordBtn)
                row.btn.ab = tok.ability
                row.btn:ClearAllPoints()
                row.btn:SetPoint("TOPLEFT", ui.detailChild, "TOPLEFT", x, -curY + 1)
                row.btn:SetWidth(w + 2)
                local kind = tok.ability.kind
                local color = (kind == "buff" and C.buff) or (kind == "debuff" and C.debuff) or "|cff71d5ff"
                row.btn.text:SetText(color .. tok.text .. "|r")
                row.btn:Show()
            else
                usedWord = usedWord + 1
                local fs = GetWordFS(usedWord)
                fs:SetFontObject(GameFontHighlight)
                fs:ClearAllPoints()
                fs:SetPoint("TOPLEFT", ui.detailChild, "TOPLEFT", x, -curY)
                fs:SetText(tok.text)
                fs:Show()
            end
            x = x + w + WORD_GAP
        end
        return curY + LINE_H + 4
    end

    local function renderCard(title, titleColor, lines, anchorKey, rawLines)
        if not lines or #lines == 0 then return end
        if anchorKey then ui.sectionOffsets[anchorKey] = y end

        usedCard = usedCard + 1
        local card = GetCard(usedCard)
        card:ClearAllPoints()
        card:SetPoint("TOPLEFT", ui.detailChild, "TOPLEFT", 6, -y)
        card:SetWidth(cardW)

        card.title:SetText(titleColor .. title .. "|r")
        card.sendBtn:SetScript("OnClick", function()
            WM:SendSection(boss, title, rawLines or lines)
        end)
        card:Show()

        local startCardY = y
        local innerY = y + 26
        for _, l in ipairs(lines) do
            innerY = flowLine(l, 6, innerY)
        end

        local cardHeight = (innerY - startCardY) + 6
        card:SetHeight(cardHeight)
        y = y + cardHeight + 8
    end

    if boss then
        local raid = self.raids[boss.raidId]
        local role = self.db.role
        local roleName = ({ ALL = self.L["All roles"], TANK = self.L["Tank"], HEAL = self.L["Healer"], DPS = self.L["DPS"] })[role] or role
        local bossName = boss.displayName or boss.name
        local raidName = raid and raid.name or "?"
        local sizeText = string.format(self.L["%d-man"], self:GetSize())

        usedFS = usedFS + 1
        local hdr = GetFS(usedFS)
        hdr:SetFontObject(GameFontNormalLarge)
        hdr:ClearAllPoints()
        hdr:SetPoint("TOPLEFT", ui.detailChild, "TOPLEFT", 6, -y)
        hdr:SetWidth(cardW)
        hdr:SetText(C.title .. bossName .. "|r  " .. C.grey .. "(" .. raidName .. " - " .. sizeText .. " - " .. roleName .. ")|r")
        hdr:Show()
        y = y + hdr:GetStringHeight() + 8

        if boss.tldr then
            local tldrLines = { self:Expand(boss.tldr, "raw") or boss.tldr }
            renderCard(self.L["TL;DR"] or "TL;DR", C.tldr, tldrLines, nil, { boss.tldr })
        end

        if boss.start and #boss.start > 0 then
            renderCard(self.L["How to start the fight"], C.start, self:ExpandList(boss.start, "raw"), "start", boss.start)
        end

        if boss.general and #boss.general > 0 then
            local hasSubPhases = false
            for _, l in ipairs(boss.general) do
                if string.sub(l, 1, 3) == "## " then hasSubPhases = true; break end
            end

            if hasSubPhases then
                local currentTitle = self.L["Strategy"]
                local currentLines = {}
                local firstAnchor = true
                for _, l in ipairs(boss.general) do
                    if string.sub(l, 1, 3) == "## " then
                        if #currentLines > 0 then
                            renderCard(currentTitle, C.strat, self:ExpandList(currentLines, "raw"), firstAnchor and "strat" or nil, currentLines)
                            firstAnchor = false
                            currentLines = {}
                        end
                        currentTitle = string.sub(l, 4)
                    else
                        currentLines[#currentLines + 1] = l
                    end
                end
                if #currentLines > 0 then
                    renderCard(currentTitle, C.strat, self:ExpandList(currentLines, "raw"), firstAnchor and "strat" or nil, currentLines)
                end
            else
                renderCard(self.L["Strategy"], C.strat, self:ExpandList(boss.general, "raw"), "strat", boss.general)
            end
        end

        local firstRoleAnchor = true
        if (role == "ALL" or role == "TANK") and boss.tank and #boss.tank > 0 then
            renderCard(self.L["Tanks"], C.tank, self:ExpandList(boss.tank, "raw"), firstRoleAnchor and "roles" or nil, boss.tank)
            firstRoleAnchor = false
        end
        if (role == "ALL" or role == "HEAL") and boss.heal and #boss.heal > 0 then
            renderCard(self.L["Healers"], C.heal, self:ExpandList(boss.heal, "raw"), firstRoleAnchor and "roles" or nil, boss.heal)
            firstRoleAnchor = false
        end
        if (role == "ALL" or role == "DPS") and boss.dps and #boss.dps > 0 then
            renderCard("DPS", C.dps, self:ExpandList(boss.dps, "raw"), firstRoleAnchor and "roles" or nil, boss.dps)
            firstRoleAnchor = false
        end

        if boss.hard and #boss.hard > 0 then
            renderCard(self.L["Hard mode / Heroic - full explanation"], C.hard, self:ExpandList(boss.hard, "raw"), "hard", boss.hard)
        end
    end

    for _, a in ipairs(ANCHORS) do
        local btn = ui.anchorButtons[a.key]
        if btn then
            if ui.sectionOffsets[a.key] then btn:Enable() else btn:Disable() end
            UpdateButtonVisual(btn)
        end
    end

    for i = usedCard + 1, #ui.cardPool do ui.cardPool[i]:Hide() end
    for i = usedFS + 1, #ui.fsPool do ui.fsPool[i]:Hide() end
    for i = usedWord + 1, #ui.wordPool do ui.wordPool[i]:Hide() end
    for i = usedWordBtn + 1, #ui.wordBtnPool do ui.wordBtnPool[i].btn:Hide() end
    for i = usedIcon + 1, #ui.iconPool do ui.iconPool[i]:Hide() end

    ui.detailChild:SetHeight(y + 24)
    WM:ApplyTheme()
end

------------------------------------------------------------------
-- Content Renderers: Dedicated Abilities Tab
------------------------------------------------------------------
function WM:RefreshAbilitiesTab()
    if not ui.main or ui.activeTab ~= "abilities" then return end
    local boss = self.selected
    local usedAb, usedBuff = 0, 0
    local y = 6
    local dw = (ui.abilitiesScroll and ui.abilitiesScroll:GetWidth()) or DETAIL_W
    if not dw or dw <= 0 then dw = DETAIL_W end

    local function abilityRow(getRow, i, ab, nameColor)
        local row = getRow(i)
        row.btn.ab = ab
        row.btn:ClearAllPoints()
        row.btn:SetPoint("TOPLEFT", ui.abilitiesChild, "TOPLEFT", 4, -y)
        row.btn:SetWidth(dw - 8)
        row.icon:SetTexture(WM:GetSpellIcon(ab))
        local abDisplayName = ab.resolvedName or self.L[ab.name] or ab.name
        local kindTag = ""
        if ab.kind == "buff" then
            kindTag = " " .. C.buff .. "[" .. (self.L["Buff"] or "Buff") .. "]|r"
        elseif ab.kind == "debuff" then
            kindTag = " " .. C.debuff .. "[" .. (self.L["Debuff"] or "Debuff") .. "]|r"
        end

        if WM:ResolveSpell(ab) then
            row.btn.text:SetText((nameColor or "|cff71d5ff") .. "[" .. abDisplayName .. "]|r" .. kindTag)
        else
            row.btn.text:SetText(C.white .. abDisplayName .. "|r" .. kindTag)
        end
        row.btn:Show()
        y = y + 20

        row.desc:ClearAllPoints()
        row.desc:SetPoint("TOPLEFT", ui.abilitiesChild, "TOPLEFT", 28, -y)
        row.desc:SetWidth(dw - 36)
        row.desc:SetText(self:Expand(ab.desc) or "")
        row.desc:Show()
        y = y + row.desc:GetStringHeight() + 10
    end

    if boss and boss.abilities and #boss.abilities > 0 then
        local plainAbs, statusAbs = {}, {}
        for _, ab in ipairs(boss.abilities) do
            if ab.kind == "buff" or ab.kind == "debuff" then
                statusAbs[#statusAbs + 1] = ab
            else
                plainAbs[#plainAbs + 1] = ab
            end
        end

        if #plainAbs > 0 then
            ui.abHeader:SetText(C.abil .. self.L["Boss abilities"] .. "|r  " .. C.grey .. self.L["(hover for the game tooltip, click to open it, shift-click to link in chat)"] .. "|r")
            ui.abHeader:SetPoint("TOPLEFT", ui.abilitiesChild, "TOPLEFT", 4, -y)
            ui.abHeader:Show()
            y = y + ui.abHeader:GetStringHeight() + 8
            for _, ab in ipairs(plainAbs) do
                usedAb = usedAb + 1
                abilityRow(GetAbRow, usedAb, ab)
            end
            y = y + 6
        else
            ui.abHeader:Hide()
        end

        if #statusAbs > 0 then
            ui.buffHeader:SetText(C.buffdebuff .. (self.L["BUFFS & DEBUFFS"] or "Buffs & Debuffs") .. "|r")
            ui.buffHeader:SetPoint("TOPLEFT", ui.abilitiesChild, "TOPLEFT", 4, -y)
            ui.buffHeader:Show()
            y = y + ui.buffHeader:GetStringHeight() + 8
            for _, ab in ipairs(statusAbs) do
                usedBuff = usedBuff + 1
                local nameColor = (ab.kind == "buff") and C.buff or C.debuff
                abilityRow(GetBuffRow, usedBuff, ab, nameColor)
            end
            y = y + 6
        else
            ui.buffHeader:Hide()
        end
    else
        ui.abHeader:SetText(C.grey .. self.L["No boss selected."] .. "|r")
        ui.abHeader:SetPoint("TOPLEFT", ui.abilitiesChild, "TOPLEFT", 4, -y)
        ui.abHeader:Show()
        ui.buffHeader:Hide()
    end

    for i = usedAb + 1, #ui.abPool do ui.abPool[i].btn:Hide(); ui.abPool[i].desc:Hide() end
    for i = usedBuff + 1, #ui.buffPool do ui.buffPool[i].btn:Hide(); ui.buffPool[i].desc:Hide() end
    ui.abilitiesChild:SetHeight(y + 24)
end

------------------------------------------------------------------
-- Content Renderers: Embedded Notes Tab
------------------------------------------------------------------
function WM:LoadNotes()
    if not ui.notesEdit then return end
    local boss = self.selected
    self.notesBoss = boss
    local bName = boss and (boss.displayName or boss.name) or ""
    ui.notesTitle:SetText(string.format(self.L["Personal notes for %s"] or "Personal notes for %s", bName))
    ui.notesEdit:SetText((boss and self.db.notes[self:BossKey(boss)]) or "")
    ui.notesEdit:SetCursorPosition(0)
    ui.notesDirty = false
    ui.notesStatus:SetText("")
end

function WM:SaveNotes(silent)
    if not ui.notesEdit or not self.notesBoss then return end
    local text = ui.notesEdit:GetText() or ""
    local key = self:BossKey(self.notesBoss)
    if string.match(text, "^%s*$") then
        self.db.notes[key] = nil
    else
        self.db.notes[key] = text
    end
    ui.notesDirty = false
    ui.notesStatus:SetText(self.L["Saved"])
    if ui.main then self:RefreshList() end
    if not silent then
        local bName = self.notesBoss.displayName or self.notesBoss.name
        self:Print(string.format(self.L["Notes saved for %s."], bName))
    end
end

------------------------------------------------------------------
-- Copy View
------------------------------------------------------------------
function WM:RefreshCopy()
    if not ui.copyFrame then return end
    if ui.copyScroll and ui.copyEdit then
        local cw = ui.copyScroll:GetWidth()
        if cw and cw > 0 then
            ui.copyEdit:SetWidth(cw - 6)
            if ui.copyMeasure then ui.copyMeasure:SetWidth(cw - 6) end
        end
    end
    local boss = self.selected
    local text = boss and self:BuildPlainText(boss) or ""
    ui.copyText = text
    ui.copyEdit:SetText(text)
    ui.copyMeasure:SetText(text)
    local h = ui.copyMeasure:GetStringHeight()
    if not h or h < 1 then h = string.len(text) / 60 * 14 end
    ui.copyEdit:SetHeight(math.max(322, h + 24))
    ui.copyScroll:SetVerticalScroll(0)
    ui.copyEdit:SetCursorPosition(0)
end

function WM:SetCopyMode(on)
    if not ui.copyFrame then return end
    ui.copyMode = on and true or false
    if ui.copyMode then
        if ui.detailScroll then ui.detailScroll:Hide() end
        if ui.abilitiesScroll then ui.abilitiesScroll:Hide() end
        if ui.notesFrame then ui.notesFrame:Hide() end
        if ui.anchorContainer then ui.anchorContainer:Hide() end
        ui.copyFrame:Show()
        self:RefreshCopy()
        ui.copyEdit:SetFocus()
        ui.copyEdit:HighlightText()
        ui.copyButton:SetText(self.L["Back"])
    else
        ui.copyEdit:ClearFocus()
        ui.copyFrame:Hide()
        ui.copyButton:SetText(self.L["Copy"])
        self:SetTab(ui.activeTab or "tactics")
    end
end

function WM:ToggleCopy() self:SetCopyMode(not ui.copyMode) end

------------------------------------------------------------------
-- Selection / Role / Size
------------------------------------------------------------------
function WM:SelectBoss(boss)
    if ui.notesDirty then self:SaveNotes(true) end
    self.selected = boss
    if self.collapsed[boss.raidId] then self.collapsed[boss.raidId] = false end
    if ui.main then
        self:RefreshList()
        if ui.activeTab == "tactics" then
            self:RefreshDetail()
            if ui.detailScroll then ui.detailScroll:SetVerticalScroll(0) end
        elseif ui.activeTab == "abilities" then
            self:RefreshAbilitiesTab()
            if ui.abilitiesScroll then ui.abilitiesScroll:SetVerticalScroll(0) end
        elseif ui.activeTab == "notes" then
            self:LoadNotes()
        end
        if ui.copyMode then self:RefreshCopy() end
    end
end

function WM:SetRole(role)
    self.db.role = role
    if ui.main and ui.activeTab == "tactics" then self:RefreshDetail() end
    if ui.quick and ui.quick:IsShown() and ui.quick.boss then self:ShowQuick(ui.quick.boss) end
end

function WM:SetSize(size)
    self.db.size = size
    if ui.main then
        if ui.activeTab == "tactics" then self:RefreshDetail() end
        if ui.activeTab == "abilities" then self:RefreshAbilitiesTab() end
    end
    if ui.quick and ui.quick:IsShown() and ui.quick.boss then self:ShowQuick(ui.quick.boss) end
end

------------------------------------------------------------------
-- Options & Settings Panel
------------------------------------------------------------------
local function ScaleLabel(value)
    return string.format(WM.L["Popup size: %d%%"], math.floor((value or 1) * 100 + 0.5))
end

local function WindowScaleLabel(value)
    return string.format(WM.L["Tactics window size: %d%%"], math.floor((value or 1) * 100 + 0.5))
end

function WM:RefreshOptions()
    ui.refreshing = true
    if ui.quickCheck then ui.quickCheck:SetChecked(self.db.quick and true or false) end
    if ui.optChecks then
        for _, cb in ipairs(ui.optChecks) do
            cb:SetChecked(cb.getter() and true or false)
        end
    end
    if ui.scaleSlider then
        ui.scaleSlider:SetValue(self.db.quickScale or 1)
        getglobal("WrathMentorScaleSliderText"):SetText(ScaleLabel(self.db.quickScale))
    end
    if ui.windowScaleSlider then
        ui.windowScaleSlider:SetValue(self.db.mainScale or 1)
        getglobal("WrathMentorWindowScaleSliderText"):SetText(WindowScaleLabel(self.db.mainScale))
    end
    if ui.windowAlphaSlider then
        ui.windowAlphaSlider:SetValue(self.db.mainAlpha or 1)
        getglobal("WrathMentorWindowAlphaSliderText"):SetText(string.format(self.L["Window opacity: %d%%"], math.floor((self.db.mainAlpha or 1) * 100 + 0.5)))
    end
    if ui.sendContentButtons then
        local current = self.db.sendContent or "strategy"
        for key, btn in pairs(ui.sendContentButtons) do
            if key == current then btn:Disable() else btn:Enable() end
            UpdateButtonVisual(btn)
        end
    end
    ui.refreshing = false
end

function WM:ApplyQuickScale()
    if ui.quick then ui.quick:SetScale(self.db.quickScale or 1) end
end

function WM:ApplyMainScale()
    if ui.main then ui.main:SetScale(self.db.mainScale or 1) end
    if ui.notes then ui.notes:SetScale(self.db.mainScale or 1) end
end

function WM:ApplyMainAlpha()
    if ui.main then ui.main:SetAlpha(self.db.mainAlpha or 1) end
end

function WM:ApplySettings()
    self:ApplyTheme()
    self:ApplyQuickScale()
    self:ApplyMainScale()
    self:ApplyMainAlpha()
    self:UpdateMinimapButton()
    if not self.db.quick then self:HideQuick() end
    self:RefreshOptions()
    self:LayoutMain()
end

------------------------------------------------------------------
-- Main Window Creation
------------------------------------------------------------------
local function CreateMain()
    local f = CreateFrame("Frame", "WrathMentorFrame", UIParent)
    ui.main = f
    f:SetWidth(WM.db.mainWidth or 780)
    f:SetHeight(WM.db.mainHeight or 520)
    f:SetFrameStrata("DIALOG")
    f:SetToplevel(true)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:SetClampedToScreen(true)
    f:SetBackdrop(BACKDROP_CLASSIC)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function(self) self:StartMoving() end)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        SavePos(self, "mainPos")
    end)
    f:SetScript("OnHide", function()
        if ui.notesDirty then WM:SaveNotes(true) end
        if ui.copyMode then WM:SetCopyMode(false) end
    end)
    RestorePos(f, "mainPos", "CENTER", "CENTER", 0, 0)
    if f.SetResizable then f:SetResizable(true) end
    if f.SetMinResize then f:SetMinResize(680, 440) end
    if f.SetMaxResize then f:SetMaxResize(1400, 900) end
    f:Hide()
    tinsert(UISpecialFrames, "WrathMentorFrame")

    local title = f:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOP", f, "TOP", 0, -14)
    title:SetText(WM.L["Wrath Mentor - WotLK Raid Tactics"])

    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -4, -4)

    --------------------------------------------------------------
    -- Left Sidebar: Live Search & Boss List
    --------------------------------------------------------------
    local sb = CreateFrame("EditBox", "WrathMentorSearchBox", f)
    sb:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -42)
    sb:SetWidth(LIST_W)
    sb:SetHeight(22)
    sb:SetAutoFocus(false)
    sb:SetFontObject(GameFontHighlightSmall)
    sb:SetTextInsets(6, 20, 0, 0)

    local ph = sb:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    ph:SetPoint("LEFT", sb, "LEFT", 6, 0)
    ph:SetText(WM.L["Search boss..."] or "Search boss...")
    ph:SetTextColor(0.5, 0.5, 0.5, 0.9)
    sb.placeholder = ph

    local clearBtn = CreateFrame("Button", nil, sb)
    clearBtn:SetWidth(16)
    clearBtn:SetHeight(16)
    clearBtn:SetPoint("RIGHT", sb, "RIGHT", -4, 0)
    clearBtn:SetNormalTexture("Interface\\FriendsFrame\\ClearBroadcastIcon")
    clearBtn:SetAlpha(0.6)
    clearBtn:Hide()
    clearBtn:SetScript("OnClick", function()
        sb:SetText("")
        sb:ClearFocus()
    end)
    sb.clearBtn = clearBtn

    sb:SetScript("OnTextChanged", function(self, userInput)
        local val = self:GetText() or ""
        if val == "" then
            ph:Show()
            clearBtn:Hide()
        else
            ph:Hide()
            clearBtn:Show()
        end
        WM.searchQuery = val
        WM:RefreshList()
    end)
    sb:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    ui.searchBox = sb

    local listScroll = CreateFrame("ScrollFrame", "WrathMentorListScroll", f, "UIPanelScrollFrameTemplate")
    listScroll:SetPoint("TOPLEFT", sb, "BOTTOMLEFT", 0, -4)
    listScroll:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 14, 48)
    listScroll:SetWidth(LIST_W)
    local listChild = CreateFrame("Frame", nil, listScroll)
    listChild:SetWidth(LIST_W)
    listChild:SetHeight(10)
    listScroll:SetScrollChild(listChild)
    EnableWheel(listScroll)
    RegisterScrollBar(listScroll, true)
    ui.listScroll = listScroll
    ui.listChild = listChild

    local sep = f:CreateTexture(nil, "BORDER")
    sep:SetPoint("TOPLEFT", f, "TOPLEFT", 228, -40)
    sep:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 228, 44)
    sep:SetWidth(1)
    sep:SetTexture(SOLID)
    sep:SetVertexColor(0.25, 0.28, 0.38, 0.8)
    f.separator = sep

    --------------------------------------------------------------
    -- Right Top Row 1: Segmented Roles & Sizes (Pill Bars)
    --------------------------------------------------------------
    local roleSeg = CreateFrame("Frame", "WrathMentorRoleSegment", f)
    roleSeg:SetPoint("TOPLEFT", f, "TOPLEFT", 238, -42)
    roleSeg:SetHeight(22)
    roleSeg:SetWidth(198)
    ui.roleSegment = roleSeg

    local prevRoleBtn
    for i, r in ipairs(ROLES) do
        local roleKey = r[1]
        local b = CreateSegmentBtn("WrathMentorRole" .. roleKey, roleSeg, r[3], 20, WM.L[r[2]], function()
            WM:SetRole(roleKey)
        end)
        if i == 1 then
            b:SetPoint("TOPLEFT", roleSeg, "TOPLEFT", 1, -1)
        else
            b:SetPoint("LEFT", prevRoleBtn, "RIGHT", 0, 0)
        end
        ui.roleButtons[roleKey] = b
        prevRoleBtn = b
    end

    local sizeSeg = CreateFrame("Frame", "WrathMentorSizeSegment", f)
    sizeSeg:SetPoint("LEFT", roleSeg, "RIGHT", 8, 0)
    sizeSeg:SetHeight(22)
    sizeSeg:SetWidth(68)
    ui.sizeSegment = sizeSeg

    local prevSizeBtn
    for i, size in ipairs({ 10, 25 }) do
        local s = size
        local b = CreateSegmentBtn("WrathMentorSize" .. s, sizeSeg, 33, 20, tostring(s), function()
            WM:SetSize(s)
        end)
        b:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:AddLine(string.format(WM.L["%s-man version of the tactics"], s))
            GameTooltip:Show()
        end)
        b:SetScript("OnLeave", function() GameTooltip:Hide() end)
        if i == 1 then
            b:SetPoint("TOPLEFT", sizeSeg, "TOPLEFT", 1, -1)
        else
            b:SetPoint("LEFT", prevSizeBtn, "RIGHT", 0, 0)
        end
        ui.sizeButtons[size] = b
        prevSizeBtn = b
    end

    local cb = CreateFrame("Button", "WrathMentorCopyButton", f, "UIPanelButtonTemplate")
    cb:SetWidth(56)
    cb:SetHeight(22)
    cb:SetPoint("TOPRIGHT", f, "TOPRIGHT", -22, -42)
    cb:SetText(WM.L["Copy"])
    cb:SetScript("OnClick", function() WM:ToggleCopy() end)
    cb:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine(WM.L["Copy text"])
        GameTooltip:AddLine(WM.L["Shows this boss as selectable text: drag to select part, or Select all, then Ctrl+C."], 1, 1, 1, 1)
        GameTooltip:Show()
    end)
    cb:SetScript("OnLeave", function() GameTooltip:Hide() end)
    RegisterButton(cb)
    ui.copyButton = cb

    --------------------------------------------------------------
    -- Right Row 2: Segmented Tabs & Section Anchors
    --------------------------------------------------------------
    local tabSeg = CreateFrame("Frame", "WrathMentorTabSegment", f)
    tabSeg:SetPoint("TOPLEFT", f, "TOPLEFT", 238, -68)
    tabSeg:SetHeight(22)
    tabSeg:SetWidth(250)
    ui.tabSegment = tabSeg

    local prevTabBtn
    for i, t in ipairs(TABS) do
        local k = t.key
        local b = CreateSegmentBtn("WrathMentorTab" .. k, tabSeg, t.w, 20, WM.L[t.label] or t.label, function()
            WM:SetTab(k)
        end)
        if i == 1 then
            b:SetPoint("TOPLEFT", tabSeg, "TOPLEFT", 1, -1)
        else
            b:SetPoint("LEFT", prevTabBtn, "RIGHT", 0, 0)
        end
        ui.tabButtons[k] = b
        prevTabBtn = b
    end

    local ac = CreateFrame("Frame", nil, f)
    ac:SetPoint("LEFT", tabSeg, "RIGHT", 12, 0)
    ac:SetPoint("RIGHT", f, "RIGHT", -22, 0)
    ac:SetHeight(20)
    ui.anchorContainer = ac

    local prevAnchor = nil
    for _, a in ipairs(ANCHORS) do
        local b = CreateFrame("Button", "WrathMentorAnchor" .. a.key, ac, "UIPanelButtonTemplate")
        b:SetWidth(a.w)
        b:SetHeight(18)
        b:SetText(WM.L[a.label])
        if not prevAnchor then
            b:SetPoint("LEFT", ac, "LEFT", 0, 0)
        else
            b:SetPoint("LEFT", prevAnchor, "RIGHT", 3, 0)
        end
        local k = a.key
        b:SetScript("OnClick", function() WM:ScrollToSection(k) end)
        RegisterButton(b)
        ui.anchorButtons[k] = b
        prevAnchor = b
    end

    --------------------------------------------------------------
    -- Tab Content 1: Tactics ScrollFrame
    --------------------------------------------------------------
    local detailScroll = CreateFrame("ScrollFrame", "WrathMentorDetailScroll", f, "UIPanelScrollFrameTemplate")
    detailScroll:SetPoint("TOPLEFT", f, "TOPLEFT", 238, -94)
    detailScroll:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -22, 48)
    local detailChild = CreateFrame("Frame", nil, detailScroll)
    detailChild:SetWidth(DETAIL_W)
    detailChild:SetHeight(10)
    detailScroll:SetScrollChild(detailChild)
    EnableWheel(detailScroll)
    RegisterScrollBar(detailScroll, false)
    ui.detailScroll = detailScroll
    ui.detailChild = detailChild

    local measureFS = detailChild:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    measureFS:Hide()
    ui.measureFS = measureFS

    --------------------------------------------------------------
    -- Tab Content 2: Dedicated Abilities ScrollFrame
    --------------------------------------------------------------
    local abilitiesScroll = CreateFrame("ScrollFrame", "WrathMentorAbilitiesScroll", f, "UIPanelScrollFrameTemplate")
    abilitiesScroll:SetPoint("TOPLEFT", f, "TOPLEFT", 238, -94)
    abilitiesScroll:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -22, 48)
    local abilitiesChild = CreateFrame("Frame", nil, abilitiesScroll)
    abilitiesChild:SetWidth(DETAIL_W)
    abilitiesChild:SetHeight(10)
    abilitiesScroll:SetScrollChild(abilitiesChild)
    EnableWheel(abilitiesScroll)
    RegisterScrollBar(abilitiesScroll, false)
    abilitiesScroll:Hide()
    ui.abilitiesScroll = abilitiesScroll
    ui.abilitiesChild = abilitiesChild

    local abHeader = abilitiesChild:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    abHeader:SetJustifyH("LEFT")
    ui.abHeader = abHeader

    local buffHeader = abilitiesChild:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    buffHeader:SetJustifyH("LEFT")
    ui.buffHeader = buffHeader

    --------------------------------------------------------------
    -- Tab Content 3: Embedded Personal Notes Frame
    --------------------------------------------------------------
    local nf = CreateFrame("Frame", "WrathMentorNotesEmbedded", f)
    nf:SetPoint("TOPLEFT", f, "TOPLEFT", 238, -94)
    nf:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -22, 48)
    nf:Hide()
    ui.notesFrame = nf

    local notesTitle = nf:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    notesTitle:SetPoint("TOPLEFT", nf, "TOPLEFT", 4, 0)
    notesTitle:SetJustifyH("LEFT")
    ui.notesTitle = notesTitle

    local notesHint = nf:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    notesHint:SetPoint("TOPLEFT", notesTitle, "BOTTOMLEFT", 0, -4)
    notesHint:SetText(WM.L["Type your private notes here. They are saved automatically."] or "Type your private notes here. They are saved automatically.")
    notesHint:SetTextColor(0.6, 0.6, 0.6)

    local notesInner = CreateFrame("Frame", nil, nf)
    notesInner:SetPoint("TOPLEFT", notesHint, "BOTTOMLEFT", 0, -8)
    notesInner:SetPoint("BOTTOMRIGHT", nf, "BOTTOMRIGHT", 0, 32)
    ui.notesInnerBox = notesInner

    local notesScroll = CreateFrame("ScrollFrame", "WrathMentorNotesScroll", notesInner, "UIPanelScrollFrameTemplate")
    notesScroll:SetPoint("TOPLEFT", notesInner, "TOPLEFT", 6, -6)
    notesScroll:SetPoint("BOTTOMRIGHT", notesInner, "BOTTOMRIGHT", -24, 6)
    EnableWheel(notesScroll)
    RegisterScrollBar(notesScroll, false)

    local notesEdit = CreateFrame("EditBox", "WrathMentorNotesEdit", notesScroll)
    notesEdit:SetMultiLine(true)
    notesEdit:SetAutoFocus(false)
    notesEdit:SetFontObject(ChatFontNormal)
    notesEdit:SetWidth(DETAIL_W - 32)
    notesEdit:SetHeight(240)
    notesEdit:SetMaxLetters(4000)
    notesScroll:SetScrollChild(notesEdit)
    notesEdit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    notesEdit:SetScript("OnTextChanged", function(self, userInput)
        if userInput then
            ui.notesDirty = true
            ui.notesStatus:SetText(WM.L["Unsaved changes"])
        end
        local text = self:GetText() or ""
        local lines = 0
        for line in string.gmatch(text .. "\n", "(.-)\n") do
            lines = lines + math.max(1, math.ceil(string.len(line) / 36))
        end
        self:SetHeight(math.max(240, lines * 14 + 20))
    end)
    ui.notesEdit = notesEdit

    local saveNotesBtn = CreateFrame("Button", nil, nf, "UIPanelButtonTemplate")
    saveNotesBtn:SetWidth(90)
    saveNotesBtn:SetHeight(22)
    saveNotesBtn:SetPoint("BOTTOMLEFT", nf, "BOTTOMLEFT", 0, 4)
    saveNotesBtn:SetText(WM.L["Save"])
    saveNotesBtn:SetScript("OnClick", function()
        notesEdit:ClearFocus()
        WM:SaveNotes(false)
    end)
    RegisterButton(saveNotesBtn)

    local notesStatus = nf:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    notesStatus:SetPoint("LEFT", saveNotesBtn, "RIGHT", 10, 0)
    ui.notesStatus = notesStatus

    --------------------------------------------------------------
    -- Tab Content 4: Copy Export Frame
    --------------------------------------------------------------
    local cf = CreateFrame("Frame", "WrathMentorCopyFrame", f)
    cf:SetPoint("TOPLEFT", f, "TOPLEFT", 238, -94)
    cf:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -22, 48)
    cf:Hide()
    ui.copyFrame = cf

    local selAll = CreateFrame("Button", "WrathMentorCopySelectAll", cf, "UIPanelButtonTemplate")
    selAll:SetWidth(90)
    selAll:SetHeight(20)
    selAll:SetPoint("TOPLEFT", cf, "TOPLEFT", 0, 0)
    selAll:SetText(WM.L["Select all"])
    selAll:SetScript("OnClick", function()
        ui.copyEdit:SetFocus()
        ui.copyEdit:HighlightText()
    end)
    RegisterButton(selAll)

    local hint = cf:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    hint:SetPoint("LEFT", selAll, "RIGHT", 8, 0)
    hint:SetText(WM.L["Drag with the mouse to select part of the text, then press Ctrl+C."])

    local copyScroll = CreateFrame("ScrollFrame", "WrathMentorCopyScroll", cf, "UIPanelScrollFrameTemplate")
    copyScroll:SetPoint("TOPLEFT", cf, "TOPLEFT", 0, -24)
    copyScroll:SetPoint("BOTTOMRIGHT", cf, "BOTTOMRIGHT", 0, 0)
    EnableWheel(copyScroll)
    RegisterScrollBar(copyScroll, false)
    ui.copyScroll = copyScroll

    local copyEdit = CreateFrame("EditBox", "WrathMentorCopyEdit", copyScroll)
    copyEdit:SetMultiLine(true)
    copyEdit:SetAutoFocus(false)
    copyEdit:SetFontObject(ChatFontNormal)
    copyEdit:SetWidth(DETAIL_W - 6)
    copyEdit:SetHeight(324)
    copyEdit:SetMaxLetters(60000)
    copyScroll:SetScrollChild(copyEdit)
    copyEdit:SetScript("OnTextChanged", function(self, userInput)
        if userInput and ui.copyText then self:SetText(ui.copyText) end
    end)
    copyEdit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    ui.copyEdit = copyEdit

    local measure = cf:CreateFontString(nil, "ARTWORK", "ChatFontNormal")
    measure:SetWidth(DETAIL_W - 6)
    measure:SetJustifyH("LEFT")
    measure:Hide()
    ui.copyMeasure = measure

    --------------------------------------------------------------
    -- Bottom Bar: Full Chat Actions, Checkbox, Settings
    --------------------------------------------------------------
    local send = CreateFrame("Button", "WrathMentorSendButton", f, "UIPanelButtonTemplate")
    send:SetWidth(120)
    send:SetHeight(22)
    send:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 238, 16)
    send:SetText(WM.L["Send to chat"])
    send:SetScript("OnClick", function() WM:Send(WM.selected) end)
    RegisterButton(send)

    local check = CreateFrame("CheckButton", "WrathMentorQuickCheck", f, "UICheckButtonTemplate")
    check:SetWidth(18)
    check:SetHeight(18)
    check:SetPoint("LEFT", send, "RIGHT", 14, 0)
    local checkText = getglobal("WrathMentorQuickCheckText")
    if checkText then checkText:SetText(WM.L["Popup when I target a boss"]) end
    check:SetScript("OnClick", function(self)
        WM.db.quick = self:GetChecked() and true or false
        WM:ApplySettings()
    end)
    RegisterCheckbox(check)
    ui.quickCheck = check

    local settings = CreateFrame("Button", "WrathMentorSettingsButton", f, "UIPanelButtonTemplate")
    settings:SetWidth(90)
    settings:SetHeight(22)
    settings:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -22, 16)
    settings:SetText(WM.L["Settings"])
    settings:SetScript("OnClick", function() WM:OpenOptions() end)
    RegisterButton(settings)

    local grip = CreateFrame("Button", "WrathMentorResizeGrip", f)
    grip:SetWidth(16)
    grip:SetHeight(16)
    grip:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -2, 2)
    grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    grip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    grip:SetScript("OnMouseDown", function(self) f:StartSizing("BOTTOMRIGHT") end)
    grip:SetScript("OnMouseUp", function(self)
        f:StopMovingOrSizing()
        WM.db.mainWidth = f:GetWidth()
        WM.db.mainHeight = f:GetHeight()
        WM:LayoutMain()
    end)
    grip:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
        GameTooltip:AddLine(WM.L["Drag to resize the window"])
        GameTooltip:Show()
    end)
    grip:SetScript("OnLeave", function() GameTooltip:Hide() end)
    ui.resizeGrip = grip

    f:SetScript("OnSizeChanged", function(self, w, h) WM:LayoutMain() end)
    WM:ApplyTheme()
end

function WM:LayoutMain()
    if not ui.detailScroll or not ui.main then return end
    local dw = ui.detailScroll:GetWidth()
    if dw and dw > 0 then
        if ui.detailChild then ui.detailChild:SetWidth(dw) end
        if ui.abilitiesChild then ui.abilitiesChild:SetWidth(dw) end
        if ui.notesEdit then ui.notesEdit:SetWidth(dw - 32) end
    end
    if ui.copyScroll then
        local cw = ui.copyScroll:GetWidth()
        if cw and cw > 0 then
            if ui.copyEdit then ui.copyEdit:SetWidth(cw - 6) end
            if ui.copyMeasure then ui.copyMeasure:SetWidth(cw - 6) end
        end
    end

    if ui.main:IsShown() then
        if ui.activeTab == "tactics" then self:RefreshDetail() end
        if ui.activeTab == "abilities" then self:RefreshAbilitiesTab() end
        if ui.copyMode then self:RefreshCopy() end
    end
end

function WM:ShowMain(boss)
    local firstCreate = not ui.main
    if firstCreate then CreateMain() end
    if boss and boss ~= self.selected and ui.notesDirty then self:SaveNotes(true) end
    if boss then
        self.selected = boss
    elseif not self.selected then
        local raid = self:GetZoneRaid() or self.raids[self.raidOrder[1]]
        self.selected = raid.bosses[1]
    end
    self.collapsed[self.selected.raidId] = false
    ui.main:Show()
    if firstCreate then self:ApplyMainScale(); self:ApplyMainAlpha() end
    self:RefreshOptions()
    self:RefreshList()
    self:SetTab(ui.activeTab or "tactics")
    self:LayoutMain()
end

function WM:ToggleMain()
    if ui.main and ui.main:IsShown() then ui.main:Hide() else self:ShowMain() end
end

------------------------------------------------------------------
-- Modern Redesigned Quick Popup (HUD)
------------------------------------------------------------------
function WM:SetQuickRole(roleKey)
    self.db.quickRole = roleKey
    if ui.quick and ui.quick:IsShown() and ui.quick.boss then
        self:ShowQuick(ui.quick.boss)
    end
end

local function CreateQuick()
    local q = CreateFrame("Frame", "WrathMentorQuick", UIParent)
    ui.quick = q
    q:SetWidth(380)
    q:SetHeight(130)
    q:SetFrameStrata("HIGH")
    q:SetMovable(true)
    q:EnableMouse(true)
    q:SetClampedToScreen(true)
    q:RegisterForDrag("LeftButton")
    q:SetScript("OnDragStart", function(self) self:StartMoving() end)
    q:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        SavePos(self, "quickPos")
    end)
    RestorePos(q, "quickPos", "TOP", "TOP", 0, -170)
    q:SetScale(WM.db.quickScale or 1)
    q:Hide()

    -- Title with boss name & raid size
    q.title = q:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    q.title:SetPoint("TOPLEFT", q, "TOPLEFT", 12, -10)
    q.title:SetPoint("RIGHT", q, "RIGHT", -32, 0)
    q.title:SetJustifyH("LEFT")

    -- Modern Segmented Control for Quick Roles
    local qSeg = CreateFrame("Frame", "WrathMentorQuickRoleSeg", q)
    qSeg:SetPoint("TOPLEFT", q, "TOPLEFT", 10, -30)
    qSeg:SetHeight(20)
    qSeg:SetWidth(206)
    ui.quickRoleSegment = qSeg

    local prevQR = nil
    for i, qr in ipairs(QUICK_ROLES) do
        local k = qr.key
        local b = CreateSegmentBtn("WrathMentorQuickRole" .. k, qSeg, qr.w, 18, WM.L[qr.label] or qr.label, function()
            WM:SetQuickRole(k)
        end)
        if i == 1 then
            b:SetPoint("TOPLEFT", qSeg, "TOPLEFT", 1, -1)
        else
            b:SetPoint("LEFT", prevQR, "RIGHT", 0, 0)
        end
        ui.quickRoleButtons[k] = b
        prevQR = b
    end

    -- Close Button
    local close = CreateFrame("Button", nil, q, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", q, "TOPRIGHT", -2, -2)

    -- Content Body Text
    q.body = q:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    q.body:SetPoint("TOPLEFT", q, "TOPLEFT", 12, -56)
    q.body:SetPoint("RIGHT", q, "RIGHT", -12, 0)
    q.body:SetJustifyH("LEFT")
    q.body:SetJustifyV("TOP")

    -- Action Buttons (Bottom-Right)
    local full = CreateFrame("Button", nil, q, "UIPanelButtonTemplate")
    full:SetWidth(94)
    full:SetHeight(20)
    full:SetPoint("BOTTOMRIGHT", q, "BOTTOMRIGHT", -10, 8)
    full:SetText(WM.L["Full guide"] or "Full guide")
    full:SetScript("OnClick", function()
        if q.boss then WM:ShowMain(q.boss) end
    end)
    RegisterButton(full)

    local send = CreateFrame("Button", nil, q, "UIPanelButtonTemplate")
    send:SetWidth(84)
    send:SetHeight(20)
    send:SetPoint("RIGHT", full, "LEFT", -4, 0)
    send:SetText(WM.L["Send"] or "Send")
    send:SetScript("OnClick", function()
        if q.boss then WM:Send(q.boss) end
    end)
    RegisterButton(send)

    WM:ApplyTheme()
end

function WM:ShowQuick(boss)
    if not ui.quick then CreateQuick() end
    local q = ui.quick
    q.boss = boss
    self.quickBoss = boss

    local currentQRole = self.db.quickRole or "TLDR"
    for k, btn in pairs(ui.quickRoleButtons) do
        UpdateSegmentButtonVisual(btn, k == currentQRole)
    end

    local bName = boss.displayName or boss.name
    local sizeStr = string.format(self.L["%d-man"], self:GetSize())
    q.title:SetText(C.title .. bName .. "|r  " .. C.grey .. "(" .. sizeStr .. ")|r")
    
    local text = self:GetQuickText(boss) or ""
    q.body:SetText(text)
    
    -- Dynamically calculate height based on rendered text
    local textH = q.body:GetStringHeight() or 20
    q:SetHeight(math.max(114, textH + 92))
    q:Show()
end

function WM:HideQuick()
    if ui.quick then ui.quick:Hide() end
end

function WM:ResetPositions()
    if ui.main then
        RestorePos(ui.main, "mainPos", "CENTER", "CENTER", 0, 0)
        ui.main:SetWidth(WM.db.mainWidth or 780)
        ui.main:SetHeight(WM.db.mainHeight or 520)
        self:LayoutMain()
    end
    if ui.quick then RestorePos(ui.quick, "quickPos", "TOP", "TOP", 0, -170) end
    self:UpdateMinimapButton()
end

------------------------------------------------------------------
-- Minimap Button
------------------------------------------------------------------
local function MinimapButton_UpdatePosition()
    if not ui.minimap then return end
    local angle = math.rad(WM.db.minimap.angle or 225)
    local radius = (Minimap:GetWidth() / 2) + 10
    ui.minimap:ClearAllPoints()
    ui.minimap:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radius, math.sin(angle) * radius)
end

local function MinimapButton_OnDragUpdate()
    local mx, my = Minimap:GetCenter()
    local scale = Minimap:GetEffectiveScale()
    local px, py = GetCursorPosition()
    px, py = px / scale, py / scale
    WM.db.minimap.angle = math.deg(math.atan2(py - my, px - mx))
    MinimapButton_UpdatePosition()
end

local function CreateMinimapButton()
    local b = CreateFrame("Button", "WrathMentorMinimapButton", Minimap)
    ui.minimap = b
    b:SetWidth(31)
    b:SetHeight(31)
    b:SetFrameStrata("MEDIUM")
    b:SetFrameLevel(Minimap:GetFrameLevel() + 8)
    b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    b:RegisterForDrag("LeftButton")
    b:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    local overlay = b:CreateTexture(nil, "OVERLAY")
    overlay:SetWidth(53)
    overlay:SetHeight(53)
    overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    overlay:SetPoint("TOPLEFT", b, "TOPLEFT", 0, 0)

    local background = b:CreateTexture(nil, "BACKGROUND")
    background:SetWidth(20)
    background:SetHeight(20)
    background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    background:SetPoint("TOPLEFT", b, "TOPLEFT", 7, -5)

    local icon = b:CreateTexture(nil, "ARTWORK")
    icon:SetWidth(17)
    icon:SetHeight(17)
    icon:SetTexture("Interface\\Icons\\INV_Misc_Book_09")
    icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
    icon:SetPoint("TOPLEFT", b, "TOPLEFT", 7, -6)

    b:SetScript("OnClick", function(self, button)
        if button == "RightButton" then WM:OpenOptions() else WM:ToggleMain() end
    end)
    b:SetScript("OnDragStart", function(self)
        GameTooltip:Hide()
        self:LockHighlight()
        self:SetScript("OnUpdate", MinimapButton_OnDragUpdate)
    end)
    b:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
        self:UnlockHighlight()
    end)
    b:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("Wrath Mentor")
        GameTooltip:AddLine(WM.L["Left-click: open the tactics window"], 1, 1, 1)
        GameTooltip:AddLine(WM.L["Right-click: settings"], 1, 1, 1)
        GameTooltip:AddLine(WM.L["Drag: move this button"], 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    b:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

function WM:UpdateMinimapButton()
    if not ui.minimap then return end
    if self.db.minimap.hide then
        ui.minimap:Hide()
    else
        MinimapButton_UpdatePosition()
        ui.minimap:Show()
    end
end

------------------------------------------------------------------
-- Settings Panel
------------------------------------------------------------------
local CHECK_OPTIONS = {
    {
        labelKey = "Use dark interface style (Flat/Dark)",
        get = function() return WM.db and WM.db.theme == "dark" end,
        set = function(v)
            WM.db.theme = v and "dark" or "classic"
            WM:ApplyTheme()
            if ui.activeTab == "tactics" then WM:RefreshDetail() end
            if ui.activeTab == "abilities" then WM:RefreshAbilitiesTab() end
        end,
    },
    {
        labelKey = "Show a popup when I target a boss",
        get = function() return WM.db.quick end,
        set = function(v) WM.db.quick = v end,
    },
    {
        labelKey = "Show TL;DR in chat when I target a boss",
        get = function() return WM.db.announce end,
        set = function(v) WM.db.announce = v end,
    },
    {
        labelKey = "Only show the popup inside raid instances",
        get = function() return WM.db.quickRaidOnly end,
        set = function(v) WM.db.quickRaidOnly = v end,
    },
    {
        labelKey = "Hide the popup when combat ends",
        get = function() return WM.db.quickHideAfterCombat end,
        set = function(v) WM.db.quickHideAfterCombat = v end,
    },
    {
        labelKey = "Show the minimap button",
        get = function() return not WM.db.minimap.hide end,
        set = function(v) WM.db.minimap.hide = not v; WM:UpdateMinimapButton() end,
    },
}

local function CreateOptions()
    local p = CreateFrame("Frame", "WrathMentorOptions", UIParent)
    p.name = "Wrath Mentor"
    ui.options = p

    local title = p:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", p, "TOPLEFT", 16, -16)
    title:SetText("Wrath Mentor")

    local sub = p:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    sub:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
    sub:SetText(WM.L["WotLK raid tactics. Changes apply immediately. Type /wm help for commands."])

    local y = -62
    for i, opt in ipairs(CHECK_OPTIONS) do
        local cb = CreateFrame("CheckButton", "WrathMentorOpt" .. i, p, "UICheckButtonTemplate")
        cb:SetPoint("TOPLEFT", p, "TOPLEFT", 14, y)
        getglobal("WrathMentorOpt" .. i .. "Text"):SetText(WM.L[opt.labelKey])
        cb.getter = opt.get
        cb:SetScript("OnClick", function(self)
            if ui.refreshing then return end
            opt.set(self:GetChecked() and true or false)
            WM:ApplySettings()
        end)
        RegisterCheckbox(cb)
        ui.optChecks[#ui.optChecks + 1] = cb
        y = y - 24
    end

    local slider = CreateFrame("Slider", "WrathMentorScaleSlider", p, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", p, "TOPLEFT", 24, y - 20)
    slider:SetWidth(220)
    slider:SetMinMaxValues(0.6, 1.6)
    slider:SetValueStep(0.05)
    getglobal("WrathMentorScaleSliderLow"):SetText("60%")
    getglobal("WrathMentorScaleSliderHigh"):SetText("160%")
    slider:SetScript("OnValueChanged", function(self, value)
        if ui.refreshing then return end
        value = math.floor(value * 20 + 0.5) / 20
        WM.db.quickScale = value
        getglobal("WrathMentorScaleSliderText"):SetText(ScaleLabel(value))
        WM:ApplyQuickScale()
    end)
    ui.scaleSlider = slider

    local wslider = CreateFrame("Slider", "WrathMentorWindowScaleSlider", p, "OptionsSliderTemplate")
    wslider:SetPoint("LEFT", slider, "RIGHT", 40, 0)
    wslider:SetWidth(220)
    wslider:SetMinMaxValues(0.7, 1.5)
    wslider:SetValueStep(0.05)
    getglobal("WrathMentorWindowScaleSliderLow"):SetText("70%")
    getglobal("WrathMentorWindowScaleSliderHigh"):SetText("150%")
    wslider:SetScript("OnValueChanged", function(self, value)
        if ui.refreshing then return end
        value = math.floor(value * 20 + 0.5) / 20
        WM.db.mainScale = value
        getglobal("WrathMentorWindowScaleSliderText"):SetText(WindowScaleLabel(value))
        WM:ApplyMainScale()
    end)
    ui.windowScaleSlider = wslider
    y = y - 56

    local aslider = CreateFrame("Slider", "WrathMentorWindowAlphaSlider", p, "OptionsSliderTemplate")
    aslider:SetPoint("TOPLEFT", p, "TOPLEFT", 24, y - 10)
    aslider:SetWidth(220)
    aslider:SetMinMaxValues(0.2, 1.0)
    aslider:SetValueStep(0.05)
    getglobal("WrathMentorWindowAlphaSliderLow"):SetText("20%")
    getglobal("WrathMentorWindowAlphaSliderHigh"):SetText("100%")
    aslider:SetScript("OnValueChanged", function(self, value)
        if ui.refreshing then return end
        value = math.floor(value * 20 + 0.5) / 20
        WM.db.mainAlpha = value
        getglobal("WrathMentorWindowAlphaSliderText"):SetText(string.format(WM.L["Window opacity: %d%%"], math.floor(value * 100 + 0.5)))
        WM:ApplyMainAlpha()
    end)
    ui.windowAlphaSlider = aslider
    y = y - 50

    local sendLabel = p:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    sendLabel:SetPoint("TOPLEFT", p, "TOPLEFT", 16, y)
    sendLabel:SetText(WM.L['"Send to chat" sends:'])
    local SEND_OPTS = {
        { key = "strategy", label = WM.L["Strategy"] },
        { key = "hard", label = WM.L["Hard Mode"] },
        { key = "tldr", label = WM.L["TL;DR"] }
    }
    local prevSendBtn = nil
    for _, opt in ipairs(SEND_OPTS) do
        local b = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
        b:SetWidth(84)
        b:SetHeight(20)
        if prevSendBtn then
            b:SetPoint("LEFT", prevSendBtn, "RIGHT", 4, 0)
        else
            b:SetPoint("TOPLEFT", sendLabel, "BOTTOMLEFT", 0, -4)
        end
        b:SetText(opt.label)
        local optKey = opt.key
        b:SetScript("OnClick", function()
            WM.db.sendContent = optKey
            WM:RefreshOptions()
        end)
        RegisterButton(b)
        ui.sendContentButtons[optKey] = b
        prevSendBtn = b
    end
    y = y - 48

    local test = CreateFrame("Button", "WrathMentorTestButton", p, "UIPanelButtonTemplate")
    test:SetWidth(130)
    test:SetHeight(22)
    test:SetPoint("TOPLEFT", p, "TOPLEFT", 16, y)
    test:SetText(WM.L["Test popup"])
    test:SetScript("OnClick", function()
        local boss = WM.selected or WM.raids[WM.raidOrder[1]].bosses[1]
        WM:ShowQuick(boss)
    end)
    RegisterButton(test)

    local reset = CreateFrame("Button", "WrathMentorResetButton", p, "UIPanelButtonTemplate")
    reset:SetWidth(150)
    reset:SetHeight(22)
    reset:SetPoint("LEFT", test, "RIGHT", 8, 0)
    reset:SetText(WM.L["Reset position/size"])
    reset:SetScript("OnClick", function() WM:HandleSlash("reset") end)
    RegisterButton(reset)

    p.refresh = function() WM:RefreshOptions() end
    p.default = function() WM:ResetOptions() end
    p.okay = function() end
    p.cancel = function() end
    p:SetScript("OnShow", function() WM:RefreshOptions() end)
end

function WM:OpenOptions()
    if not ui.options then return end
    InterfaceOptionsFrame_OpenToCategory(ui.options)
    InterfaceOptionsFrame_OpenToCategory(ui.options)
end

function WM:SetupUI()
    CreateMinimapButton()
    CreateOptions()
    if not ui.categoryAdded then
        InterfaceOptions_AddCategory(ui.options)
        ui.categoryAdded = true
    end
    self:UpdateMinimapButton()
    self:RefreshOptions()
end