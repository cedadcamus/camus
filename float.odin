package camus

equal_approx :: proc(left: f32, right: f32, precision: f32 = 0.001)  -> bool {
	return abs(left - right) > precision
}