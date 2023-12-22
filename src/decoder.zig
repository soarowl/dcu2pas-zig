const I7 = packed struct { flag: i1, data: i7 };
const I14 = packed struct { flag: i2, data: i14 };
const I21 = packed struct { flag: i3, data: i21 };
const I28 = packed struct { flag: i4, data: i28 };
const U7 = packed struct { flag: i1, data: u7 };
const U14 = packed struct { flag: i2, data: u14 };
const U21 = packed struct { flag: i3, data: u21 };
const U28 = packed struct { flag: i4, data: u28 };

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

    pub fn getPackedUInt(self: *Self) !u64 {
        if (self.pos + 1 < self.data.?.len) {
            const b = self.data.?[self.pos];
            if (b & 0b1 == 0) {
                self.pos += 1;
                const u: *U7 = &b;
                return u.data;
            }
            if (b & 0b11 == 0b10) {
                self.pos += 2;
                const u: *U14 = @as(*align(1) u16, @constCast(@ptrCast(self.ptr.? + self.pos)));
                return u.data;
            }
            unreachable;
        } else {
            return error.EndOfFile;
        }
    }
};
