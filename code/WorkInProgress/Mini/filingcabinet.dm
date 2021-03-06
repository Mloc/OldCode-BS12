/obj/filingcabinet
	name = "Filing Cabinet"
	desc = "A large cabinet with drawers."
	icon = 'computer.dmi'
	icon_state = "messyfiles"
	density = 1
	anchored = 1

/obj/filingcabinet/attackby(obj/item/weapon/paper/P,mob/M)
	if(istype(P))
		M << "You put the [P] in the [src]."
		M.drop_item()
		P.loc = src
	else
		M << "You can't put a [P] in the [src]!"

/obj/filingcabinet/attack_hand(mob/user)
	if(src.contents.len <= 0)
		user << "The [src] is empty."
		return
	var/obj/item/weapon/paper/P = input(user,"Choose a sheet to take out.","[src]", "Cancel") as obj in src.contents
	if(in_range(src,user))
		P.loc = user.loc