extends Node

var msg_rpc := MessagePackRPC.new()
var cnt := 0

func _on_message_received(msg: Array):
	match msg[0]:
		0:
			%ClientSide.text += "Client << [Reqest] " + str(msg) + "\n"
			var time_dict := Time.get_datetime_dict_from_system()
			msg_rpc.response(msg[1], time_dict)
			%ClientSide.text += "Client >> [Respose] " + str([1, msg[1], time_dict])
		1:
			%ClientSide.text += "Client << [Respose] " + str(msg) + "\n"
			pass
		2:
			%ClientSide.text += "Client << [Notification] " + str(msg) + "\n"
	

# Called when the node enters the scene tree for the first time.
func _ready():
	msg_rpc.message_received.connect(_on_message_received)
	await get_tree().create_timer(1).timeout
#	Currently only support tcp connection.
	msg_rpc.connect_to("tcp://127.0.0.1:12345")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		msg_rpc.async_callv("test", [])
		msg_rpc.notifyv("test", [1.2, 3, true, {"k": null}, cnt])
		cnt += 1
	pass

