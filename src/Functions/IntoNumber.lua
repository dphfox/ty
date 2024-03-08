--!strict
--!nolint LocalShadow
-- ty - Experiments with static type inference for runtime type validation
-- By Elttob, MIT license

local Package = script.Parent.Parent.Parent
local Maybe = require(Package.Maybe)

local Types = require(Package.ty.Types)
local Def = require(Package.ty.Def)

local IntoNumber: Types.FnIntoNumber = function(innerDef, base)
	return Def.new(
		`tonumber({innerDef.ExpectsType}{if base == nil then "" else ", " .. base})`,
		function(self, x)
			local Cast = innerDef:Cast(x)
			return Cast.some and tonumber(Cast.value, base) ~= nil
		end,
		function(self, x)
			local result = innerDef:Cast(x)
			if not result.some then
				return Maybe.None(self.NotOfTypeError)
			else
				local num = tonumber(result.value, base)
				if num == nil then
					return Maybe.None(`Numeric conversion not possible for {self.ExpectsType}`)
				else
					return Maybe.Some(num)
				end
			end
		end
	)
end

return IntoNumber