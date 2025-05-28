const w4 = @import("wasm4.zig");

const expect = @import("std").testing.expect;

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
