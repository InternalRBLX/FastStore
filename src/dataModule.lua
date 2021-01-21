local DataStore = {}
local TimesThrough = 5

function DataStore.Get(SavedDataStore, key)
	local Result
	for _ = 1, TimesThrough do
		local Data
		Result = { pcall(function()
			Data = SavedDataStore:GetAsync(key)
		end) }
		if Result[1] then
			return Data, true
		end
	end
	warn(Result[2])
	return nil, false
end

function DataStore.Set(SavedDataStore, key, value)
	local Result
	for _ = 1, TimesThrough do
		Result = { pcall(function()
			SavedDataStore:SetAsync(key, value)
		end) }
		if Result[1] then
			return true
		end
		wait(.75)
	end
	warn(Result[2])
	return false
end

function DataStore.Update(SavedDataStore, key, transformFunction)
	local Result
	for _ = 1, TimesThrough do
		Result = { pcall(function()
			SavedDataStore:UpdateAsync(key, transformFunction)
		end) }
		if Result[1] then
			return true
		end
		wait(.75)
	end
	warn(Result[2])
	return false
end

return DataStore