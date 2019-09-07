-- modulo para os desenhar os tiles das layers

local drawTls = {}

function drawTls.drawTileLayer(layer, self)
   if type(layer) == nil then
      layer = self.layers[layer]
   end

   if layer.type ~= "tilelayer" then
      print ("Tipo de layer invalido: is not tilelayer")
   end

   for _, batch in pairs(layer.batches) do
      love.graphics.draw(batch, math.floor(layer.x), math.floor(layer.y))
   end
end

return drawTls