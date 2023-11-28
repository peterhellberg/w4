//
// WASM-4: https://wasm4.org/docs

// ┌───────────────────────────────────────────────────────────────────────────┐
// │                                                                           │
// │ Platform Constants                                                        │
// │                                                                           │
// └───────────────────────────────────────────────────────────────────────────┘

pub const SCREEN_SIZE: u32 = 160;

// ┌───────────────────────────────────────────────────────────────────────────┐
// │                                                                           │
// │ Memory Addresses                                                          │
// │                                                                           │
// └───────────────────────────────────────────────────────────────────────────┘

pub const PALETTE: *[4]u32 = @ptrFromInt(0x04);
pub const DRAW_COLORS: *u16 = @ptrFromInt(0x14);
pub const GAMEPAD1: *const u8 = @ptrFromInt(0x16);
pub const GAMEPAD2: *const u8 = @ptrFromInt(0x17);
pub const GAMEPAD3: *const u8 = @ptrFromInt(0x18);
pub const GAMEPAD4: *const u8 = @ptrFromInt(0x19);
pub const MOUSE_X: *const i16 = @ptrFromInt(0x1a);
pub const MOUSE_Y: *const i16 = @ptrFromInt(0x1c);
pub const MOUSE_BUTTONS: *const u8 = @ptrFromInt(0x1e);
pub const SYSTEM_FLAGS: *u8 = @ptrFromInt(0x1f);
pub const NETPLAY: *const u8 = @ptrFromInt(0x20);
pub const FRAMEBUFFER: *[6400]u8 = @ptrFromInt(0xA0);

pub const BUTTON_1: u8 = 1;
pub const BUTTON_2: u8 = 2;
pub const BUTTON_LEFT: u8 = 16;
pub const BUTTON_RIGHT: u8 = 32;
pub const BUTTON_UP: u8 = 64;
pub const BUTTON_DOWN: u8 = 128;

pub const MOUSE_LEFT: u8 = 1;
pub const MOUSE_RIGHT: u8 = 2;
pub const MOUSE_MIDDLE: u8 = 4;

pub const SYSTEM_PRESERVE_FRAMEBUFFER: u8 = 1;
pub const SYSTEM_HIDE_GAMEPAD_OVERLAY: u8 = 2;

// ┌───────────────────────────────────────────────────────────────────────────┐
// │                                                                           │
// │ Drawing Functions                                                         │
// │                                                                           │
// └───────────────────────────────────────────────────────────────────────────┘

/// Copies pixels to the framebuffer.
pub extern fn blit(sprite: [*]const u8, x: i32, y: i32, width: u32, height: u32, flags: u32) void;

/// Copies a subregion within a larger sprite atlas to the framebuffer.
pub extern fn blitSub(sprite: [*]const u8, x: i32, y: i32, width: u32, height: u32, src_x: u32, src_y: u32, stride: u32, flags: u32) void;

pub const BLIT_2BPP: u32 = 1;
pub const BLIT_1BPP: u32 = 0;
pub const BLIT_FLIP_X: u32 = 2;
pub const BLIT_FLIP_Y: u32 = 4;
pub const BLIT_ROTATE: u32 = 8;

/// Draws a line between two points.
pub extern fn line(x1: i32, y1: i32, x2: i32, y2: i32) void;

/// Draws an oval (or circle).
pub extern fn oval(x: i32, y: i32, width: u32, height: u32) void;

/// Draws a rectangle.
pub extern fn rect(x: i32, y: i32, width: u32, height: u32) void;

/// Draws text using the built-in system font.
pub fn text(str: []const u8, x: i32, y: i32) void {
    textUtf8(str.ptr, str.len, x, y);
}
extern fn textUtf8(strPtr: [*]const u8, strLen: usize, x: i32, y: i32) void;

/// Draws a vertical line
pub extern fn vline(x: i32, y: i32, len: u32) void;

/// Draws a horizontal line
pub extern fn hline(x: i32, y: i32, len: u32) void;

/// Draws a single pixel
pub fn pixel(x: i32, y: i32) void {
    if (x < 0 or x > SCREEN_SIZE or y < 0 or y > SCREEN_SIZE) {
        return;
    }

    const ux: usize = @intCast(x);
    const uy: usize = @intCast(y);
    const idx: usize = (uy * 160 + ux) >> 2;
    const sx: u3 = @intCast(x);
    const shift = (sx & 0b11) * 2;
    const mask = @as(u8, 0b11) << shift;
    const palette_color: u8 = @intCast(DRAW_COLORS.* & 0b1111);

    if (palette_color == 0) {
        return;
    }

    const c = (palette_color - 1) & 0b11;

    FRAMEBUFFER[idx] = (c << shift) | (FRAMEBUFFER[idx] & ~mask);
}

/// Clear the entire screen
pub fn clear(c: u8) void {
    for (FRAMEBUFFER) |*x| {
        x.* = c - 1 | (c - 1 << 2) | (c - 1 << 4) | (c - 1 << 6);
    }
}

// ┌───────────────────────────────────────────────────────────────────────────┐
// │                                                                           │
// │ Sound Functions                                                           │
// │                                                                           │
// └───────────────────────────────────────────────────────────────────────────┘

/// Plays a sound tone.
pub extern fn tone(frequency: u32, duration: u32, volume: u32, flags: u32) void;

pub const TONE_PULSE1: u32 = 0;
pub const TONE_PULSE2: u32 = 1;
pub const TONE_TRIANGLE: u32 = 2;
pub const TONE_NOISE: u32 = 3;
pub const TONE_MODE1: u32 = 0;
pub const TONE_MODE2: u32 = 4;
pub const TONE_MODE3: u32 = 8;
pub const TONE_MODE4: u32 = 12;
pub const TONE_PAN_LEFT: u32 = 16;
pub const TONE_PAN_RIGHT: u32 = 32;

// ┌───────────────────────────────────────────────────────────────────────────┐
// │                                                                           │
// │ Storage Functions                                                         │
// │                                                                           │
// └───────────────────────────────────────────────────────────────────────────┘

/// Reads up to `size` bytes from persistent storage into the pointer `dest`.
pub extern fn diskr(dest: [*]u8, size: u32) u32;

/// Writes up to `size` bytes from the pointer `src` into persistent storage.
pub extern fn diskw(src: [*]const u8, size: u32) u32;

// ┌───────────────────────────────────────────────────────────────────────────┐
// │                                                                           │
// │ Other Functions                                                           │
// │                                                                           │
// └───────────────────────────────────────────────────────────────────────────┘

/// Prints a message to the debug console.
pub fn trace(x: []const u8) void {
    traceUtf8(x.ptr, x.len);
}
extern fn traceUtf8(strPtr: [*]const u8, strLen: usize) void;

/// Use with caution, as there's no compile-time type checking.
///
/// * %c, %d, and %x expect 32-bit integers.
/// * %f expects 64-bit floats.
/// * %s expects a *zero-terminated* string pointer.
///
/// See https://github.com/aduros/wasm4/issues/244 for discussion and type-safe
/// alternatives.
pub extern fn tracef(x: [*:0]const u8, ...) void;

// ┌───────────────────────────────────────────────────────────────────────────┐
// │                                                                           │
// │ Higher Level API                                                          │
// │                                                                           │
// └───────────────────────────────────────────────────────────────────────────┘

pub const MouseData = struct {
    x: i16 = 0,
    y: i16 = 0,
    b: u8 = 0,
};

pub const Mouse = struct {
    x: i32 = 0,
    y: i32 = 0,

    data: MouseData = .{},
    prev: MouseData = .{},

    pub fn update(self: *Mouse) void {
        self.prev = self.data;

        self.data.x = MOUSE_X.*;
        self.data.y = MOUSE_Y.*;
        self.data.b = MOUSE_BUTTONS.*;

        if (self.data.x >= 0 and self.data.x <= SCREEN_SIZE)
            self.x = @as(i32, @intCast(self.data.x));

        if (self.data.y >= 0 and self.data.y <= SCREEN_SIZE)
            self.y = @as(i32, @intCast(self.data.y));
    }

    pub fn pressed(self: *Mouse, btn: u8) bool {
        return (self.data.b & btn != 0) and !(self.prev.b & btn != 0);
    }

    pub fn held(self: *Mouse, btn: u8) bool {
        return (self.data.b & btn != 0) and (self.prev.b & btn != 0);
    }

    pub fn released(self: *Mouse, btn: u8) bool {
        return !(self.data.b & btn != 0) and (self.prev.b & btn != 0);
    }
};

pub const Button = struct {
    prev: [4]u8 = .{0} ** 4,
    data: [4]u8 = .{0} ** 4,

    pub fn update(self: *Button) void {
        self.prev = self.data;

        self.data[0] = GAMEPAD1.*;
        self.data[1] = GAMEPAD2.*;
        self.data[2] = GAMEPAD3.*;
        self.data[3] = GAMEPAD4.*;
    }

    pub fn pressed(self: *Button, n: u2, btn: u8) bool {
        return (self.data[n] & btn != 0) and !(self.prev[n] & btn != 0);
    }

    pub fn held(self: *Button, n: u2, btn: u8) bool {
        return (self.data[n] & btn != 0) and (self.prev[n] & btn != 0);
    }

    pub fn released(self: *Button, n: u2, btn: u8) bool {
        return !(self.data[n] & btn != 0) and (self.prev[n] & btn != 0);
    }
};
