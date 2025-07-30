local shortcut = {
	type = "shortcut",
	name = "auto-lamp-shortcut",
	order = "b[blueprints]-s[auto-lamp-tool]",
	action = "spawn-item",
	item_to_spawn = "auto-lamp-tool",
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
local selector = {
	type = "selection-tool",
	select = select_mode,
	alt_select = select_mode,
	reverse_select = reverse_mode,
	alt_reverse_select = reverse_mode,
	name = "auto-lamp-tool",
	icons = {
		{
			icon = data.raw["upgrade-item"]["upgrade-planner"].icon
		},
		{
			icon = data.raw["item"]["big-electric-pole"].icon,
			scale = 0.3125,
			shift = {-4, -2}
		},
		{
			icon = data.raw["item"]["small-lamp"].icon,
			scale = 0.25,
			shift = {4, 4}
		}
	},
	flags = {"only-in-cursor", "spawnable"},
	subgroup = "tool",
	order = "c[automated-construction]-b[auto-lamp-tool]",
	stack_size = 1,
	stackable = false
}
local key_sequence = {
	name = "give-auto-lamp-tool",
	type = "custom-input",
	key_sequence = "SHIFT + L",
	action = "spawn-item",
	item_to_spawn = "auto-lamp-tool",
	consuming = "none",
	order = "b"
}

data.extend({shortcut, selector, key_sequence})
