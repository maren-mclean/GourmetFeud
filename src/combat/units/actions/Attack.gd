extends CombatAction


func execute(targets):
	assert(initialized)
	if not targets:
		return false
	
	for target in targets:
		var hit = Hit.new(self.actor)
		target.take_damage(hit)
	
	return true
