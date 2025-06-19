local isClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC;
if not isClassic then return; end

local lib = LibStub:NewLibrary("AuraDurations-1.0", 1);

if not lib then
    return -- already loaded and no upgrade necessary
end

--
local MAX_TARGET_BUFFS = MAX_TARGET_BUFFS or 32;
local MAX_TARGET_DEBUFFS = MAX_TARGET_DEBUFFS or 16;

local UnitAura = UnitAura
local LibClassicDurations;

local defaults = {
    auraSizeSmall = 17, -- SMALL_AURA_SIZE,
    auraSizeLarge = 21, -- LARGE_AURA_SIZE,
    auraOffsetY = 1, -- AURA_OFFSET_Y,
    noDebuffFilter = true, -- noBuffDebuffFilterOnTarget
    dynamicBuffSize = true
}

---@class frame
local frame = CreateFrame("Frame");
lib.frame = frame;

function frame:SetDefaults()
    for k, v in pairs(defaults) do AuraDurationsDB[k] = v; end

    self:Update()
end

function frame:SetState(state)
    for k, v in pairs(state) do AuraDurationsDB[k] = v; end

    self:Update()
end

function frame:Update()
    TargetFrame_UpdateAuras(TargetFrame)
end

frame:SetScript("OnEvent", function(self, event, ...)
    return self[event](self, event, ...);
end)

frame:RegisterEvent("PLAYER_LOGIN")
function frame:PLAYER_LOGIN(event, ...)
    -- print(event, ...)

    if type(AuraDurationsDB) ~= 'table' or true then
        print('AuraDurations: new DB!')
        AuraDurationsDB = {}
        self.AuraDurationsDB = AuraDurationsDB;
        lib.AuraDurationsDB = AuraDurationsDB;
        frame:SetDefaults()
    end

    LibClassicDurations = LibStub("LibClassicDurations", true)
    if LibClassicDurations then
        LibClassicDurations:Register("AuraDurations")
        UnitAura = LibClassicDurations.UnitAuraWrapper

        hooksecurefunc("TargetFrame_UpdateAuras", frame.TargetBuffHook)
        hooksecurefunc("CompactUnitFrame_UtilSetBuff", frame.CompactUnitFrameBuffHook)
        hooksecurefunc("CompactUnitFrame_UtilSetDebuff", frame.CompactUnitFrameDeBuffHook)
    end
end

frame.TargetBuffHook = function(self)
    -- print('TargetBuffHook')
    local frameName, frameCooldown;
    local selfName = self:GetName();
    ---@diagnostic disable-next-line: undefined-field
    local unit = self.unit;

    for i = 1, MAX_TARGET_BUFFS do
        local buffName, icon, count, debuffType, duration, expirationTime, caster, canStealOrPurge, _, spellId, _, _,
              casterIsPlayer, nameplateShowAll = UnitBuff(unit, i, nil);

        if (buffName) then
            frameName = selfName .. "Buff" .. (i);

            -- blizzard default
            -- -- Handle cooldowns
            -- frameCooldown = _G[frameName .. "Cooldown"];
            -- CooldownFrame_Set(frameCooldown, expirationTime - duration, duration, duration > 0, true);

            -- using Lib
            -- Handle cooldowns
            frameCooldown = _G[frameName .. "Cooldown"];
            local durationLib, expirationTimeLib = LibClassicDurations:GetAuraDurationByUnit(unit, spellId, caster);
            if duration == 0 and durationLib then
                duration = durationLib;
                expirationTime = expirationTimeLib;
            end
            CooldownFrame_Set(frameCooldown, expirationTime - duration, duration, duration > 0, true);
        else
            break
        end
    end

    local frameNum = 1;
    local index = 1;

    ---@diagnostic disable-next-line: undefined-field
    local maxDebuffs = self.maxDebuffs or MAX_TARGET_DEBUFFS;
    while (frameNum <= maxDebuffs and index <= maxDebuffs) do
        local debuffName, icon, count, debuffType, duration, expirationTime, caster, _, _, spellId, _, _,
              casterIsPlayer, nameplateShowAll = UnitDebuff(unit, index, "INCLUDE_NAME_PLATE_ONLY");
        if (debuffName) then
            if (TargetFrame_ShouldShowDebuffs(unit, caster, nameplateShowAll, casterIsPlayer)) then
                frameName = selfName .. "Debuff" .. frameNum;
                frame = _G[frameName];
                if (icon) then
                    -- -- blizzard default
                    -- -- Handle cooldowns
                    -- frameCooldown = _G[frameName .. "Cooldown"];
                    -- CooldownFrame_Set(frameCooldown, expirationTime - duration, duration, duration > 0, true);

                    -- using Lib
                    -- Handle cooldowns
                    frameCooldown = _G[frameName .. "Cooldown"];
                    local durationLib, expirationTimeLib = LibClassicDurations:GetAuraDurationByUnit(unit, spellId,
                                                                                                     caster);
                    if duration == 0 and durationLib then
                        duration = durationLib;
                        expirationTime = expirationTimeLib;
                    end
                    CooldownFrame_Set(frameCooldown, expirationTime - duration, duration, duration > 0, true);

                    frameNum = frameNum + 1;
                end
            end
        else
            break
        end
        index = index + 1;
    end
end

-- based on blizz: function CompactUnitFrame_UtilSetBuff(buffFrame, unit, index, filter)
frame.CompactUnitFrameBuffHook = function(buffFrame, unit, index, filter)
    local name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura =
        UnitBuff(unit, index, filter);

    local durationLib, expirationTimeLib = LibClassicDurations:GetAuraDurationByUnit(unit, spellId, unitCaster);
    if duration == 0 and durationLib then
        duration = durationLib;
        expirationTime = expirationTimeLib;
    end

    -- CompactUnitFrame_UpdateCooldownFrame(buffFrame, expirationTime - duration, duration, true); -- blizz default

    -- from function CompactUnitFrame_UpdateCooldownFrame(frame, expirationTime, duration, buff)
    local enabled = expirationTime and expirationTime ~= 0;
    if enabled then
        local startTime = expirationTime - duration;
        CooldownFrame_Set(buffFrame.cooldown, startTime, duration, true);
    else
        CooldownFrame_Clear(buffFrame.cooldown);
    end
end

-- based on blizz: function CompactUnitFrame_UtilSetDebuff(debuffFrame, unit, index, filter, isBossAura, isBossBuff)
frame.CompactUnitFrameDeBuffHook = function(debuffFrame, unit, index, filter, isBossAura, isBossBuff)
    local name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId;
    if (isBossBuff) then
        name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId = UnitBuff(
                                                                                                               unit,
                                                                                                               index,
                                                                                                               filter);
    else
        name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId = UnitDebuff(
                                                                                                               unit,
                                                                                                               index,
                                                                                                               filter);
    end

    local durationLib, expirationTimeLib = LibClassicDurations:GetAuraDurationByUnit(unit, spellId, unitCaster);
    if duration == 0 and durationLib then
        duration = durationLib;
        expirationTime = expirationTimeLib;
    end

    -- CompactUnitFrame_UpdateCooldownFrame(debuffFrame, expirationTime, duration, false);

    -- from function CompactUnitFrame_UpdateCooldownFrame(frame, expirationTime, duration, buff)
    local enabled = expirationTime and expirationTime ~= 0;
    if enabled then
        local startTime = expirationTime - duration;
        CooldownFrame_Set(debuffFrame.cooldown, startTime, duration, true);
    else
        CooldownFrame_Clear(debuffFrame.cooldown);
    end
end

