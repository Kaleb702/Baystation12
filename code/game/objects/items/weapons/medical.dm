/*
CONTAINS:
MEDICAL


*/


/obj/item/stack/medical/attack(mob/living/carbon/M as mob, mob/user as mob)
	if (M.stat == 2)
		var/t_him = "it"
		if (M.gender == MALE)
			t_him = "him"
		else if (M.gender == FEMALE)
			t_him = "her"
		user << "\red \The [M] is dead, you cannot help [t_him]!"
		return
	if (M.health < 0)
		var/t_him = "it"
		if (M.gender == MALE)
			t_him = "him"
		else if (M.gender == FEMALE)
			t_him = "her"
		user << "\red \The [M] is wounded badly, this item cannot help [t_him]!"
		return


	if (!istype(M))
		user << "\red \The [src] cannot be applied to [M]!"
		return 1

	if ( ! (istype(user, /mob/living/carbon/human) || \
			istype(user, /mob/living/silicon) || \
			istype(user, /mob/living/carbon/monkey) && ticker && ticker.mode.name == "monkey") )
		user << "\red You don't have the dexterity to do this!"
		return 1

	if (user)
		if (M != user)
			user.visible_message( \
				"\blue [M] has been applied with [src] by [user].", \
				"\blue You apply \the [src] to [M]." \
			)
		else
			var/t_himself = "itself"
			if (user.gender == MALE)
				t_himself = "himself"
			else if (user.gender == FEMALE)
				t_himself = "herself"

			user.visible_message( \
				"\blue [M] applied [src] on [t_himself].", \
				"\blue You apply \the [src] on yourself." \
			)

	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/datum/organ/external/affecting = H.get_organ("chest")

		if(istype(user, /mob/living/carbon/human))
			var/mob/living/carbon/human/user2 = user
			affecting = H.get_organ(check_zone(user2.zone_sel.selecting))
		else
			if(!istype(affecting, /datum/organ/external) || affecting:burn_dam <= 0)
				affecting = H.get_organ("head")

		if (affecting.heal_damage(src.heal_brute, src.heal_burn))
			H.UpdateDamageIcon()

		if(H.bloodloss > 0 && heal_brute > 0)		// fix wounds too if bruise pack
			var/stoped = 0
			for(var/datum/organ/external/wound/W in affecting.wounds)
				if(W.bleeding)
					W.stopbleeding()
					stoped = 0
					break
			if(!stoped)
				// user << "There is no bleeding wound at [t]" //code no longer in a dedicated obj, thus this doesn't really matter
				return
			if (user)
				if (M != user)
					for (var/mob/O in viewers(H, null))
						O.show_message("\red [H] has been bandaged with [src] by [user]", 1)
				else
					var/t_himself = "itself"
					if (user.gender == MALE)
						t_himself = "himself"
					else if (user.gender == FEMALE)
						t_himself = "herself"
					for (var/mob/O in viewers(H, null))
						O.show_message("\red [H] bandaged [t_himself] with [src]", 1)

		M.updatehealth()
	else
		M.heal_organ_damage((src.heal_brute/2), (src.heal_burn/2))

	use(1)
