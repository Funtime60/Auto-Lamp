poleQueue = {}
spotQueue = {}

local function on_shortcut(event)
	if event.prototype_name == "auto-lamp-shortcut" then
		local player = game.players[event.player_index]
		player.cursor_stack.set_stack({name = "auto-lamp-tool"})
		player.cursor_stack_temporary = true
	end
end

local function on_drop(event)
	if event.entity and event.entity.stack and event.entity.stack.name == "auto-lamp-tool" then
		event.entity.stack.clear()
	end
end

local function on_area_selected(event)
	if event.item ~= "auto-lamp-tool" then
		return
	end
	
	local player = game.players[event.player_index]
	local surface = player.surface
	
	local player_settings = settings.get_player_settings(player)
	local lamp_distance   = player_settings["auto-lamp-distance"].value --TODO Convert this to a map setting, I can't get the calling player here and don't feel like storing it.
	
	local electric = surface.find_entities_filtered({area = event.area, type = "electric-pole", force = player.force})
	for _, entity in pairs(electric) do
		poleQueue["UN"..entity.unit_number] = {entity = entity, lamp_distance = lamp_distance, player_name = player.name}
	end
end

local function on_reverse_selected(event)
	if event.item ~= "auto-lamp-tool" then
		return
	end

	local player = game.players[event.player_index]
	local surface = player.surface

	local lamps = surface.find_entities_filtered({area = event.area, type = "lamp", force = player.force})
	for _, entity in pairs(lamps) do
		player.print(serpent.block(entity))
	end
end

local function on_tick(event)
	local _, spot   = next(spotQueue)
	if spot then
		local continue = false

		local parent   = spot.parent
		local surface  = parent.surface
		local force    = parent.force
		local position = {spot.x, spot.y}
		local distance = spot.distance
		local player   = spot.player

		if parent.valid and surface.can_place_entity({name = "small-lamp", position = position, force = force}) and surface.count_entities_filtered({position = position, radius = distance, type = "lamp"}) == 0 and surface.count_entities_filtered({position = position, radius = distance, ghost_type = "lamp"}) == 0 then
			surface.create_entity({name = "entity-ghost", inner_name = "small-lamp", expires = false, position = position, force = force, player = player})
		else
			continue = true
		end
		
		spotQueue[spot.x..":"..spot.y] = nil
		if continue then
			on_tick(event)
		end
	else
		local _, wrapper = next(poleQueue)
		if wrapper then
			local entity        = wrapper.entity
			local lamp_distance = wrapper.lamp_distance
			local player_name   = wrapper.player_name
			if entity.valid then
				local supply_area = entity.prototype.get_supply_area_distance(entity.quality)
				local entity_size = math.abs(entity.prototype.selection_box.left_top.x * 2)
				local position    = entity.position
				for x = position.x - supply_area + 0.5, position.x + supply_area do
					for y = position.y - supply_area + 0.5, position.y + supply_area do
						if math.abs(x - position.x) * 2 > entity_size or math.abs(y - position.y) * 2 > entity_size then
							if not spotQueue[x..":"..y] then
								spotQueue[x..":"..y] = {x = x, y = y, parent = entity, distance = lamp_distance, player = player_name}
							end
						end
					end
				end
				-- game.players[1].print("Tick: "..event.tick.." | Unit Number - "..entity.unit_number.." -> "..serpent.block(supply_area))
			end
			poleQueue["UN"..entity.unit_number] = nil
		end
	end
end

script.on_event(defines.events.on_lua_shortcut, on_shortcut)
script.on_event(defines.events.on_tick, on_tick)
script.on_event(defines.events.on_player_selected_area, on_area_selected)
script.on_event(defines.events.on_player_alt_selected_area, on_area_selected)
script.on_event(defines.events.on_player_reverse_selected_area, on_reverse_selected)
script.on_event(defines.events.on_player_alt_reverse_selected_area, on_reverse_selected)
script.on_event(defines.events.on_player_dropped_item, on_drop)
