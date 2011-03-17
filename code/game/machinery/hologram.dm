/obj/machinery/hologram_ai
	name = "Hologram Projector Platform"
	icon = 'stationobjs.dmi'
	icon_state = "hologram0"
	var/atom/projection = null
	var/temp = null
	var/lumens = 0.0
	var/h_r = 245.0
	var/h_g = 245.0
	var/h_b = 245.0
	anchored = 1.0

/obj/machinery/hologram_ai/wall_projector
	name = "Hologram Wall Projector"
	icon_state = "wall_hologram0"

/obj/machinery/hologram_ai/New()
	..()

/obj/machinery/hologram_ai/attack_ai(user as mob)
	src.show_console(user)
	return

/obj/machinery/hologram_ai/proc/render()
	var/icon/I = new /icon('human.dmi', "body_m_s")

	if (src.lumens >= 0)
		I.Blend(rgb(src.lumens, src.lumens, src.lumens), ICON_ADD)
	else
		I.Blend(rgb(- src.lumens,  -src.lumens,  -src.lumens), ICON_SUBTRACT)

	I.Blend(new /icon('human.dmi', "mouth_m_s"), ICON_OVERLAY)
	I.Blend(new /icon('human.dmi', "underwear1_m_s"), ICON_OVERLAY)

	var/icon/U = new /icon('human_face.dmi', "hair_a_s")
	U.Blend(rgb(src.h_r, src.h_g, src.h_b), ICON_ADD)

	I.Blend(U, ICON_OVERLAY)

	I.Blend(new /icon('uniform.dmi', "aqua_s"), ICON_OVERLAY)

	src.projection.icon = I

/obj/machinery/hologram_ai/proc/show_console(var/mob/user as mob)
	var/dat
	user.machine = src
	if (src.temp)
		dat = text("[]<BR><BR><A href='?src=\ref[];temp=1'>Clear</A>", src.temp, src)
	else
		dat = text("<B>Hologram Status:</B><HR>\nPower: <A href='?src=\ref[];power=1'>[]</A><HR>\n<B>Hologram Control:</B><BR>\nColor Luminosity: []/220 <A href='?src=\ref[];reset=1'>\[Reset\]</A><BR>\nLighten: <A href='?src=\ref[];light=1'>1</A> <A href='?src=\ref[];light=10'>10</A><BR>\nDarken: <A href='?src=\ref[];light=-1'>1</A> <A href='?src=\ref[];light=-10'>10</A><BR>\n<BR>\nHair Color: ([],[],[]) <A href='?src=\ref[];h_reset=1'>\[Reset\]</A><BR>\nRed (0-255): <A href='?src=\ref[];h_r=-300'>\[0\]</A> <A href='?src=\ref[];h_r=-10'>-10</A> <A href='?src=\ref[];h_r=-1'>-1</A> [] <A href='?src=\ref[];h_r=1'>1</A> <A href='?src=\ref[];h_r=10'>10</A> <A href='?src=\ref[];h_r=300'>\[255\]</A><BR>\nGreen (0-255): <A href='?src=\ref[];h_g=-300'>\[0\]</A> <A href='?src=\ref[];h_g=-10'>-10</A> <A href='?src=\ref[];h_g=-1'>-1</A> [] <A href='?src=\ref[];h_g=1'>1</A> <A href='?src=\ref[];h_g=10'>10</A> <A href='?src=\ref[];h_g=300'>\[255\]</A><BR>\nBlue (0-255): <A href='?src=\ref[];h_b=-300'>\[0\]</A> <A href='?src=\ref[];h_b=-10'>-10</A> <A href='?src=\ref[];h_b=-1'>-1</A> [] <A href='?src=\ref[];h_b=1'>1</A> <A href='?src=\ref[];h_b=10'>10</A> <A href='?src=\ref[];h_b=300'>\[255\]</A><BR>", src, (src.projection ? "On" : "Off"),  -src.lumens + 35, src, src, src, src, src, src.h_r, src.h_g, src.h_b, src, src, src, src, src.h_r, src, src, src, src, src, src, src.h_g, src, src, src, src, src, src, src.h_b, src, src, src)
	user << browse(dat, "window=hologram_console")
	onclose(user, "hologram_console")
	return

/obj/machinery/hologram_ai/Topic(href, href_list)
	..()
	if (!istype(usr, /mob/living/silicon/ai))
		return

	if (href_list["power"])
		if (src.projection)
			if(istype(src, /obj/machinery/hologram_ai/wall_projector))
				src.icon_state = "wall_hologram0"
			else
				src.icon_state = "hologram0"

			//src.projector.projection = null
			del(src.projection)
		else
			src.projection = new /obj/projection( src.loc )
			src.projection.icon = 'human.dmi'
			src.projection.icon_state = "male"
			if(istype(src, /obj/machinery/hologram_ai/wall_projector))
				src.icon_state = "wall_hologram1"
			else
				src.icon_state = "hologram1"
			src.render()
	else if (href_list["h_r"])
		if (src.projection)
			src.h_r += text2num(href_list["h_r"])
			src.h_r = min(max(src.h_r, 0), 255)
			render()
	else if (href_list["h_g"])
		if (src.projection)
			src.h_g += text2num(href_list["h_g"])
			src.h_g = min(max(src.h_g, 0), 255)
			render()
	else if (href_list["h_b"])
		if (src.projection)
			src.h_b += text2num(href_list["h_b"])
			src.h_b = min(max(src.h_b, 0), 255)
			render()
	else if (href_list["light"])
		if (src.projection)
			src.lumens += text2num(href_list["light"])
			src.lumens = min(max(src.lumens, -185.0), 35)
			render()
	else if (href_list["reset"])
		if (src.projection)
			src.lumens = 0
			render()
	else if (href_list["temp"])
		src.temp = null
	src.show_console(usr)