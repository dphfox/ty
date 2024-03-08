--!strict
--!nolint LocalShadow
-- ty - Experiments with static type inference for runtime type validation
-- By Elttob, MIT license

local Package = script.Parent.Parent.Parent
local Maybe = require(Package.Maybe)

local Types = require(Package.ty.Types)
local Def = require(Package.ty.Def)

local Typeof: Types.FnTypeof = function(typeString)
	return Def.new(
		typeString,
		function(self, x)
			return typeof(x) == typeString
		end,
		function(self, x)
			if typeof(x) == typeString then
				return Maybe.Some(x)
			else
				return Maybe.None(self.NotOfTypeError)
			end
		end
	)
end

return Typeof