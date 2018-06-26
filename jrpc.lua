local jrpc_obj = {}

local function check_type(val, name, ...)
	local valtype = type(val)
	
	for _,v in ipairs({...}) do
		if valtype == v then
			return true
		end
	end
	
	return nil, name .. " is an invalid type"
end

-- Validates a request object. This also will validate a notification object.
jrpc_obj.validate_request = function(obj)
	if obj.jsonrpc ~= "2.0" then
		return nil, "Incorrect version"
	elseif not check_type(obj.method, "method", "string") then
		return check_type(obj.method, "method", "string")
	elseif not check_type(obj.params, "params", "nil", "table")  then
		return check_type(obj.params, "params", "nil", "table")
	end
	
	return check_type(obj.id, "id", "number", "string", "nil")
end

-- Validates a request object strictly.
jrpc_obj.validate_strict_request = function(obj)
	if obj.jsonrpc ~= "2.0" then
		return nil, "Incorrect version"
	elseif not check_type(obj.method, "method", "string") then
		return check_type(obj.method, "method", "string")
	elseif not check_type(obj.params, "params", "nil", "table")  then
		return check_type(obj.params, "params", "nil", "table")
	end
	
	return check_type(obj.id, "id", "number", "string")
end

-- Validates a notification object.
jrpc_obj.validate_notification = function(obj)
	if obj.jsonrpc ~= "2.0" then
		return nil, "Incorrect version"
	elseif not check_type(obj.method, "method", "string") then
		return check_type(obj.method, "method", "string")
	elseif not check_type(obj.params, "params", "nil", "table")  then
		return check_type(obj.params, "params", "nil", "table")
	end
	
	return check_type(obj.id, "id", "nil")
end

-- A boolean xor function.
local function xor(a, b)
	return (a or b) and not (a and b)
end

-- Validates a response object.
jrpc_obj.validate_response = function(obj)
	if obj.jsonrpc ~= "2.0" then
		return nil, "Incorrect version"
	elseif xor(obj.result == nil, obj.error == nil) then
		return nil, "result == error"
	elseif obj.result == nil and not jrpc_obj.validate_error(obj.error) then
		return nil, "Invalid error object"
	elseif obj.error and obj.id ~= nil then
		return nil, "id present on error"
	end
	
	return check_type(obj.id, "id", "number", "string")
end

-- Validates an error object.
jrpc_obj.validate_error = function(obj)
	if not check_type(obj.code, "code", "number") then
		return check_type(obj.code, "code", "number")
	elseif code % 1 ~= 0 then
		return nil, "code isn't an integer"
	elseif not check_type(obj.message, "message", "string") then
		return check_type(obj.code, "code", "string")
	end
	
	return true
end

-- Determines the type of object.
jrpc_obj.determine_type = function(obj)
	if jrpc_obj.validate_request(obj) then
		return "request"
	elseif jrpc_obj.validate_notification(obj) then
		return "notification"
	elseif jrpc_obj.validate_response(obj) then
		return "response"
	elseif jrpc_obj.validate_error(obj) then
		return "error"
	else
		return nil, "Unknown type"
	end
end

return jrpc_obj
