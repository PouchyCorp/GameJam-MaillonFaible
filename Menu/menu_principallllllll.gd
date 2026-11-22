extends Control
@on_ready var niveau = preload("res://game.tscn")

func _on_start_btn_pressed() -> void:
	get_tree().change_scene_to_packed(niveau)
	pass


func _on_quitter_btn_pressed() -> void:
	get_tree().quit()
