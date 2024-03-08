--!strict
--!nolint LocalShadow
-- ty - Experiments with static type inference for runtime type validation
-- By Elttob, MIT license

local Package = script.Parent.Parent.Parent
local Maybe = require(Package.Maybe)

local Types = require(Package.ty.Types)
local Def = require(Package.ty.Def)

local And: Types.FnAnd = function(first, last)
	return Def.new(
		`({first.ExpectsType}) & ({last.ExpectsType})`,
		function(self, x)
			return first:Matches(x) and last:Matches(x)
		end,
		function(self, x)
			local result = first:Cast(x)
			if not result.some then
				return Maybe.None(self.NotOfTypeError)
			end
			local result = last:Cast(result.value)
			if not result.some then
				return Maybe.None(self.NotOfTypeError)
			end
			return result
		end
	)
end

return And