
require("precache_resource")

-- GameMode
require("main_game")



function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
	Precache_Resource(context)
end

-- Create the game mode when we activate
function Activate()
	GameRules.GameMode = MainGame()
	GameRules.GameMode:InitGameMode()
end
