#define COMSIG_MOB_MOVESPEED_UPDATED "mob_updated_movespeed"
///from base of /mob/Login(): ()
#define COMSIG_MOB_LOGIN "mob_login"
///from base of /mob/Logout(): ()
#define COMSIG_MOB_LOGOUT "mob_logout"
//seems somewhat useful
#define COMSIG_MOB_STATCHANGE "mob_statchange"

///before attackingtarget has happened, source is the attacker and target is the attacked
#define COMSIG_HOSTILE_PRE_ATTACKINGTARGET "hostile_pre_attackingtarget"
	#define COMPONENT_HOSTILE_NO_PREATTACK (1<<0) //cancel the attack, only works before attack happens
//#define COMPONENT_HOSTILE_NO_ATTACK COMPONENT_CANCEL_ATTACK_CHAIN //cancel the attack, only works before attack happens
///after attackingtarget has happened, source is the attacker and target is the attacked, extra argument for if the attackingtarget was successful
#define COMSIG_HOSTILE_POST_ATTACKINGTARGET "hostile_post_attackingtarget"

///Called when a /mob/living/simple_animal/hostile finds a new target: (atom/source, new_target)
#define COMSIG_HOSTILE_FOUND_TARGET "comsig_hostile_found_target"

#define COMSIG_MOB_ABILITY_STARTED "comsig_mob_ability_started"
#define COMSIG_MOB_ABILITY_FINISHED "comsig_mob_ability_finished"

#define COMSIG_SIMPLEMOB_PRE_ATTACK_RANGED "basicmob_pre_attack_ranged"
	#define COMPONENT_CANCEL_RANGED_ATTACK COMPONENT_CANCEL_ATTACK_CHAIN //! Cancel to prevent the attack from happening

///from the ranged_attacks component for basic mobs: (mob/living/basic/firer, atom/target, modifiers)
#define COMSIG_SIMPLEMOB_POST_ATTACK_RANGED "basicmob_post_attack_ranged"

///Check for /datum/emote/living/pray/run_emote(): message
#define COMSIG_CARBON_PRAY "carbon_prayed"
///Prevents the carbon's patron from hearing this prayer due to cancelation.
#define CARBON_PRAY_CANCEL (1<<0)

/// Called from the base of '/obj/item/bodypart/proc/drop_limb(special)' ()
#define COMSIG_MOB_DISMEMBER "mob_drop_limb"
	#define COMPONENT_CANCEL_DISMEMBER (1<<0) //cancel the drop limb

/// from base of mob/living/updatestamina()
#define COMSIG_LIVING_STAMINA_UPDATE "living_stamina_update"

/// Sent from /mob/living/basic/proc/look_dead() : ()
#define COMSIG_BASICMOB_LOOK_DEAD "basicmob_look_dead"
/// Sent from /mob/living/basic/proc/look_alive() : ()
#define COMSIG_BASICMOB_LOOK_ALIVE "basicmob_look_alive"
//from base of atom/attack_basic_mob(): (/mob/user)
#define COMSIG_ATOM_ATTACK_BASIC_MOB "attack_basic_mob"
	#define COMSIG_BASIC_ATTACK_CANCEL_CHAIN (1<<0)

/// From base of /mob/proc/update_held_items
#define COMSIG_MOB_UPDATE_HELD_ITEMS "mob_update_held_items"
