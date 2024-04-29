shader_type canvas_item;

#include "res://fractals/Color.gdshaderinc"


// color values
uniform float red_freq=1.6615;
uniform float green_freq=1.246;
uniform float blue_freq=0.831;
uniform float red_phase=0;
uniform float green_phase=0;
uniform float blue_phase=0;

uniform float zoom = 0.5;
uniform highp vec2 position = vec2(0.0, 0.0);
uniform float aspect_ratio = 1.778;

uniform highp vec2 seed = vec2(-0.794084, 0.136444);
uniform float power = 2.0;
uniform float iterations = 50.0;
uniform float divergence_threshhold = 4.0;

void fragment() {	
	float i = 0.0;
	
	highp vec2 c = seed;
	
	highp vec2 z;
	z.x = aspect_ratio * (UV.x - 0.5) / zoom - position.x;
	z.y = (UV.y - 0.5) / zoom + position.y;
	
	if(power==2.0)
		while( i<iterations && length(z) <= divergence_threshhold ) { 
			z = vec2(z.x*z.x - z.y*z.y, power*z.x*z.y) + c;		//20fps
			i++;		
		}		

	vec4 color;

	if (i >= iterations) 
		color = vec4(0.0, 0.0, 0.0, 1.0);
	else { 
		if(power>1.) {
			 i -= log(log(length(z))) / log(power);	
		}
		color = getColor(i/iterations, red_freq, red_phase, 
		green_freq, green_phase, 
		blue_freq, blue_phase);
	}
		
	COLOR = color;
}
