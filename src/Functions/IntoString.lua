--!strict
--!nolint LocalShadow
-- ty - Experiments with static type inference for runtime type validation
-- By Elttob, MIT license

local Package = script.Parent.Parent.Parent
local Maybe = require(Package.Maybe)

local Types = require(Package.ty.Types)
local Def = require(Package.ty.Def)

local IntoString: Types.FnIntoString = function(innerDef)
	return Def.new(
		`tostring({innerDef.ExpectsType})`,
		function(self, x)
			local Cast = innerDef:Cast(x)
			return Cast.some and tostring(Cast.value) ~= nil
		end,
		function(self, x)
			local result = innerDef:Cast(x)
			if not result.some then
				return Maybe.None(self.NotOfTypeError)
			else
				local str = tostring(result.value)
				if str == nil then
					return Maybe.None(`String conversion not possible for {self.ExpectsType}`)
				else
					return Maybe.Some(str)
				end
			end
		end
	)
end

return IntoString