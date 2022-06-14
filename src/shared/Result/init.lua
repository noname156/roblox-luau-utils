-- reference: https://doc.rust-lang.org/std/result/enum.Result.html#

local Types = require(script.Parent.Types)

export type Result<T, E> = Types.Result<T, E>
export type Err<E> = Types.Err<E>
export type Ok<T> = Types.Ok<T>

local Ok = {}
local Err = {}
local Result = {}

function Result:isOk()
	return getmetatable(self) == Ok
end

function Result:isOkAnd<T>(f: (T) -> boolean)
	return if getmetatable(self) == Err then false else f(self._v :: T)
end

function Result:isErr()
	return getmetatable(self) == Err
end

function Result:isErrAnd<E>(f: (E) -> boolean)
	return if getmetatable(self) == Ok then false else f(self._v :: E)
end

function Result:ok<T>()
	return if getmetatable(self) == Ok then require(script.Parent.Option).Some(self._v :: T) else require(script.Parent.Option).None
end

function Result:err<E>()
	return if getmetatable(self) == Err then require(script.Parent.Option).Some(self._v :: E) else require(script.Parent.Option).None
end

function Result:map<T, E, U>(op: (T) -> U)
	return if getmetatable(self) == Err then self :: Result<T, E> else table.freeze(setmetatable({ _v = op(self._v :: T) }, Ok)) :: Result<U, E>
end

function Result:mapOr<T, U>(default: U, f: (T) -> U)
	return if getmetatable(self) == Err then default else f(self._v :: T)
end

function Result:mapOrElse<T, E, U>(default: (E) -> U, f: (T) -> U)
	return if getmetatable(self) == Err then default(self._v :: E) else f(self._v :: T)
end

function Result:mapErr<T, E, F>(op: (E) -> F)
	return if getmetatable(self) == Ok then self :: Result<T, E> else table.freeze(setmetatable({ _v = op(self._v :: E) }, Err)) :: Result<T, F>
end

function Result:inspect<T>(f: (T) -> ())
	if getmetatable(self) == Ok then
		f(self._v :: T)
	end

	return self :: Result<T, any>
end

function Result:inspectErr<E>(f: (E) -> ())
	if getmetatable(self) == Err then
		f(self._v :: E)
	end

	return self :: Result<any, E>
end

function Result:expect(msg: string)
	if getmetatable(self) == Err then
		error(msg, 2)
	end

	return self._v
end

function Result:unwrap()
	if getmetatable(self) == Err then
		error('called "Result:unwrap()" on an "Err" value', 2)
	end

	return self._v
end

function Result:expectErr(msg: string)
	if getmetatable(self) == Ok then
		error(msg, 2)
	end

	return self._v
end

function Result:unwrapErr()
	if getmetatable(self) == Ok then
		error('called "Result:unwrapErr()" on an "Ok" value', 2)
	end

	return self._v
end

-- original naming: https://doc.rust-lang.org/std/result/enum.Result.html#method.and
function Result:andRes<T, E, U>(res: Result<U, E>)
	return if getmetatable(self) == Ok then res else self :: Result<T, E>
end

function Result:andThen<T, E, U>(op: (T) -> Result<U, E>)
	return if getmetatable(self) == Err then self :: Result<T, E> else op(self._v :: T) :: Result<U, E>
end

-- original naming: https://doc.rust-lang.org/std/result/enum.Result.html#method.or
function Result:orRes<T, E, F>(res: Result<T, F>)
	return if getmetatable(self) == Err then res else self :: Result<T, E>
end

function Result:orElse<T, E, F>(op: (E) -> Result<T, F>)
	return if getmetatable(self) == Ok then self :: Result<T, E> else op(self._v :: E) :: Result<T, F>
end

function Result:unwrapOr<T>(default: T)
	return if getmetatable(self) == Ok then self._v :: T else default
end

function Result:unwrapOrElse<T, E>(op: (E) -> T)
	return if getmetatable(self) == Ok then self._v :: T else op(self._v :: E)
end

function Result:contains(x)
	return getmetatable(self) == Ok and self._v == x
end

function Result:containsErr(f)
	return getmetatable(self) == Err and self._v == f
end

table.freeze(Result)

Ok.__index = Result

function Ok:__tostring()
	return "Ok<" .. typeof(self._v) .. ">"
end

function Ok:__eq(value)
	return type(value) == "table" and getmetatable(value) == Ok and value._v == self._v
end

Err.__index = Result

function Err:__tostring()
	return "Err<" .. typeof(self._v) .. ">"
end

function Err:__eq(value)
	return type(value) == "table" and getmetatable(value) == Err and value._v == self._v
end

-- make sure no more edits could be applied
table.freeze(Ok)
table.freeze(Err)

local ResultExport = {
	Ok = function(value)
		return table.freeze(setmetatable({ _v = value }, Ok))
	end,
	Err = function(err)
		return table.freeze(setmetatable({ _v = err }, Err))
	end,

	_ok = Ok,
	_err = Err,
	_result = Result,

	is = function(value)
		if type(value) ~= "table" then
			return false
		end

		local metatable = getmetatable(value)
		return if metatable then metatable.__index == Result else false
	end,
}

table.freeze(ResultExport)

return ResultExport :: {
	Ok: <T>(T) -> Result<T, nil>,
	Err: <E>(E) -> Result<nil, E>,
	is: (value: any) -> boolean,
}
