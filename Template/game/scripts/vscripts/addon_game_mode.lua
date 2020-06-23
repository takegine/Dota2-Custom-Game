
require("precache_resource")

require('constants')

-- GameMode
require("main_game")
require("holdout_game_mode")


function Precache(context)
	Precache_Resource(context)
	PrecacheCHoldoutGameMode(context)
end


function Activate()
	GameRules.GameMode = MainGame()
	GameRules.GameMode:InitGameMode()
	if HOLDOUT_ENABLED then
		ActivateCHoldoutGameMode()
	end
end
