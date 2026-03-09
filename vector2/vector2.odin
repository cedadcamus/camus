package vector2

import "../float"


equal_approx :: proc(left: [2]f32, right: [2]f32, precision: f32 = 0.001) -> bool {
	return float.equal_approx(left[0], right[0], precision) && float.equal_approx(left[1], right[1], precision)
}