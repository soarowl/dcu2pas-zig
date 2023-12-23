const std = @import("std");

const I7 = packed struct { flag: u1, data: i7 };
const I14 = packed struct { flag: u2, data: i14 };
const I21 = packed struct { flag: u3, data: i21 };
const I28 = packed struct { flag: u4, data: i28 };
const U7 = packed struct { flag: u1, data: u7 };
const U14 = packed struct { flag: u2, data: u14 };
const U21 = packed struct { flag: u3, data: u21 };
const U28 = packed struct { flag: u4, data: u28 };

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
        if (self.pos + @sizeOf(T) <= self.data.?.len) {
            const val = @as(*align(1) T, @constCast(@ptrCast(self.ptr.? + self.pos))).*;
            self.pos += @sizeOf(T);
            return val;
        } else {
            return error.EndOfFile;
        }
    }

    pub fn getPackedUInt(self: *Self) !u64 {
        if (self.pos + 1 <= self.data.?.len) {
            const b = self.data.?[self.pos];
            if (b & 0b1 == 0) {
                const u: *U7 = @as(*U7, @constCast(@ptrCast(&b)));
                self.pos += 1;
                return u.*.data;
            }
            if (b & 0b11 == 0b01) {
                if (self.pos + 2 <= self.data.?.len) {
                    const u: *align(1) U14 = @as(*align(1) U14, @constCast(@ptrCast(self.ptr.? + self.pos)));
                    self.pos += 2;
                    return u.*.data;
                }
                return error.EndOfFile;
            }
            if (b & 0b111 == 0b011) {
                if (self.pos + 3 <= self.data.?.len) {
                    const u: *align(1) U21 = @as(*align(1) U21, @constCast(@ptrCast(self.ptr.? + self.pos)));
                    self.pos += 3;
                    return u.*.data;
                }
                return error.EndOfFile;
            }
            if (b & 0b1111 == 0b0111) {
                if (self.pos + 4 <= self.data.?.len) {
                    const u: *align(1) U28 = @as(*align(1) U28, @constCast(@ptrCast(self.ptr.? + self.pos)));
                    self.pos += 4;
                    return u.*.data;
                }
                return error.EndOfFile;
            }
            if (b == 0b1111) {
                if (self.pos + 5 <= self.data.?.len) {
                    const u: *align(1) u32 = @as(*align(1) u32, @constCast(@ptrCast(self.ptr.? + self.pos + 1)));
                    self.pos += 5;
                    return u.*;
                }
                return error.EndOfFile;
            }
            if (b == 0b1111_1111) {
                if (self.pos + 9 <= self.data.?.len) {
                    const u: *align(1) u64 = @as(*align(1) u64, @constCast(@ptrCast(self.ptr.? + self.pos + 1)));
                    self.pos += 9;
                    return u.*;
                }
                return error.EndOfFile;
            }
            unreachable;
        }
        return error.EndOfFile;
    }

    pub fn getPackedInt(self: *Self) !i64 {
        if (self.pos + 1 <= self.data.?.len) {
            const b = self.data.?[self.pos];
            if (b & 0b1 == 0) {
                const i: *I7 = @as(*I7, @constCast(@ptrCast(&b)));
                self.pos += 1;
                return i.*.data;
            }
            if (b & 0b11 == 0b01) {
                if (self.pos + 2 <= self.data.?.len) {
                    const i: *align(1) I14 = @as(*align(1) I14, @constCast(@ptrCast(self.ptr.? + self.pos)));
                    self.pos += 2;
                    return i.*.data;
                }
                return error.EndOfFile;
            }
            if (b & 0b111 == 0b011) {
                if (self.pos + 3 <= self.data.?.len) {
                    const i: *align(1) I21 = @as(*align(1) I21, @constCast(@ptrCast(self.ptr.? + self.pos)));
                    self.pos += 3;
                    return i.*.data;
                }
                return error.EndOfFile;
            }
            if (b & 0b1111 == 0b0111) {
                if (self.pos + 4 <= self.data.?.len) {
                    const i: *align(1) I28 = @as(*align(1) I28, @constCast(@ptrCast(self.ptr.? + self.pos)));
                    self.pos += 4;
                    return i.*.data;
                }
                return error.EndOfFile;
            }
            if (b == 0b1111) {
                if (self.pos + 5 <= self.data.?.len) {
                    const i: *align(1) i32 = @as(*align(1) i32, @constCast(@ptrCast(self.ptr.? + self.pos + 1)));
                    self.pos += 5;
                    return i.*;
                }
                return error.EndOfFile;
            }
            if (b == 0b1111_1111) {
                if (self.pos + 9 <= self.data.?.len) {
                    const i: *align(1) i64 = @as(*align(1) i64, @constCast(@ptrCast(self.ptr.? + self.pos + 1)));
                    self.pos += 9;
                    return i.*;
                }
                return error.EndOfFile;
            }
            unreachable;
        }
        return error.EndOfFile;
    }
};

test "get unsigned" {
    const data = &[_]u8{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4, 8, 9 };
    var decoder = Decoder.init(data);
    const i_1 = try decoder.get(u8);
    try std.testing.expect(1 == i_1);
    const i_2 = try decoder.get(u16);
    try std.testing.expect(0x0302 == i_2);
    const i_4 = try decoder.get(u32);
    try std.testing.expect(0x07060504 == i_4);
    const i_8 = try decoder.get(u64);
    try std.testing.expect(0x08040302_01000908 == i_8);
}

test "get signed" {
    const data = &[_]u8{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4, 8, 9 };
    var decoder = Decoder.init(data);
    const i_1 = try decoder.get(i8);
    try std.testing.expect(1 == i_1);
    const i_2 = try decoder.get(i16);
    try std.testing.expect(0x0302 == i_2);
    const i_4 = try decoder.get(i32);
    try std.testing.expect(0x07060504 == i_4);
    const i_8 = try decoder.get(i64);
    try std.testing.expect(0x08040302_01000908 == i_8);
}

test "packed unsigned" {
    const data = &[_]u8{ 8, 0b101, 3, 0b1011, 5, 6, 0b10111, 8, 9, 0, 0b1111, 2, 3, 4, 8, 0xff, 1, 2, 3, 4, 5, 6, 7, 8 };
    var decoder = Decoder.init(data);
    const i_1 = try decoder.getPackedUInt();
    try std.testing.expect(0b100 == i_1);
    const i_2 = try decoder.getPackedUInt();
    try std.testing.expect(0b0011_0000_01 == i_2);
    const i_3 = try decoder.getPackedUInt();
    try std.testing.expect(0b110_00000101_0000_1 == i_3);
    const i_4 = try decoder.getPackedUInt();
    try std.testing.expect(0b1001_00001000_0001 == i_4);
    const i_5 = try decoder.getPackedUInt();
    try std.testing.expect(0x08040302 == i_5);
    const i_6 = try decoder.getPackedUInt();
    try std.testing.expect(0x0807060504030201 == i_6);
}

test "packed signed" {
    const data = &[_]u8{ 8, 0b101, 3, 0b1011, 5, 6, 0b10111, 8, 9, 0, 0b1111, 2, 3, 4, 8, 0xff, 1, 2, 3, 4, 5, 6, 7, 8 };
    var decoder = Decoder.init(data);
    const i_1 = try decoder.getPackedInt();
    try std.testing.expect(0b100 == i_1);
    const i_2 = try decoder.getPackedInt();
    try std.testing.expect(0b0011_0000_01 == i_2);
    const i_3 = try decoder.getPackedInt();
    try std.testing.expect(0b110_00000101_0000_1 == i_3);
    const i_4 = try decoder.getPackedInt();
    try std.testing.expect(0b1001_00001000_0001 == i_4);
    const i_5 = try decoder.getPackedInt();
    try std.testing.expect(0x08040302 == i_5);
    const i_6 = try decoder.getPackedInt();
    try std.testing.expect(0x0807060504030201 == i_6);
}

test "packed signed(minus) i7" {
    const data = &[_]u8{0b1000_0010};
    var decoder = Decoder.init(data);
    const i_1 = try decoder.getPackedInt();
    try std.testing.expect(0b111110 + 1 == -i_1);
}

test "packed signed(minus) i14" {
    const data = &[_]u8{ 0b1000_0101, 0b1000_0011 };
    var decoder = Decoder.init(data);
    const i_2 = try decoder.getPackedInt();
    try std.testing.expect(0b1111100011110 + 1 == -i_2);
}

test "packed signed(minus) i21" {
    const data = &[_]u8{ 0b1011, 5, 0b1000_0000 };
    var decoder = Decoder.init(data);
    const i_3 = try decoder.getPackedInt();
    try std.testing.expect(0b11111111111101011110 + 1 == -i_3);
}

test "packed signed(minus) i28" {
    const data = &[_]u8{ 0b10111, 8, 9, 0b1000_0000 };
    var decoder = Decoder.init(data);
    const i_4 = try decoder.getPackedInt();
    try std.testing.expect(0b111111111110110111101111110 + 1 == -i_4);
}

test "packed signed(minus) i32" {
    const data = &[_]u8{ 0b1111, 2, 3, 4, 0b1000_0000 };
    var decoder = Decoder.init(data);
    const i_5 = try decoder.getPackedInt();
    try std.testing.expect(0b1111111111110111111110011111110 == -i_5);
}

test "packed signed(minus) i64" {
    const data = &[_]u8{ 0xff, 1, 2, 3, 4, 5, 6, 7, 0b1000_0000 };
    var decoder = Decoder.init(data);
    const i_6 = try decoder.getPackedInt();
    try std.testing.expect(0b111111111111000111110011111101011111011111111001111110111111111 == -i_6);
}
