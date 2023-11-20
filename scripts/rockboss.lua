easyEdit.bossList:get("archive"):addBoss("Mission_RockBoss")
easyEdit.bossList:get("rst"):addBoss("Mission_RockBoss")
--adds the rock boss to archive and rst, I couldn't find the other two vanilla islands
--don't know how to add to modded islands if they exist

local mod = mod_loader.mods[modApi.currentMod]
local path = mod.resourcePath
local writepath = "img/units/aliens/"
local readpath = path .. writepath
local imagepath = writepath:sub(5,-1)

modApi:appendAsset(writepath .."rock_B.png", readpath .."rock_B.png")
modApi:appendAsset(writepath .."rock_Ba.png", readpath .."rock_Ba.png")
modApi:appendAsset(writepath .."rock_B_death.png", readpath .."rock_B_death.png")
modApi:appendAsset(writepath .."rock_B_emerge.png", readpath .."rock_B_emerge.png")
modApi:appendAsset(writepath .."rock_Bw.png", readpath .."rock_Bw.png")

local a = ANIMS
local base = a.EnemyUnit:new{Image = imagepath .."rock_B.png", PosX = -20, PosY = 1, NumFrames = 1, Height = 1 }
local baseEmerge = a.BaseEmerge:new{Image = imagepath .."rock_B_emerge.png", PosX = -20, PosY = 1, Height = 1}
a.rock_B  =	base
a.rock_Be =	baseEmerge
a.rock_Ba =	base:new{ Image = "units/aliens/rock_Ba.png", NumFrames = 1 }
a.rock_Bd =	base:new{ Image = "units/aliens/rock_B_death.png", NumFrames = 13, Time = 0.14, Loop = false }
a.rock_Bw =	base:new{ Image = "units/aliens/rock_Bw.png", PosY = 10 }

---- MISSION DESCRIPTION
Mission_RockBoss = Mission_Boss:new{
	Name = "Rock Leader",
	BossPawn = "Meta_RockBoss",
	GlobalSpawnMod = 0,	--two reasons: 1. it doesn't do anything by itself 2. some Vek need to be left alive for cool stuff to happen
	BossText = "Destroy the Rock Leader"
}

-------- BOSS DESCRIPTION
Meta_RockBoss = {
	Health = 5,
	Armor = true,	--not sure, either that or more HP?
	MoveSpeed = 0,
	Image = "rock_B",
	Name = "Rock Leader",
	-- ImageOffset = 2,
	SkillList = { "Meta_RockBossSkill" },
	SoundLocation = "/support/rock/",
	Massive = true,
	ImpactMaterial = IMPACT_ROCK,
	DefaultTeam = TEAM_ENEMY,
	IsPortrait = false,
	Tier = TIER_BOSS,
	Neutral = true,
		-- DefaultTeam = TEAM_NONE,
		
}
AddPawn("Meta_RockBoss") 

function Meta_RockBoss:GetWeapon()  
	--will use this later to make alternative behavior: if nothing to upgrade, explode?
	return 1
end


Meta_RockBossSkill = Skill:new{
	Name = "Empowering Pulse",
	Class = "Enemy",
	PathSize = 1,
	Description = "Boosts all Veks instantly; at the end of the turn, permanently empowers the weapons of surviving Veks.",
	TipImage = {
		Unit = Point(2,3),
		Enemy = Point(2,1),
		Target = Point(2,2),
		CustomPawn = "BeetleBoss"
	}
}

function Meta_RockBossSkill:GetTargetArea(point)
	local ret = PointList()
	ret:push_back(point)
	return ret
end


function Meta_RockBossSkill:GetTargetScore(p)
	return 10
end

function Meta_RockBossSkill:GetSkillEffect(p1,p2)
	ret = SkillEffect()
	local upgradesCount = 0
	for _, tile in ipairs(Board) do
		local pawn = Board:GetPawn(tile)
		if pawn and pawn:GetTeam() == TEAM_ENEMY and pawn:GetWeaponCount() > 0 then
			local weaponName = pawn:GetWeaponType(1)
			if weaponName:sub(-1, -1) == "2" and _G[weaponName:sub(1, -2).."B"] or weaponName:sub(-1, -1) == "1" and _G[weaponName:sub(1, -2).."2"] then
				upgradesCount = upgradesCount + 1
			end
		end
	end
	if upgradesCount == 0 then
		local sdDamage = SpaceDamage(p1, DAMAGE_DEATH)
		sdDamage.sAnimation = "ExploArt3"
		ret:AddQueuedDamage(sdDamage)
		for i = DIR_START, DIR_END do
			for j = 1, 2 do
				local curr = p1 + DIR_VECTORS[i] * j
				local damage = SpaceDamage(curr, 3)
				if j == 2 then damage.sAnimation = "explopush2" end
				ret:AddQueuedDamage(damage)
			end
		end
	else
		ret:AddScript([[
		for _, tile in ipairs(Board) do
			local pawn = Board:GetPawn(tile)
			if pawn and pawn:GetTeam() == TEAM_ENEMY and pawn:GetWeaponCount() > 0 then
				local weaponName = pawn:GetWeaponType(1)
				if weaponName:sub(-1, -1) == "2" and _G[weaponName:sub(1, -2).."B"] then
					Board:GetPawn(pawn:GetId()):RemoveWeapon(1)
					Board:GetPawn(pawn:GetId()):AddWeaponVanilla(weaponName:sub(1, -2).."B")
				elseif weaponName:sub(-1, -1) == "1" and _G[weaponName:sub(1, -2).."2"] then
					Board:GetPawn(pawn:GetId()):RemoveWeapon(1)
					Board:GetPawn(pawn:GetId()):AddWeaponVanilla(weaponName:sub(1, -2).."2")
				end
			end
		end]])
		ret:AddAnimation(p1, "PulseBlast")
	end
	return ret
end

