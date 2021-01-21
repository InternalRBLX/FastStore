# @rbxts/faststore

## Installation:
```npm i @rbxts/faststore```

## Example Usage:
```typescript
// SERVER ONLY | I wILL MAKE A CLIENT MODULE SOON \\
import { setSetting, Get, run } from '@rbxts/faststore'
import { Players, RunService } from '@rbxts/services'

const AllData = {
    Inventory: {},
    Cash: 0,
    Level: 1
};
const LeaderStats = {
    Cash: 0,
    Level: 1
}

setSetting('defaultSave', AllData)
setSetting('leaderStats', LeaderStats)
setSetting('saveKey', 'TESTING_001')

// Runs Data (only use once)
run()

// Getting Player Data (you only need to add the if statement if your in studio)
// Player Argument
Players.PlayerAdded.Connect(function(plr: Player) {
    let Data = Get(plr)
    if (Data === undefined && !RunService.IsStudio) { // (IN STUDIO IT MIGHT NOT LOAD DATA)
        plr.Kick('Data Did Not Load')
    }

    print(Data)
})
```

## Settings:
The possible settings you can set are the following:

| Setting Name | Setting Value Type | Setting Description | Setting Default | Setting Example
|---|---|---|---|---|
| saveKey | String | Sets The `SaveKey` to the String. | `'TESTING_0001'` | `'TESTING_001'` |
| defaultSave | Array<any> | Sets the `Data` that will be saved | `{Inventory: {}, Cash: 0, Level: 1};` | `{Inventory: {},Cash: 0,Level: 1};` |
| leaderStats | Array<any> | Sets The `Leaderstats` and their Values. | `{Cash: 0, Level: 1}` | `{Coins: 0}` |