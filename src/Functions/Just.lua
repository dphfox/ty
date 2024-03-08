--!strict
--!nolint LocalShadow
-- ty - Experiments with static type inference for runtime type validation
-- By Elttob, MIT license

local Package = script.Parent.Parent.Parent
local Maybe = require(Package.Maybe)

local Types = require(Package.ty.Types)
local Def = require(Package.ty.Def)

local Just: Types.FnJust = function(literal, type)
	return Def.new(
		type or tostring(literal),
		function(self, x)
			return rawequal(x, literal)
		end,
		function(self, x)
			if rawequal(x, literal) then
				return Maybe.Some(x)
			else
				return Maybe.None(self.NotOfTypeError)
			end
		end
	)
end

return Just