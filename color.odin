package camus

import sdl "vendor:sdl3"

color_negative :: proc(color: ^sdl.Color) {
    color_negative_sample(color, color^)
}

color_negative_sample :: proc(color: ^sdl.Color, sample: sdl.Color) {
    r: i16 = i16(sample.r) - 255
    g: i16 = i16(sample.g) - 255
    b: i16 = i16(sample.b) - 255
    color.r = u8(abs(r))
    color.g = u8(abs(g))
    color.b = u8(abs(b))
}

color_lighter :: proc(color: ^sdl.Color, amount: u8 = 25) {
    color_lighter_sample(color, color^)
}

color_lighter_sample :: proc(color: ^sdl.Color, sample: sdl.Color, amount: u8 = 25) {
    color.r = sample.r + amount
    color.g = sample.g + amount
    color.b = sample.b + amount
}

color_darker :: proc(color: ^sdl.Color, amount: u8 = 25) {
    color_darker_sample(color, color^)
}

color_darker_sample :: proc(color: ^sdl.Color, sample: sdl.Color, amount: u8 = 25) {
    color.r = sample.r - amount
    color.g = sample.g - amount
    color.b = sample.b - amount
}