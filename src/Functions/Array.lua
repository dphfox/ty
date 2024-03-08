--!strict
--!nolint LocalShadow
-- ty - Experiments with static type inference for runtime type validation
-- By Elttob, MIT license

local Package = script.Parent.Parent.Parent
local Maybe = require(Package.Maybe)

local Types = require(Package.ty.Types)
local Def = require(Package.ty.Def)

local Array: Types.FnArray = function<V>(values: Types.Def<V>)
	return Def.new(
		`\{{values.ExpectsType}}`,
		function(self, x)
			if typeof(x) ~= "table" then
				return false
			end
			local x = x :: {[unknown]: unknown}
			local expected = #x
			local encountered = 0
			for key, value in pairs(x) do
				encountered += 1
				if encountered > expected or typeof(key) ~= "number" or not values:Matches(value) then
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
			local casted: {V}? = nil
			local expected = #x
			local encountered = 0
			for key, value in pairs(x) do
				encountered += 1
				if encountered > expected or typeof(key) ~= "number" then
					return Maybe.None(self.NotOfTypeError)
				end
				local castedValue = values:Cast(value)
				if not castedValue.some then
					return Maybe.None(self.NotOfTypeError)
				end
				if casted == nil then
					if castedValue.value == value then
						continue
					end
					casted = table.clone(x) :: {V}
				end
				local casted = casted :: {V}
				casted[key] = castedValue.value
			end
			return Maybe.Some(if casted == nil then x :: {V} else casted)
		end
	)
end

return Array