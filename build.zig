const std = @import("std");

pub fn build(b: *std.Build) void {
    _ = b.addModule("w4", .{
        .root_source_file = b.path("src/wasm4.zig"),
    });
}
