extends Node2D
# Main loop
var input1: InputThingy = null
var input2: InputThingy = null
var input3: InputThingy = null

var output1: OutputThingy = null
var output2: OutputThingy = null
var output3: OutputThingy = null

var timer: Timer = null
var phaseID = 0;

var file = "res://Assets/balancing.json"
var json_as_text = FileAccess.get_file_as_string(file)
var json_as_dict = JSON.parse_string(json_as_text) as Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	input1 = %Constructs.get_node("InputThingy1") as InputThingy
	input2 = %Constructs.get_node("InputThingy2") as InputThingy
	input3 = %Constructs.get_node("InputThingy3") as InputThingy

	output1 = %Constructs.get_node("OutputThingy1") as OutputThingy
	output2 = %Constructs.get_node("OutputThingy2") as OutputThingy
	output3 = %Constructs.get_node("OutputThingy3") as OutputThingy

	timer = get_node("PhaseTimer")
	timer.connect("timeout", Callable(self, "_on_phase_timer_timeout"))





# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	
	
	if (output1.requirementsMet() and output2.requirementsMet() and output3.requirementsMet()):
	
		# TODO : play happy sound and increase score

		# Clear every contraption on the scene
		for child in %Constructs.get_children():
			if child is Contraption:
				child.clear_items()

		phaseID += 1

		input1.emitting = false
		input2.emitting = false
		input3.emitting = false

		var nextWaveStartTime = 5 # TODO read the json

		timer.start(nextWaveStartTime)

		var dict = json_as_dict[str(phaseID)]["sources"]

		input1.thingToDispense = dict["0"]
		input2.thingToDispense = dict["1"]
		input3.thingToDispense = dict["2"]

		dict = json_as_dict[str(phaseID)]["requirements"]

		output1.requirements = dict["0"]
		output2.requirements = dict["1"]
		output3.requirements = dict["2"]

		output1._update_requirements_label()
		output2._update_requirements_label()
		output3._update_requirements_label()	

	if timer.is_stopped() == false:
		var timeLeft = timer.time_left
		var timeLeftInt = int(timeLeft)
		var timeLeftStr = str(timeLeftInt)
		var label : Label = get_node("PhaseTimerLabel")
		label.visible = true
		label.text = "Next wave in: " + timeLeftStr + "s"

	else:
		var label : Label = get_node("PhaseTimerLabel")
		label.visible = false




func _on_phase_timer_timeout() -> void:
	# TODO : read the json and update the requirements of the output thingies
	input1.emitting = true
	input2.emitting = true
	input3.emitting = true


func _on_command_button_pressed_conveyor() -> void:

	Grid._on_contraption_command("conveyor")
	pass # Replace with function body.


func _on_command_button_pressed_splitter() -> void:
	Grid._on_contraption_command("splitter")
	pass # Replace with function body.


func _on_command_button_pressed_heater() -> void:
	Grid._on_contraption_command("heater")
	pass # Replace with function body.


func _on_command_button_pressed_merger() -> void:
	Grid._on_contraption_command("merger")
	pass # Replace with function body.


func _on_command_button_pressed_cutter() -> void:
	Grid._on_contraption_command("cutter")
	pass # Replace with function body.
