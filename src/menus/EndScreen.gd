
extends Control


func _ready():
	$MarginContainer/Menu/Buttons/MainMenu.grab_focus()
	for button in $MarginContainer/Menu/Buttons.get_children():
		button.connect("pressed", self, "_on_Button_pressed", [button.scene_to_load])


func _on_Button_pressed(scene_to_load):
	print(scene_to_load)
	get_tree().change_scene(scene_to_load)
	
func _on_EndGame_pressed():
	get_tree().quit()
#Dont put end Game under Buttons or will iterate as a normal button
