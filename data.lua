local shortcut = {
	type = "shortcut",
	name = "auto-lamp-shortcut",
	order = "a",
	action = "lua",
	style = "default",
	icon = data.raw["item"]["small-lamp"].icon,
	small_icon = data.raw["item"]["small-lamp"].icon,
}
local select_mode = {
	mode = {"any-entity"},
	border_color = {r = 1, g = 1, b = 1},
	cursor_box_type = "pair",
	entity_type_filters = {"electric-pole", "lamp"}
}
local reverse_mode = {
	mode = {"any-entity"},
	border_color = {r = 1, g = 1, b = 0},
	cursor_box_type = "pair",
	entity_type_filters = {"lamp"}
}
local selector =	 {
	type = "selection-tool",
	select = select_mode,
	alt_select = select_mode,
	reverse_select = reverse_mode,
	alt_reverse_select = reverse_mode,
	name = "auto-lamp-tool",
	icon = data.raw["item"]["small-lamp"].icon,
	flags = {"only-in-cursor"},
	subgroup = "tool",
	order = "c[automated-construction]-b[deconstruction-planner]",
	stack_size = 1,
	stackable = false,
}

data.extend({shortcut, selector})
