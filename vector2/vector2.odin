package vector2

import "../float"

Vector2 :: struct {
	x: f32,
	y: f32,
}

Vector2Int :: struct {
	x: i32,
	y: i32,
}

Vector2U8 :: struct {
	x: u8,
	y: u8,
}


ZERO : Vector2 : Vector2{0, 0}

equal_approx :: proc(left: Vector2, right: Vector2, precision: f32 = 0.001) -> bool {
	return float.equal_approx(left.x, right.x, precision) && float.equal_approx(left.y, right.y, precision)
}