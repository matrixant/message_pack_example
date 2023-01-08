extends Node

var msg_rpc := MessagePackRPC.new()


func _on_request_received(msgid: int, method: String, params: Array):
	%ClientSide.text += "Client << [Reqest] " + str([msgid, method, params]) + "\n"
	msg_rpc.response(msgid, "Normal request success")
	%ClientSide.text += "Client >> [Response] " + str([msgid, "Normal request success"]) + "\n"


func _on_response_received(msgid: int, error, result):
	%ClientSide.text += "Client << [Response] " + str([msgid, error, result]) + "\n"


func _on_notification_received(method: String, params: Array):
	%ClientSide.text += "Client << [Notification] " + str([method, params]) + "\n"


func _on_specified_request(msgid: int, method: String, params: Array):
	print("Client received specified request: %s(%s)" % [method, params])
#	Response the result
	msg_rpc.response(msgid, "Specified request success")
#	Or response an error
#	msg_rpc.response_error(msgid, {"err_code" : FAILED, "info" : "Request failed"})


func _on_specified_notify(method: String, params: Array):
	print("Client received specified notification: %s(%s)" % [method, params])


# Called when the node enters the scene tree for the first time.
func _ready():
#	msg_rpc.message_received.connect(_on_message_received)
	msg_rpc.request_received.connect(_on_request_received)
	msg_rpc.response_received.connect(_on_response_received)
	msg_rpc.notification_received.connect(_on_notification_received)
#	Specified request bind
	msg_rpc.register_request("specified_request", _on_specified_request)
#	Specified notification bind
	msg_rpc.register_notification("specified_notify", _on_specified_notify)
	await get_tree().create_timer(0.5).timeout
#	Currently only support tcp connection.
	msg_rpc.connect_to_host("127.0.0.1", 12345)


func _on_message_received(msg: Array):
	match msg[0]:
		MessagePackRPC.REQUEST:
			print("Client receive an request.")
		MessagePackRPC.RESPONSE:
			print("Client receive an response.")
		MessagePackRPC.NOTIFICATION:
			print("Client receive a notification.")


func _on_client_request_pressed():
	msg_rpc.async_callv("normal_request", [%ClientInput.text])
	msg_rpc.async_callv("specified_request", [%ClientInput.text])


func _on_client_notify_pressed():
	msg_rpc.notifyv("normal_notify", [%ClientInput.text])
	msg_rpc.notifyv("specified_notify", [%ClientInput.text])
