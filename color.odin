package camus

color_negative :: proc(color: ^Color, sample: Color) {
    r: i16 = i16(sample.r) - 255
    g: i16 = i16(sample.g) - 255
    b: i16 = i16(sample.b) - 255
    color.r = u8(abs(r))
    color.g = u8(abs(g))
    color.b = u8(abs(b))
}