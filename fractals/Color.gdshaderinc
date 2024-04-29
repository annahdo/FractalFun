





vec4 getColor(float i, float red_freq, float red_phase, 
		float green_freq, float green_phase, 
		float blue_freq, float blue_phase) {
			
	float multiplier = 6.5; // = 2*pi makes sure that the complete range is covered 
	float red = (sin(red_freq*multiplier*i + red_phase) +1.0)/2.0;
	float green = (sin(green_freq*multiplier*i + green_phase) +1.0)/2.0;
	float blue = (sin(blue_freq*multiplier*i + blue_phase) +1.0)/2.0;

			
	return vec4(red, green, blue, 1.0);
}
