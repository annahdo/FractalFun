extends Node

const JULIA = preload("res://fractals/Julia.gdshader")
const MANDELBROT = preload("res://fractals/Mandelbrot.gdshader")
const starting_fractal = 'Julia'
const MIN_ZOOM = 0.1
const MAX_ZOOM = 31000.0 # afterwards I see pixels
var MOUSE_DRAG = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Display.material = ShaderMaterial.new()
	set_fractal(starting_fractal)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func get_rel_mouse_pos() -> Vector2:
	var mouse_pos:Vector2 = get_viewport().get_mouse_position()
	var half_window_size = get_viewport().get_visible_rect().size/2.0
	# mouse position relative to middle of window
	mouse_pos.x = (mouse_pos.x-half_window_size.x)/half_window_size.x
	mouse_pos.y = (-mouse_pos.y + half_window_size.y)/half_window_size.y

	return mouse_pos
	
func update_zoom(zoom) -> void:
	zoom = max(zoom, MIN_ZOOM)
	zoom = min(zoom, MAX_ZOOM)
	$Display.material.set_shader_parameter("zoom", zoom)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
	var val:float
	# zoom in
	if Input.is_action_just_pressed("SCROLL_DOWN"):
		var zoom = $Display.material.get_shader_parameter("zoom") * 1.1
		update_zoom(zoom)
		
		var mouse_pos = get_rel_mouse_pos()
		var fractal_pos:Vector2 = $Display.material.get_shader_parameter("position")
		fractal_pos -= mouse_pos/zoom/10
		$Display.material.set_shader_parameter("position", fractal_pos)	
	# zoom out
	elif Input.is_action_just_pressed("SCROLL_UP"):
		var zoom = $Display.material.get_shader_parameter("zoom")
		# in order to return to the same point when zooming in and out we need to
		# update the position with the current zoom before updating the zoom.
		var mouse_pos = get_rel_mouse_pos()
		var fractal_pos:Vector2 = $Display.material.get_shader_parameter("position")
		fractal_pos += mouse_pos/zoom/10
		$Display.material.set_shader_parameter("position", fractal_pos)
		update_zoom(zoom/1.1)
		
	elif Input.is_action_just_pressed("MOUSE_LEFT"):
		if not mouse_on_control_panel():
			MOUSE_DRAG = true
	elif Input.is_action_just_released("MOUSE_LEFT"):
		MOUSE_DRAG = false
	update_aspect_ratio() 

func _input(event) -> void:
	if event is InputEventMouseMotion:
		if MOUSE_DRAG:
			print(Input.MOUSE_MODE_CAPTURED)
			var move:Vector2 = Vector2(event.relative.x, -event.relative.y) 
			var fractal_pos:Vector2 = $Display.material.get_shader_parameter("position")
			var zoom = $Display.material.get_shader_parameter("zoom")
			var screen_x = get_viewport().get_visible_rect().size.x
			print(move/zoom/screen_x)
			fractal_pos += move/zoom/screen_x
			$Display.material.set_shader_parameter("position", fractal_pos)


func set_fractal(fractal_type) -> void:
	if fractal_type == 'Julia':
		$Display.material.shader = JULIA
	elif fractal_type == 'Mandelbrot':
		$Display.material.shader = MANDELBROT
	set_default_shader_params(fractal_type)

# make sure the fractal is not squeezed it the window is resized or similar
func update_aspect_ratio() -> void:
	var vs:Vector2 = get_viewport().get_size()
	$Display.material.set_shader_parameter("aspect_ratio", vs.x/vs.y)

func mouse_on_control_panel() -> bool:
	var mouse_pos:Vector2 = get_viewport().get_mouse_position()
	var ui_size = $ControlPanel.size
	print('mouse: ', mouse_pos)
	print('ui_size: ', ui_size)
	if mouse_pos.x < ui_size.x and mouse_pos.y<ui_size.y:
		return true and $ControlPanel.visible
	
	return false
	
func set_default_shader_params(fractal_type) -> void:
	# Define a dictionary to hold default shader parameters
	var default_shader_params = {}
	default_shader_params['Julia']= {
		"zoom": 0.5,
		"position": Vector2(0.0, 0.0),
		"aspect_ratio": 1.778,
		"seed": Vector2(-0.794084, 0.136444),
		"power": 2.0,
		"iterations": 50
	}
	default_shader_params['Mandelbrot']= {
		"zoom": 0.36,
		"position": Vector2(0.75, 0.0),
		"aspect_ratio": 1.778,
		"power": 2.0,
		"iterations": 50
	}
	var shader_params = default_shader_params[fractal_type]
	for param in shader_params.keys():
		$Display.material.set_shader_parameter(param, shader_params[param])

	
	
