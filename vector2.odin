package camus

vector_2_equal_approx :: proc(left: [2]f32, right: [2]f32, precision: f32 = 0.001) -> bool {
	return equal_approx(left[0], right[0], precision) && equal_approx(left[1], right[1], precision)
}