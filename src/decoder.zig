pub const Decoder = struct {
    const Self = @This();
    data: ?[]const u8 = null,
    pos: usize = 0,
    ptr: ?[*]const u8 = null,

    pub fn init(data: []const u8) Self {
        var this = Self{};
        this.data = data;
        this.ptr = data.ptr;
        return this;
    }

    pub fn get(self: *Self, comptime T: type) !T {
        if (self.pos + @sizeOf(T) < self.data.?.len) {
            const val = @as(*align(1) T, @constCast(@ptrCast(self.ptr.? + self.pos))).*;
            self.pos += @sizeOf(T);
            return val;
        } else {
            return error.EndOfFile;
        }
    }
};
