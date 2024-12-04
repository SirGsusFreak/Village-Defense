extends ProgressBar

# Updates the value of the ProgressBar
func update_health_bar(current_health: int, max_health: int) -> void:
	self.max_value = max_health  # Set the maximum health value
	self.value = current_health  # Set the current health value
	
