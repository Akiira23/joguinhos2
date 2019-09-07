-- modulo para os desenhar os objetos das layers

local drawObj = {}

function drawObj.drawObjectLayer(layer)
   if type(layer) == "string" or type(layer) == "number" then
      layer = self.layers[layer]
   end
   if layer.type ~= "objectgroup" then
      print ("Tipo de layer invalido: nao e objectgroup.")
   end

   local r,g,b,a = love.graphics.getColor()
   local color = {r, g, b, a*layer.opacity}

   love.graphics.setColor(color)
end

return drawObj