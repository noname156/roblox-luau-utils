local Types = require(script.Parent.Parent.Types)
local None = require(script.Parent.Parent.None)

type Record<K, V> = Types.Record<K, V>

--[[
	Merges values from zero or more tables onto a target table.
   If a value is set to None, it will instead be removed from the table.

   reference: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/assign
]]
local function assign<K, V>(target: Record<K, V>, ...: Record<K, V>?)
	for index = 1, select("#", ...) do
		local source = select(index, ...)
		if source ~= nil then
			for key, value in pairs(source) do
				target[key] = if value == None then nil else value
			end
		end
	end
	return target
end

return assign
