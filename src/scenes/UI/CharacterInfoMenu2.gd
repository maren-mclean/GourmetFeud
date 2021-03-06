extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var unit
# Called when the node enters the scene tree for the first time.
func _update():

	var healthz = unit.stats.health
	var strengthz = unit.stats.strength
	var vital = unit.stats.vitality
	var charisma = unit.stats.charisma
	var confident = unit.stats.confidence
	var dexter = unit.stats.dexterity
	var speedz = unit.stats.speed
	
	$BaseHP2.text = "25"
	$CurrentHP2.text = str(healthz)
	 
	$BaseSTR2.text = "8"
	$CurrentSTR2.text = str(strengthz)
	 
	$BaseVIT2.text = "1"
	$CurrentVIT2.text = str(vital)
	 
	$BaseCHR2.text = "1"
	$CurrentCHR2.text = str(charisma)
	 
	$BaseCON2.text = "1"
	$CurrentCON2.text = str(confident)
	 
	$BaseDEX2.text = "1"
	$CurrentDEX2.text = str(dexter)
	 
	$BaseSPD2.text = "10"
	$CurrentSPD2.text = str(speedz)
	 
	

func toggle_visibility (visibility):
	self.visible = visibility

func attachunit(unit):
	self.unit = unit

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
