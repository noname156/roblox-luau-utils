return function()
	local returnArgs = require(script.Parent.Parent.FunctionUtils.returnArgs)
	local void = require(script.Parent.Parent.FunctionUtils.void)
	local Result = require(script.Parent)

	local RETURN_TRUE = returnArgs(true)
	local RETURN_TRUE_AND_NIL = returnArgs(true, nil)
	local RETURN_FALSE = returnArgs(false)
	local RETURN_FALSE_AND_NIL = returnArgs(false, nil)
	local RETURN_NIL_AND_NIL = returnArgs(nil, nil)
	local RETURN_TABLE = returnArgs({})
	local RETURN_NIL = returnArgs(nil)
	local function UNREACHABLE() end

	it("should throw an error to modify the exported table", function()
		expect(function()
			getmetatable(Result).__index = {}
		end).to.throw()

		expect(function()
			setmetatable(Result, {})
		end).to.throw()

		expect(function()
			Result.NEW_FIELD = {}
		end).to.throw()
	end)

	it("should throw an error on attempt to modify Ok", function()
		expect(function()
			getmetatable(Result.Ok()).__index = {}
		end).to.throw()

		expect(function()
			setmetatable(Result.Ok(), {})
		end).to.throw()

		expect(function()
			Result.Ok().NEW_FIELD = {}
		end).to.throw()
	end)

	it("should throw an error on attempt to modify Err", function()
		expect(function()
			getmetatable(Result.Err()).__index = {}
		end).to.throw()

		expect(function()
			setmetatable(Result.Err(), {})
		end).to.throw()

		expect(function()
			Result.Err().NEW_FIELD = {}
		end).to.throw()
	end)

	describe("Ok", function()
		it("should print a nice string instead of a table", function()
			expect(function()
				assert(tostring(Result.Ok()) == "Ok<nil>")
				assert(tostring(Result.Ok(1)) == "Ok<number>")
				assert(tostring(Result.Ok(CFrame.identity)) == "Ok<CFrame>")
			end).never.to.throw()
		end)

		it("should implement __eq metamethod", function()
			expect(function()
				assert(Result.Ok() == Result.Ok())
				assert(Result.Ok(0) == Result.Ok(0))
			end).never.to.throw()
		end)
	end)

	describe("Err", function()
		it("should print a nice string instead of a table", function()
			expect(function()
				assert(tostring(Result.Err()) == "Err<nil>")
				assert(tostring(Result.Err(0)) == "Err<number>")
				assert(tostring(Result.Err(CFrame.identity)) == "Err<CFrame>")
			end).never.to.throw()
		end)

		it("should implement __eq metamethod", function()
			expect(function()
				assert(Result.Err() == Result.Err())
				assert(Result.Err(0) == Result.Err(0))
			end).never.to.throw()
		end)
	end)

	describe(":isOk()", function()
		it("should recognize Ok", function()
			expect(function()
				assert(Result.Ok():isOk() == true)
			end).never.to.throw()
		end)

		it("should recognize Err", function()
			expect(function()
				assert(Result.Err():isOk() == false)
			end).never.to.throw()
		end)

		it("should throw an error if any argument provided", function()
			expect(function()
				Result.Ok():isOk(nil, nil)
			end).to.throw()

			expect(function()
				Result.Err():isOk(nil, nil)
			end).to.throw()
		end)
	end)

	describe(":isOkAnd()", function()
		it("should recognize Ok", function()
			expect(function()
				assert(Result.Ok():isOkAnd(RETURN_FALSE) == false)
				assert(Result.Ok():isOkAnd(RETURN_TRUE) == true)
			end).never.to.throw()
		end)

		it("should recognize Err", function()
			expect(function()
				assert(Result.Err():isOkAnd(RETURN_FALSE) == false)
				assert(Result.Err():isOkAnd(RETURN_TRUE) == false)
			end).never.to.throw()
		end)

		it("should throw an error if extra arguments provided", function()
			expect(function()
				Result.Ok():isOkAnd(RETURN_TRUE, nil, nil)
			end).to.throw()

			expect(function()
				Result.Err():isOkAnd(RETURN_TRUE, nil, nil)
			end).to.throw()
		end)

		it("should throw an error if 'f' is not a function", function()
			expect(function()
				Result.Ok():isOkAnd()
			end).to.throw()

			expect(function()
				Result.Ok():isOkAnd({})
			end).to.throw()

			expect(function()
				Result.Err():isOkAnd()
			end).to.throw()

			expect(function()
				Result.Err():isOkAnd({})
			end).to.throw()
		end)

		it("should not call 'f' function when Result is Err", function()
			expect(function()
				Result.Err():isOkAnd(error)
			end).never.to.throw()
		end)

		it("should provide a valid value to 'f' function", function()
			expect(function()
				Result.Ok(0):isOkAnd(function(v)
					assert(v == 0)
					return true
				end)
			end).never.to.throw()
		end)

		it("should throw an error if no values returned from 'f' function", function()
			expect(function()
				Result.Ok():isOkAnd(void)
			end).to.throw()
		end)

		it("should throw an error if multiple values returned from 'f' function", function()
			expect(function()
				Result.Ok():isOkAnd(RETURN_TRUE_AND_NIL)
			end).to.throw()

			expect(function()
				Result.Ok():isOkAnd(RETURN_FALSE_AND_NIL)
			end).to.throw()
		end)

		it("should throw an error if value returned from 'f' function is not a boolean", function()
			expect(function()
				Result.Ok():isOkAnd(RETURN_TABLE)
			end).to.throw()

			expect(function()
				Result.Ok():isOkAnd(RETURN_NIL)
			end).to.throw()
		end)
	end)

	describe(":isErr()", function()
		it("should recognize Err", function()
			expect(function()
				assert(Result.Err():isErr() == true)
			end).never.to.throw()
		end)

		it("should recognize Ok", function()
			expect(function()
				assert(Result.Ok():isErr() == false)
			end).never.to.throw()
		end)

		it("should throw an error if any arguments provided", function()
			expect(function()
				Result.Ok():isErr(nil, nil)
			end).to.throw()

			expect(function()
				Result.Err():isErr(nil, nil)
			end).to.throw()
		end)
	end)

	describe(":isErrAnd()", function()
		it("should recognize Err", function()
			expect(function()
				assert(Result.Err():isErrAnd(RETURN_TRUE) == true)
				assert(Result.Err():isErrAnd(RETURN_FALSE) == false)
			end).never.to.throw()
		end)

		it("should recognize Ok", function()
			expect(function()
				assert(Result.Ok():isErrAnd(RETURN_TRUE) == false)
				assert(Result.Ok():isErrAnd(RETURN_FALSE) == false)
			end).never.to.throw()
		end)

		it("should throw an error if extra arguments provided", function()
			expect(function()
				Result.Ok():isErrAnd(RETURN_TRUE, nil, nil)
			end).to.throw()

			expect(function()
				Result.Err():isErrAnd(RETURN_TRUE, nil, nil)
			end).to.throw()
		end)

		it("should throw an error if 'f' is not a function", function()
			expect(function()
				Result.Ok():isErrAnd({})
			end).to.throw()

			expect(function()
				Result.Err():isErrAnd({})
			end).to.throw()
		end)

		it("should not call 'f' function when Result is Ok", function()
			expect(function()
				Result.Ok():isErrAnd(error)
			end).never.to.throw()
		end)

		it("should throw an error if 'f' function returned no values", function()
			expect(function()
				Result.Err():isErrAnd(void)
			end).to.throw()
		end)

		it("should throw an error if 'f' function returned multiple values", function()
			expect(function()
				Result.Err():isErrAnd(RETURN_TRUE_AND_NIL)
			end).to.throw()

			expect(function()
				Result.Err():isErrAnd(RETURN_FALSE_AND_NIL)
			end).to.throw()
		end)

		it("should throw an error if value returned from 'f' function is not a boolean", function()
			expect(function()
				Result.Err():isErrAnd(RETURN_TABLE)
			end).to.throw()

			expect(function()
				Result.Err():isErrAnd(RETURN_NIL)
			end).to.throw()
		end)
	end)

	describe(":ok()", function()
		return
	end)

	describe(":err()", function()
		return
	end)

	describe(":map()", function()
		it("should map Ok to another Ok", function()
			expect(function()
				assert(Result.Ok():map(RETURN_TRUE) == Result.Ok(true))
				assert(Result.Ok(true):map(RETURN_NIL) == Result.Ok())
			end).never.to.throw()
		end)

		it("should not map Err", function()
			expect(function()
				Result.Err():map(error)
			end).never.to.throw()
		end)

		it("should throw an error if extra arguments provided", function()
			expect(function()
				Result.Ok():map(RETURN_NIL, nil, nil)
			end).to.throw()

			expect(function()
				Result.Err():map(RETURN_NIL, nil, nil)
			end).to.throw()
		end)

		it("should throw an error if no `op` function provided", function()
			expect(function()
				Result.Ok():map()
			end).to.throw()

			expect(function()
				Result.Ok():map({})
			end).to.throw()

			expect(function()
				Result.Err():map()
			end).to.throw()

			expect(function()
				Result.Err():map({})
			end).to.throw()
		end)

		it("should not call 'op' function when called on Err", function()
			expect(function()
				Result.Err():map(error)
			end).never.to.throw()
		end)

		it("should throw an error when multiple values returned from 'op' function", function()
			expect(function()
				Result.Ok():map(RETURN_NIL_AND_NIL)
			end).to.throw()
		end)

		it("should not throw an error when single value returned from 'op' function", function()
			expect(function()
				Result.Ok():map(RETURN_TRUE)
				Result.Ok():map(RETURN_FALSE)
				Result.Ok():map(RETURN_NIL)
				Result.Ok():map(RETURN_TABLE)
			end).never.to.throw()
		end)
	end)

	describe(":mapOr()", function()
		it("should map Err to 'default' value", function()
			expect(function()
				assert(Result.Err():mapOr(0, UNREACHABLE) == 0)
				assert(Result.Err(200):mapOr(nil, UNREACHABLE) == nil)
			end).never.to.throw()
		end)

		it("should map Ok to value returned from 'f' function", function()
			expect(function()
				assert(Result.Ok():mapOr(nil, RETURN_TRUE) == true)
			end).never.to.throw()
		end)

		it("should throw an error when extra argument provided", function()
			expect(function()
				Result.Ok():mapOr(nil, RETURN_TRUE, nil)
			end).to.throw()

			expect(function()
				Result.Ok():mapOr(nil, RETURN_TRUE, {})
			end).to.throw()

			expect(function()
				Result.Err():mapOr(nil, UNREACHABLE, nil)
			end).to.throw()

			expect(function()
				Result.Err():mapOr(nil, UNREACHABLE, nil)
			end).to.throw()
		end)

		it("should throw an error when no 'f' function provided", function()
			expect(function()
				Result.Ok():mapOr(nil, nil)
			end).to.throw()

			expect(function()
				Result.Err():mapOr(nil, nil)
			end).to.throw()
		end)

		it("should throw an error when no values returned from 'f' function", function()
			expect(function()
				Result.Ok():mapOr(nil, void)
			end).to.throw()
		end)

		it("should throw an error when multiple values returned from 'f' function", function()
			expect(function()
				Result.Ok():mapOr(nil, RETURN_NIL_AND_NIL)
			end).to.throw()
		end)

		it("should not throw an error when single value returned from 'f' function", function()
			expect(function()
				assert(Result.Ok():mapOr(nil, RETURN_TRUE) == true)
				assert(Result.Ok():mapOr(nil, RETURN_FALSE) == false)
			end).never.to.throw()
		end)

		it("should not call 'f' function when called on Err", function()
			expect(function()
				assert(Result.Err():mapOr(true, error) == true)
				assert(Result.Err():mapOr(nil, error) == nil)
			end).never.to.throw()
		end)
	end)

	describe(":mapOrElse()", function()
		it("should map Err to value returned from 'default' function", function()
			expect(function()
				assert(Result.Err():mapOrElse(RETURN_TRUE, UNREACHABLE) == true)
				assert(Result.Err():mapOrElse(RETURN_NIL, UNREACHABLE) == nil)
			end).never.to.throw()
		end)

		it("should map Ok to value returned from 'f' function", function()
			expect(function()
				assert(Result.Ok():mapOrElse(error, RETURN_TRUE) == true)
				assert(Result.Ok():mapOrElse(error, RETURN_NIL) == nil)
			end).never.to.throw()
		end)

		it("should throw an error when extra arguments provided", function()
			expect(function()
				Result.Ok():mapOrElse(UNREACHABLE, RETURN_TRUE, nil, nil)
			end).to.throw()

			expect(function()
				Result.Err():mapOrElse(RETURN_TRUE, UNREACHABLE, nil, nil)
			end).to.throw()
		end)

		it("should throw an error in case 'default' function is not provided", function()
			expect(function()
				Result.Ok():mapOrElse(nil, RETURN_NIL)
			end).to.throw()

			expect(function()
				Result.Err():mapOrElse(nil, void)
			end).to.throw()
		end)

		it("should throw an error in case 'f' function is not provided", function()
			expect(function()
				Result.Ok():mapOrElse(void, nil)
			end).to.throw()

			expect(function()
				Result.Err():mapOrElse(RETURN_NIL, nil)
			end).to.throw()
		end)

		it("should throw an error when no values returned from 'default' function", function()
			expect(function()
				Result.Err():mapOrElse(void, UNREACHABLE)
			end).to.throw()
		end)

		it("should throw an error when multiple values returned from 'default' function", function()
			expect(function()
				Result.Err():mapOrElse(RETURN_NIL_AND_NIL, UNREACHABLE)
			end).to.throw()
		end)

		it("should not throw an error when single value returned from 'default' function", function()
			expect(function()
				Result.Err():mapOrElse(RETURN_TRUE, UNREACHABLE)
				Result.Err():mapOrElse(RETURN_NIL, UNREACHABLE)
			end).never.to.throw()
		end)

		it("should throw an error when no values returned from 'f' function", function()
			expect(function()
				Result.Ok():mapOrElse(UNREACHABLE, void)
			end).to.throw()
		end)

		it("should throw an error when multiple values returned from 'f' function", function()
			expect(function()
				Result.Ok():mapOrElse(UNREACHABLE, RETURN_NIL_AND_NIL)
			end).to.throw()
		end)

		it("should not throw an error when single value returned from 'f' function", function()
			expect(function()
				Result.Ok():mapOrElse(UNREACHABLE, RETURN_TRUE)
				Result.Ok():mapOrElse(UNREACHABLE, RETURN_NIL)
			end).never.to.throw()
		end)
	end)

	describe(":mapErr()", function()
		it("should map Err to another Err", function()
			expect(function()
				assert(Result.Err():mapErr(function()
					return 0
				end) == Result.Err(0))
			end).never.to.throw()
		end)

		it("should not map Ok", function()
			expect(function()
				assert(Result.Ok():mapErr(RETURN_TRUE) == Result.Ok())
			end).never.to.throw()
		end)

		it("should throw an error when extra arguments provided", function()
			expect(function()
				Result.Ok():mapErr(UNREACHABLE, nil, nil)
			end).to.throw()

			expect(function()
				Result.Err():mapErr(RETURN_TRUE, nil, nil)
			end).to.throw()
		end)

		it("should throw an error then no 'op' function provided", function()
			expect(function()
				Result.Ok():mapErr()
			end).to.throw()

			expect(function()
				Result.Err():mapErr()
			end).to.throw()

			expect(function()
				Result.Ok():mapErr({})
			end).to.throw()

			expect(function()
				Result.Err():mapErr({})
			end).to.throw()
		end)

		it("should throw an error when no values returned from 'op' function", function()
			expect(function()
				Result.Err():mapErr(void)
			end).to.throw()
		end)

		it("should throw an error when multiple values returned from 'op' function", function()
			expect(function()
				Result.Err():mapErr(RETURN_NIL_AND_NIL)
			end).to.throw()
		end)

		it("should not throw an error when single value returned from 'op' function", function()
			expect(function()
				Result.Err():mapErr(RETURN_NIL)
				Result.Err():mapErr(RETURN_TRUE)
			end).never.to.throw()
		end)
	end)

	describe(":inspect()", function()
		it("should throw an error when extra arguments provided", function()
			expect(function()
				Result.Ok():inspect(void, nil, nil)
			end).to.throw()

			expect(function()
				Result.Err():inspect(void, nil, nil)
			end).to.throw()
		end)

		it("should throw an error when no 'f' function provided", function()
			expect(function()
				Result.Ok():inspect()
			end).to.throw()

			expect(function()
				Result.Ok():inspect({})
			end).to.throw()

			expect(function()
				Result.Err():inspect()
			end).to.throw()

			expect(function()
				Result.Err():inspect({})
			end).to.throw()
		end)

		it("should throw an error when inspect function returned atleast one value", function()
			expect(function()
				Result.Ok():inspect(RETURN_NIL)
			end).to.throw()

			expect(function()
				Result.Ok():inspect(RETURN_TRUE)
			end).to.throw()

			expect(function()
				Result.Ok():inspect(RETURN_NIL_AND_NIL)
			end).to.throw()
		end)

		it("should not call 'f' function when called on Err", function()
			expect(function()
				Result.Err():inspect(error)
			end).never.to.throw()
		end)
	end)

	describe(":inspectErr()", function()
		it("should throw an error when extra arguments provided", function()
			expect(function()
				Result.Ok():inspectErr(void, nil, nil)
			end).to.throw()

			expect(function()
				Result.Err():inspectErr(void, nil, nil)
			end).to.throw()
		end)

		it("should throw an error when no 'f' function provided", function()
			expect(function()
				Result.Ok():inspectErr()
			end).to.throw()

			expect(function()
				Result.Ok():inspectErr({})
			end).to.throw()

			expect(function()
				Result.Err():inspectErr()
			end).to.throw()

			expect(function()
				Result.Err():inspectErr({})
			end).to.throw()
		end)

		it("should throw an error if atleast one value returned from 'f' function", function()
			expect(function()
				Result.Err():inspectErr(RETURN_NIL)
			end).to.throw()

			expect(function()
				Result.Err():inspectErr(RETURN_TRUE)
			end).to.throw()

			expect(function()
				Result.Err():inspectErr(RETURN_NIL_AND_NIL)
			end).to.throw()
		end)

		it("should not call 'f' function when called on Ok", function()
			expect(function()
				Result.Ok():inspectErr(error)
			end).never.to.throw()
		end)
	end)

	describe(":expect()", function()
		it("should throw an error if extra arguments provided", function()
			expect(function()
				Result.Ok():expect("msg", nil, nil)
			end).to.throw()
		end)

		it("should throw an error when no 'msg' argument provided", function()
			expect(function()
				Result.Ok():expect(nil)
			end).to.throw()

			expect(function()
				Result.Ok():expect({})
			end).to.throw()
		end)

		it("should throw an error when called on Err", function()
			expect(function()
				Result.Err():expect("msg")
			end).to.throw()
		end)
	end)

	describe(":unwrap()", function()
		it("should throw an error if any arguments provided", function()
			expect(function()
				Result.Ok():unwrap(nil, nil)
			end).to.throw()
		end)

		it("should throw an error when called on Err", function()
			expect(function()
				Result.Err():unwrap()
			end).to.throw()
		end)
	end)

	describe(":expectErr()", function()
		it("should throw an error if extra arguments provided", function()
			expect(function()
				Result.Err():expectErr("msg", nil, nil)
			end).to.throw()
		end)

		it("should throw an error if 'msg' argument is not provided", function()
			expect(function()
				Result.Err():expectErr(nil)
			end).to.throw()
		end)

		it("should throw an error when called on Ok", function()
			expect(function()
				Result.Ok():expectErr("msg")
			end).to.throw()
		end)
	end)

	describe(":unwrapErr()", function()
		it("should throw an error when any arguments provided", function()
			expect(function()
				Result.Err():unwrapErr(nil, nil)
			end).to.throw()
		end)

		it("should throw an error when called on Ok", function()
			expect(function()
				Result.Ok():unwrapErr()
			end).to.throw()
		end)
	end)

	describe(":andRes()", function()
		it("should return 'res' argument when called on Ok", function()
			expect(function()
				assert(Result.Ok():andRes(Result.Ok(3)) == Result.Ok(3))
			end).never.to.throw()
		end)

		it("should return self when called on Err", function()
			expect(function()
				assert(Result.Err():andRes(Result.Ok()) == Result.Err())
			end).never.to.throw()
		end)

		it("should throw an error when extra arguments provided", function()
			expect(function()
				Result.Ok():andRes(Result.Ok(), nil, nil)
			end).to.throw()
		end)

		it("should throw an error when no 'res' argument provided", function()
			expect(function()
				Result.Ok():andRes()
			end).to.throw()

			expect(function()
				Result.Ok():andRes({})
			end).to.throw()

			expect(function()
				Result.Err():andRes()
			end).to.throw()

			expect(function()
				Result.Err():andRes({})
			end).to.throw()
		end)
	end)

	describe(":andThen()", function()
		it("should return self when called on Err", function()
			expect(function()
				assert(Result.Err():andThen(UNREACHABLE) == Result.Err())
			end).never.to.throw()
		end)

		it("should return Result from 'op' function when called on Ok", function()
			expect(function()
				assert(Result.Ok():andThen(function()
					return Result.Ok(true)
				end) == Result.Ok(true))
			end).never.to.throw()
		end)

		it("should throw an error when extra arguments provided", function()
			expect(function()
				Result.Ok():andThen(RETURN_NIL, nil, nil)
			end).to.throw()

			expect(function()
				Result.Err():andThen(RETURN_NIL, nil, nil)
			end).to.throw()
		end)

		it("should throw an error when no 'op' argument provided", function()
			expect(function()
				Result.Ok():andThen()
			end).to.throw()

			expect(function()
				Result.Ok():andThen({})
			end).to.throw()

			expect(function()
				Result.Err():andThen()
			end).to.throw()

			expect(function()
				Result.Err():andThen({})
			end).to.throw()
		end)

		it("should throw an error when value returned from 'op' function is not a Result", function()
			expect(function()
				Result.Ok():andThen(RETURN_NIL)
			end).to.throw()

			expect(function()
				Result.Ok():andThen(RETURN_TRUE)
			end).to.throw()
		end)
	end)

	describe(":orRes()", function()
		it("should return 'res' in case self is Err", function()
			expect(function()
				assert(Result.Err():orRes(Result.Ok()) == Result.Ok())
			end).never.to.throw()
		end)

		it("should return self in case self is Ok", function()
			expect(function()
				assert(Result.Ok():orRes(Result.Err()) == Result.Ok())
			end).never.to.throw()
		end)

		it("should throw an error if extra arguments provided", function()
			expect(function()
				Result.Ok():orRes(Result.Ok(), nil, nil)
			end).to.throw()

			expect(function()
				Result.Err():orRes(Result.Ok(), nil, nil)
			end).to.throw()
		end)

		it("should throw an error if no 'res' argument provided", function()
			expect(function()
				Result.Ok():orRes()
			end).to.throw()

			expect(function()
				Result.Ok():orRes({})
			end).to.throw()

			expect(function()
				Result.Err():orRes()
			end).to.throw()

			expect(function()
				Result.Err():orRes()
			end).to.throw()
		end)
	end)

	describe(":orElse()", function()
		it("should throw an error if extra arguments provided", function()
			expect(function()
				Result.Ok():orElse(function()
					return Result.Err()
				end, nil, nil)
			end).to.throw()

			expect(function()
				Result.Err():orElse(function()
					return Result.Err()
				end, nil, nil)
			end).to.throw()
		end)

		it("should throw an error if no 'op' argument provided", function()
			expect(function()
				Result.Ok():orElse()
			end).to.throw()

			expect(function()
				Result.Ok():orElse({})
			end).to.throw()

			expect(function()
				Result.Err():orElse()
			end).to.throw()

			expect(function()
				Result.Err():orElse({})
			end).to.throw()
		end)

		it("should throw an error if value returned from 'op' function is not Result", function()
			expect(function()
				Result.Err():orElse(RETURN_NIL)
			end).to.throw()

			expect(function()
				Result.Err():orElse(RETURN_NIL)
			end).to.throw()
		end)
	end)

	describe(":unwrapOr()", function()
		it("should throw an error if extra arguments provided", function()
			expect(function()
				Result.Ok():unwrapOr(nil, nil, nil)
			end).to.throw()

			expect(function()
				Result.Err():unwrapOr(nil, nil, nil)
			end).to.throw()
		end)

		it("should throw an error if no 'default' argument provided", function()
			expect(function()
				Result.Ok():unwrapOr()
			end).to.throw()

			expect(function()
				Result.Err():unwrapOr()
			end).to.throw()
		end)
	end)

	describe(":unwrapOrElse()", function()
		it("should not call 'op' function when called on Err", function()
			expect(function()
				Result.Ok():unwrapOrElse(error)
			end).never.to.throw()
		end)

		it("should throw an error if extra arguments provided", function()
			expect(function()
				Result.Ok():unwrapOrElse(RETURN_NIL, nil, nil)
			end).to.throw()

			expect(function()
				Result.Err():unwrapOrElse(RETURN_NIL, nil, nil)
			end).to.throw()
		end)

		it("should throw an error if no 'op' argument provided", function()
			expect(function()
				Result.Ok():unwrapOrElse()
			end).to.throw()

			expect(function()
				Result.Ok():unwrapOrElse({})
			end).to.throw()

			expect(function()
				Result.Err():unwrapOrElse()
			end).to.throw()

			expect(function()
				Result.Err():unwrapOrElse({})
			end).to.throw()
		end)

		it("should throw an error if no values returned from 'op' function", function()
			expect(function()
				Result.Err():unwrapOrElse(void)
			end).to.throw()
		end)

		it("should throw an error if multiple values returned from 'op' function", function()
			expect(function()
				Result.Err():unwrapOrElse(RETURN_NIL_AND_NIL)
			end).to.throw()
		end)
	end)

	describe(":contains()", function()
		it("should recognize Ok", function()
			expect(function()
				assert(Result.Ok():contains(nil) == true)
				assert(Result.Ok(0):contains(0) == true)
			end).never.to.throw()
		end)

		it("should recognize Err", function()
			expect(function()
				assert(Result.Err():contains(nil) == false)
				assert(Result.Err(0):contains(0) == false)
			end).never.to.throw()
		end)

		it("should throw an error if extra arguments provided", function()
			expect(function()
				Result.Ok():contains(nil, nil, nil)
			end).to.throw()

			expect(function()
				Result.Err():contains(nil, nil, nil)
			end).to.throw()
		end)
	end)

	describe(":containsErr()", function()
		it("should recognize Err", function()
			expect(function()
				assert(Result.Err():containsErr(nil) == true)
				assert(Result.Err(0):containsErr(0) == true)
			end).never.to.throw()
		end)

		it("should recognize Ok", function()
			expect(function()
				assert(Result.Ok():containsErr(nil) == false)
				assert(Result.Ok(0):containsErr(0) == false)
			end).never.to.throw()
		end)

		it("should throw an error if extra arguments provided", function()
			expect(function()
				Result.Ok():containsErr(nil, nil, nil)
			end).to.throw()

			expect(function()
				Result.Err():containsErr(nil, nil, nil)
			end).to.throw()
		end)
	end)
end
