--!strict
--!nolint LocalShadow
-- ty - Experiments with static type inference for runtime type validation
-- By Elttob, MIT license

local Package = script.Parent.Parent.Parent
local Maybe = require(Package.Maybe)

local Types = require(Package.ty.Types)
local Def = require(Package.ty.Def)

local MapOf: Types.FnMapOf = function<K, V>(keys: Types.Def<K>, values: Types.Def<V>)
	return Def.new(
		`\{[{keys.ExpectsType}]: {values.ExpectsType}}`,
		function(self, x)
			if typeof(x) ~= "table" then
				return false
			end
			local x = x :: {[unknown]: unknown}
			for key, value in pairs(x) do
				if not keys:Matches(key) or not values:Matches(value) then
					return false
				end
			end
			return true
		end,
		function(self, x)
			if typeof(x) ~= "table" then
				return Maybe.None(self.NotOfTypeError)
			end
			local x = x :: {[unknown]: unknown}
			local casted: {[K]: V}? = nil
			for key, value in pairs(x) do
				local castedKey = keys:Cast(key)
				if not castedKey.some then
					return Maybe.None(self.NotOfTypeError)
				end
				local castedValue = values:Cast(value)
				if not castedValue.some then
					return Maybe.None(self.NotOfTypeError)
				end
				if casted == nil then
					if castedKey.value == key and castedValue.value == value then
						continue
					end
					casted = table.clone(x) :: {[K]: V}
				end
				local casted = casted :: {[K]: V}
				casted[castedKey.value] = castedValue.value
			end
			return Maybe.Some(if casted == nil then x :: {[K]: V} else casted)
		end
	)
end

return MapOf