extends Node

var MachineSpeed = 3.0;

var DropTime = 6.0;

var DispenseTime = 3.0;

enum Sides {
	LEFT,
	RIGHT,
	FRONT,
	BACK
}

var file = "res://Assets/transformation.json"
var json_as_text = FileAccess.get_file_as_string(file)
var json_as_dict = JSON.parse_string(json_as_text) as Dictionary

var OilDrainPerSecond = 1.5;
var OilRecovery = 25.0;

var MaxOil = 100.0;
var MinOil = 0.0;
var OilWarningLevel = 20.0;
var OilCriticalLevel = 5.0;
