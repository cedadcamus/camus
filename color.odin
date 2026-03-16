package camus

import sdl "vendor:sdl3"

color_to_fcolor :: proc(color: ^sdl.FColor, sample: sdl.Color) {
    color.r = f32(sample.r) / 255
    color.g = f32(sample.g) / 255
    color.b = f32(sample.b) / 255
    color.a = f32(sample.a) / 255
}

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

color_negative_sample_tof :: proc(color: ^sdl.FColor, sample: sdl.Color) {
    r: i16 = i16(sample.r) - 255
    g: i16 = i16(sample.g) - 255
    b: i16 = i16(sample.b) - 255
    color.r = f32(abs(r) / 255)
    color.g = f32(abs(g) / 255)
    color.b = f32(abs(b) / 255)
    color.a = f32(sample.a) / 255
}

color_lighter :: proc(color: ^sdl.Color, amount: u8 = 25) {
    color_lighter_sample(color, color^)
}

color_lighter_sample :: proc(color: ^sdl.Color, sample: sdl.Color, amount: u8 = 25) {
    color.r = sample.r + amount
    color.g = sample.g + amount
    color.b = sample.b + amount
}

color_lighter_sample_tof :: proc(color: ^sdl.FColor, sample: sdl.Color, amount: u8 = 25) {
    color.r = f32(sample.r + amount) / 255
    color.g = f32(sample.g + amount) / 255
    color.b = f32(sample.b + amount) / 255
    color.a = f32(sample.a) / 255
}

color_darker :: proc(color: ^sdl.Color, amount: u8 = 25) {
    color_darker_sample(color, color^)
}

color_darker_sample :: proc(color: ^sdl.Color, sample: sdl.Color, amount: u8 = 25) {
    color.r = sample.r - amount
    color.g = sample.g - amount
    color.b = sample.b - amount
}

color_darker_sample_tof :: proc(color: ^sdl.FColor, sample: sdl.Color, amount: u8 = 25) {
    color.r = f32(sample.r - amount) / 255
    color.g = f32(sample.g - amount) / 255
    color.b = f32(sample.b - amount) / 255
    color.a = f32(sample.a) / 255
}
