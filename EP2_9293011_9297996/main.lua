--modulo principal para a execucao do love

local calls  = require "calls"
local map, tx, ty, points
local time = 0

function love.load()
   map = calls("tests/test.lua")
   tx, ty = 0, 0

end

function love.update(dt)
   map:update(dt)
   local passou = 1
   -- Move map
   time = (time + dt)%14
   if time >= 0 and time < 4 then 
      tx = tx + 180 * dt
   elseif time >= 4 and time < 5 then
      ty = ty - 180 * dt
   elseif time >= 5 and time < 8 then
      tx = tx + 180 * dt
      ty = ty + 180 * dt
   elseif time >= 8 and time < 10 then
      tx = tx - 180 * dt
      ty = ty + 180 * dt
   else
      tx = tx - 225 * dt
      ty = ty - 180 * dt
   end
end

function love.draw()
   love.graphics.setColor(1, 1, 1)
   map:draw(-tx, -ty)
end
