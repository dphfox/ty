--!strict
-- From 'ty' by Elttob, MIT license

local Package = script.Parent.Parent
local Maybe = require(Package.Maybe)

-- FUTURE: Luau can't currently handle adding in '& Methods' due to heavy
-- restrictions on what generic types can do.
export type Def<CastTo> = DefNoMethods<CastTo> -- & Methods
type DefNoMethods<CastTo> = {
	ExpectsType: string,
	NotOfTypeError: string,
	Matches: (self: Def<CastTo>, unknown) -> boolean,
	Cast: (self: Def<CastTo>, unknown) -> Maybe.Maybe<CastTo>
}

export type Constants = {
	Unknown: Def<unknown>,
	Never: Def<never>,

	Number: Def<number>,
	Boolean: Def<boolean>,
	String: Def<string>,
	Thread: Def<thread>,
	Table: Def<{[unknown]: unknown}>,
	Function: Def<(...unknown) -> (...unknown)>,

	True: Def<true>,
	False: Def<false>,
	Nil: Def<nil>
}

export type Methods = {
	Typeof: FnTypeof,
	Just: FnJust,
	Optional: FnOptional,
	Or: FnOr,
	And: FnAnd,
	MapOf: FnMapOf,
	Array: FnArray,
	Struct: FnStruct,
	IntoTagged: FnIntoTagged,
	IntoString: FnIntoString,
	IntoNumber: FnIntoNumber,
	Retype: FnRetype,
	Untyped: FnUntyped,
	Nicknamed: FnNicknamed,
	CastOrError: FnCastOrError
}

export type FnTypeof = <T>(
	typeString: string
) -> Def<T>

export type FnJust = <T>(
	literal: T,
	type: string?
) -> Def<T>

export type Optional<T> = Def<T?>
export type FnOptional = <T>(
	innerDef: Def<T>
) -> Optional<T>


export type Or<F, L> = Def<F | L>
export type FnOr = <F, L>(
	first: Def<F>,
	last: Def<L>
) -> Or<F, L>


export type And<F, L> = Def<F & L>
export type FnAnd = <F, L>(
	first: Def<F>,
	last: Def<L>
) -> And<F, L>


export type MapOf<K, V> = Def<{[K]: V}>
export type FnMapOf = <K, V>(
	keys: Def<K>,
	values: Def<V>
) -> MapOf<K, V>


export type Array<V> = Def<{V}>
export type FnArray = <V>(
	values: Def<V>
) -> Array<V>

-- FUTURE: suboptimal type for this; try keyof when it launches?
export type Struct<K, V> = Def<{[K]: V}> 
export type FnStruct = <K, V>(
	object: {[K & string]: Def<V>}
) -> Struct<K, V>

export type IntoTagged<Tag, T> = Def<{__tag: Tag, value: T}>
export type FnIntoTagged = <Tag, T>(
	innerDef: Def<T>,
	tag: Tag
) -> IntoTagged<Tag, T>

export type FnIntoString = <T>(
	innerDef: Def<T>
) -> Def<string>

export type FnIntoNumber = <T>(
	innerDef: Def<T>,
	base: number?
) -> Def<string>

export type FnRetype = <T>(
	def: Def<any>
) -> Def<T>

export type FnUntyped = (
	def: Def<any>
) -> Def<any>

export type FnNicknamed = <T>(
	innerDef: Def<T>,
	newName: string
) -> Def<T>

export type FnCastOrError = <T>(
	def: Def<T>,
	x: unknown
) -> T

return nil