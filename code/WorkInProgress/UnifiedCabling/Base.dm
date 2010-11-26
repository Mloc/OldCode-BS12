// =
// = The Unified (-Type-Tree) Cable Network System
// = Written by Sukasa with assistance from Googolplexed
// =
// = Cleans up the type tree and reduces future code maintenance
// = Also makes it easy to add new cable & network types
// =

// Unified Cable Network System - Generic Cable Class

/obj/cabling
	icon_state = "0-1"
	layer = 2.5
	level = 1
	anchored = 1

	var/Direction1 = 0
	var/Direction2 = 0
	var/list/ConnectableTypes = list( /obj/machinery )
	var/NetworkControllerType = /datum/UnifiedNetworkController
	var/obj/item/SeparateWithType = /obj/item/weapon/wirecutters
	var/DropCablePieceType = null

/obj/cabling/New()
	..()
	spawn(0)
		// Set Direction1 and Direction2 based on the initial state of the cable after creation + setup

		var/Dash = findtext(icon_state, "-")

		Direction1 = text2num( copytext( icon_state, 1, Dash ) )
		Direction2 = text2num( copytext( icon_state, Dash + 1 ) )

		if(level == 1)
			Hide(src.loc)

		if (world.time > 30)
			var/list/P = CableConnections(get_step_3d(src, Direction1)) | CableConnections(get_step_3d(src, Direction2))

			if(!P.len)
				var/datum/UnifiedNetwork/NewNetwork = CreateUnifiedNetwork(type)
				NewNetwork.BuildFrom(src, NetworkControllerType)
			else
				var/obj/cabling/C = P[1]
				var/datum/UnifiedNetwork/NewNetwork = C.Networks[type]
				NewNetwork.CableBuilt(src, P)


/obj/cabling/proc/Hide(var/turf/Location)
	if (!istype(Location))
		return
	if(!istype(loc, /turf/space))
		invisibility = Location.intact ? 101 : 0
	UpdateIcon()


/obj/cabling/proc/UpdateIcon()
	icon_state = "[Direction1]-[Direction2][invisibility?"-f":""]"
	return


/obj/cabling/Del()
	if (!defer_cables_rebuild)
		var/datum/UnifiedNetwork/Network = Networks[type]
		Network.CutCable(src)
	else
		if(Debug)
			check_diary()
			diary << "Deferring U.C. deletion at \[[x], [y], [z]]: #[NetworkNumber]"
	..()


/obj/cabling/proc/CableConnections(var/turf/Target, var/IncludeAlreadyConnected = 0)
	var/list/Cables = list()
	var/Direction = get_dir_3d(Target, src)

	for(var/obj/cabling/C in Target)
		if ((!IncludeAlreadyConnected || !C.NetworkNumber) && C.type == src.type)
			if (C.Direction1 == Direction || C.Direction2 == Direction)
				Cables += C

	Cables -= src

	return Cables

/obj/cabling/proc/AllConnections(var/turf/Target, var/IncludeAlreadyConnected = 0)
	var/list/Connections = list()
	var/Direction = get_dir_3d(Target, src)

	for(var/obj/cabling/C in Target)
		if ((!IncludeAlreadyConnected || !C.NetworkNumber[type]) && C.type == src.type)
			if (C.Direction1 == Direction || C.Direction2 == Direction)
				Connections += C

	Direction = reverse_dir_3d(Direction)

	for(var/obj/O in Target)
		if (istype(O, /obj/cabling))
			continue

		if ((!IncludeAlreadyConnected || !O.NetworkNumber[type]) && CanConnect(O.type))
			if (Direction1 == Direction1 || Direction2 == Direction2)
				Connections += O

	Connections -= src

	return Connections

/obj/cabling/proc/CanConnect(var/obj/ConnectTo)
	for(var/Type in ConnectableTypes)
		if(istype(ConnectTo, Type))
			return 1
	return 0

/obj/cabling/attackby(var/obj/item/weapon/W, var/mob/User)
	var/datum/UnifiedNetwork/Network = Networks[type]
	add_fingerprint(User)

	var/turf/T = src.loc

	if(T.intact && level == 1)
		return

	if(istype(W, SeparateWithType))

		if (DropCablePieceType)
			DropCablePieces()

		for(var/mob/O in viewers(src, null))
			O.show_message("\red [User] cuts the [name].", 1)

		Network.Controller.CableCut(src, User)

		del src

	else if(istype(W, /obj/item/weapon/cable_coil))

		//TODO - Start laying cable

	else if(istype(W, /obj/item/device))

		Network.Controller.DeviceUsed(W, src)

/obj/cabling/proc/DropCablePieces()
	if (DropCablePieceType)
		new DropCablePieceType(loc, Direction1 ? 2 : 1)


/obj/cabling/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
		if(2.0)
			if (prob(50))
				DropCablePieces()
				del(src)

		if(3.0)
			if (prob(25))
				DropCablePieces()
				del(src)
	return