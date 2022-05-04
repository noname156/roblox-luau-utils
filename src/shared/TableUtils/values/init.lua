local Types = require(script.Parent.Parent.Types)

type Record<K, V> = Types.Record<K, V>
type Array<T> = Types.Array<T>

local function values<V>(source: Record<any, V>): Array<V>
	local result = table.create(#source)
	for _, v in pairs(source) do
		table.insert(result, v)
	end
	return result
end

return values
