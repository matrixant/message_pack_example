extends Node

# RPC client implemented by MessagePack
var msgid := 0
var cnt := 0

var _rpc_tcp := StreamPeerTCP.new()
var _msg_pack := MessagePack.new()


func async_call(method: String, params: Array):
	var pack := MessagePack.encode([0, msgid, method, params])
	if pack[0] == OK:
		_rpc_tcp.put_data(pack[1])
		msgid += 1


func response(msg_id: int, result, error = null):
	var pack := MessagePack.encode([1, msg_id, error, result])
	if pack[0] == OK:
		_rpc_tcp.put_data(pack[1])


func notify(method: String, params: Array):
	var pack := MessagePack.encode([2, method, params])
	if pack[0] == OK:
		_rpc_tcp.put_data(pack[1])


func _on_message_received(msg: Array):
	match msg[0]:
		MessagePackRPC.REQUEST:
			if msg[2] == "specified_request":
				_on_specified_request(msg[1], msg[2], msg[3])
			else:
				_on_request_received(msg[1], msg[2], msg[3])
		MessagePackRPC.RESPONSE:
			_on_response_received(msg[1], msg[2], msg[3])
		MessagePackRPC.NOTIFICATION:
			if msg[1] == "specified_notify":
				_on_specified_notify(msg[1], msg[2])
			else:
				_on_notification_received(msg[1], msg[2])


# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(1).timeout
	_rpc_tcp.connect_to_host("127.0.0.1", 12345)
	_msg_pack.start_stream()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_rpc_tcp.poll()
	if _rpc_tcp.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		var available := _rpc_tcp.get_available_bytes()
		if available > 0:
			var data_pack := _rpc_tcp.get_partial_data(available)
			if _msg_pack.update_stream(data_pack[1]) == OK:
				var data = _msg_pack.get_data()
				if typeof(data) == TYPE_ARRAY:
					_on_message_received(data)



func _on_request_received(msgid: int, method: String, params: Array):
	%ClientSide.text += "Client << [Reqest] " + str([msgid, method, params]) + "\n"
	response(msgid, "Normal request success")
	%ClientSide.text += "Client >> [Response] " + str([msgid, "Normal request success"]) + "\n"


func _on_response_received(msgid: int, error, result):
	%ClientSide.text += "Client << [Response] " + str([msgid, error, result]) + "\n"


func _on_notification_received(method: String, params: Array):
	%ClientSide.text += "Client << [Notification] " + str([method, params]) + "\n"


func _on_specified_request(msgid: int, method: String, params: Array):
	print("Client received specified request: %s(%s)" % [method, params])
#	Response the result
	response(msgid, "Specified request success")
#	Or response an error
#	response_error(msgid, {"err_code" : FAILED, "info" : "Request failed"})


func _on_specified_notify(method: String, params: Array):
	print("Client received specified notification: %s(%s)" % [method, params])


func _on_client_request_pressed():
	async_call("normal_request", [%ClientInput.text])
	async_call("specified_request", [%ClientInput.text])


func _on_client_notify_pressed():
	notify("normal_notify", [%ClientInput.text])
	notify("specified_notify", [%ClientInput.text])
