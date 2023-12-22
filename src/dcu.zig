const std = @import("std");
const decoder = @import("decoder.zig");

pub const Dcu = struct {
    const Self = @This();
    decoder: ?decoder.Decoder = null,
    version: u32 = 0,

    pub fn init(self: *Self, data: []const u8) void {
        self.decoder = decoder.Decoder.init(data);
    }

    pub fn decode(self: *Self) !void {
        self.version = try self.decoder.?.get(u32);

        std.debug.print("version: {x:08}\n", .{self.version});
    }
};
