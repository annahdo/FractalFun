extends Node


const JULIA = preload("res://fractals/Julia.gdshader")
const MANDELBROT = preload("res://fractals/Mandelbrot.gdshader")
const starting_fractal = 'Julia'
var MOUSE_DRAG = false
var helpers
var default_params

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	helpers = Helpers.new()
	default_params = DefaultParams.new()
	$Display.material = ShaderMaterial.new()
	set_fractal(starting_fractal)

	

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
	var val:float
	# zoom in
	if Input.is_action_just_pressed("SCROLL_DOWN"):
		var zoom = $Display.material.get_shader_parameter("zoom") * 1.1
		helpers.update_zoom(self, zoom)
		
		var mouse_pos = helpers.get_rel_mouse_pos(self)
		var fractal_pos:Vector2 = $Display.material.get_shader_parameter("position")
		fractal_pos -= mouse_pos/zoom/10
		$Display.material.set_shader_parameter("position", fractal_pos)	
	# zoom out
	elif Input.is_action_just_pressed("SCROLL_UP"):
		var zoom = $Display.material.get_shader_parameter("zoom")
		# in order to return to the same point when zooming in and out we need to
		# update the position with the current zoom before updating the zoom.
		var mouse_pos = helpers.get_rel_mouse_pos(self)
		var fractal_pos:Vector2 = $Display.material.get_shader_parameter("position")
		fractal_pos += mouse_pos/zoom/10
		$Display.material.set_shader_parameter("position", fractal_pos)
		helpers.update_zoom(self, zoom/1.1)
		
	elif Input.is_action_just_pressed("MOUSE_LEFT"):
		if not helpers.mouse_on_control_panel(self):
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
	default_params.set_default_shader_params(self, fractal_type)


# make sure the fractal is not squeezed it the window is resized or similar
func update_aspect_ratio() -> void:
	var vs:Vector2 = get_viewport().get_size()
	$Display.material.set_shader_parameter("aspect_ratio", vs.x/vs.y)

func set_shader_param(param, value):
	$Display.material.set_shader_parameter(param, value)
	


	
	
