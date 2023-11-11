local description = "Finally adds the most deadly Vek of them all to the game, an especially big rock. It's a boss that empowers other Veks."
local mod = {
	id = "Meta_RockLeader",
	name = "Rock Leader",
	version = "1.0",
	requirements = {},
	dependencies = { 
		modApiExt = "1.18", --We can get this by using the variable `modapiext`
	},
	modApiVersion = "2.9.1",
	icon = "img/mod_icon.png",
	description = description,
}

function mod:init()
	require(self.scriptPath .."rockboss")
end

function mod:load( options, version)
	mod.icon = self.resourcePath .."img/mod_icon.png"
end

return mod
