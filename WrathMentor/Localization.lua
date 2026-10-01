-- Wrath Mentor - Localization Manager (WoW 3.3.5a)
WrathMentor = WrathMentor or {}
local WM = WrathMentor

local L = setmetatable({}, {
    __index = function(t, k)
        return k
    end
})
WM.L = L

-- Регистрация строковых переводов (UI, зоны, имена)
function WM:RegisterLocale(locale, tbl)
    if GetLocale() ~= locale then return end
    for k, v in pairs(tbl) do
        L[k] = v
    end
end

-- Наложение локализованных тактик на базу рейда
function WM:RegisterTactics(locale, raidId, bossList)
    if GetLocale() ~= locale then return end
    local raid = self.raids and self.raids[raidId]
    if not raid then return end

    for _, bTrans in ipairs(bossList) do
        local boss = nil
        for _, b in ipairs(raid.bosses) do
            if b.name == bTrans.name then
                boss = b
                break
            end
        end

        if boss then
            if bTrans.tldr then boss.tldr = bTrans.tldr end
            if bTrans.start then boss.start = bTrans.start end
            if bTrans.general then boss.general = bTrans.general end
            if bTrans.tank then boss.tank = bTrans.tank end
            if bTrans.heal then boss.heal = bTrans.heal end
            if bTrans.dps then boss.dps = bTrans.dps end
            if bTrans.hard then boss.hard = bTrans.hard end

            if bTrans.abilities and boss.abilities then
                for i, abTrans in ipairs(bTrans.abilities) do
                    local targetAb = nil
                    if abTrans.name then
                        for _, ab in ipairs(boss.abilities) do
                            if ab.name == abTrans.name then
                                targetAb = ab
                                break
                            end
                        end
                    end
                    if not targetAb and boss.abilities[i] then
                        targetAb = boss.abilities[i]
                    end
                    if targetAb and abTrans.desc then
                        targetAb.desc = abTrans.desc
                    end
                end
            end
        end
    end
end

-- Базовый системный словарь меток (английский / системный)
WrathMentor.RAID_TARGET_MAP = WrathMentor.RAID_TARGET_MAP or {
    rt1 = 1, star = 1,
    rt2 = 2, circle = 2, coin = 2,
    rt3 = 3, diamond = 3,
    rt4 = 4, triangle = 4,
    rt5 = 5, moon = 5,
    rt6 = 6, square = 6,
    rt7 = 7, cross = 7, x = 7,
    rt8 = 8, skull = 8,
}