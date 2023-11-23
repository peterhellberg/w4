const std = @import("std");

pub fn build(b: *std.Build) void {
    _ = b.addModule("w4", .{ .source_file = .{
        .path = "src/wasm4.zig",
    } });
}
