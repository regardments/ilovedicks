-- Table utility functions.
local Table = {}

---Take a chunk out of an array into a new array.
---@param input any[]
---@param start number
---@param stop number
---@return any[]
Table.slice = LPH_NO_VIRTUALIZE(function(input, start, stop)
	local out = {}

	if start == nil then
		start = 1
	elseif start < 0 then
		start = #input + start + 1
	end
	if stop == nil then
		stop = #input
	elseif stop < 0 then
		stop = #input + stop + 1
	end

	for idx = start, stop do
		table.insert(out, input[idx])
	end

	return out
end)

---Find a value with a filter in a table and return it's value and index.
---@param input any[]
---@param predicate fun(value: any, index: number): boolean
---@return number, any
Table.find = LPH_NO_VIRTUALIZE(function(input, predicate)
	for idx, value in next, input do
		if not predicate(value, idx) then
			continue
		end

		return idx, value
	end
end)

-- Return Table module.
return Table
