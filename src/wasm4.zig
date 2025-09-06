//
// WASM-4: https://wasm4.org/docs

const w4 = @This();

// ┌───────────────────────────────────────────────────────────────────────────┐
// │                                                                           │
// │ Platform Constants                                                        │
// │                                                                           │
// └───────────────────────────────────────────────────────────────────────────┘

pub const SCREEN_SIZE = 160;
pub const FRAMEBUFFER_SIZE = (SCREEN_SIZE * SCREEN_SIZE / 4);
pub const FONT_SIZE = 8;

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
pub const FRAMEBUFFER: *[FRAMEBUFFER_SIZE]u8 = @ptrFromInt(0xA0);

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

/// Draw a circle, with center at given x and y
pub fn circle(x: i32, y: i32, r: u32) void {
    oval(
        x - @as(i32, @intCast(r)),
        y - @as(i32, @intCast(r)),
        r * 2,
        r * 2,
    );
}

/// Draws a single pixel
pub fn pixel(x: i32, y: i32) void {
    if (x < 0 or x >= SCREEN_SIZE or y < 0 or y >= SCREEN_SIZE) return;

    const ux: usize = @intCast(x);
    const uy: usize = @intCast(y);

    const idx = (uy * SCREEN_SIZE + ux) >> 2;
    const shift = (ux & 0b11) * 2;
    const mask = @as(u8, 0b11) << @intCast(shift);
    const pc: u8 = @intCast(DRAW_COLORS.* & 0b1111);

    if (idx >= FRAMEBUFFER_SIZE or pc == 0) return;

    const c = (pc - 1) & 0b11;

    if (c == 0) return;

    FRAMEBUFFER[idx] = (c << @as(u3, @intCast(shift))) | (FRAMEBUFFER[idx] & ~mask);
}

/// Clear the entire screen
pub fn clear(c: u16) void {
    const p = @as(u8, @intCast((c - 1) & 0b11));
    const k: u8 = p | (p << 2) | (p << 4) | (p << 6);

    for (FRAMEBUFFER) |*x| x.* = k;
}

/// Set the color to use
pub fn color(c: u16) void {
    DRAW_COLORS.* = c;
}

/// Set the palette to use
pub fn palette(p: [4]u32) void {
    PALETTE.* = p;
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
pub const TONE_NOTE_MODE: u32 = 64;

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

    mx: *const i16 = MOUSE_X,
    my: *const i16 = MOUSE_Y,
    mb: *const u8 = MOUSE_BUTTONS,

    pub fn update(self: *Mouse) void {
        self.prev = self.data;

        self.data.x = self.mx.*;
        self.data.y = self.my.*;
        self.data.b = self.mb.*;

        if (self.data.x >= 0 and self.data.x < SCREEN_SIZE)
            self.x = self.data.x;

        if (self.data.y >= 0 and self.data.y < SCREEN_SIZE)
            self.y = self.data.y;
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

    pub fn pos(self: *Mouse) Pos {
        return .{ .x = self.x, .y = self.y };
    }
};

pub const Button = struct {
    prev: [4]u8 = .{0} ** 4,
    data: [4]u8 = .{0} ** 4,
    pads: [4]*const u8 = .{
        GAMEPAD1,
        GAMEPAD2,
        GAMEPAD3,
        GAMEPAD4,
    },

    pub fn update(self: *Button) void {
        self.prev = self.data;

        inline for (self.pads, 0..) |gp, i| {
            self.data[i] = gp.*;
        }
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

pub const Screen = struct {
    pub const width = SCREEN_SIZE;
    pub const height = SCREEN_SIZE;
    pub const box = Box.init(0, 0, width, height);
    pub const min = box.min();
    pub const max = box.max();
    pub const center = box.center();

    pub fn set(x: i32, y: i32, c: u16) void {
        box.set(x, y, c);
    }
};

pub const Pos = struct {
    x: i32 = 0,
    y: i32 = 0,

    pub fn xy(x: i32, y: i32) Pos {
        return .{ .x = x, .y = y };
    }

    pub fn add(self: Pos, other: Pos) Pos {
        return .{ .x = self.x + other.x, .y = self.y + other.y };
    }

    pub fn eql(self: Pos, other: Pos) bool {
        return self.x == other.x and self.y == other.y;
    }

    pub fn mul(self: Pos, s: i32) Pos {
        return .{ .x = self.x * s, .y = self.y * s };
    }

    pub fn dot(self: Pos, other: Pos) i32 {
        return self.x * other.x + self.y * other.y;
    }

    pub fn sum(self: Pos) i32 {
        return self.x + self.y;
    }

    pub fn len(self: Pos) i32 {
        return self.x * self.x + self.y * self.y;
    }

    pub fn lerp(self: Pos, other: Pos, t: u8) Pos {
        return .{
            .x = self.x + @divTrunc((other.x - self.x) * @as(i32, t), 256),
            .y = self.y + @divTrunc((other.y - self.y) * @as(i32, t), 256),
        };
    }

    pub fn line(self: Pos, other: Pos, c: u16) void {
        w4.color(c);
        w4.line(self.x, self.y, other.x, other.y);
    }

    pub fn set(self: Pos, c: u16) void {
        w4.color(c);
        w4.pixel(self.x, self.y);
    }
};

pub const Dim = struct {
    w: u32 = 1,
    h: u32 = 1,

    pub fn wh(w: u32, h: u32) Dim {
        return .{ .w = w, .h = h };
    }

    pub fn eql(self: Dim, other: Dim) bool {
        return self.w == other.w and self.h == other.h;
    }

    pub fn pos(self: Dim) Pos {
        return .{
            .x = if (self.w == 0) 0 else @intCast(self.w - 1),
            .y = if (self.h == 0) 0 else @intCast(self.h - 1),
        };
    }
};

pub const Box = struct {
    pos: Pos = .{},
    dim: Dim = .{},

    pub fn init(x: i32, y: i32, w: u32, h: u32) Box {
        return .{ .pos = .xy(x, y), .dim = .wh(w, h) };
    }

    pub fn min(self: Box) Pos {
        return self.pos;
    }

    pub fn max(self: Box) Pos {
        return self.pos.add(self.dim.pos());
    }

    pub fn center(self: Box) Pos {
        return .{
            .x = self.pos.x + @divTrunc(@as(i32, @intCast(self.dim.w)), 2),
            .y = self.pos.y + @divTrunc(@as(i32, @intCast(self.dim.h)), 2),
        };
    }

    pub fn fill(self: Box, c: u16) void {
        w4.color(c);
        w4.rect(self.pos.x, self.pos.y, self.dim.w, self.dim.h);
    }

    pub fn set(self: Box, x: i32, y: i32, c: u16) void {
        const sx = self.pos.x + x;
        const sy = self.pos.y + y;
        const ma = self.max();

        if (x < 0 or y < 0 or sx > ma.x or sy > ma.y) return;

        w4.color(c);
        w4.pixel(sx, sy);
    }
};
