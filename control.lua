PoleQueue = {}
SpotQueue = {}

local function get_member_safe(object, field)
	local call_result, value = pcall( function () return object[field] end )
	if call_result then
		return value
	else
		return nil
	end
end

local function on_area_selected(event)
	if event.item ~= "auto-lamp-tool" then
		return
	end
	
	local player = game.players[event.player_index]
	
	local player_settings = settings.get_player_settings(player)
	local lamp_distance   = player_settings["auto-lamp-distance"].value
	
	for _, entity in pairs(event.entities) do
		if not entity.to_be_deconstructed() and (entity.type == "electric-pole" or entity.type == "entity-ghost" and entity.ghost_type == "electric-pole") then
			PoleQueue["UN"..entity.unit_number] = {entity = entity, lamp_distance = lamp_distance, player = player, tick = event.tick}
		end
	end
end

local function on_reverse_selected(event)
	if event.item ~= "auto-lamp-tool" then
		return
	end

	local player = game.players[event.player_index]

	local newUndoIndex = 0
	for _, entity in pairs(event.entities) do
		if entity.type == "lamp" and not entity.is_connected_to_electric_network() then
			entity.order_deconstruction(player.force, player, newUndoIndex)
			newUndoIndex = 1
		end
	end
end

local function on_tick(event)
	local _, spot   = next(SpotQueue)
	if spot then
		local continue = false

		local parent   = spot.parent
		local surface  = parent.surface
		local force    = parent.force
		local position = {spot.x, spot.y}
		local distance = spot.distance
		local player   = spot.player
		local tick = spot.tick

		local can_place = surface.can_place_entity({name = "small-lamp", position = position, force = force, build_check_type=defines.build_check_type.manual_ghost})
		local lamp_conflicts = surface.count_entities_filtered({position = position, radius = distance, type = "lamp", to_be_deconstructed = false})
		local ghost_conflicts = surface.count_entities_filtered({position = position, radius = distance, ghost_type = "lamp"})
		-- player.print(serpent.block(can_place)..":"..serpent.block(lamp_conflicts)..":"..serpent.block(ghost_conflicts))

		local undo_stack = player.undo_redo_stack

		if parent.valid and can_place and lamp_conflicts == 0 and ghost_conflicts == 0 then
			local undo_index = 0
			for index = 1, undo_stack.get_undo_item_count() do
				if undo_stack.get_undo_tag(index, 1, "auto-lamp-tool") and undo_stack.get_undo_tag(index, 1, "auto-lamp-tool") == player.name..":"..tick then
					undo_index = index
					break
				end
			end
			surface.create_entity({name = "entity-ghost", inner_name = "small-lamp", expires = false, position = position, force = force, player = player, undo_index = undo_index})
			if undo_index == 0 then
				player.undo_redo_stack.set_undo_tag(1, 1, "auto-lamp-tool", player.name..":"..tick)
			end
		else
			continue = true
		end
		
		SpotQueue[spot.x..":"..spot.y] = nil
		if continue then
			on_tick(event)
		end
	else
		local _, wrapper = next(PoleQueue)
		if wrapper then
			local entity        = wrapper.entity
			local lamp_distance = wrapper.lamp_distance
			local player        = wrapper.player
			local tick = wrapper.tick
			if entity.valid then
				local prototype = entity.prototype
				if entity.type == "entity-ghost" then
					prototype = entity.ghost_prototype
				end
				local supply_area = prototype.get_supply_area_distance(entity.quality)
				local entity_size = math.abs(prototype.selection_box.left_top.x * 2)
				local position    = entity.position
				for x = position.x - supply_area + 0.5, position.x + supply_area do
					for y = position.y - supply_area + 0.5, position.y + supply_area do
						if math.abs(x - position.x) * 2 > entity_size or math.abs(y - position.y) * 2 > entity_size then
							if not SpotQueue[x..":"..y] then
								SpotQueue[x..":"..y] = {x = x, y = y, parent = entity, distance = lamp_distance, player = player, tick = tick}
							end
						end
					end
				end
				-- player.print("Tick: "..event.tick.." | Unit Number - "..entity.unit_number.." -> "..serpent.block(supply_area))
			end
			PoleQueue["UN"..entity.unit_number] = nil
		end
	end
end

script.on_event(defines.events.on_tick, on_tick)
script.on_event(defines.events.on_player_selected_area, on_area_selected)
script.on_event(defines.events.on_player_alt_selected_area, on_area_selected)
script.on_event(defines.events.on_player_reverse_selected_area, on_reverse_selected)
script.on_event(defines.events.on_player_alt_reverse_selected_area, on_reverse_selected)
