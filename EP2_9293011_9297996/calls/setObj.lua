-- modulo para inicializar os objetos para o desenho

local setObj = {}

function setObj.convert_to_isometric(map, x, y)
   local mapH    = map.height
   local tileW   = map.tilewidth
   local tileH   = map.tileheight
   local tileX   = x / tileH
   local tileY   = y / tileH
   local offsetX = mapH * tileW / 2

   return
      (tileX - tileY) * tileW / 2 + offsetX,
      (tileX + tileY) * tileH / 2
end

function setObj.rotate_vertex(map, vertex, x, y, cos, sin, oy)
   if map.orientation == "isometric" then
      x, y               = setObj.convert_to_isometric(map, x, y)
      vertex.x, vertex.y = setObj.convert_to_isometric(map, vertex.x, vertex.y)
   end
   vertex.x = vertex.x - x
   vertex.y = vertex.y - y
   return
      x + cos * vertex.x - sin * vertex.y,
      y + sin * vertex.x + cos * vertex.y - (oy or 0)
end

function setObj.setObjectCoordinates(layer, self)
   for _, object in ipairs(layer.objects) do
      local x = layer.x + object.x
      local y = layer.y + object.y
      local w = object.width
      local h = object.height
      local cos = math.cos(math.rad(object.rotation))
      local sin = math.sin(math.rad(object.rotation))

      if object.shape == "rectangle" and not object.gid then
         object.rectangle = {}

         local vertices = {
            {x = x, y = y},
            {x = x + w, y = y},
            {x = x + w, y = y + h},
            {x = x, y = y + h},
         }

         for _, vertex in ipairs(vertices) do
            vertex.x, vertex.y = setObj.rotate_vertex(self, vertex, x, y, cos, sin)
            table.insert(object.rectangle, { x = vertex.x, y = vertex.y })
         end
      end
   end
end

function setObj.setObjectSpriteBatches(layer)
   local newBatch = love.graphics.newSpriteBatch
   local batches  = {}
   layer.batches = batches
end

function setObj.setObjectData(layer, self)
   for _, object in ipairs(layer.objects) do
      object.layer = layer
      self.objects[object.id] = object
   end
end

return setObj