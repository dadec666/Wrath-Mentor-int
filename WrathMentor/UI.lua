-- Wrath Mentor - UI (v2.3.1 Flat/Dark & Statuses Edition)
local WM = WrathMentor

local ROW_H = 18
local LIST_W = 204
local DETAIL_W = 440
local SOLID = "Interface\\Buttons\\WHITE8X8"

local ui = {
    rows = {},
    roleButtons = {},
    sizeButtons = {},
    anchorButtons = {},
    quickRoleButtons = {},
    sectionOffsets = {},
    fsPool = {},
    abPool = {},
    optChecks = {},
    skinnedButtons = {},
    skinnedScrollBars = {},
    skinnedCheckboxes = {},
}
WM.ui = ui

local ROLES = {
    { "ALL", "All", 48 },
    { "TANK", "Tank", 52 },
    { "HEAL", "Healer", 60 },
    { "DPS", "DPS", 48 },
}

local ANCHORS = {
    { key = "start", label = "Start", w = 64 },
    { key = "strat", label = "Strategy", w = 72 },
    { key = "roles", label = "Roles", w = 58 },
    { key = "abil",  label = "Abilities", w = 92 },
    { key = "hard",  label = "Hard mode", w = 82 },
}

local QUICK_ROLES = {
    { key = "TLDR", label = "TL;DR", w = 52 },
    { key = "TANK", label = "Tank",  w = 48 },
    { key = "HEAL", label = "Healer", w = 56 },
    { key = "DPS",  label = "DPS",   w = 44 },
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

local C = {
    title = "|cffffd100",
    tldr = "|cff33ff99",
    start = "|cffffa040",
    strat = "|cffffd100",
    tank = "|cff5aa7ff",
    heal = "|cff4cff4c",
    dps = "|cffff6a4c",
    abil = "|cffd7a8ff",
    hard = "|cffff7070",
    grey = "|cff9d9d9d",
    white = "|cffffffff",
    sub = "|cff8fd8ff",
    buff = "|cff33ff99",
    debuff = "|cffff7070",
}

------------------------------------------------------------------
-- Helpers
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
-- Skinning Engine (Flat/Dark & Classic)
------------------------------------------------------------------
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
    local nt = btn:GetNormalTexture()
    local pt = btn:GetPushedTexture()
    local dt = btn:GetDisabledTexture()
    local ht = btn:GetHighlightTexture()

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
    sb.track = track
end

local function UpdateScrollBarVisual(entry)
    local isDark = (WM.db and WM.db.theme == "dark")
    local sf = entry.sf
    local isLeft = entry.isLeft
    local name = sf:GetName()
    if not name then return end
    local sb = _G[name .. "ScrollBar"]
    if not sb then return end

    local thumb = sb:GetThumbTexture()

    if isDark then
        if sb.up then
            sb.up:Hide()
            sb.up:SetAlpha(0)
            sb.up:EnableMouse(false)
            sb.up.Show = sb.up.Hide
        end
        if sb.down then
            sb.down:Hide()
            sb.down:SetAlpha(0)
            sb.down:EnableMouse(false)
            sb.down.Show = sb.down.Hide
        end

        sb:ClearAllPoints()
        if isLeft then
            sb:SetPoint("TOPLEFT", sf, "TOPRIGHT", 2, 0)
            sb:SetPoint("BOTTOMLEFT", sf, "BOTTOMRIGHT", 2, 0)
        else
            sb:SetPoint("TOPLEFT", sf, "TOPRIGHT", 4, 0)
            sb:SetPoint("BOTTOMLEFT", sf, "BOTTOMRIGHT", 4, 0)
        end
        sb:SetWidth(6)

        if sb.track then
            sb.track:Show()
            sb.track:SetVertexColor(0.06, 0.07, 0.10, 0.6)
        end

        if thumb then
            thumb:SetTexture(SOLID)
            thumb:SetVertexColor(0.35, 0.55, 0.85, 0.85)
            thumb:SetWidth(6)
            thumb:SetHeight(28)
        end
    else
        if sb.up then
            sb.up.Show = nil
            sb.up:SetAlpha(1)
            sb.up:EnableMouse(true)
            sb.up:Show()
        end
        if sb.down then
            sb.down.Show = nil
            sb.down:SetAlpha(1)
            sb.down:EnableMouse(true)
            sb.down:Show()
        end

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

local function RegisterCheckbox(cb)
    ui.skinnedCheckboxes[#ui.skinnedCheckboxes + 1] = cb
end

local function UpdateCheckboxVisual(cb)
    local isDark = (WM.db and WM.db.theme == "dark")
    if isDark then
        local normal = cb:GetNormalTexture()
        if normal then normal:SetAlpha(0) end
        local pushed = cb:GetPushedTexture()
        if pushed then pushed:SetAlpha(0) end

        cb:SetBackdrop(BACKDROP_BUTTON_DARK)
        cb:SetBackdropColor(0.12, 0.14, 0.18, 0.95)
        cb:SetBackdropBorderColor(0.32, 0.35, 0.45, 1)
    else
        local normal = cb:GetNormalTexture()
        if normal then normal:SetAlpha(1) end
        local pushed = cb:GetPushedTexture()
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

    if ui.notes then
        ui.notes:SetBackdrop(backdrop)
        if isDark then
            ui.notes:SetBackdropColor(0.08, 0.09, 0.12, 0.96)
            ui.notes:SetBackdropBorderColor(0.25, 0.28, 0.38, 1)
        else
            ui.notes:SetBackdropColor(1, 1, 1, 1)
            ui.notes:SetBackdropBorderColor(1, 1, 1, 1)
        end
    end

    if ui.quick then
        ui.quick:SetBackdrop(backdrop)
        if isDark then
            ui.quick:SetBackdropColor(0.08, 0.09, 0.12, 0.96)
            ui.quick:SetBackdropBorderColor(0.25, 0.28, 0.38, 1)
        else
            ui.quick:SetBackdropColor(0, 0, 0, 0.88)
            ui.quick:SetBackdropBorderColor(1, 1, 1, 1)
        end
    end

    for _, btn in ipairs(ui.skinnedButtons) do UpdateButtonVisual(btn) end
    for _, entry in ipairs(ui.skinnedScrollBars) do UpdateScrollBarVisual(entry) end
    for _, cb in ipairs(ui.skinnedCheckboxes) do UpdateCheckboxVisual(cb) end
end

------------------------------------------------------------------
-- List rows
------------------------------------------------------------------
local function RowClick(self)
    local d = self.data
    if not d then return end
    if d.raid then
        WM.db.collapsed[d.raid.id] = not WM.db.collapsed[d.raid.id]
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
    btn.text:SetWidth(LIST_W - 12)
    btn:SetScript("OnClick", RowClick)
    return btn
end

function WM:RefreshList()
    if not ui.main then return end
    local rows = {}
    for _, id in ipairs(self.raidOrder) do
        local raid = self.raids[id]
        rows[#rows + 1] = { raid = raid }
        if not self.db.collapsed[id] then
            for _, boss in ipairs(raid.bosses) do
                rows[#rows + 1] = { boss = boss }
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
            local mark = self.db.collapsed[data.raid.id] and "+ " or "- "
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
    for i = #rows + 1, #ui.rows do
        ui.rows[i]:Hide()
    end
    ui.listChild:SetHeight(math.max(#rows * ROW_H, 10))
end

------------------------------------------------------------------
-- Detail pane
------------------------------------------------------------------
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

local function AbilityEnter(self)
    local ab = self.ab
    if not ab then return end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    local id = WM:ResolveSpell(ab)
    if id then
        GameTooltip:SetHyperlink("spell:" .. id)
    else
        local name = ab.resolvedName or WM.L[ab.name] or ab.name
        GameTooltip:AddLine(name, 1, 1, 1)
    end
    GameTooltip:Show()
end

local function AbilityLeave()
    GameTooltip:Hide()
end

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

local function GetAbRow(i)
    local row = ui.abPool[i]
    if not row then
        row = {}
        local btn = CreateFrame("Button", nil, ui.detailChild)
        btn:SetHeight(16)
        btn:SetWidth(DETAIL_W - 8)
        btn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
        local icon = btn:CreateTexture(nil, "ARTWORK")
        icon:SetWidth(16)
        icon:SetHeight(16)
        icon:SetPoint("LEFT", btn, "LEFT", 0, 0)
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        row.icon = icon
        btn.text = btn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        btn.text:SetPoint("LEFT", icon, "RIGHT", 4, 0)
        btn.text:SetJustifyH("LEFT")
        btn:SetScript("OnEnter", AbilityEnter)
        btn:SetScript("OnLeave", AbilityLeave)
        btn:SetScript("OnClick", AbilityClick)
        row.btn = btn
        row.desc = ui.detailChild:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        row.desc:SetJustifyH("LEFT")
        row.desc:SetJustifyV("TOP")
        ui.abPool[i] = row
    end
    return row
end

local function Bullets(lines)
    local out = {}
    for _, s in ipairs(lines) do
        if string.sub(s, 1, 3) == "## " then
            out[#out + 1] = C.sub .. string.sub(s, 4) .. "|r"
        else
            out[#out + 1] = "  - " .. s
        end
    end
    return table.concat(out, "\n")
end

function WM:ScrollToSection(key)
    if not ui.detailScroll then return end
    local offset = ui.sectionOffsets[key]
    if offset then
        local target = math.max(0, offset - 4)
        local max = ui.detailScroll:GetVerticalScrollRange() or 0
        if target > max then target = max end
        ui.detailScroll:SetVerticalScroll(target)
    end
end

function WM:RefreshDetail()
    if not ui.main then return end
    for key, b in pairs(ui.roleButtons) do
        if key == self.db.role then b:Disable() else b:Enable() end
        UpdateButtonVisual(b)
    end
    for key, b in pairs(ui.sizeButtons) do
        if key == self:GetSize() then b:Disable() else b:Enable() end
        UpdateButtonVisual(b)
    end

    ui.sectionOffsets = {}

    local boss = self.selected
    local used, usedAb = 0, 0
    local y = 0
    local dw = (ui.detailScroll and ui.detailScroll:GetWidth()) or DETAIL_W
    if not dw or dw <= 0 then dw = DETAIL_W end

    local function text(str, font, gap)
        used = used + 1
        local fs = GetFS(used)
        fs:SetFontObject(font or GameFontHighlight)
        fs:ClearAllPoints()
        fs:SetPoint("TOPLEFT", ui.detailChild, "TOPLEFT", 0, -y)
        fs:SetWidth(dw - 8)
        fs:SetText(str)
        fs:Show()
        y = y + fs:GetStringHeight() + (gap or 6)
    end

    local function section(title, color, lines, anchorKey)
        if not lines or #lines == 0 then return end
        if anchorKey then ui.sectionOffsets[anchorKey] = y end
        text(color .. title .. "|r", GameFontNormal, 2)
        text(Bullets(lines), GameFontHighlight, 10)
    end

    if boss then
        local raid = self.raids[boss.raidId]
        local role = self.db.role
        local roleName = ({
            ALL = self.L["All roles"],
            TANK = self.L["Tank"],
            HEAL = self.L["Healer"],
            DPS = self.L["DPS"]
        })[role] or role
        local bossName = boss.displayName or boss.name
        local raidName = raid and raid.name or "?"
        local sizeText = string.format(self.L["%d-man"], self:GetSize())

        text(C.title .. bossName .. "|r  " .. C.grey .. "(" .. raidName .. " - " .. sizeText .. " - " .. roleName .. ")|r", GameFontNormalLarge, 8)

        if boss.tldr then
            text(C.tldr .. self.L["TL;DR"] .. "|r  " .. (self:Expand(boss.tldr) or boss.tldr), GameFontHighlight, 10)
        end

        section(self.L["How to start the fight"], C.start, self:ExpandList(boss.start), "start")
        section(self.L["Strategy"], C.strat, self:ExpandList(boss.general), "strat")

        local hasRoleSection = false
        if role == "ALL" or role == "TANK" then
            if boss.tank and #boss.tank > 0 then
                if not hasRoleSection then ui.sectionOffsets["roles"] = y; hasRoleSection = true end
                section(self.L["Tanks"], C.tank, self:ExpandList(boss.tank))
            end
        end
        if role == "ALL" or role == "HEAL" then
            if boss.heal and #boss.heal > 0 then
                if not hasRoleSection then ui.sectionOffsets["roles"] = y; hasRoleSection = true end
                section(self.L["Healers"], C.heal, self:ExpandList(boss.heal))
            end
        end
        if role == "ALL" or role == "DPS" then
            if boss.dps and #boss.dps > 0 then
                if not hasRoleSection then ui.sectionOffsets["roles"] = y; hasRoleSection = true end
                section("DPS", C.dps, self:ExpandList(boss.dps))
            end
        end

        if boss.abilities and #boss.abilities > 0 then
            ui.sectionOffsets["abil"] = y
            text(C.abil .. self.L["Boss abilities"] .. "|r  " .. C.grey .. self.L["(hover for the game tooltip, click to open it, shift-click to link in chat)"] .. "|r", GameFontNormal, 4)
            for _, ab in ipairs(boss.abilities) do
                usedAb = usedAb + 1
                local row = GetAbRow(usedAb)
                row.btn.ab = ab
                row.btn:ClearAllPoints()
                row.btn:SetPoint("TOPLEFT", ui.detailChild, "TOPLEFT", 4, -y)
                row.btn:SetWidth(dw - 8)
                row.icon:SetTexture(WM:GetSpellIcon(ab))
                local abDisplayName = ab.resolvedName or self.L[ab.name] or ab.name

                -- Status Badge (Buff / Debuff)
                local kindTag = ""
                if ab.kind == "buff" then
                    kindTag = " " .. C.buff .. "[" .. (self.L["Buff"] or "Buff") .. "]|r"
                elseif ab.kind == "debuff" then
                    kindTag = " " .. C.debuff .. "[" .. (self.L["Debuff"] or "Debuff") .. "]|r"
                end

                if WM:ResolveSpell(ab) then
                    row.btn.text:SetText("|cff71d5ff[" .. abDisplayName .. "]|r" .. kindTag)
                else
                    row.btn.text:SetText(C.white .. abDisplayName .. "|r" .. kindTag)
                end
                row.btn:Show()
                y = y + 18
                row.desc:ClearAllPoints()
                row.desc:SetPoint("TOPLEFT", ui.detailChild, "TOPLEFT", 20, -y)
                row.desc:SetWidth(dw - 28)
                row.desc:SetText(self:Expand(ab.desc) or "")
                row.desc:Show()
                y = y + row.desc:GetStringHeight() + 7
            end
            y = y + 4
        end

        section(self.L["Hard mode / Heroic - full explanation"], C.hard, self:ExpandList(boss.hard), "hard")
    else
        text("", GameFontHighlight, 0)
    end

    for _, a in ipairs(ANCHORS) do
        local btn = ui.anchorButtons[a.key]
        if btn then
            if ui.sectionOffsets[a.key] then
                btn:Enable()
            else
                btn:Disable()
            end
            UpdateButtonVisual(btn)
        end
    end

    for i = used + 1, #ui.fsPool do ui.fsPool[i]:Hide() end
    for i = usedAb + 1, #ui.abPool do
        ui.abPool[i].btn:Hide()
        ui.abPool[i].desc:Hide()
    end
    ui.detailChild:SetHeight(y + 12)
    ui.detailScroll:SetVerticalScroll(0)
    if ui.copyMode then self:RefreshCopy() end
end

------------------------------------------------------------------
-- Copy view
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
        ui.detailScroll:Hide()
        ui.copyFrame:Show()
        self:RefreshCopy()
        ui.copyEdit:SetFocus()
        ui.copyEdit:HighlightText()
        ui.copyButton:SetText(self.L["Back"])
    else
        ui.copyEdit:ClearFocus()
        ui.copyFrame:Hide()
        ui.detailScroll:Show()
        ui.copyButton:SetText(self.L["Copy"])
    end
end

function WM:ToggleCopy()
    self:SetCopyMode(not ui.copyMode)
end

------------------------------------------------------------------
-- Selection / role / size
------------------------------------------------------------------
function WM:SelectBoss(boss)
    if ui.notesDirty then self:SaveNotes(true) end
    self.selected = boss
    if self.db.collapsed[boss.raidId] then self.db.collapsed[boss.raidId] = false end
    if ui.main then
        self:RefreshList()
        self:RefreshDetail()
        self:LoadNotes()
    end
end

function WM:SetRole(role)
    self.db.role = role
    if ui.main then self:RefreshDetail() end
    if ui.quick and ui.quick:IsShown() and ui.quick.boss then
        self:ShowQuick(ui.quick.boss)
    end
end

function WM:SetSize(size)
    self.db.size = size
    if ui.main then self:RefreshDetail() end
    if ui.quick and ui.quick:IsShown() and ui.quick.boss then
        self:ShowQuick(ui.quick.boss)
    end
end

------------------------------------------------------------------
-- Personal notes
------------------------------------------------------------------
function WM:RefreshNotesButton()
    if not ui.notesButton then return end
    local has = self.selected and self.db.notes[self:BossKey(self.selected)]
    ui.notesButton:SetText(has and (self.L["Notes"] .. "*") or self.L["Notes"])
    if ui.main then self:RefreshList() end
end

local function SetNotesStatus(text)
    if ui.notesStatus then ui.notesStatus:SetText(text or "") end
end

function WM:LoadNotes()
    self:RefreshNotesButton()
    if not ui.notes then return end
    local boss = self.selected
    self.notesBoss = boss
    local bName = boss and (boss.displayName or boss.name) or ""
    ui.notesTitle:SetText(self.L["Notes - "] .. bName)
    ui.notesEdit:SetText((boss and self.db.notes[self:BossKey(boss)]) or "")
    ui.notesEdit:SetCursorPosition(0)
    ui.notesDirty = false
    SetNotesStatus("")
end

function WM:SaveNotes(silent)
    if not ui.notes or not self.notesBoss then return end
    local text = ui.notesEdit:GetText() or ""
    local key = self:BossKey(self.notesBoss)
    if string.match(text, "^%s*$") then
        self.db.notes[key] = nil
    else
        self.db.notes[key] = text
    end
    ui.notesDirty = false
    SetNotesStatus(self.L["Saved"])
    self:RefreshNotesButton()
    if not silent then
        local bName = self.notesBoss.displayName or self.notesBoss.name
        self:Print(string.format(self.L["Notes saved for %s."], bName))
    end
end

local function CreateNotes()
    local n = CreateFrame("Frame", "WrathMentorNotes", ui.main)
    ui.notes = n
    n:SetWidth(270)
    n:SetHeight(360)
    n:SetPoint("TOPLEFT", ui.main, "TOPRIGHT", 2, 0)
    n:SetClampedToScreen(true)
    n:Hide()

    ui.notesTitle = n:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    ui.notesTitle:SetPoint("TOPLEFT", n, "TOPLEFT", 16, -16)
    ui.notesTitle:SetWidth(230)
    ui.notesTitle:SetJustifyH("LEFT")

    local scroll = CreateFrame("ScrollFrame", "WrathMentorNotesScroll", n, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", n, "TOPLEFT", 16, -42)
    scroll:SetWidth(222)
    scroll:SetHeight(246)
    EnableWheel(scroll)
    RegisterScrollBar(scroll, false)

    local edit = CreateFrame("EditBox", "WrathMentorNotesEdit", scroll)
    ui.notesEdit = edit
    edit:SetMultiLine(true)
    edit:SetAutoFocus(false)
    edit:SetFontObject(ChatFontNormal)
    edit:SetWidth(214)
    edit:SetHeight(246)
    edit:SetMaxLetters(4000)
    scroll:SetScrollChild(edit)
    edit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    edit:SetScript("OnTextChanged", function(self, userInput)
        if userInput then
            ui.notesDirty = true
            SetNotesStatus(WM.L["Unsaved changes"])
        end
        local text = self:GetText() or ""
        local lines = 0
        for line in string.gmatch(text .. "\n", "(.-)\n") do
            lines = lines + math.max(1, math.ceil(string.len(line) / 30))
        end
        self:SetHeight(math.max(246, lines * 14 + 20))
    end)

    ui.notesStatus = n:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    ui.notesStatus:SetPoint("BOTTOMLEFT", n, "BOTTOMLEFT", 16, 48)

    local save = CreateFrame("Button", "WrathMentorNotesSave", n, "UIPanelButtonTemplate")
    save:SetWidth(86)
    save:SetHeight(22)
    save:SetPoint("BOTTOMLEFT", n, "BOTTOMLEFT", 16, 16)
    save:SetText(WM.L["Save"])
    save:SetScript("OnClick", function()
        edit:ClearFocus()
        WM:SaveNotes(false)
    end)
    RegisterButton(save)

    local close = CreateFrame("Button", "WrathMentorNotesClose", n, "UIPanelButtonTemplate")
    close:SetWidth(86)
    close:SetHeight(22)
    close:SetPoint("LEFT", save, "RIGHT", 6, 0)
    close:SetText(WM.L["Close"])
    close:SetScript("OnClick", function() WM:ToggleNotes() end)
    RegisterButton(close)

    WM:ApplyTheme()
end

function WM:ToggleNotes()
    if not ui.main then return end
    if not ui.notes then CreateNotes() end
    if ui.notes:IsShown() then
        if ui.notesDirty then self:SaveNotes(true) end
        ui.notes:Hide()
    else
        ui.notes:Show()
        self:LoadNotes()
    end
end

------------------------------------------------------------------
-- Options & Settings
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
    ui.refreshing = false
end

function WM:ApplyQuickScale()
    if ui.quick then ui.quick:SetScale(self.db.quickScale or 1) end
end

function WM:ApplyMainScale()
    if ui.main then ui.main:SetScale(self.db.mainScale or 1) end
    if ui.notes then ui.notes:SetScale(self.db.mainScale or 1) end
end

function WM:ApplySettings()
    self:ApplyTheme()
    self:ApplyQuickScale()
    self:ApplyMainScale()
    self:UpdateMinimapButton()
    if not self.db.quick then self:HideQuick() end
    self:RefreshOptions()
end

------------------------------------------------------------------
-- Main window
------------------------------------------------------------------
local function CreateMain()
    local f = CreateFrame("Frame", "WrathMentorFrame", UIParent)
    ui.main = f
    f:SetWidth(WM.db.mainWidth or 760)
    f:SetHeight(WM.db.mainHeight or 500)
    f:SetFrameStrata("DIALOG")
    f:SetToplevel(true)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:SetClampedToScreen(true)
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
    if f.SetMinResize then f:SetMinResize(660, 420) end
    if f.SetMaxResize then f:SetMaxResize(1400, 900) end
    f:Hide()
    tinsert(UISpecialFrames, "WrathMentorFrame")

    local title = f:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOP", f, "TOP", 0, -14)
    title:SetText(WM.L["Wrath Mentor - WotLK Raid Tactics"])

    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -4, -4)

    -- Left: raid / boss list (seamless 204px column)
    local listScroll = CreateFrame("ScrollFrame", "WrathMentorListScroll", f, "UIPanelScrollFrameTemplate")
    listScroll:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -44)
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

    -- Vertical 1px separator line between columns
    local sep = f:CreateTexture(nil, "BORDER")
    sep:SetPoint("TOPLEFT", f, "TOPLEFT", 226, -40)
    sep:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 226, 44)
    sep:SetWidth(1)
    sep:SetTexture(SOLID)
    sep:SetVertexColor(0.25, 0.28, 0.38, 0.8)
    f.separator = sep

    -- Right Row 1: Role, Size, Notes, Copy (snug to the separator)
    local prev
    for i, r in ipairs(ROLES) do
        local b = CreateFrame("Button", "WrathMentorRole" .. r[1], f, "UIPanelButtonTemplate")
        b:SetWidth(r[3])
        b:SetHeight(22)
        b:SetText(WM.L[r[2]])
        if i == 1 then
            b:SetPoint("TOPLEFT", f, "TOPLEFT", 236, -44)
        else
            b:SetPoint("LEFT", prev, "RIGHT", 3, 0)
        end
        local roleKey = r[1]
        b:SetScript("OnClick", function() WM:SetRole(roleKey) end)
        RegisterButton(b)
        ui.roleButtons[roleKey] = b
        prev = b
    end

    for _, size in ipairs({ 10, 25 }) do
        local b = CreateFrame("Button", "WrathMentorSize" .. size, f, "UIPanelButtonTemplate")
        b:SetWidth(34)
        b:SetHeight(22)
        b:SetText(tostring(size))
        b:SetPoint("LEFT", prev, "RIGHT", (size == 10) and 10 or 3, 0)
        local s = size
        b:SetScript("OnClick", function() WM:SetSize(s) end)
        b:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:AddLine(string.format(WM.L["%s-man version of the tactics"], s))
            GameTooltip:Show()
        end)
        b:SetScript("OnLeave", function() GameTooltip:Hide() end)
        RegisterButton(b)
        ui.sizeButtons[size] = b
        prev = b
    end

    local nb = CreateFrame("Button", "WrathMentorNotesButton", f, "UIPanelButtonTemplate")
    nb:SetWidth(66)
    nb:SetHeight(22)
    nb:SetPoint("LEFT", prev, "RIGHT", 10, 0)
    nb:SetText(WM.L["Notes"])
    nb:SetScript("OnClick", function() WM:ToggleNotes() end)
    nb:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine(WM.L["Personal notes for this boss"])
        GameTooltip:AddLine(WM.L["Opens a side box. Press Save to keep them."], 1, 1, 1)
        GameTooltip:Show()
    end)
    nb:SetScript("OnLeave", function() GameTooltip:Hide() end)
    RegisterButton(nb)
    ui.notesButton = nb

    local cb = CreateFrame("Button", "WrathMentorCopyButton", f, "UIPanelButtonTemplate")
    cb:SetWidth(56)
    cb:SetHeight(22)
    cb:SetPoint("LEFT", nb, "RIGHT", 4, 0)
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

    -- Right Row 2: Anchor navigation buttons
    local prevAnchor = nil
    for _, a in ipairs(ANCHORS) do
        local b = CreateFrame("Button", "WrathMentorAnchor" .. a.key, f, "UIPanelButtonTemplate")
        b:SetWidth(a.w)
        b:SetHeight(19)
        b:SetText(WM.L[a.label])
        if not prevAnchor then
            b:SetPoint("TOPLEFT", f, "TOPLEFT", 236, -71)
        else
            b:SetPoint("LEFT", prevAnchor, "RIGHT", 4, 0)
        end
        local k = a.key
        b:SetScript("OnClick", function() WM:ScrollToSection(k) end)
        RegisterButton(b)
        ui.anchorButtons[k] = b
        prevAnchor = b
    end

    -- Right: detail pane
    local detailScroll = CreateFrame("ScrollFrame", "WrathMentorDetailScroll", f, "UIPanelScrollFrameTemplate")
    detailScroll:SetPoint("TOPLEFT", f, "TOPLEFT", 236, -96)
    detailScroll:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -22, 48)
    local detailChild = CreateFrame("Frame", nil, detailScroll)
    detailChild:SetWidth(DETAIL_W)
    detailChild:SetHeight(10)
    detailScroll:SetScrollChild(detailChild)
    EnableWheel(detailScroll)
    RegisterScrollBar(detailScroll, false)
    ui.detailScroll = detailScroll
    ui.detailChild = detailChild

    -- Copy view
    local cf = CreateFrame("Frame", "WrathMentorCopyFrame", f)
    cf:SetPoint("TOPLEFT", f, "TOPLEFT", 236, -96)
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

    -- Bottom controls
    local send = CreateFrame("Button", "WrathMentorSendButton", f, "UIPanelButtonTemplate")
    send:SetWidth(120)
    send:SetHeight(22)
    send:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 236, 16)
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
    grip:SetScript("OnMouseDown", function(self)
        f:StartSizing("BOTTOMRIGHT")
    end)
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

    f:SetScript("OnSizeChanged", function(self, w, h)
        WM:LayoutMain()
    end)

    WM:ApplyTheme()
end

function WM:LayoutMain()
    if not ui.detailScroll then return end
    local dw = ui.detailScroll:GetWidth()
    if dw and dw > 0 and ui.detailChild then ui.detailChild:SetWidth(dw) end
    if ui.copyScroll then
        local cw = ui.copyScroll:GetWidth()
        if cw and cw > 0 then
            if ui.copyEdit then ui.copyEdit:SetWidth(cw - 6) end
            if ui.copyMeasure then ui.copyMeasure:SetWidth(cw - 6) end
        end
    end
    if ui.main and ui.main:IsShown() then
        self:RefreshDetail()
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
    self.db.collapsed[self.selected.raidId] = false
    ui.main:Show()
    if firstCreate then self:ApplyMainScale() end
    self:RefreshOptions()
    self:RefreshList()
    self:LayoutMain()
    self:LoadNotes()
end

function WM:ToggleMain()
    if ui.main and ui.main:IsShown() then
        ui.main:Hide()
    else
        self:ShowMain()
    end
end

------------------------------------------------------------------
-- Quick popup (with role buttons)
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
    q:SetWidth(360)
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

    q.title = q:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    q.title:SetPoint("TOPLEFT", q, "TOPLEFT", 12, -10)
    q.title:SetWidth(312)
    q.title:SetJustifyH("LEFT")

    -- Role Buttons inside Quick Popup
    local prevQR = nil
    for _, qr in ipairs(QUICK_ROLES) do
        local b = CreateFrame("Button", "WrathMentorQuickRole" .. qr.key, q, "UIPanelButtonTemplate")
        b:SetWidth(qr.w)
        b:SetHeight(18)
        b:SetText(WM.L[qr.label])
        if not prevQR then
            b:SetPoint("TOPLEFT", q, "TOPLEFT", 12, -28)
        else
            b:SetPoint("LEFT", prevQR, "RIGHT", 4, 0)
        end
        local k = qr.key
        b:SetScript("OnClick", function() WM:SetQuickRole(k) end)
        RegisterButton(b)
        ui.quickRoleButtons[k] = b
        prevQR = b
    end

    q.body = q:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    q.body:SetPoint("TOPLEFT", q, "TOPLEFT", 12, -52)
    q.body:SetWidth(336)
    q.body:SetJustifyH("LEFT")
    q.body:SetJustifyV("TOP")

    local close = CreateFrame("Button", nil, q, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", q, "TOPRIGHT", -2, -2)

    local full = CreateFrame("Button", nil, q, "UIPanelButtonTemplate")
    full:SetWidth(90)
    full:SetHeight(20)
    full:SetPoint("BOTTOMRIGHT", q, "BOTTOMRIGHT", -10, 8)
    full:SetText(WM.L["Full guide"])
    full:SetScript("OnClick", function()
        if q.boss then WM:ShowMain(q.boss) end
    end)
    RegisterButton(full)

    local send = CreateFrame("Button", nil, q, "UIPanelButtonTemplate")
    send:SetWidth(90)
    send:SetHeight(20)
    send:SetPoint("RIGHT", full, "LEFT", -4, 0)
    send:SetText(WM.L["Send"])
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
        if k == currentQRole then
            btn:Disable()
        else
            btn:Enable()
        end
        UpdateButtonVisual(btn)
    end

    local bName = boss.displayName or boss.name
    local sizeStr = string.format(self.L["%d-man"], self:GetSize())
    q.title:SetText(bName .. "  |cff9d9d9d(" .. sizeStr .. ")|r")
    q.body:SetText(self:GetQuickText(boss))
    q:SetHeight(q.body:GetStringHeight() + 86)
    q:Show()
end

function WM:HideQuick()
    if ui.quick then ui.quick:Hide() end
end

function WM:PopupAllowed()
    if not self.db.quick then return false end
    local inInstance, instanceType = IsInInstance()
    if not inInstance then return false end
    if self.db.quickRaidOnly and instanceType ~= "raid" then return false end
    return true
end

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

function WM:OnTarget()
    if not self.db then return end
    if not self:PopupAllowed() then
        self:HideQuick()
        return
    end
    local boss = self:FindBossByUnit("target")
    if boss then
        if self:InCombat() then
            local key = self:BossKey(boss)
            if self.combatShown[key] then return end
            self.combatShown[key] = true
        end
        self:ShowQuick(boss)
    elseif not self:InCombat() then
        self:HideQuick()
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

function WM:ResetPositions()
    if ui.main then
        RestorePos(ui.main, "mainPos", "CENTER", "CENTER", 0, 0)
        ui.main:SetWidth(WM.db.mainWidth or 760)
        ui.main:SetHeight(WM.db.mainHeight or 500)
        self:LayoutMain()
    end
    if ui.quick then RestorePos(ui.quick, "quickPos", "TOP", "TOP", 0, -170) end
    self:UpdateMinimapButton()
end

------------------------------------------------------------------
-- Minimap button
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
        if button == "RightButton" then
            WM:OpenOptions()
        else
            WM:ToggleMain()
        end
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
-- Settings panel
------------------------------------------------------------------
local CHECK_OPTIONS = {
    {
        labelKey = "Use dark interface style (Flat/Dark)",
        get = function() return WM.db and WM.db.theme == "dark" end,
        set = function(v)
            WM.db.theme = v and "dark" or "classic"
            WM:ApplyTheme()
            WM:RefreshDetail()
        end,
    },
    {
        labelKey = "Show the minimap button",
        get = function() return not WM.db.minimap.hide end,
        set = function(v) WM.db.minimap.hide = not v end,
    },
    {
        labelKey = "Show a popup when I target a boss",
        get = function() return WM.db.quick end,
        set = function(v) WM.db.quick = v end,
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

    local y = -70
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
        y = y - 28
    end

    local slider = CreateFrame("Slider", "WrathMentorScaleSlider", p, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", p, "TOPLEFT", 24, y - 30)
    slider:SetWidth(240)
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
    wslider:SetPoint("TOPLEFT", p, "TOPLEFT", 24, y - 70)
    wslider:SetWidth(240)
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

    local test = CreateFrame("Button", "WrathMentorTestButton", p, "UIPanelButtonTemplate")
    test:SetWidth(130)
    test:SetHeight(22)
    test:SetPoint("TOPLEFT", p, "TOPLEFT", 16, y - 120)
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
    InterfaceOptions_AddCategory(ui.options)
    self:UpdateMinimapButton()
    self:RefreshOptions()
end
