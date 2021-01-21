declare class PlayerData {
    /**
	 * Sets a setting
	 * @param settingName The name of the setting to set
	 * @param settingValue The value of the setting to set
	 */
    setSetting(settingName: "defaultSave", settingValue: Array<any>): void;
    setSetting(settingName: "saveKey", settingValue: string): void;
	setSetting(settingName: "leaderStats", settingValue: Array<any>): void;
	// setSetting(settingName: "avoider", settingValue: string): void;
    
    /**
	 * Converts The Player UserId into a String
	 * @param player The Player Who Is Saving
	 */
    ConvertToPlayerKey(player: Player): string

    /**
	 * Converts The Player UserId into a String
	 * @param player The Player Who Is Saving
	 */
	Get(player: Player): void
	
	/**
	 * Runs The DataStore (ONLY USE THIS ONCE);
	 * MAKE SURE YOU HAVE API SERVICES ON!!!
	 */
	run(): void
}

type SettingNameTypes = 'defaultSave' | 'saveKey' | 'leaderStats'
declare function setSetting(settingName: SettingNameTypes, settingValue: string | object): void
declare function ConvertToPlayerKey(player: Player): string
declare function Get(player: Player): object
declare function run(): void

export { setSetting, ConvertToPlayerKey, Get, run }