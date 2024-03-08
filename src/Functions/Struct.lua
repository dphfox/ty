--!strict
--!nolint LocalShadow
-- ty - Experiments with static type inference for runtime type validation
-- By Elttob, MIT license

local Package = script.Parent.Parent.Parent
local Maybe = require(Package.Maybe)

local Types = require(Package.ty.Types)
local Def = require(Package.ty.Def)

local Struct: Types.FnStruct = function<K, V>(object: {[K & string]: Types.Def<V>})
	local expectTypeParts = {}
	for key, value in object do
		table.insert(expectTypeParts, `{key}: {value.ExpectsType}`)
	end
	return Def.new(
		`\{{table.concat(expectTypeParts, ", ")}}`,
		function(self, x)
			if typeof(x) ~= "table" then
				return false
			end
			local x = x :: {[unknown]: unknown}
			for key, value in pairs(x) do
				if typeof(key) ~= "string" then
					return false
				end
				local key = key :: K & string
				local innerDef = object[key]
				if innerDef == nil or not innerDef:Matches(value) then
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
				if typeof(key) ~= "string" then
					return Maybe.None(self.NotOfTypeError)
				end
				local key = key :: K & string
				local innerDef = object[key]
				if innerDef == nil then
					return Maybe.None(self.NotOfTypeError)
				end
				local castedValue = innerDef:Cast(value)
				if not castedValue.some then
					return Maybe.None(self.NotOfTypeError)
				end
				if casted == nil then
					if castedValue.value == value then
						continue
					end
					casted = table.clone(x) :: {[K]: V}
				end
				local casted = casted :: {[K]: V}
				casted[key] = castedValue.value
			end
			return Maybe.Some(if casted == nil then x :: {[K]: V} else casted)
		end
	)
end

return Struct