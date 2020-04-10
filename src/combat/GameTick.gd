extends Node

"""
List of GameTick Signals | Keeps flow of combat strict in order processing
GameTick Signals should emit in this order:
	Started GameTick
	Started Status Phase
	Finished Status Phase
	Started Charge Phase
	Finished Charge Phase
	Started GTP Phase
	Finished GTP Phase
	Started Action Phase
	Finished Action Phase
	Finished GameTick
"""
signal started_gametick
signal started_status_phase
signal finished_status_phase
signal started_charge_phase
signal finished_charge_phase
signal started_gtp_phase
signal finished_gtp_phase
signal started_action_phase
signal finished_action_phase
signal finished_gametick

onready var coliseum = get_parent()
onready var units = coliseum.get_node("Units")
onready var battlemenu = get_parent().get_node("CanvasLayer/BattleMenu")
onready var bm_waitbutton = battlemenu.get_node("BMButtonContainer/BMWaitButton")

signal finished_active_turns

var active = false
var gametick_counter = 0

"""
	Queue of readied units to take their turns the next available Action Phase
"""
var readied_units = [] 

func _ready():

	# Wait for level intro to be completed
	#intro_node.animation_player.play_intro()
	#yield(intro_node.animation_player, "finished_intro")
	pass


func initialize():
	# Connect components to relevant signals
	for unit in units.units:
		unit.initialize()
		self.connect("started_gtp_phase", unit, "progress_tick_counter")
		unit.connect("completed_turn", self, "unready_unit")
		unit.connect("unit_ready", self, "ready_unit")
	self.connect("finished_gtp_phase", self, "sort_unit_queue")
	print("initialized gametick")


func gametick_loop():
	while active:
		# ===== Start of GameTick =====
		self.gametick_counter += 1
		emit_signal("started_gametick", self.gametick_counter)
		
		# ===== Status Phase =====
		emit_signal("started_status_phase")
		emit_signal("finished_status_phase")
		
		# ===== Charge / Held Action Phase =====
		emit_signal("started_charge_phase")
		emit_signal("finished_charge_phase")
		
		# ===== GameTick+ Phase =====
		emit_signal("started_gtp_phase", self.gametick_counter)
		print("Gametick Loop Iteration: " + str(self.gametick_counter))
		for unit in units.units:
			print(unit.stats.tick_counter, "\t| ", unit.name)
		
		emit_signal("finished_gtp_phase")
		
		# ===== Action Phase =====
		emit_signal("started_action_phase")
		
		if not readied_units.empty():
			yield(self.take_active_turns(), "completed")
		
		emit_signal("finished_action_phase")
		
		# ===== Finished GameTick =====
		emit_signal("finished_gametick")


func ready_unit(unit):
	self.readied_units.append(unit)


func unready_unit(unit):
	#self.readied_units.erase(unit)
	pass


func sort_unit_queue():
	if not self.readied_units.empty():
		self.readied_units.sort_custom(self, "sort_units_by_tick_counter")


func sort_units_by_tick_counter(unit_1, unit_2):
	var unit_1_tick = unit_1.get_tick_counter()
	var unit_2_tick = unit_2.get_tick_counter()
	if unit_2_tick < unit_1_tick:
		return true
	else:
		return false


func take_active_turns():
	while not self.readied_units.empty():
		var unit = self.readied_units.front()
		print(unit.name + "'s Turn!")
		
		"""
			Instead of Unit taking control:
		unit.take_turn()
		yield(unit, "completed_turn")
			Have Unit set up anything particular with start of turn 
			(ie. animate, wind-up) 
			which yields a state to resume once the turn is completed 
			(ie. wind-down)
		"""
		
		yield(unit.take_active_turn(), "completed")
		
		# Set up battle menu at Unit location w/ small offset
		battlemenu.set_position(Vector2(unit.position.x + 32, unit.position.y + 32))
		# TODO: Connect Battle Menu button events to Unit specifics like navigation etc.
		
		# Set yield to UI's turn complete signal (The player selects "Wait")
		yield(bm_waitbutton, "pressed")
		
		# Once complete signal received, let unit finish its active turn (ie. wind down)
		battlemenu.set_position(Vector2(10000, 10000))
		unit.finish_active_turn()
		
		# Finally, remove the unit from the queue of readied units
		# Need to do this here so if the unit cancels its action we can instead
		# start the turn over cleanly at a previous point (nothing selected, 
		# after move+before attack, before move+after attack)
		# TODO: Be aware of how to distinguish what move the unit can currently do
		# Currently the Unit has a couple of stat variables distinguishing how many
		# move and attack actions it has left this turn. 
		# It gets reset on the .resume() call above
		self.readied_units.pop_front()
	print("emitting")
	emit_signal("finished_active_turns")
