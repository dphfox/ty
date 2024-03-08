--!strict
-- ty - Experiments with static type inference for runtime type validation
-- By Elttob, MIT license

local Package = script.Parent.Parent
local Types = require(Package.ty.Types)
local Maybe = require(Package.Maybe)

local Def = {}

Def.methodMeta = {__index = nil :: Types.Methods?}

local function linkMethods<T>(
	def
): Types.Def<T>
	setmetatable(def, Def.methodMeta)
	return def :: any
end

function Def.new<CastTo>(
	expectsType: string,
	matches: (self: Types.Def<CastTo>, unknown) -> boolean,
	cast: (self: Types.Def<CastTo>, unknown) -> Maybe.Maybe<CastTo>
): Types.Def<CastTo>
	local def = {}
	def.Matches = matches
	def.ExpectsType = expectsType
	def.NotOfTypeError = `Type is not {expectsType}`
	def.Cast = cast
	return linkMethods(def)
end

return Def