/** Networking will use RPCs to send packets. These RPCs can also be
	used by computer terminals to process user input.
	http://whoopshop.com/index.php/topic,1529.msg23274.html#msg23274
**/

/datum/function
	var
		name = "None"
		arg1 = null
		arg2 = null
		arg3 = null
		arg4 = null
		arg5 = null

	proc/get_args()
		var/list/rval = list()
		if(arg1 == null) return rval
		rval += arg1
		if(arg2 == null) return rval
		rval += arg2
		if(arg3 == null) return rval
		rval += arg3
		if(arg4 == null) return rval
		rval += arg4
		if(arg5 == null) return rval
		rval += arg5

/datum/packet
	var
		datum/function/func
		source_id = 0
		destination_id = 0


/obj/machinery/proc/call_function(datum/function/F)

/obj/machinery/proc/receive_packet(var/obj/machinery/sender, datum/packet/P)

// computers can have a console interaction
/obj/machinery/var/mob/console_user
/obj/machinery/var/datum/os/operating_system

/obj/machinery/proc/display_console(mob/user)
	winshow(user, "console", 1)
	console_user = user

	operating_system = new/datum/os()
	user.comp = operating_system
	showdinow()
	operating_system.owner = user
	showdinow(user,blah)
	operating_system.boot()

/obj/machinery/process()
	if( !(console_user in range(1,src)) )
		winshow(console_user, "console", 0)
		console_user.comp = null
		console_user = null
	..()

/obj/machinery/computer/console
	name = "Computer Console"
	icon = 'computer.dmi'
	icon_state = "console"


/obj/machinery/computer/console/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/curer/attack_hand(var/mob/user as mob)
	if(..())
		return
	if(!console_user)
		src.display_console(user)
		return 1