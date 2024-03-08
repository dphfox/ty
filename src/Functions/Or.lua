--!strict
--!nolint LocalShadow
-- ty - Experiments with static type inference for runtime type validation
-- By Elttob, MIT license

local Package = script.Parent.Parent.Parent
local Maybe = require(Package.Maybe)

local Types = require(Package.ty.Types)
local Def = require(Package.ty.Def)

local Or: Types.FnOr = function<F, L>(first: Types.Def<F>, last: Types.Def<L>)
	return Def.new(
		`{first.ExpectsType} | {last.ExpectsType}`,
		function(self, x)
			return first:Matches(x) or last:Matches(x)
		end,
		function(self, x)
			local result = first:Cast(x)
			if result.some then
				return result :: Maybe.Maybe<F | L>
			end
			local result = last:Cast(x)
			return if result.some then result else Maybe.None(self.NotOfTypeError)
		end
	)
end

return Or