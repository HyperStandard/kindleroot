util = {}

function util.os()
	return _BUILD.OS -- blergh
end

function util.generatecall( command, arguments )
	if util.os() == "Windows" then
		return command .. ".exe " .. arguments
	else
		return "./" .. command .. " " .. arguments
	end
end

util.processes = {}

function util.run( command, callback )
	local proc = QProcess.new()

	local function proccallback( obj, code, status )
		local out = proc:readAll()

		callback( code, out )
	end

	proc:connect( "2finished(int,QProcess::ExitStatus)", wrap( proccallback, nil, "int,QProcess::ExitStatus" ) )
	proc:start( command, QIODevice.OpenModeFlag.ReadOnly )

	table.insert( util.processes, proc )
end

-- sigh

local wrapper = QObject.new()
local id = 0

function unconditional_wrap( fun, obj, args )
	args = args or ""

	wrapper:__addmethod( "runmethod" .. id .. "(" .. args .. ")", function( ... )
		if obj then
			return fun( obj, ... )
		else
			return fun( ... )
		end
	end )

	id = id + 1
	return wrapper, "1runmethod" .. id - 1 .. "(" .. args .. ")"
end

function wrap( fun, obj, args )
	if util.os() ~= "Windows" then return fun end

	return unconditional_wrap( fun, obj, args )
end