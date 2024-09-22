local sprite_layer_names = { "stone", "sleepers", "metals", "signals", "collisions" }
local sprite_layer_indices = { stone = 1, sleepers = 2, metals = 3, signals = 4, collisions = 5 }

---@class elevated_sprite_layer
---@field name string name of the layer
---@field yshift number? number of tiles to shift the layer graphics vertically
---@field bottom boolean? place this layer at the bottom of the stack
---@field shadow boolean? set the draw_as_shadow field for this layer
---@field fileprefix string? alternate filename prefix to use instead of layer name

---@type elevated_sprite_layer[]
local elevated_sprite_layers = {
  { name = "shadow", yshift = 3, bottom = true, shadow = true, fileprefix = "stone" },
  { name = "connections" },
  { name = "fences", yshift = -0.5 },
}

---@param name string
---@param icon string
---@return { [1] : data.RecipePrototype, [2] : data.ItemPrototype }
local function get_recipe_and_item_prototypes(name, icon)
  return
    {
      {
        type = "recipe",
        name = name,
        enabled = true,
        result = name,
        ingredients = {},
      },
      {
        type = "item",
        name = name,
        icon = icon,
        icon_size = 64,
        place_result = name,
        stack_size = 100,
      },
    }
end

---@param name string
---@param icon data.FileName
---@param selection_size { [1]: number, [2]: number }
---@param collision_size { [1]: number, [2]: number }?
---@return data.SimpleEntityWithOwnerPrototype
local function get_entity_prototype(name, icon, selection_size, collision_size)
  ---@type data.SimpleEntityWithOwnerPrototype
  entity = table.deepcopy(data.raw["simple-entity-with-owner"]["simple-entity-with-owner"])
  if selection_size == nil then
    selection_size = {2,2}
    collision_size = {1.8,1.8}
  end
  collision_size = collision_size or selection_size
  entity.minable = {hardness = 0.1, mining_time = 0.5, result = name}
  entity.name = name
  entity.icon = icon
  entity.max_health = 1000
  entity.collision_mask = {}
  entity.build_grid_size = 2
  entity.collision_box = {{-collision_size[1]/2, -collision_size[2]/2}, {collision_size[1]/2, collision_size[2]/2}}
  entity.selection_box = {{-selection_size[1]/2, -selection_size[2]/2}, {selection_size[1]/2, selection_size[2]/2}}
  entity.flags = {"placeable-neutral", "player-creation"}
  return entity
end

---Update a prototype to convert from grounded to elevated: shift sprites, add layers for shadow, connections, fences
---@param entity data.SimpleEntityWithOwnerPrototype
local function elevate(entity)
  ---@type data.Sprite4Way.struct
  local picture = entity.picture--[[@as data.Sprite4Way.struct]]
  ---@type string, data.Sprite
  for _, sprite in pairs(picture--[=[@as table<string, data.Sprite>]=]) do
    if sprite.layers then
      for layer_index, layer in pairs(sprite.layers) do
        if layer_index ~= sprite_layer_indices["collisions"] then
          if layer.shift ~= nil then
            layer.shift[2] = layer.shift[2] - 3
          else
            layer.shift = {0, -3}
          end
        end
      end
      orig_bottom_layer = 1
      for i, layer_def in pairs(elevated_sprite_layers) do
        local new_layer = table.deepcopy(sprite.layers[orig_bottom_layer])
        new_layer.shift[2] = new_layer.shift[2] + (layer_def["yshift"] and layer_def["yshift"] or 0)
        new_layer.draw_as_shadow = layer_def["shadow"]
        new_layer.filename = new_layer.filename:gsub("entity/" .. sprite_layer_names[1] .. "%-", "entity/" .. ( layer_def["fileprefix"] or layer_def["name"] ).. "-")
        if layer_def["bottom"] then
          table.insert(sprite.layers, 1, new_layer)
          orig_bottom_layer = orig_bottom_layer + 1
        else
          table.insert(sprite.layers, sprite_layer_indices["collisions"], new_layer) -- collisions stay on top
        end
      end
      sprite.layers[orig_bottom_layer].tint = {r=1, g=0.75, b=0.75, a=1}
    else
      if sprite.shift ~= nil then
        if sprite.shift.y then
          sprite.shift.y = sprite.shift.y - 3
        else
          sprite.shift[2] = sprite.shift[2] - 3
        end
      else
        sprite.shift = {x=0, y=-3}
      end
    end
  end
  entity.render_layer = "higher-object-above"
  -- not allowed in current Factorio
  -- entity.selection_box[1][2] = entity.selection_box[1][2] - 3
  -- entity.selection_box[2][2] = entity.selection_box[2][2] - 3
end


---Get a set of layers for a sprite that come from files named for a specific layer
---@param layer data.Sprite
---@return data.Sprite[]
local function get_sprite_layers(layer)
  local layers = {}
  for _, layer_name in pairs(sprite_layer_names) do
    local new_layer = table.deepcopy(layer)
    new_layer.filename = new_layer.filename:gsub("entity/","entity/" .. layer_name .. "-")
    table.insert(layers, new_layer)
  end
  return layers
end


---@type string, string
local name, icon
---@type data.SimpleEntityWithOwnerPrototype
local entity


-- every rail gets generated with elevated and non-elevated versions
for elevation_id, elevation_name in pairs({"lo", "hi"}) do

  -- straight north/south and east/west rails
  name = "fake-rail-" .. elevation_name .. "-orthogonal"
  icon = "__fake-new-rails__/graphics/entity/stone-orthogonal-1.png"
  data:extend(get_recipe_and_item_prototypes(name, icon))
  entity = get_entity_prototype(name, icon, {2.57, 1.8}, {1.98, 1.4})
  entity.picture = {
    north = { layers = get_sprite_layers( {
      filename = "__fake-new-rails__/graphics/entity/orthogonal-1.png",
      width = 80,
      height = 112,
      shift = {0, 0},
    } ) },
    east = { layers = get_sprite_layers( {
      filename = "__fake-new-rails__/graphics/entity/orthogonal-2.png",
      width = 112,
      height = 80,
      shift = {0, 0},
    } ) },
  }
  entity.picture.south = table.deepcopy(entity.picture.north)
  entity.picture.west = table.deepcopy(entity.picture.east)
  if elevation_id == 2 then
    elevate(entity)
  end
  data:extend({entity})

  -- straight 45-degree diagonal rails
  name = "fake-rail-" .. elevation_name .. "-diagonal"
  icon = "__fake-new-rails__/graphics/entity/stone-diagonal-1.png"
  data:extend(get_recipe_and_item_prototypes(name, icon))
  entity = get_entity_prototype(name, icon, {2,2})
  entity.build_grid_size = 2
  entity.tile_width = 4
  entity.tile_height = 4
  -- local offset = 11/32
  entity.picture = {
    north = { layers = get_sprite_layers( {
      filename = "__fake-new-rails__/graphics/entity/diagonal-1.png",
      width = 112,
      height = 112,
      -- shift = {offset, -offset},
    } ) },
    east = { layers = get_sprite_layers( {
      filename = "__fake-new-rails__/graphics/entity/diagonal-2.png",
      width = 112,
      height = 112,
      -- shift = {offset, offset},
    } ) },
  }
  entity.picture.south = table.deepcopy(entity.picture.north)
  entity.picture.west = table.deepcopy(entity.picture.east)
  if elevation_id == 2 then
    elevate(entity)
  end
  data:extend({entity})

  -- straight ~26-degree half-diagonal rails
  for flip=1,2 do
    name = "fake-rail-" .. elevation_name .. "-half-diagonal-" .. flip
    icon = "__fake-new-rails__/graphics/entity/stone-half-diagonal-" .. (flip*2-1) .. ".png"
    data:extend(get_recipe_and_item_prototypes(name, icon))
    entity = get_entity_prototype(name, icon, {2,2})
    entity.picture = {
      north = { layers = get_sprite_layers( {
        filename = "__fake-new-rails__/graphics/entity/half-diagonal-" .. (flip*2-1) .. ".png",
        width = 160,
        height = 112,
      } ) },
      east = { layers = get_sprite_layers( {
          filename = "__fake-new-rails__/graphics/entity/half-diagonal-" .. (flip*2) .. ".png",
        width = 112,
        height = 160,
      } ) },
    }
    entity.picture.south = table.deepcopy(entity.picture.north)
    entity.picture.west = table.deepcopy(entity.picture.east)
    if elevation_id == 2 then
      elevate(entity)
    end
    data:extend({entity})
  end

  -- curves
  for _, curve_type in pairs({"orthogonal", "diagonal"}) do
    for flip=1,2 do
      -- look at bottom of ramp-east for fuckup that cascaded into these and maybe also orthogonal
      name = "fake-rail-" .. elevation_name .. "-" .. curve_type .. "-to-half-diagonal-" .. flip
      icon = "__fake-new-rails__/graphics/entity/stone-" .. curve_type .. "-to-half-diagonal-" .. ((flip-1)*4+1) .. ".png"
      data:extend(get_recipe_and_item_prototypes(name, icon))
      entity = get_entity_prototype(name, icon, {curve_type == "orthogonal" and 4 or 2,2})
      entity.picture = {
        north = { layers = get_sprite_layers( {
          filename = "__fake-new-rails__/graphics/entity/" .. curve_type .. "-to-half-diagonal-" .. ((flip-1)*4+1) .. ".png",
          width = curve_type == "diagonal" and 168 or 182,
          height = curve_type == "diagonal" and 144 or 112,
          shift = curve_type == "diagonal" and {flip == 1 and -1/8 or 1/8, -1/2} or {flip == 1 and -19/32 or 19/32, 0},
        } ) },
        east = { layers = get_sprite_layers( {
          filename = "__fake-new-rails__/graphics/entity/" .. curve_type .. "-to-half-diagonal-" .. ((flip-1)*4+2) .. ".png",
          width = curve_type == "diagonal" and 144 or 112,
          height = curve_type == "diagonal" and 168 or 182,
          shift = curve_type == "diagonal" and {1/2, flip == 1 and -1/8 or 1/8} or {0, flip == 1 and -19/32 or 19/32},
        } ) },
        south = { layers = get_sprite_layers( {
          filename = "__fake-new-rails__/graphics/entity/" .. curve_type .. "-to-half-diagonal-" .. ((flip-1)*4+3) .. ".png",
          width = curve_type == "diagonal" and 168 or 182,
          height = curve_type == "diagonal" and 144 or 112,
          shift = curve_type == "diagonal" and {flip == 1 and 1/8 or -1/8, 1/2} or {flip == 1 and 19/32 or -19/32, 0},
        } ) },
        west = { layers = get_sprite_layers( {
            filename = "__fake-new-rails__/graphics/entity/" .. curve_type .. "-to-half-diagonal-" .. ((flip-1)*4+4) .. ".png",
          width = curve_type == "diagonal" and 144 or 112,
          height = curve_type == "diagonal" and 168 or 182,
          shift = curve_type == "diagonal" and {-1/2, flip == 1 and 1/8 or -1/8} or {0, flip == 1 and 19/32 or -19/32},
        } ) },
      }
      if elevation_id == 2 then
        elevate(entity)
      end
      data:extend({entity})
    end
  end

end

-- ramps
name = "fake-rail-ramp"
icon = "__fake-new-rails__/graphics/entity/ramp-east.png"
data:extend(get_recipe_and_item_prototypes(name, icon))
entity = get_entity_prototype(name, icon, {4,16}, {3.6, 15.6})
entity.tile_width = 2
entity.picture = {
  north = {
    filename = "__fake-new-rails__/graphics/entity/ramp-north.png",
    width = 128,
    height = 640,
    shift = {0, -2.0},
  },
  east = {
    filename = "__fake-new-rails__/graphics/entity/ramp-east.png",
    width = 512,
    height = 208,
    shift = {0, -1.25},
  },
  south = {
    filename = "__fake-new-rails__/graphics/entity/ramp-south.png",
    width = 128,
    height = 544,
    shift = {0, -0.5},
  },
  west = {
    filename = "__fake-new-rails__/graphics/entity/ramp-west.png",
    width = 512,
    height = 208,
    shift = {0, -1.25},
  },
}
data:extend({entity})

-- support
name = "fake-rail-support"
icon = "__fake-new-rails__/graphics/entity/support.png"
data:extend(get_recipe_and_item_prototypes(name, icon))
entity = get_entity_prototype(name, icon, {3,3}, {2.8, 2.8})
entity.tile_height = 4
entity.tile_width = 4
entity.build_grid_size = 1
entity.picture = {
  filename = "__fake-new-rails__/graphics/entity/support.png",
  width = 128,
  height = 200,
  shift = {0, -1.125},
}
data:extend({entity})

local signal_sprite_directions_info = {
  {"north", {x=1,y=0}},
  {"east", {x=0,y=1}},
  {"south", {x=-2,y=0}},
  {"west", {x=0,y=-2}}
}

-- signals
-- elevated and non-elevated versions
for elevation_id, elevation_name in pairs({"lo", "hi"}) do
  for _, signal_info in pairs({{96, "rail-signal"}, {160, "rail-chain-signal"}}) do
    local signal_sprite_size = signal_info[1]
    local signal_name = signal_info[2]
    name = "fake-" .. signal_name .. "-" .. elevation_name
    icon = "__base__/graphics/icons/" .. signal_name .. ".png"
    data:extend(get_recipe_and_item_prototypes(name, icon))
    entity = get_entity_prototype(name, icon, {1,1}, {0.4, 0.4})
    entity.build_grid_size = 1
    for index, sprite_info in pairs(signal_sprite_directions_info) do
      local sprite_direction = sprite_info[1]
      entity.picture[sprite_direction] = {
        filename = "__base__/graphics/entity/" .. signal_name .. "/" .. signal_name .. ".png",
        width = signal_sprite_size,
        height = signal_sprite_size,
        x = signal_name == "rail-chain-signal" and 480 or 0, -- green chain signals in fourth column
        y = (index - 1) * signal_sprite_size * 2,
        shift = signal_name == "rail-chain-signal" and table.deepcopy(sprite_info[2]) or nil -- chain signals are off center
      }
    end
    if elevation_id == 2 then
      elevate(entity)
    end
    data:extend({entity})
  end
end
