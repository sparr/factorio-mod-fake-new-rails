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

local function get_entity_prototype(name, icon, size)
  local entity = table.deepcopy(data.raw["simple-entity-with-owner"]["simple-entity-with-owner"])
  entity.minable = {hardness = 0.1, mining_time = 0.5, result = name}
  entity.name = name
  entity.icon = icon
  entity.max_health = 1000
  entity.collision_mask = {} -- so they can overlap with each other
  entity.build_grid_size = 2
  entity.collision_box = {{-size[1]/2+0.1, -size[2]/2+0.1}, {size[1]/2-0.1, size[2]/2-0.1}}
  entity.selection_box = {{-size[1]/2, -size[2]/2}, {size[1]/2, size[2]/2}}
  return entity
end

local function elevate(entity)
  local picture = entity.picture
  for _, sprite in pairs(picture) do
    for _, layer in pairs(sprite.layers) do
      if layer.shift ~= nil then
        layer.shift[2] = layer.shift[2] - 3
      else
        layer.shift = {0, -3}
      end
    end
    local shadow_layer = table.deepcopy(sprite.layers[1])
    shadow_layer.shift[2] = shadow_layer.shift[2] + 3
    shadow_layer.draw_as_shadow = true
    table.insert(sprite.layers, 1, shadow_layer)
    local fences_layer = table.deepcopy(sprite.layers[2])
    fences_layer.filename = fences_layer.filename:gsub("entity/stone%-", "entity/fences-")
    fences_layer.shift[2] = fences_layer.shift[2] - 0.5
    table.insert(sprite.layers, fences_layer)
    local connections_layer = table.deepcopy(sprite.layers[2])
    connections_layer.filename = connections_layer.filename:gsub("entity/stone%-", "entity/connections-")
    table.insert(sprite.layers, connections_layer)
  end
  -- not allowed in current Factorio
  -- entity.selection_box[1][2] = entity.selection_box[1][2] - 3
  -- entity.selection_box[2][2] = entity.selection_box[2][2] - 3
end

local function sprite_layers(layer)
  local layers = {}
  for _, layer_name in pairs({"stone", "sleepers", "metals", "signals"}) do
    local new_layer = table.deepcopy(layer)
    new_layer.filename = new_layer.filename:gsub("entity/","entity/" .. layer_name .. "-")
    table.insert(layers, new_layer)
  end
  return layers
end

for elevation_id, elevation_name in pairs({"lo", "hi"}) do

  -- straight north/south and east/west rails
  local name = "fake-rail-" .. elevation_name .. "-orthogonal"
  local icon = "__fake-new-rails__/graphics/entity/stone-orthogonal-1.png"
  data:extend(get_recipe_and_item_prototypes(name, icon))
  local entity = get_entity_prototype(name, icon, {2,2})
  entity.picture = {
    north = { layers = sprite_layers( {
      filename = "__fake-new-rails__/graphics/entity/orthogonal-1.png",
      width = 80,
      height = 112,
      shift = {0, 0},
    } ) },
    east = { layers = sprite_layers( {
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
  local name = "fake-rail-" .. elevation_name .. "-diagonal"
  local icon = "__fake-new-rails__/graphics/entity/stone-diagonal-1.png"
  data:extend(get_recipe_and_item_prototypes(name, icon))
  local entity = get_entity_prototype(name, icon, {2,2})
  entity.build_grid_size = 1
  -- local offset = 11/32
  entity.picture = {
    north = { layers = sprite_layers( {
      filename = "__fake-new-rails__/graphics/entity/diagonal-1.png",
      width = 112,
      height = 112,
      -- shift = {offset, -offset},
    } ) },
    east = { layers = sprite_layers( {
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
    local name = "fake-rail-" .. elevation_name .. "-half-diagonal-" .. flip
    local icon = "__fake-new-rails__/graphics/entity/stone-half-diagonal-" .. (flip*2-1) .. ".png"
    data:extend(get_recipe_and_item_prototypes(name, icon))
    local entity = get_entity_prototype(name, icon, {2,2})
    entity.picture = {
      north = { layers = sprite_layers( {
        filename = "__fake-new-rails__/graphics/entity/half-diagonal-" .. (flip*2-1) .. ".png",
        width = 160,
        height = 112,
      } ) },
      east = { layers = sprite_layers( {
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
      local name = "fake-rail-" .. elevation_name .. "-" .. curve_type .. "-to-half-diagonal-" .. flip
      local icon = "__fake-new-rails__/graphics/entity/stone-" .. curve_type .. "-to-half-diagonal-" .. ((flip-1)*4+1) .. ".png"
      data:extend(get_recipe_and_item_prototypes(name, icon))
      local entity = get_entity_prototype(name, icon, {curve_type == "orthogonal" and 4 or 2,2})
      entity.picture = {
        north = { layers = sprite_layers( {
          filename = "__fake-new-rails__/graphics/entity/" .. curve_type .. "-to-half-diagonal-" .. ((flip-1)*4+1) .. ".png",
          width = curve_type == "diagonal" and 168 or 182,
          height = curve_type == "diagonal" and 144 or 112,
          shift = curve_type == "diagonal" and {flip == 1 and -1/8 or 1/8, -1/2} or {flip == 1 and -19/32 or 19/32, 0},
        } ) },
        east = { layers = sprite_layers( {
          filename = "__fake-new-rails__/graphics/entity/" .. curve_type .. "-to-half-diagonal-" .. ((flip-1)*4+2) .. ".png",
          width = curve_type == "diagonal" and 144 or 112,
          height = curve_type == "diagonal" and 168 or 182,
          shift = curve_type == "diagonal" and {1/2, flip == 1 and -1/8 or 1/8} or {0, flip == 1 and -19/32 or 19/32},
        } ) },
        south = { layers = sprite_layers( {
          filename = "__fake-new-rails__/graphics/entity/" .. curve_type .. "-to-half-diagonal-" .. ((flip-1)*4+3) .. ".png",
          width = curve_type == "diagonal" and 168 or 182,
          height = curve_type == "diagonal" and 144 or 112,
          shift = curve_type == "diagonal" and {flip == 1 and 1/8 or -1/8, 1/2} or {flip == 1 and 19/32 or -19/32, 0},
        } ) },
        west = { layers = sprite_layers( {
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
local name = "fake-rail-ramp"
local icon = "__fake-new-rails__/graphics/entity/ramp-east.png"
data:extend(get_recipe_and_item_prototypes(name, icon))
local entity = get_entity_prototype(name, icon, {2,16})
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
local name = "fake-rail-support"
local icon = "__fake-new-rails__/graphics/entity/support.png"
data:extend(get_recipe_and_item_prototypes(name, icon))
local entity = get_entity_prototype(name, icon, {2,2})
entity.build_grid_size = 1
entity.picture = {
  filename = "__fake-new-rails__/graphics/entity/support.png",
  width = 128,
  height = 200,
  shift = {0, -1.125},
}
data:extend({entity})
