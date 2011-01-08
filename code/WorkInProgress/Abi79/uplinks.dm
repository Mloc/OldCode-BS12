/*

SYNDICATE UPLINKS

TO-DO:
	Once wizard is fixed, make sure the uplinks work correctly for it. wizard.dm is right now uncompiled and with broken code in it.

	Clean the code up and comment it. Part of it is right now copy-pasted, with the general Topic() and modifications by Abi79.

		I should take a more in-depth look at both the copy-pasted code for the individual uplinks below, and at each gamemode's code
		to see how uplinks are assigned and if there are any bugs with those.


A list of items and costs is stored under the datum of every game mode, alongside the number of crystals, and the welcoming message.

*/

/obj/item/device/uplink
	var/welcome 					// Welcoming menu message
	var/menu_message = "" 			// The actual menu text
	var/items						// List of items
	var/list/ItemList				// Parsed list of items
	var/uses 						// Numbers of crystals

/obj/item/device/uplink/pda
	name = "uplink module"
	desc = "An electronic uplink system of unknown origin."
	icon = 'module.dmi'
	icon_state = "power_mod"
	var/obj/item/device/pda/hostpda = null

	var/orignote = null 		//Restore original notes when locked.
	var/active = 0 				//Are we currently active?
	var/unlocking_code = "" 	//The unlocking password.

/obj/item/device/uplink/radio
	name = "station bounced radio"
	icon = 'device.dmi'
	icon_state = "radio"
	var/temp = null 			//Temporary storage area for a message offering the option to destroy the radio
	var/selfdestruct = 0		//Set to 1 while the radio is self destructing itself.
	var/obj/item/device/radio/origradio = null
	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT
	w_class = 2.0
	item_state = "radio"
	throwforce = 5
	throw_speed = 4
	throw_range = 20
	m_amt = 100


/obj/item/device/uplink/New()
	welcome = ticker.mode.uplink_welcome
	items = dd_replacetext(ticker.mode.uplink_items, "\n", "")	// Getting the text string of items
	ItemList = dd_text2list(src.items, ";")	// Parsing the items text string
	uses = ticker.mode.uplink_uses

//Let's build a menu!
/obj/item/device/uplink/proc/generate_menu()
	src.menu_message = "<B>[src.welcome]</B><BR>"
	src.menu_message += "Tele-Crystals left: [src.uses]<BR>"
	src.menu_message += "<HR>"
	src.menu_message += "<B>Request item:</B><BR>"
	src.menu_message += "<I>Each item costs a number of tele-crystals as indicated by the number following their name.</I><BR>"

	var/cost
	var/item
	var/name
	var/path_obj
	var/path_text

	for(var/O in ItemList)
		O = stringsplit(O, " (")

		path_text = O[1]
		cost = text2num(O[2])

		if(cost>uses)
			continue

		path_obj = text2path(path_text)
		item = new path_obj()
		name = item:name
		del item

		src.menu_message += "<A href='byond://?src=\ref[src];buy_item=[path_text];cost=[cost]'>[name]</A> ([cost])<BR>"


	src.menu_message += "<HR>"
	return

/obj/item/device/uplink/Topic(href, href_list)
	if (href_list["buy_item"])
		if(text2num(href_list["cost"]) > uses) // Not enough crystals for the item
			return 0

		if(usr:mind && ticker.mode.traitors[usr:mind])
			var/datum/traitorinfo/info = ticker.mode.traitors[usr:mind]
			info.spawnlist += href_list["buy_item"]

		uses -= text2num(href_list["cost"])

		return 1


/*
 *PDA uplink
 */

//Syndicate uplink hidden inside a traitor PDA
//Communicate with traitor through the PDA's note function.

/obj/item/device/uplink/pda/proc/unlock()
	if ((isnull(src.hostpda)) || (src.active))
		return

	src.orignote = src.hostpda.note
	src.active = 1
	src.hostpda.mode = 5 //Switch right to the notes program

	src.generate_menu()
	src.hostpda.note = src.menu_message

	for (var/mob/M in viewers(1, src.hostpda.loc))
		if (M.client && M.machine == src.hostpda)
			src.hostpda.attack_self(M)

	return

/obj/item/device/uplink/pda/attack_self(mob/user as mob)
	src.generate_menu()
	src.hostpda.note = src.menu_message


/obj/item/device/uplink/pda/Topic(href, href_list)
	if ((isnull(src.hostpda)) || (!src.active))
		return

	if (usr.stat || usr.restrained() || !in_range(src.hostpda, usr))
		return

	if(..() == 1) // We can afford the item
		var/path_obj = text2path(href_list["buy_item"])
		var/item = new path_obj(get_turf(src.hostpda))
		if(istype(item, /obj/spawner)) // Spawners need to have del called on them to avoid leaving a marker behind
			del item


	src.attack_self(usr)
	src.hostpda.attack_self(usr)

	return


/*
 *Portable radio uplink
 */

//A Syndicate uplink disguised as a portable radio

/obj/item/device/uplink/radio/attack_self(mob/user as mob)
	user.machine = src
	var/dat

	if (src.selfdestruct)
		dat = "Self Destructing..."
	else
		if (src.temp)
			dat = "[src.temp]<BR><BR><A href='byond://?src=\ref[src];clear_selfdestruct=1'>Clear</A>"
		else
			src.generate_menu()
			dat = src.menu_message
			if (src.origradio) // Checking because sometimes the radio uplink may be spawned by itself, not as a normal unlockable radio
				dat += "<A href='byond://?src=\ref[src];lock=1'>Lock</A><BR>"
				dat += "<HR>"
			dat += "<A href='byond://?src=\ref[src];selfdestruct=1'>Self-Destruct</A>"

	user << browse(dat, "window=radio")
	onclose(user, "radio")
	return

/obj/item/device/uplink/radio/Topic(href, href_list)
	if (usr.stat || usr.restrained())
		return

	var/mob/living/carbon/human/H = usr

	if (!( istype(H, /mob/living/carbon/human)))
		return 1

	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))))
		usr.machine = src

		if(href_list["buy_item"])
			if(..() == 1) // We can afford the item
				var/path_obj = text2path(href_list["buy_item"])
				var/item = new path_obj(get_turf(src.loc))
				if(istype(item, /obj/spawner)) // Spawners need to have del called on them to avoid leaving a marker behind
					del item

			src.attack_self(usr)
			return

		else if (href_list["lock"] && src.origradio)
			// presto chango, a regular radio again! (reset the freq too...)
			usr.machine = null
			usr << browse(null, "window=radio")
			var/obj/item/device/radio/T = src.origradio
			var/obj/item/device/uplink/radio/R = src
			R.loc = T
			T.loc = usr
			// R.layer = initial(R.layer)
			R.layer = 0
			if (usr.client)
				usr.client.screen -= R
			if (usr.r_hand == R)
				usr.u_equip(R)
				usr.r_hand = T
			else
				usr.u_equip(R)
				usr.l_hand = T
			R.loc = T
			T.layer = 20
			T.set_frequency(initial(T.frequency))
			T.attack_self(usr)
			return

		else if (href_list["selfdestruct"])
			src.temp = "<A href='byond://?src=\ref[src];selfdestruct2=1'>Self-Destruct</A>"

		else if (href_list["selfdestruct2"])
			src.selfdestruct = 1
			spawn (100)
				explode()
				return

		else if (href_list["clear_selfdestruct"])
			src.temp = null

		if (istype(src.loc, /mob))
			attack_self(src.loc)
		else
			for(var/mob/M in viewers(1, src))
				if (M.client)
					src.attack_self(M)
	return

/obj/item/device/uplink/radio/proc/explode()
	var/turf/location = get_turf(src.loc)
	if(location)
		location.hotspot_expose(SPARK_TEMP,125)
		explosion(location, 0, 0, 2, 4, 1)

	del(src.master)
	del(src)
	return