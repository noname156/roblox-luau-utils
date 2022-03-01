local Types = require(script.Parent.Types)

local function valuesFast(tbl: Types.GenericTable)
	local new: Types.GenericTable = table.create(#tbl)

	for _, v in pairs(tbl) do
		table.insert(new, v)
	end

	return new
end

return valuesFast
