--!strict
--!nolint LocalShadow
-- ty - Experiments with static type inference for runtime type validation
-- By Elttob, MIT license

local Package = script.Parent.Parent.Parent
local Maybe = require(Package.Maybe)

local Types = require(Package.ty.Types)
local Def = require(Package.ty.Def)

local IntoTagged: Types.FnIntoTagged = function(innerDef, tag)
	return Def.new(
		`\{__tag: {tag}, value: {innerDef.ExpectsType}}`,
		function(self, x)
			return innerDef:Matches(x)
		end,
		function(self, x)
			local result = innerDef:Cast(x)
			if not result.some then
				return Maybe.None(self.NotOfTypeError)
			else
				return Maybe.Some({__tag = tag, value = x})
			end
		end
	)
end

return IntoTagged