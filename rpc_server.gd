extends Control


var server := TCPServer.new()
var msg_rpc := MessagePackRPC.new()


func _on_request_received(msgid: int, method: String, params: Array):
	%ServerSide.text += "Server << [Reqest] " + str([msgid, method, params]) + "\n"
	msg_rpc.response(msgid, "Normal request success")
	%ServerSide.text += "Server >> [Response] " + str([msgid, "Normal request success"]) + "\n"


func _on_response_received(msgid: int, error, result):
	%ServerSide.text += "Server << [Response] " + str([msgid, error, result]) + "\n"


func _on_notification_received(method: String, params: Array):
	%ServerSide.text += "Server << [Notification] " + str([method, params]) + "\n"


func _on_specified_request(msgid: int, method: String, params: Array):
	print("Server received specified request: %s(%s)" % [method, params])
#	Response the result
	msg_rpc.response(msgid, "Specified request success")
#	Or response an error
#	msg_rpc.response_error(msgid, {"err_code" : FAILED, "info" : "Request failed"})


func _on_specified_notify(method: String, params: Array):
	print("Server received specified notification: %s(%s)" % [method, params])


func _ready():
#	msg_rpc.message_received.connect(_on_message_received)
	msg_rpc.request_received.connect(_on_request_received)
	msg_rpc.response_received.connect(_on_response_received)
	msg_rpc.notification_received.connect(_on_notification_received)
#	Specified request bind
	msg_rpc.register_request("specified_request", _on_specified_request)
#	Specified notification bind
	msg_rpc.register_notification("specified_notify", _on_specified_notify)
	server.listen(12345, "127.0.0.1")


func _physics_process(delta):
	if server.is_listening():
		if server.is_connection_available():
			if not msg_rpc.is_rpc_connected():
				msg_rpc.takeover_connection(server.take_connection())


func _on_message_received(msg: Array):
	match msg[0]:
		MessagePackRPC.REQUEST:
			print("Server receive an request.")
		MessagePackRPC.RESPONSE:
			print("Server receive an response.")
		MessagePackRPC.NOTIFICATION:
			print("Server receive a notification.")


func _on_server_request_pressed():
	msg_rpc.async_callv("normal_request", [%ServerInput.text])
	msg_rpc.async_callv("specified_request", [%ServerInput.text])


func _on_server_notify_pressed():
	msg_rpc.notifyv("normal_notify", [%ServerInput.text])
	msg_rpc.notifyv("specified_notify", [%ServerInput.text])
