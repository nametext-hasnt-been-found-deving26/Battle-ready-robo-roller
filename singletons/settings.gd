extends Node

var dash_modes = ["drag", "stop", "mixed"]
var current_dash_mode := "drag"

func save_dash_mode():
	var cfg := ConfigFile.new()
	cfg.set_value("Abilities", "down_dash_mode", current_dash_mode)
	cfg.save("user://settings.ini")

func load_dash_mode():
	var cfg := ConfigFile.new()
	if cfg.load("user://settings.ini") == OK:
		current_dash_mode = cfg.get_value("Abilities", "down_dash_mode", "drag")

func cycle_dash_mode():
	var index = dash_modes.find(current_dash_mode)
	index = (index + 1) % dash_modes.size()
	current_dash_mode = dash_modes[index]
	save_dash_mode()
