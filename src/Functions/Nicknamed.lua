--!strict
--!nolint LocalShadow
-- ty - Experiments with static type inference for runtime type validation
-- By Elttob, MIT license

local Package = script.Parent.Parent.Parent
local Types = require(Package.ty.Types)
local Def = require(Package.ty.Def)

local Nicknamed: Types.FnNicknamed = function<T>(innerDef, newName)
	return Def.new(
		newName,
		innerDef.Matches,
		innerDef.Cast
	)
end

return Nicknamed