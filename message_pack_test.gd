extends Control


var server := TCPServer.new()
var msg_rpc := MessagePackRPC.new()


func _ready():
	msg_rpc.message_received.connect(message_handle)
	server.listen(12345, "127.0.0.1")


func _physics_process(delta):
	if server.is_listening():
		if server.is_connection_available():
			if not msg_rpc.is_rpc_connected():
				msg_rpc.takeover_connection(server.take_connection())


func message_handle(msg: Array):
	match msg[0]:
		0:
			%ServerSide.text += "Server << [Reqest] " + str(msg) + "\n"
			var time_dict := Time.get_datetime_dict_from_system()
			msg_rpc.response(msg[1], time_dict)
			%ServerSide.text += "Server >> [Respose] " + str([1, msg[1], time_dict])
		1:
			%ServerSide.text += "Server << [Respose] " + str(msg) + "\n"
			pass
		2:
			%ServerSide.text += "Server << [Notification] " + str(msg) + "\n"
	
	
