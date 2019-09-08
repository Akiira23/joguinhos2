--modulo para mexer nos tiles das layers

local layerTls = {}

function layerTls.getLayerTilePosition(layer, tile, x, y, self)
   local tileW = self.tilewidth
   local tileH = self.tileheight
   local tileX, tileY

   if self.orientation ~= nil then
      tileX = (x - y) * (tileW / 2) + tile.offset.x + layer.width * tileW / 2 - self.tilewidth / 2
      tileY = (x + y - 2) * (tileH / 2) + tile.offset.y
   end

   return tileX, tileY
end

function layerTls.addNewLayerTile(layer, tile, x, y, self)
   local tileset = tile.tileset
   local image = self.tilesets[tile.tileset].image

   local batches = layer.batches
   local size = layer.width * layer.height

   batches[tileset] = batches[tileset] or love.graphics.newSpriteBatch(image, size)

   local batch = batches[tileset]
   local tileX, tileY = layerTls.getLayerTilePosition(layer, tile, x, y, self)

   local instance = {
      layer = layer,
      gid   = tile.gid,
      x     = tileX,
      y     = tileY,
      r     = tile.r,
      oy    = 0
   }

   if batch then
      instance.batch = batch
      instance.id = batch:add(tile.quad, tileX, tileY, tile.r, tile.sx, tile.sy)
   end

   self.tileInstances[tile.gid] = self.tileInstances[tile.gid] or {}
   table.insert(self.tileInstances[tile.gid], instance)
end

return layerTls
