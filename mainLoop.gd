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
	# pass # Replace with function body.





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

		var input1type = ""
		var input2type = "buche"
		var input3type = "buche"

		input1.thingToDispense = input1type
		input2.thingToDispense = input2type
		input3.thingToDispense = input3type

		var requirements1 = {"buche": 1}
		var requirements2 = {}
		var requirements3 = {}

		output1.requirements = requirements1
		output2.requirements = requirements2
		output3.requirements = requirements3

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
