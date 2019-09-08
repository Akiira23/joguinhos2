-- modulo para inicializar os tiles dos layers para o desenho

local setTls = {}

function setTls.get_tiles(imageW, tileW, margin, spacing)
   imageW  = imageW - margin
   local n = 0

   while imageW >= tileW do
      imageW = imageW - tileW
      if n ~= 0 then imageW = imageW - spacing end
      if imageW >= 0 then n  = n + 1 end
   end

   return n
end

function setTls.setTiles(index, tileset, gid, bg, self)
   local quad = love.graphics.newQuad
   local imageW = tileset.imagewidth
   local imageH = tileset.imageheight
   local tileW = tileset.tilewidth
   local tileH = tileset.tileheight
   local margin = tileset.margin
   local spacing = tileset.spacing
   local tilesw = setTls.get_tiles(imageW, tileW, margin, spacing)
   local tilesh = setTls.get_tiles(imageH, tileH, margin, spacing)

   love.graphics.setBackgroundColor(bg)

   for y = 1, tilesh do
      for x = 1, tilesw do
         local id    = gid - tileset.firstgid
         local quadX = (x - 1) * tileW + margin + (x - 1) * spacing
         local quadY = (y - 1) * tileH + margin + (y - 1) * spacing
         local type = ""
         local properties = ""
         local terrain = ""
         local animation = ""
         local objectGroup = ""

         local tile = {
            id          = id,
            gid         = gid,
            tileset     = index,
            type        = type,
            quad        = quad(
               quadX,  quadY,
               tileW,  tileH,
               imageW, imageH
            ),
            properties  = properties or {},
            terrain     = terrain,
            animation   = animation,
            objectGroup = objectGroup,
            frame       = 1,
            time        = 0,
            width       = tileW,
            height      = tileH,
            sx          = 1,
            sy          = 1,
            r           = 0,
            offset      = tileset.tileoffset,
         }

         self.tiles[gid] = tile
         gid             = gid + 1
      end
   end

   return gid
end

function setTls.setTileData(layer, self)
   local i   = 1
   local map = {}
   for y = 1, layer.height do
      map[y] = {}
      for x = 1, layer.width do
         local gid = layer.data[i]
         if gid > 0 then
            map[y][x] = self.tiles[gid]
         end
         i = i + 1
      end
   end
   layer.data = map
end

return setTls
