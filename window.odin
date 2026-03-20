package camus

import sdl "vendor:sdl3"

window_size := []i32{640, 480}
window_size_f := []f32{640, 480}

window_size_changed :: proc() {
	sdl.GetWindowSize(window, &window_size[0], &window_size[1])
	window_size_f[0] = f32(window_size[0])
	window_size_f[1] = f32(window_size[1])
}
