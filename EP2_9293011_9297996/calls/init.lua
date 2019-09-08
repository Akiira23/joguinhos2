--modulo para a inicializacao das funcoes necessarias para realizar os desenhos nas telas

local CALLS = {
   cache = {}
}

local cwd = (...):gsub('%.init$', '') .. "."
local setTls = require(cwd .. "setTls")
local layerTls = require(cwd .. "layerTls")
local drawTls = require(cwd .. "drawTls")
local setObj = require(cwd .. "setObj")
local drawObj = require(cwd .. "drawObj")
local Map = {}
Map.__index = Map

local function new(map, ox, oy)
   local dir = ""
   if type(map) == "table" then
      map = setmetatable(map, Map)
   else
      local ext = map:sub(-4, -1)
      assert(ext == ".lua", string.format(
         "Tipo invalido: %s. deve ser .lua.",
         ext
      ))
      dir = map:reverse():find("[/\\]")
      if dir ~= nil then
         dir = map:sub(1, 1 + (#map - dir))
      end
      map = setmetatable(assert(love.filesystem.load(map))(), Map)
   end
   map:init(dir, ox, oy)
   return map
end

function CALLS.__call(_, map, ox, oy)
   return new(map, ox, oy)
end

function Map:init(path, ox, oy)
   self:resize()
   self.objects       = {}
   self.tiles         = {}
   self.tileInstances = {}
   self.drawRange     = {
      sx = 1,
      sy = 1,
      ex = self.width,
      ey = self.height,
   }
   self.offsetx = ox or 0
   self.offsety = oy or 0

   self.freeBatchSprites = {}
   setmetatable(self.freeBatchSprites, { __mode = 'k' })

   local gid = 1
   for i, tileset in ipairs(self.tilesets) do
      assert(tileset.image, "tilests image not found.")
      if love.graphics.isCreated then
         local formatted_path = (path .."/".. tileset.image)

         if not CALLS.cache[formatted_path] then
            tileset.image = love.graphics.newImage(love.image.newImageData(formatted_path))
            CALLS.cache[formatted_path] = tileset.image
         else
            tileset.image = CALLS.cache[formatted_path]
         end
      end

      local bg = self.backgroundcolor
      gid = setTls.setTiles(i, tileset, gid, bg, self)
   end
   local layers = {}
   for _, layer in ipairs(self.layers) do
      table.insert(layers, layer)
   end
   self.layers = layers
   for _, layer in ipairs(self.layers) do
      self:setLayer(layer, path)
   end
end

function Map:set_batches(layer)
   layer.batches = {}
   --right-down default
   if self.orientation ~= nil then
      local startX = 1
      local startY = 1
      local endX = layer.width
      local endY = layer.height
      local incrementX = 1
      local incrementY = 1
      if self.renderorder == "right-up" then
         startY, endY, incrementY = endY, startY, -1
      elseif self.renderorder == "left-down" then
         startX, endX, incrementX = endX, startX, -1
      elseif self.renderorder == "left-up" then
         startX, endX, incrementX = endX, startX, -1
         startY, endY, incrementY = endY, startY, -1
      end
      for y = startY, endY, incrementY do
         for x = startX, endX, incrementX do
            local tile
               tile = layer.data[y][x]
            if tile then
               layerTls.addNewLayerTile(layer, tile, x, y, self)
            end
         end
      end
   end
end

function Map:update(dt)
   for _, layer in ipairs(self.layers) do
      layer:update(dt)
   end
end

function Map:draw(tx, ty, sx, sy)
   local current_canvas = love.graphics.getCanvas()
   love.graphics.setCanvas(self.canvas)
   love.graphics.clear()
   love.graphics.push()
   love.graphics.origin()
   love.graphics.translate(math.floor(tx or 0), math.floor(ty or 0))

   for _, layer in ipairs(self.layers) do
      if layer.visible and layer.opacity > 0 then
         if layer.type == "tilelayer" then
            self:drawLayer(layer)
         elseif layer.type == "objectgroup" then
            drawObj.drawObjectLayer(layer)
         end
      end
   end

   love.graphics.pop()
   love.graphics.push()
   love.graphics.origin()
   love.graphics.scale(sx or 1, sy or sx or 1)
   love.graphics.setCanvas(current_canvas)
   love.graphics.draw(self.canvas)
   love.graphics.pop()
end

function Map.drawLayer(_, layer)
   local r,g,b,a = love.graphics.getColor()
   love.graphics.setColor(r, g, b, a * layer.opacity)
   layer:draw()
   love.graphics.setColor(r,g,b,a)
end

function Map:setLayer(layer)
   layer.x      = (layer.x or 0) + layer.offsetx + self.offsetx
   layer.y      = (layer.y or 0) + layer.offsety + self.offsety
   layer.update = function() end

   if layer.type == "tilelayer" then
      setTls.setTileData(layer, self)
      self:set_batches(layer)
      layer.draw = function() drawTls.drawTileLayer(layer) end
   elseif layer.type == "objectgroup" then
      setObj.setObjectData(layer, self)
      setObj.setObjectCoordinates(layer, self)
      setObj.setObjectSpriteBatches(layer)
      layer.draw = function() drawObj.drawObjectLayer(layer) end
   end
   self.layers[layer.name] = layer
end

function Map:resize(w, h)
   if love.graphics.isCreated then
      w = w or love.graphics.getWidth()
      h = h or love.graphics.getHeight()

      self.canvas = love.graphics.newCanvas(w, h)
   end
end

return setmetatable({}, CALLS)
