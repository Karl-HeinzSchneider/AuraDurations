# \# AuraDurations

Simple addon to bring back buff/debuff swipe timers for the **default** TargetFrame and CompactRaidFrame on Era.

## Features

(Era only)

Adds the cooldown swipe texture to buffs and debuffs on the TargetFrame and CompactRaidFrame; similar to _ClassicAuraDurations_ (which seems abandoned). 

Also adds simple configuration for:
  - Show All Enemy Debuffs | If false, filters out non player debuffs on the target
  - Aura Size
  - Dynamic Buff Size | Highlights player buffs/debuffs on the target by increasing their aura size
  - Aura Size Small | AuraSize of non player buffs/debuffs when using 'Dynamic Buff Size'

Uses the default API and is based on blizzard code from TBC onwards; also uses [LibClassicDurations](https://github.com/rgd87/LibClassicDurations) to improve results.

## Screenshots
![](Screenshots/AuraDurations.png)

![](Screenshots/AuraDurations_dynamic.png)

![](Screenshots/AuraDurations_Options.png)


## For addon developers

Source code released under MIT licence.

Can be embeded (as the initial purpose was adding this functionality to [DragonflightUI classic](https://www.curseforge.com/wow/addons/dragonflight-ui-classic)).

To embed:
  - Include `AuraDurations_embed.xml`
  - Load the lib with `local auraDurations = LibStub:GetLibrary('AuraDurations-1.0')`
  - Update the state with `auraDurations.frame:SetState(...)` which automatically adds the functionality on the first call
  - Currently used options:
    ```  
    local defaults = {
      auraSizeSmall = 17, -- SMALL_AURA_SIZE,
      auraSizeLarge = 21, -- LARGE_AURA_SIZE,
      auraOffsetY = 1, -- AURA_OFFSET_Y,
      noDebuffFilter = true, -- noBuffDebuffFilterOnTarget
      dynamicBuffSize = true, -- showDynamicBuffSize
      auraRowWidth = 122, -- AURA_ROW_WIDTH
      totAuraRowWidth = 101, -- TOT_AURA_ROW_WIDTH
      numTotAuraRows = 2 -- NUM_TOT_AURA_ROWS
    }    
    ```
    Defaults accessible through `auraDurations.Defaults`; set defaults with `auraDurations.frame:SetDefaults()`.
