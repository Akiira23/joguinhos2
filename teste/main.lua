
local sti  = require "sti"
local map, tx, ty, points
local time = 0

function love.load()
	-- Load map
	map = sti("tests/test.lua")

	-- Prepare translations
	tx, ty = 0, 0

end

function love.update(dt)
	map:update(dt)

	-- Move map
	time = (time + dt)%17
	if time >= 0 and time < 4 then 
		tx = tx + 180 * dt
		ty = ty - 50 * dt
	elseif time >= 4 and time < 5 then
		ty = ty + 180 * dt
	elseif time >= 5 and time < 9 then
		tx = tx + 150 * dt
	elseif time >= 9 and time < 13 then
		tx = tx - 100 * dt
		ty = ty + 140 * dt
	else
		tx = tx - 160 * dt
		ty = ty - 140 * dt
	end

	if tx > 390 and tx < 400 and ty < -47 and ty > -50 then
		tx, ty = 0, 0
	end
end

function love.draw()
	-- Draw map
	love.graphics.setColor(1, 1, 1)
	map:draw(-tx, -ty)
end
