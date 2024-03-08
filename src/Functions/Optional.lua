--!strict
--!nolint LocalShadow
-- ty - Experiments with static type inference for runtime type validation
-- By Elttob, MIT license

local Package = script.Parent.Parent.Parent
local Maybe = require(Package.Maybe)

local Types = require(Package.ty.Types)
local Def = require(Package.ty.Def)

local Optional: Types.FnOptional = function<T>(innerDef: Types.Def<T>)
	return Def.new(
		`({innerDef.ExpectsType})?`,
		function(self, x)
			if x == nil then
				return true
			end
			return innerDef:Matches(x)
		end,
		function(self, x)
			if x == nil then
				return Maybe.Some(nil) :: Maybe.Maybe<T?>
			end
			local result = innerDef:Cast(x)
			return if result.some then result else Maybe.None(self.NotOfTypeError)
		end
	)
end

return Optional