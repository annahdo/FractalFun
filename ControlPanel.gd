extends Panel


# Called when the node enters the scene tree for the first time.
func _ready():
	print('ready')
	call_deferred("_on_julia_button_pressed")



func _process(delta):
	# hide control panel
	if Input.is_action_just_released("KEY_ESCAPE"):
		visible = !visible
	if Input.is_action_just_released("KEY_QUIT"):
		get_tree().quit()


func _on_quit_button_pressed():
	get_tree().quit()

func _on_hide_button_pressed():
	visible = !visible


func _on_julia_button_pressed():
	get_parent().set_fractal('Julia')


func _on_mandelbrot_button_pressed():
	get_parent().set_fractal('Mandelbrot')
