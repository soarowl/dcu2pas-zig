const std = @import("std");

pub var gpa = std.heap.GeneralPurposeAllocator(.{}){};
pub const allocator = gpa.allocator();
pub var arena = std.heap.ArenaAllocator.init(allocator);
pub const arenaAllocator = arena.allocator();
