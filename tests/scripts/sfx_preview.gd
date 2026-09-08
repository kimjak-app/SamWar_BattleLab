extends Control

func _ready() -> void:
	$Content/Enabled.set_pressed_no_signal(GameAudio.is_sfx_enabled())
	$Content/Volume.set_value_no_signal(GameAudio.get_sfx_volume())
	$Content/Enabled.toggled.connect(GameAudio.set_sfx_enabled)
	$Content/Volume.value_changed.connect(GameAudio.set_sfx_volume)
	for button in $Content/Grid.get_children():
		button.pressed.connect(GameAudio.play_sfx.bind(str(button.name)))
