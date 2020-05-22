/decl/webhook/send_ban
	id = WEBHOOK_XENO_WHITELIST

/decl/webhook/send_ban/get_message(var/list/data)
	. = ..()

	if(!data || !data.len)
		.["content"] = "Тут должно быть сообщение о вайтлисте, но кто то вызвал вебхук вручную."
		return

	if(!data["grant"] && !data["revoke"])
		return
	if(!data["ckey"])		data["ckey"] = "ДАННЫЕ УДАЛЕНЫ"
	if(!data["type"])		data["type"] = "ДАННЫЕ УДАЛЕНЫ"

	var/list/desc = list()
	desc["title"] = "Ксеномодератор - [data["ckey"]]"
	desc["description"] = "Изменения внесены в [data["type"]]"
	desc["color"] = COLOR_WEBHOOK_XENO
	desc["author"] = list(
		"name" = "Изменение вайтлиста на расы",
		"icon_url" = "https://cdn.discordapp.com/emojis/244791612268347392.png?v=1")	// :inf: emoji

	var/list/grant = data["grant"]
	var/list/revoke = data["revoke"]
	var/icon = "https://cdn.discordapp.com/emojis/680793066415980576.png?v=1"			// :SeemsRichKot: emoji
	if(!grant || (revoke && (revoke.len >= grant.len)))
		icon = "https://cdn.discordapp.com/emojis/601028456675016706.png?v=1"			// :resomisad: emoji
	desc["thumbnail"] = list("url" = icon)
	var/list/A = list()
	var/list/B = list()
	for(var/ckey in grant)
		var/list/check = grant[ckey]
		for(var/race in check)
			B += "++[race]"
		A[ckey] = B
	grant = A
	A.Cut()
	B.Cut()
	for(var/ckey in revoke)
		var/list/check = revoke[ckey]
		for(var/race in check)
			B += "--[race]"
		A[ckey] = B
	revoke = A

	var/list/unite = grant + revoke
	if(!unite || !unite.len)
		.["content"] = "Сюда пришло изменение вайтлиста, но мы потеряли список."
		return
	var/list/fields = list()
	unite = sortList(unite)		//sorting by ckey
	for(var/ckey in unite)
		var/list/check = unite[ckey]
		check = sortList(check)	//sorting by race
		var/list/text
		for(var/race in check)
			text += race
		fields += list(list(
			"name" = ckey,
			"value" = jointext(text, "\n\t")
		))
	if(fields && fields.len)
		desc["fields"] = list(fields)
	.["embeds"] = list(desc)