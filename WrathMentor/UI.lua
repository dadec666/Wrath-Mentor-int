-- Wrath Mentor - UI (v2)
local WM = WrathMentor

local ROW_H = 18
local LIST_W = 196
local DETAIL_W = 440

local ui = { rows = {}, roleButtons = {}, sizeButtons = {}, fsPool = {}, abPool = {}, optChecks = {} }
WM.ui = ui

local ROLES = {
    { "ALL", "All", 48 },
    { "TANK", "Tank", 52 },
    { "HEAL", "Healer", 60 },
    { "DPS", "DPS", 48 },
}

local BACKDROP_DIALOG = {
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 },
}

local BACKDROP_TOOLTIP = {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
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
    btn.text:SetWidth(LIST_W - 22)
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
            btn.text:SetPoint("LEFT", btn, "LEFT", 16, 0)
            btn.text:SetText(data.boss.name)
            if self.db.notes[self:BossKey(data.boss)] then
                btn.text:SetTextColor(0.55, 0.85, 1)   -- bosses with personal notes are tinted blue
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
-- Detail pane (block layout: text blocks + clickable ability rows)
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
        GameTooltip:AddLine(ab.name, 1, 1, 1)
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
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)  -- trim the default icon border
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

local function Bullets(lines, headColor)
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

function WM:RefreshDetail()
    if not ui.main then return end
    for key, b in pairs(ui.roleButtons) do
        if key == self.db.role then b:Disable() else b:Enable() end
    end
    for key, b in pairs(ui.sizeButtons) do
        if key == self:GetSize() then b:Disable() else b:Enable() end
    end
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

    local function section(title, color, lines)
        if not lines or #lines == 0 then return end
        text(color .. title .. "|r", GameFontNormal, 2)
        text(Bullets(lines), GameFontHighlight, 10)
    end

    if boss then
        local raid = self.raids[boss.raidId]
        local role = self.db.role
        local roleName = ({ ALL = "All roles", TANK = "Tank", HEAL = "Healer", DPS = "DPS" })[role]
        text(C.title .. boss.name .. "|r  " .. C.grey .. "(" .. (raid and raid.name or "?") .. " - " .. self:GetSize() .. "-man - " .. roleName .. ")|r", GameFontNormalLarge, 8)

        if boss.tldr then
            text(C.tldr .. "TL;DR|r  " .. (self:Expand(boss.tldr) or boss.tldr), GameFontHighlight, 10)
        end
        section("How to start the fight", C.start, self:ExpandList(boss.start))
        section("Strategy", C.strat, self:ExpandList(boss.general))
        if role == "ALL" or role == "TANK" then section("Tanks", C.tank, self:ExpandList(boss.tank)) end
        if role == "ALL" or role == "HEAL" then section("Healers", C.heal, self:ExpandList(boss.heal)) end
        if role == "ALL" or role == "DPS" then section("DPS", C.dps, self:ExpandList(boss.dps)) end

        if boss.abilities and #boss.abilities > 0 then
            text(C.abil .. "Boss abilities|r  " .. C.grey .. "(hover for the game tooltip, click to open it, shift-click to link in chat)|r", GameFontNormal, 4)
            for _, ab in ipairs(boss.abilities) do
                usedAb = usedAb + 1
                local row = GetAbRow(usedAb)
                row.btn.ab = ab
                row.btn:ClearAllPoints()
                row.btn:SetPoint("TOPLEFT", ui.detailChild, "TOPLEFT", 4, -y)
                row.btn:SetWidth(dw - 8)
                row.icon:SetTexture(WM:GetSpellIcon(ab))
                if WM:ResolveSpell(ab) then
                    row.btn.text:SetText("|cff71d5ff[" .. ab.name .. "]|r")
                else
                    row.btn.text:SetText(C.white .. ab.name .. "|r")
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

        section("Hard mode / Heroic - full explanation", C.hard, self:ExpandList(boss.hard))

    else
        text("", GameFontHighlight, 0)
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
-- Copy view: the whole boss text as plain, selectable text.
-- (Normal on-screen text cannot be selected in WoW; an edit box can.)
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
        ui.copyButton:SetText("Back")
    else
        ui.copyEdit:ClearFocus()
        ui.copyFrame:Hide()
        ui.detailScroll:Show()
        ui.copyButton:SetText("Copy")
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
-- Personal notes (side box)
------------------------------------------------------------------
function WM:RefreshNotesButton()
    if not ui.notesButton then return end
    local has = self.selected and self.db.notes[self:BossKey(self.selected)]
    ui.notesButton:SetText(has and "Notes*" or "Notes")
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
    ui.notesTitle:SetText("Notes - " .. (boss and boss.name or ""))
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
    SetNotesStatus("|cff4cff4cSaved|r")
    self:RefreshNotesButton()
    if not silent then self:Print("Notes saved for " .. self.notesBoss.name .. ".") end
end

local function CreateNotes()
    local n = CreateFrame("Frame", "WrathMentorNotes", ui.main)
    ui.notes = n
    n:SetWidth(270)
    n:SetHeight(360)
    n:SetPoint("TOPLEFT", ui.main, "TOPRIGHT", -6, -30)
    n:SetBackdrop(BACKDROP_DIALOG)
    n:SetClampedToScreen(true)
    n:Hide()

    ui.notesTitle = n:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    ui.notesTitle:SetPoint("TOPLEFT", n, "TOPLEFT", 20, -20)
    ui.notesTitle:SetWidth(220)
    ui.notesTitle:SetJustifyH("LEFT")

    local scroll = CreateFrame("ScrollFrame", "WrathMentorNotesScroll", n, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", n, "TOPLEFT", 20, -46)
    scroll:SetWidth(210)
    scroll:SetHeight(240)
    EnableWheel(scroll)

    local edit = CreateFrame("EditBox", "WrathMentorNotesEdit", scroll)
    ui.notesEdit = edit
    edit:SetMultiLine(true)
    edit:SetAutoFocus(false)
    edit:SetFontObject(ChatFontNormal)
    edit:SetWidth(206)
    edit:SetHeight(240)
    edit:SetMaxLetters(4000)
    scroll:SetScrollChild(edit)
    edit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    edit:SetScript("OnTextChanged", function(self, userInput)
        if userInput then
            ui.notesDirty = true
            SetNotesStatus("|cffffd100Unsaved changes|r")
        end
        local text = self:GetText() or ""
        local lines = 0
        for line in string.gmatch(text .. "\n", "(.-)\n") do
            lines = lines + math.max(1, math.ceil(string.len(line) / 30))
        end
        self:SetHeight(math.max(240, lines * 14 + 20))
    end)

    ui.notesStatus = n:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    ui.notesStatus:SetPoint("BOTTOMLEFT", n, "BOTTOMLEFT", 22, 52)

    local save = CreateFrame("Button", "WrathMentorNotesSave", n, "UIPanelButtonTemplate")
    save:SetWidth(90)
    save:SetHeight(22)
    save:SetPoint("BOTTOMLEFT", n, "BOTTOMLEFT", 20, 22)
    save:SetText("Save")
    save:SetScript("OnClick", function()
        edit:ClearFocus()
        WM:SaveNotes(false)
    end)

    local close = CreateFrame("Button", "WrathMentorNotesClose", n, "UIPanelButtonTemplate")
    close:SetWidth(90)
    close:SetHeight(22)
    close:SetPoint("LEFT", save, "RIGHT", 6, 0)
    close:SetText("Close")
    close:SetScript("OnClick", function() WM:ToggleNotes() end)
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
-- Options synchronisation
------------------------------------------------------------------
local function ScaleLabel(value)
    return "Popup size: " .. math.floor((value or 1) * 100 + 0.5) .. "%"
end

local function WindowScaleLabel(value)
    return "Tactics window size: " .. math.floor((value or 1) * 100 + 0.5) .. "%"
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
    f:SetBackdrop(BACKDROP_DIALOG)
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
    -- Resizable via the bottom-right corner grip
    if f.SetResizable then f:SetResizable(true) end
    if f.SetMinResize then f:SetMinResize(640, 420) end
    if f.SetMaxResize then f:SetMaxResize(1400, 900) end
    f:Hide()
    tinsert(UISpecialFrames, "WrathMentorFrame")

    local title = f:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOP", f, "TOP", 0, -18)
    title:SetText("Wrath Mentor - WotLK Raid Tactics")

    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -6, -6)

    -- Left: raid / boss list (fixed width, stretches taller/shorter with the window)
    local listScroll = CreateFrame("ScrollFrame", "WrathMentorListScroll", f, "UIPanelScrollFrameTemplate")
    listScroll:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -50)
    listScroll:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 20, 58)
    listScroll:SetWidth(LIST_W)
    local listChild = CreateFrame("Frame", nil, listScroll)
    listChild:SetWidth(LIST_W)
    listChild:SetHeight(10)
    listScroll:SetScrollChild(listChild)
    EnableWheel(listScroll)
    ui.listScroll = listScroll
    ui.listChild = listChild

    -- Right: role buttons, size buttons, notes button (one row)
    local prev
    for i, r in ipairs(ROLES) do
        local b = CreateFrame("Button", "WrathMentorRole" .. r[1], f, "UIPanelButtonTemplate")
        b:SetWidth(r[3])
        b:SetHeight(22)
        b:SetText(r[2])
        if i == 1 then
            b:SetPoint("TOPLEFT", f, "TOPLEFT", 268, -50)
        else
            b:SetPoint("LEFT", prev, "RIGHT", 2, 0)
        end
        local roleKey = r[1]
        b:SetScript("OnClick", function() WM:SetRole(roleKey) end)
        ui.roleButtons[roleKey] = b
        prev = b
    end
    for _, size in ipairs({ 10, 25 }) do
        local b = CreateFrame("Button", "WrathMentorSize" .. size, f, "UIPanelButtonTemplate")
        b:SetWidth(34)
        b:SetHeight(22)
        b:SetText(tostring(size))
        b:SetPoint("LEFT", prev, "RIGHT", (size == 10) and 12 or 2, 0)
        local s = size
        b:SetScript("OnClick", function() WM:SetSize(s) end)
        b:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:AddLine(s .. "-man version of the tactics")
            GameTooltip:Show()
        end)
        b:SetScript("OnLeave", function() GameTooltip:Hide() end)
        ui.sizeButtons[size] = b
        prev = b
    end
    local nb = CreateFrame("Button", "WrathMentorNotesButton", f, "UIPanelButtonTemplate")
    nb:SetWidth(64)
    nb:SetHeight(22)
    nb:SetPoint("LEFT", prev, "RIGHT", 12, 0)
    nb:SetText("Notes")
    nb:SetScript("OnClick", function() WM:ToggleNotes() end)
    nb:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine("Personal notes for this boss")
        GameTooltip:AddLine("Opens a side box. Press Save to keep them.", 1, 1, 1)
        GameTooltip:Show()
    end)
    nb:SetScript("OnLeave", function() GameTooltip:Hide() end)
    ui.notesButton = nb

    local cb = CreateFrame("Button", "WrathMentorCopyButton", f, "UIPanelButtonTemplate")
    cb:SetWidth(52)
    cb:SetHeight(22)
    cb:SetPoint("LEFT", nb, "RIGHT", 4, 0)
    cb:SetText("Copy")
    cb:SetScript("OnClick", function() WM:ToggleCopy() end)
    cb:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine("Copy text")
        GameTooltip:AddLine("Shows this boss as selectable text: drag to select part, or Select all, then Ctrl+C.", 1, 1, 1, 1)
        GameTooltip:Show()
    end)
    cb:SetScript("OnLeave", function() GameTooltip:Hide() end)
    ui.copyButton = cb

    -- Right: detail (stretches both ways as the window is resized)
    local detailScroll = CreateFrame("ScrollFrame", "WrathMentorDetailScroll", f, "UIPanelScrollFrameTemplate")
    detailScroll:SetPoint("TOPLEFT", f, "TOPLEFT", 268, -82)
    detailScroll:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -20, 58)
    local detailChild = CreateFrame("Frame", nil, detailScroll)
    detailChild:SetWidth(DETAIL_W)
    detailChild:SetHeight(10)
    detailScroll:SetScrollChild(detailChild)
    EnableWheel(detailScroll)
    ui.detailScroll = detailScroll
    ui.detailChild = detailChild

    -- Copy view (hidden until the Copy button is pressed; stretches with the window too)
    local cf = CreateFrame("Frame", "WrathMentorCopyFrame", f)
    cf:SetPoint("TOPLEFT", f, "TOPLEFT", 268, -82)
    cf:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -20, 58)
    cf:Hide()
    ui.copyFrame = cf

    local selAll = CreateFrame("Button", "WrathMentorCopySelectAll", cf, "UIPanelButtonTemplate")
    selAll:SetWidth(90)
    selAll:SetHeight(20)
    selAll:SetPoint("TOPLEFT", cf, "TOPLEFT", 0, 0)
    selAll:SetText("Select all")
    selAll:SetScript("OnClick", function()
        ui.copyEdit:SetFocus()
        ui.copyEdit:HighlightText()
    end)

    local hint = cf:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    hint:SetPoint("LEFT", selAll, "RIGHT", 8, 0)
    hint:SetText("Drag with the mouse to select part of the text, then press Ctrl+C.")

    local copyScroll = CreateFrame("ScrollFrame", "WrathMentorCopyScroll", cf, "UIPanelScrollFrameTemplate")
    copyScroll:SetPoint("TOPLEFT", cf, "TOPLEFT", 0, -26)
    copyScroll:SetPoint("BOTTOMRIGHT", cf, "BOTTOMRIGHT", 0, 0)
    EnableWheel(copyScroll)
    ui.copyScroll = copyScroll

    local copyEdit = CreateFrame("EditBox", "WrathMentorCopyEdit", copyScroll)
    copyEdit:SetMultiLine(true)
    copyEdit:SetAutoFocus(false)
    copyEdit:SetFontObject(ChatFontNormal)
    copyEdit:SetWidth(DETAIL_W - 6)
    copyEdit:SetHeight(324)
    copyEdit:SetMaxLetters(60000)
    copyScroll:SetScrollChild(copyEdit)
    -- Read-only: any typing or pasting is undone immediately, selecting and copying still work
    copyEdit:SetScript("OnTextChanged", function(self, userInput)
        if userInput and ui.copyText then self:SetText(ui.copyText) end
    end)
    copyEdit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    ui.copyEdit = copyEdit

    -- Hidden text used only to measure how tall the copy text is
    local measure = cf:CreateFontString(nil, "ARTWORK", "ChatFontNormal")
    measure:SetWidth(DETAIL_W - 6)
    measure:SetJustifyH("LEFT")
    measure:Hide()
    ui.copyMeasure = measure

    -- Bottom: send + option + settings
    local send = CreateFrame("Button", "WrathMentorSendButton", f, "UIPanelButtonTemplate")
    send:SetWidth(120)
    send:SetHeight(22)
    send:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 268, 20)
    send:SetText("Send to chat")
    send:SetScript("OnClick", function() WM:Send(WM.selected) end)

    local check = CreateFrame("CheckButton", "WrathMentorQuickCheck", f, "UICheckButtonTemplate")
    check:SetPoint("LEFT", send, "RIGHT", 14, 0)
    local checkText = getglobal("WrathMentorQuickCheckText")
    if checkText then checkText:SetText("Popup when I target a boss") end
    check:SetScript("OnClick", function(self)
        WM.db.quick = self:GetChecked() and true or false
        WM:ApplySettings()
    end)
    ui.quickCheck = check

    local settings = CreateFrame("Button", "WrathMentorSettingsButton", f, "UIPanelButtonTemplate")
    settings:SetWidth(90)
    settings:SetHeight(22)
    settings:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -24, 20)
    settings:SetText("Settings")
    settings:SetScript("OnClick", function() WM:OpenOptions() end)

    -- Drag-to-resize grip in the bottom-right corner
    local grip = CreateFrame("Button", "WrathMentorResizeGrip", f)
    grip:SetWidth(16)
    grip:SetHeight(16)
    grip:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -4, 4)
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
        GameTooltip:AddLine("Drag to resize the window")
        GameTooltip:Show()
    end)
    grip:SetScript("OnLeave", function() GameTooltip:Hide() end)
    ui.resizeGrip = grip

    -- Re-wrap text when the window is resized (by the grip, or SetWidth/SetHeight from saved state)
    f:SetScript("OnSizeChanged", function(self, w, h)
        WM:LayoutMain()
    end)
end

-- Re-applies the current window width to the detail/copy panes and re-wraps their text.
-- Called after a resize (grip drag) and whenever the window is (re)created.
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
-- Quick popup (shown when you target a boss inside an instance)
------------------------------------------------------------------
local function CreateQuick()
    local q = CreateFrame("Frame", "WrathMentorQuick", UIParent)
    ui.quick = q
    q:SetWidth(340)
    q:SetHeight(120)
    q:SetFrameStrata("HIGH")
    q:SetMovable(true)
    q:EnableMouse(true)
    q:SetClampedToScreen(true)
    q:SetBackdrop(BACKDROP_TOOLTIP)
    q:SetBackdropColor(0, 0, 0, 0.88)
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
    q.title:SetPoint("TOPLEFT", q, "TOPLEFT", 12, -12)
    q.title:SetWidth(290)
    q.title:SetJustifyH("LEFT")

    q.body = q:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    q.body:SetPoint("TOPLEFT", q, "TOPLEFT", 12, -32)
    q.body:SetWidth(316)
    q.body:SetJustifyH("LEFT")
    q.body:SetJustifyV("TOP")

    local close = CreateFrame("Button", nil, q, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", q, "TOPRIGHT", 2, 2)

    local full = CreateFrame("Button", nil, q, "UIPanelButtonTemplate")
    full:SetWidth(90)
    full:SetHeight(20)
    full:SetPoint("BOTTOMRIGHT", q, "BOTTOMRIGHT", -10, 10)
    full:SetText("Full guide")
    full:SetScript("OnClick", function()
        if q.boss then WM:ShowMain(q.boss) end
    end)

    local send = CreateFrame("Button", nil, q, "UIPanelButtonTemplate")
    send:SetWidth(90)
    send:SetHeight(20)
    send:SetPoint("RIGHT", full, "LEFT", -4, 0)
    send:SetText("Send")
    send:SetScript("OnClick", function()
        if q.boss then WM:Send(q.boss) end
    end)
end

function WM:ShowQuick(boss)
    if not ui.quick then CreateQuick() end
    local q = ui.quick
    q.boss = boss
    self.quickBoss = boss
    q.title:SetText(boss.name .. "  |cff9d9d9d(" .. self:GetSize() .. "-man)|r")
    q.body:SetText(self:GetQuickText(boss))
    q:SetHeight(q.body:GetStringHeight() + 70)
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

-- Once-per-fight rule: inside a fight the popup appears at most once per boss.
-- If you close it, retargeting an add and then the boss again will NOT bring it back.
WM.combatShown = {}

function WM:InCombat()
    return self.inCombat or (UnitAffectingCombat("player") and true or false)
end

function WM:OnEnterCombat()
    self.inCombat = true
    self.combatShown = {}
    -- A popup that was already up when the fight started counts as shown for this fight
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
            if self.combatShown[key] then return end   -- already shown (or closed) this fight
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
-- Minimap button (hand-made, no libraries needed)
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
        GameTooltip:AddLine("Left-click: open the tactics window", 1, 1, 1)
        GameTooltip:AddLine("Right-click: settings", 1, 1, 1)
        GameTooltip:AddLine("Drag: move this button", 0.7, 0.7, 0.7)
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
-- Settings panel (Interface Options > AddOns > Wrath Mentor)
------------------------------------------------------------------
local CHECK_OPTIONS = {
    {
        label = "Show the minimap button",
        get = function() return not WM.db.minimap.hide end,
        set = function(v) WM.db.minimap.hide = not v end,
    },
    {
        label = "Show a popup when I target a boss",
        get = function() return WM.db.quick end,
        set = function(v) WM.db.quick = v end,
    },
    {
        label = "Only show the popup inside raid instances",
        get = function() return WM.db.quickRaidOnly end,
        set = function(v) WM.db.quickRaidOnly = v end,
    },
    {
        label = "Hide the popup when combat ends",
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
    sub:SetText("WotLK raid tactics. Changes apply immediately. Type /wm help for commands.")

    local y = -70
    for i, opt in ipairs(CHECK_OPTIONS) do
        local cb = CreateFrame("CheckButton", "WrathMentorOpt" .. i, p, "UICheckButtonTemplate")
        cb:SetPoint("TOPLEFT", p, "TOPLEFT", 14, y)
        getglobal("WrathMentorOpt" .. i .. "Text"):SetText(opt.label)
        cb.getter = opt.get
        cb:SetScript("OnClick", function(self)
            if ui.refreshing then return end
            opt.set(self:GetChecked() and true or false)
            WM:ApplySettings()
        end)
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
    test:SetText("Test popup")
    test:SetScript("OnClick", function()
        local boss = WM.selected or WM.raids[WM.raidOrder[1]].bosses[1]
        WM:ShowQuick(boss)
    end)

    local reset = CreateFrame("Button", "WrathMentorResetButton", p, "UIPanelButtonTemplate")
    reset:SetWidth(150)
    reset:SetHeight(22)
    reset:SetPoint("LEFT", test, "RIGHT", 8, 0)
    reset:SetText("Reset position/size")
    reset:SetScript("OnClick", function() WM:HandleSlash("reset") end)

    p.refresh = function() WM:RefreshOptions() end
    p.default = function() WM:ResetOptions() end
    p.okay = function() end
    p.cancel = function() end
    p:SetScript("OnShow", function() WM:RefreshOptions() end)
end

function WM:OpenOptions()
    if not ui.options then return end
    -- Called twice on purpose: the 3.3.5 client sometimes opens the wrong page on the first call
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

-- Applying the saved window scale is deferred to ShowMain (below), since the
-- window itself is only created the first time it is shown.
