-- Dont include this file when embeding in other addons
local addonName, addonTable = ...
if addonName ~= 'AuraDurations' then return; end

local lib = LibStub:GetLibrary('AuraDurations-1.0')

if not lib or lib.optionsSet then return; end
lib.optionsSet = true;

-- print('hook options!')
local frame = lib.frame;

local SettingsDefaultStringFormat = "\n\n(Default: |cff8080ff%s|r)"

local function SetupOptions()
    -- print('options!')

    local AuraDurationsDB = AuraDurationsDB;

    local function OnSettingChanged(setting, value)
        -- print("Setting changed:", setting:GetVariable(), value)
        -- DevTools_Dump({AuraDurationsDB})
        frame:Update()
    end

    local category = Settings.RegisterVerticalLayoutCategory("AuraDurations")
    lib.addonCategory = category

    do
        local name = "Show All Enemy Debuffs"
        local variable = "Show All Enemy Debuffs"
        local variableKey = "noDebuffFilter"
        local variableTbl = AuraDurationsDB
        local defaultValue = lib.Defaults.noDebuffFilter

        local setting = Settings.RegisterAddOnSetting(category, variable, variableKey, variableTbl, type(defaultValue),
                                                      name, defaultValue)
        setting:SetValueChangedCallback(OnSettingChanged)

        local tooltip = "Displays friendly and enemy debuffs on the TargetFrame, and not just your own."
        tooltip = tooltip .. string.format(SettingsDefaultStringFormat, tostring(defaultValue))
        Settings.CreateCheckbox(category, setting, tooltip)
    end

    do
        -- RegisterProxySetting example. This will run the GetValue and SetValue
        -- callbacks whenever access to the setting is required.

        local name = "Aura Size"
        local variable = "Aura Size"
        local defaultValue = lib.Defaults.auraSizeLarge
        local minValue = 8
        local maxValue = 64
        local step = 1

        local function GetValue()
            return AuraDurationsDB.auraSizeLarge or defaultValue
        end

        local function SetValue(value)
            AuraDurationsDB.auraSizeLarge = value
        end

        local setting = Settings.RegisterProxySetting(category, variable, type(defaultValue), name, defaultValue,
                                                      GetValue, SetValue)
        setting:SetValueChangedCallback(OnSettingChanged)

        local tooltip = "Sets the size of an aura on the TargetFrame."
        tooltip = tooltip .. string.format(SettingsDefaultStringFormat, tostring(defaultValue))
        local options = Settings.CreateSliderOptions(minValue, maxValue, step)
        options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);
        Settings.CreateSlider(category, setting, options, tooltip)
    end

    do
        local name = "Dynamic Buff Size"
        local variable = "Dynamic Buff Size"
        local variableKey = "dynamicBuffSize"
        local variableTbl = AuraDurationsDB
        local defaultValue = lib.Defaults.dynamicBuffSize

        local setting = Settings.RegisterAddOnSetting(category, variable, variableKey, variableTbl, type(defaultValue),
                                                      name, defaultValue)
        setting:SetValueChangedCallback(OnSettingChanged)

        local tooltip = "Increases the size of the player buffs and debuffs on the target."
        tooltip = tooltip .. string.format(SettingsDefaultStringFormat, tostring(defaultValue))
        Settings.CreateCheckbox(category, setting, tooltip)
    end

    do
        -- RegisterProxySetting example. This will run the GetValue and SetValue
        -- callbacks whenever access to the setting is required.

        local name = "Aura Size Small"
        local variable = "Aura Size Small"
        local defaultValue = lib.Defaults.auraSizeSmall
        local minValue = 8
        local maxValue = 64
        local step = 1

        local function GetValue()
            return AuraDurationsDB.auraSizeSmall or defaultValue
        end

        local function SetValue(value)
            AuraDurationsDB.auraSizeSmall = value
        end

        local setting = Settings.RegisterProxySetting(category, variable, type(defaultValue), name, defaultValue,
                                                      GetValue, SetValue)
        setting:SetValueChangedCallback(OnSettingChanged)

        local tooltip = "Sets the size of non player auras on the TargetFrame when using 'Dynamic Buff Size'."
        tooltip = tooltip .. string.format(SettingsDefaultStringFormat, tostring(defaultValue))
        local options = Settings.CreateSliderOptions(minValue, maxValue, step)
        options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);
        Settings.CreateSlider(category, setting, options, tooltip)
    end

    Settings.RegisterAddOnCategory(category)

end
hooksecurefunc(frame, 'PLAYER_LOGIN', SetupOptions)

