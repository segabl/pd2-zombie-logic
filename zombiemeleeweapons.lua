-- This is an example file for adding player melee weapons to enemies
-- In this example, weapons are randomized, but they can be easily set up like normal in charactertweakdata
-- Note that randomizing from the entire player weapon pool will likely cause small hitches due to dynamic loading/unloading
-- Remove the line below to enable the effects of this file
do return end


-- This part of the code copies all player melee weapons and makes them available to enemies
-- It's also possible to copy just the ones you plan to give to enemies but it doesn't hurt do just copy all
for k, v in pairs(tweak_data.blackmarket.melee_weapons) do
	tweak_data.weapon.npc_melee[k] = {
		unit_name = v.third_unit and Idstring(v.third_unit),
		sound_miss = v.sounds and v.sounds.hit_air,
		sound_hit = v.sounds and v.sounds.hit_body,
		damage = tweak_data.weapon.npc_melee.knife_1.damage,
		animation_param = v.anim_global_param,
		player_blood_effect = true
	}
end


-- The following functions handle melee weapons for enemies
-- Note that the melee weapon unit has to be loaded first, since player weapons are only loaded on demand
-- Units should also be unleaded when not used anymore, which we can do whenever the enemy using the weapon dies
function CopBase:melee_weapon()
	if not self._melee_weapon then
		-- Randomizing melee weapon here, use `self._melee_weapon = self._char_tweak.melee_weapon or "weapon"` if you want to take melee from the charactertweakdata preset instead
		self._melee_weapon = table.random_key(tweak_data.weapon.npc_melee)
		self._melee_weapon_data = tweak_data.weapon.npc_melee[self._melee_weapon]
		if self._melee_weapon_data.unit_name and DB:has(Idstring("unit"), self._melee_weapon_data.unit_name) then
			managers.dyn_resource:load(Idstring("unit"), self._melee_weapon_data.unit_name, managers.dyn_resource.DYN_RESOURCES_PACKAGE)
		else
			self._melee_weapon_data = nil
		end
	end
	return self._melee_weapon
end

Hooks:PostHook(CopBase, "pre_destroy", "melee_unload", function (self)
	if self._melee_weapon_data then
		managers.dyn_resource:unload(Idstring("unit"), self._melee_weapon_data.unit_name, managers.dyn_resource.DYN_RESOURCES_PACKAGE)
	end
end)
