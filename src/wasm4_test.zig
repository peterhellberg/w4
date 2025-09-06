const w4 = @import("wasm4.zig");
const std = @import("std");

const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

pub fn expectEql(comptime T: type, a: T, b: T) !void {
    try std.testing.expect(a.eql(b));
}

test "Mouse pressed, held, released and position tracking" {
    var fake = w4.MouseData{ .x = 10, .y = 20 };

    var mouse = w4.Mouse{
        .mx = &fake.x,
        .my = &fake.y,
        .mb = &fake.b,
    };

    { // Initial state (button not pressed)
        mouse.update();
    }

    { // Press mouse left button
        fake.b = w4.MOUSE_LEFT;
        fake.x = 12;
        fake.y = 22;

        mouse.update();

        try expect(mouse.pressed(w4.MOUSE_LEFT));
        try expect(mouse.x == 12);
        try expect(mouse.y == 22);
    }

    { // Continue holding
        mouse.update();

        try expect(mouse.held(1));
    }

    { // Release
        fake.b = 0;

        mouse.update();

        try expect(mouse.released(1));
    }
}

test "Button pressed, held, released" {
    var fake = [_]u8{ 0, 0, 0, 0 };

    var buttons = w4.Button{
        .pads = [_]*const u8{
            &fake[0],
            &fake[1],
            &fake[2],
            &fake[3],
        },
    };

    { // Initial state (button not pressed)
        fake[0] = 0;

        buttons.update();
    }

    { // Pressed
        fake[0] = 1;

        buttons.update();

        try expect(buttons.pressed(0, 1));
    }

    { // Held
        buttons.update();

        try expect(buttons.held(0, 1));
    }

    { // Released
        fake[0] = 0;

        buttons.update();

        try expect(buttons.released(0, 1));
    }
}

test "Screen behaves as expected" {
    const s = w4.Screen;

    {
        try expectEqual(s.width, w4.SCREEN_SIZE);
        try expectEqual(s.height, w4.SCREEN_SIZE);
    }

    {
        try expectEqual(s.min.x, 0);
        try expectEqual(s.min.y, 0);
    }

    {
        try expectEqual(s.max.x, w4.SCREEN_SIZE - 1);
        try expectEqual(s.max.y, w4.SCREEN_SIZE - 1);
    }

    {
        try expectEqual(s.center.x, w4.SCREEN_SIZE / 2);
        try expectEqual(s.center.y, w4.SCREEN_SIZE / 2);
    }
}

test "Pos behaves as expected" {
    const a = w4.Pos.xy(1, 2);
    const b = w4.Pos.xy(3, 4);

    try expect(a.mul(2).eql(.{ .x = 2, .y = 4 }));
    try expect(a.add(b).eql(.{ .x = 4, .y = 6 }));

    try expectEqual(3, a.sum());
    try expectEqual(5, a.len());

    const c = a.lerp(b.mul(50), 128);

    try expectEqual(c.x, 75);
    try expectEqual(c.y, 101);
}

test "Dim behaves as expected" {
    const a = w4.Dim.wh(0, 0);
    const b = w4.Dim.wh(1, 1);
    const c = w4.Dim.wh(2, 4);

    try expect(a.pos().eql(.{ .x = 0, .y = 0 }));
    try expect(b.pos().eql(.{ .x = 0, .y = 0 }));
    try expect(c.pos().eql(.{ .x = 1, .y = 3 }));
}

test "Box behaves as expected" {
    const a = w4.Box.init(1, 2, 3, 4);
    const b = w4.Box.init(2, 4, 6, 8);

    try expectEql(w4.Pos, a.pos, a.min());
    try expectEql(w4.Pos, a.pos, .{ .x = 1, .y = 2 });
    try expectEql(w4.Dim, a.dim, .{ .w = 3, .h = 4 });

    try expectEql(w4.Pos, b.pos, b.min());
    try expectEql(w4.Pos, b.pos, .{ .x = 2, .y = 4 });
    try expectEql(w4.Dim, b.dim, .{ .w = 6, .h = 8 });
}
