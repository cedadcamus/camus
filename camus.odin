package camus

import "base:runtime"
import "core:log"
import sdl "vendor:sdl3"
import "vector2"
import "core:time"

// show
debug := false

is_running := false

// callbacks
InitCallback :: proc()
init: InitCallback = proc() {}
TickCallback :: proc(delta_time: f64)
tick: TickCallback = proc(delta_time: f64) {}
FixedTickCallback :: proc()
fixed_tick: FixedTickCallback = proc() {}

// settings
background_color: Color
window_size: vector2.Vector2Int = vector2.Vector2Int{640, 480}

// generated variables
window: ^sdl.Window
renderer: ^sdl.Renderer

Color :: struct {
	r: u8,
	g: u8,
	b: u8,
	a: u8,
}

run :: proc() {
	old_time : time.Time = time.now()
	current_time: time.Time
	delta_time: f64
	context.logger = log.create_console_logger()

	is_running = true
	if debug {
		log.logf(runtime.Logger_Level.Info, "game started")
	}
	sdl_init := sdl.Init(sdl.INIT_VIDEO)
	if !sdl_init {
		log.panic(sdl.GetError())
	}
	window = sdl.CreateWindow("Camus", window_size.x, window_size.y, sdl.WINDOW_OPENGL)
	if window == nil {
		log.panic(sdl.GetError())
	}
	renderer = sdl.CreateRenderer(window, nil)
	if renderer == nil {
		log.panic(sdl.GetError())
	}

	init()
	
	for is_running {
		event:sdl.Event
		for sdl.PollEvent(&event) {
			if event.type == sdl.EventType.QUIT {
				is_running = false
			}
		}
		
		sdl.SetRenderDrawColor(renderer, background_color.r, background_color.g, background_color.b, background_color.a)
		sdl.RenderClear(renderer)
		
		current_time = time.now()
		delta_time = time.duration_milliseconds(time.diff(old_time, current_time))
		old_time = current_time
		
		// TODO update when physics
		tick(delta_time)
		
		sdl.RenderPresent(renderer)
	}

	sdl.DestroyWindow(window)
	if debug {
		log.logf(runtime.Logger_Level.Info, "game ended")
	}
}


draw_line :: proc(color: Color, start: vector2.Vector2, end: vector2.Vector2) {
	sdl.SetRenderDrawColor(renderer, color.r, color.g, color.b, color.a)
	sdl.RenderLine(renderer, start.x, start.y, end.x, end.y)
}


draw_rect :: proc(color: Color, rect: ^sdl.FRect) {
	sdl.SetRenderDrawColor(renderer, color.r, color.g, color.b, color.a)
	sdl.RenderRect(renderer, rect)
}