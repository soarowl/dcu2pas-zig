const std = @import("std");
const decoder = @import("decoder.zig");

pub const DelphiVersion = enum(u8) {
    D6 = 0x0E,
    @"Delphi 6" = 0x0E,
    D7 = 0x0F,
    @"Delphi 7" = 0x0F,
    @"Delphi 2005" = 0x11,
    BDS2006 = 0x12,
    @"Delphi 2006" = 0x12,
    Delphi2007 = 0x12,
    @"Delphi 2007" = 0x12,
    Delphi2009 = 0x14,
    @"Delphi 2009" = 0x14,
    Delphi2010 = 0x15,
    @"Delphi 2010" = 0x15,
    DelphiXE = 0x16,
    @"Delphi XE" = 0x16,
    DelphiXE2 = 0x17,
    @"Delphi XE2" = 0x17,
    DelphiEX3 = 0x18,
    @"Delphi XE3" = 0x18,
    DelphiEX4 = 0x19,
    @"Delphi XE4" = 0x19,
    DelphiXE5 = 0x1A,
    @"Delphi XE5" = 0x1A,
    DelphiXE6 = 0x1B,
    @"Delphi XE6" = 0x1B,
    DelphiXE7 = 0x1C,
    @"Delphi XE7" = 0x1C,
    DelphiXE8 = 0x1D,
    @"Delphi XE8" = 0x1D,
    DelphiD10S = 0x1E,
    @"Delphi 10 Seattle" = 0x1E,
    @"Delphi 10.1 Berlin" = 0x1F,
    @"Delphi 10.2" = 0x20,
    @"Delphi 10.3" = 0x21,
    @"Delphi 10.4" = 0x22,
    DelphiD11A = 0x23,
    @"Delphi 11" = 0x23,
    DelphiD12A = 0x24,
    @"Delphi 12" = 0x24,
};

pub const Plateform = enum(u8) {
    Win32 = 0x00,
    Win32 = 0x03,
    OSX32 = 0x04,
    iOSSimulator = 0x14,
    Win64 = 0x23,
    Android32 = 0x67,
    iOSDevice32 = 0x76,
    Android32 = 0x77,
    Android64 = 0x87,
    iOSDevice32 = 0x94,
};

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
