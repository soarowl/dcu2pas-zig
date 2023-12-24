const std = @import("std");
const info = @import("build_info");
const dcu = @import("dcu.zig");
const global = @import("global.zig");
const cli = @import("zig-cli");

var config = struct {
    files: [][]const u8 = undefined,
}{};
var files_arg = cli.PositionalArg{
    .name = "file",
    .help = "Files to decompiled",
    .value_ref = cli.mkRef(&config.files),
};
var app = &cli.App{
    .author = "Zhuo Nengwen",
    .command = cli.Command{
        .name = "dcu2pas",
        .target = cli.CommandTarget{
            .action = cli.CommandAction{
                .positional_args = cli.PositionalArgs{
                    .args = &.{&files_arg},
                    .first_optional_arg = &files_arg,
                },
                .exec = run_decompile,
            },
        },
    },
    .version = info.build_date ++ "-" ++ info.git_commit,
};

pub fn main() !void {
    defer std.debug.assert(global.gpa.deinit() == .ok);
    defer global.arena.deinit();
    try cli.run(app, global.arenaAllocator);
}

fn run_decompile() !void {
    const c = &config;
    for (c.files) |file| {
        std.debug.print("Decompiling {s}...\n", .{file});
        try decompile_file(file);
    }
    std.debug.print("Done.\n", .{});
}

fn decompile_file(fileName: []const u8) !void {
    // Open the file
    const file = try std.fs.cwd().openFile(fileName, .{ .mode = .read_only });
    defer file.close();

    // Read the contents
    const buffer_size = 4 * 1024 * 1024 * 1024;
    const file_buffer = try file.readToEndAlloc(global.allocator, buffer_size);
    defer global.allocator.free(file_buffer);
    try decomiple_buffer(file_buffer);
}

fn decomiple_buffer(buffer: []u8) !void {
    var d = dcu.Dcu{};
    d.init(buffer);
    return d.decode();
}
