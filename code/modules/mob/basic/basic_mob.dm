/*
*	Fully ports tgstation's basicmob system with edits and omissions to suit roguecode
*/

///Simple animals 2.0, This time, let's really try to keep it simple. This basetype should purely be used as a base-level for implementing simplified behaviours for things such as damage and attacks. Everything else should be in components or AI behaviours.
/mob/living/basic
	name = "basic mob"
//	icon = 'icons/mob/simple/animal.dmi'
	health = 20
	maxHealth = 20
	max_stamina = BASIC_MOB_STAMINA_MATCH_HEALTH
	gender = PLURAL
	living_flags = MOVES_ON_ITS_OWN
	status_flags = CANPUSH | CANSTUN
//	fire_stack_decay_rate = -5 // Reasonably fast as NPCs will not usually actively extinguish themselves

	var/basic_mob_flags = NONE

	///Defines how fast the basic mob can move. This is not a multiplier
	var/speed = 1
	///How much stamina the mob recovers per second, if set to >0 stamina loses its normal function of resetting after a set amount of time
	var/stamina_recovery = 0
	///How slow will we get when we lose all our stamina?
	var/max_stamina_slowdown = 3
	///Percentage of max stamina loss we need to lose in order to get stunned
	var/stamina_crit_threshold = 100

	///how much damage this basic mob does to objects, if any.
	var/obj_damage = 0
	///How much armour they ignore, as a flat reduction from the targets armour value.
	var/armour_penetration = 0
	///Damage type of a simple mob's melee attack, should it do damage.
	var/melee_damage_type = BRUTE
	///How much wounding power it has
//	var/wound_bonus = CANT_WOUND
	///How much bare wounding power it has
	var/exposed_wound_bonus = 0
	///If the attacks from this are sharp
	var/sharpness = NONE

	/// Sound played when the critter attacks.
	var/attack_sound
	/// Override for the visual attack effect shown on 'do_attack_animation()'.
	var/attack_vis_effect
	///Played when someone punches the creature.
//	var/attacked_sound = SFX_PUNCH //This should be an element
	/// How often can you melee attack?
	var/melee_attack_cooldown = 2 SECONDS

	/// Variable maintained for compatibility with attack_animal procs until simple animals can be refactored away. Use element instead of setting manually.
	var/environment_smash = ENVIRONMENT_SMASH_STRUCTURES

	/// 1 for full damage, 0 for none, -1 for 1:1 heal from that source.
	var/list/damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, STAMINA = 1, OXY = 1)

	///Verbs used for speaking e.g. "Says" or "Chitters". This can be elementized
	var/list/speak_emote = list()

	///When someone interacts with the simple animal.
	///Help-intent verb in present continuous tense.
	var/response_help_continuous = "pokes"
	///Help-intent verb in present simple tense.
	var/response_help_simple = "poke"
	///Disarm-intent verb in present continuous tense.
	var/response_disarm_continuous = "shoves"
	///Disarm-intent verb in present simple tense.
	var/response_disarm_simple = "shove"
	///Harm-intent verb in present continuous tense.
	var/response_harm_continuous = "hits"
	///Harm-intent verb in present simple tense.
	var/response_harm_simple = "hit"

	///Basic mob's own attacks verbs,
	///Attacking verb in present continuous tense.
	var/attack_verb_continuous = "attacks"
	///Attacking verb in present simple tense.
	var/attack_verb_simple = "attack"
	///Attacking, but without damage, verb in present continuous tense.
	var/friendly_verb_continuous = "nuzzles"
	///Attacking, but without damage, verb in present simple tense.
	var/friendly_verb_simple = "nuzzle"

	////////THIS SECTION COULD BE ITS OWN ELEMENT
	///Icon to use
	var/icon_living = ""
	///Icon when the animal is dead. Don't use animated icons for this.
	var/icon_dead = ""
	///We only try to show a gibbing animation if this exists.
	var/icon_gib = null

/mob/living/basic/Initialize(mapload)
	. = ..()

	if(gender == PLURAL)
		gender = pick(MALE,FEMALE)

	if(!real_name)
		real_name = name

	if(!loc)
		stack_trace("Basic mob being instantiated in nullspace")

	update_basic_mob_varspeed()
	make_stamina_slowable()

	if(speak_emote)
		speak_emote = string_list(speak_emote)

/// Ensures that this mob can be slowed from taking stamina damage
/mob/living/basic/proc/make_stamina_slowable()
	if (max_stamina == BASIC_MOB_STAMINA_MATCH_HEALTH)
		max_stamina = maxHealth
	if (damage_coeff[STAMINA] <= 0 || max_stamina <= 0 || max_stamina_slowdown <= 0)
		return
	AddElement(/datum/element/basic_stamina_slowdown, minium_stamina_threshold = max_stamina / 3, maximum_stamina = max_stamina, maximum_slowdown = max_stamina_slowdown)

/mob/living/basic/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	. = ..()
	if(staminaloss > 0)
		adjustStaminaLoss(-stamina_recovery * seconds_per_tick, forced = TRUE)

/*/mob/living/basic/get_default_say_verb()
	return length(speak_emote) ? pick(speak_emote) : ..()*/

/mob/living/basic/death(gibbed)
	. = ..()
	if(basic_mob_flags & DEL_ON_DEATH)
		ghostize(can_reenter_corpse = FALSE)
		qdel(src)
	else
		health = 0
		look_dead()

/mob/living/basic/gib()
	if(butcher_results || guaranteed_butcher_results)
		var/list/butcher_loot = list()
		if(butcher_results)
			butcher_loot += butcher_results
		if(guaranteed_butcher_results)
			butcher_loot += guaranteed_butcher_results
		var/atom/loot_destination = drop_location()
		for(var/path in butcher_loot)
			for(var/i in 1 to butcher_loot[path])
				new path(loot_destination)
	return ..()

/**
 * Apply the appearance and properties this mob has when it dies
 * This is called by the mob pretending to be dead too so don't put loot drops in here or something
 */
/mob/living/basic/proc/look_dead()
	icon_state = icon_dead
	if(basic_mob_flags & FLIP_ON_DEATH)
		transform = transform.Turn(180)
	if(!(basic_mob_flags & REMAIN_DENSE_WHILE_DEAD))
		ADD_TRAIT(src, TRAIT_UNDENSE, BASIC_MOB_DEATH_TRAIT)
	SEND_SIGNAL(src, COMSIG_BASICMOB_LOOK_DEAD)

/mob/living/basic/revive(full_heal_flags = NONE, excess_healing = 0, force_grab_ghost = FALSE)
	. = ..()
	if(!.)
		return
	look_alive()

/// Apply the appearance and properties this mob has when it is alive
/mob/living/basic/proc/look_alive()
	icon_state = icon_living
	if(basic_mob_flags & FLIP_ON_DEATH)
		transform = transform.Turn(180)
	if(!(basic_mob_flags & REMAIN_DENSE_WHILE_DEAD))
		REMOVE_TRAIT(src, TRAIT_UNDENSE, BASIC_MOB_DEATH_TRAIT)
	SEND_SIGNAL(src, COMSIG_BASICMOB_LOOK_ALIVE)

/mob/living/basic/examine(mob/user)
	. = ..()
	if(stat != DEAD)
		return
//	. += span_deadsay("Upon closer examination, [p_they()] appear[p_s()] to be [HAS_MIND_TRAIT(user, TRAIT_NAIVE) ? "asleep" : "dead"].")

/mob/living/basic/proc/melee_attack(atom/target, list/modifiers, ignore_cooldown = FALSE)
	if(!early_melee_attack(target, modifiers, ignore_cooldown))
		return FALSE
	var/result = target.attack_basic_mob(src, modifiers)
	SEND_SIGNAL(src, COMSIG_HOSTILE_POST_ATTACKINGTARGET, target, result)
	if(!ignore_cooldown)
		changeNext_move(melee_attack_cooldown) // Set it again because objects like to fuck with it in attack_basic_mob
	return result

/mob/living/basic/proc/early_melee_attack(atom/target, list/modifiers, ignore_cooldown = FALSE)
	face_atom(target)
	if(!ignore_cooldown)
		changeNext_move(melee_attack_cooldown) // Set cooldown early in case it is cancelled
	if(SEND_SIGNAL(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, target, Adjacent(target), modifiers) & COMPONENT_HOSTILE_NO_ATTACK)
		return FALSE //but more importantly return before attack_animal called
	return TRUE

/mob/living/basic/resolve_unarmed_attack(atom/attack_target, list/modifiers)
	melee_attack(attack_target, modifiers)

/mob/living/basic/proc/set_varspeed(var_value)
	speed = var_value
	update_basic_mob_varspeed()

/mob/living/basic/proc/update_basic_mob_varspeed()
	if(speed == 0)
		remove_movespeed_modifier(/datum/movespeed_modifier/simplemob_varspeed)
	add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/simplemob_varspeed, multiplicative_slowdown = speed)
	SEND_SIGNAL(src, POST_BASIC_MOB_UPDATE_VARSPEED)

/mob/living/basic/relaymove(mob/living/user, direction)
	if(user.incapacitated)
		return
	return relaydrive(user, direction)

/mob/living/basic/get_status_tab_items()
	. = ..()
	. += "Health: [round((health / maxHealth) * 100)]%"
//	. += "Combat Mode: [combat_mode ? "On" : "Off"]"

/mob/living/basic/put_in_hands(obj/item/I, del_on_fail = FALSE, merge_stacks = TRUE, ignore_animation = TRUE)
	. = ..()
	if (.)
		update_held_items()

/mob/living/basic/update_held_items()
	. = ..()
	if(isnull(client) || isnull(hud_used) || hud_used.hud_version == HUD_STYLE_NOHUD)
		return
	var/turf/our_turf = get_turf(src)
	for(var/obj/item/held in held_items)
		var/index = get_held_index_of_item(held)
		SET_PLANE(held, ABOVE_HUD_PLANE, our_turf)
		held.screen_loc = ui_hand_position(index)
		client.screen |= held

/mob/living/basic/proc/hop_on_nearby_turf()
	var/dir = pick(GLOB.cardinals)
	Move(get_step(src, dir), dir)
	animate(src, pixel_y = 18, time = 0.4 SECONDS, flags = ANIMATION_RELATIVE, easing = CUBIC_EASING|EASE_OUT)
	animate(pixel_y = -18, time = 0.4 SECONDS, flags = ANIMATION_RELATIVE, easing = CUBIC_EASING|EASE_IN)
