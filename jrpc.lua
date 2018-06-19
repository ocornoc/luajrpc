local json = require "cjson"
local socket = require "socket"
local jrpc = {_VERSION = 20180615}
local jobj = require "jrpc_obj"
jrpc.obj = jobj

local function wrap_send(self, obj, override)
	if not override then
		assert(jobj.determine_type(obj))
	end
	
	return self.socket:send(json.encode(obj))
end

local function wrap_receive(self)
	local resp = self.socket:receive()
	
	return json.decode(resp)
end

jrpc.wrap_socket = function(sock)
	return {
		socket = sock,
		raw_send = sock.send,
		raw_receive = sock.receive,
		send = wrap_send,
		receive = wrap_receive,
	}
end

return jrpc
