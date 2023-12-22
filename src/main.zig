const std = @import("std");
const info = @import("build_info");
const cli = @import("zig-cli");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

var config = struct {
    file: []const u8 = undefined,
}{};
var file_arg = cli.PositionalArg{
    .name = "file",
    .help = "File to decompile",
    .value_ref = cli.mkRef(&config.file),
};
var app = &cli.App{
    .author = "Zhuo Nengwen",
    .command = cli.Command{
        .name = "dcu2pas",
        .target = cli.CommandTarget{
            .action = cli.CommandAction{ .positional_args = cli.PositionalArgs{
                .args = &.{&file_arg},
            }, .exec = run_decompile },
        },
    },
    .version = info.build_date ++ "-" ++ info.git_commit,
};

pub fn main() !void {
    defer std.debug.assert(gpa.deinit() == .ok);
    return cli.run(app, allocator);
}

fn run_decompile() !void {
    const c = &config;
    std.debug.print("Decompiling {s}...\n", .{c.file});
    try decompile_file(c.file);
    std.debug.print("Done.\n", .{});
}

fn decompile_file(fileName: []const u8) !void {
    // Open the file
    const file = try std.fs.openFileAbsolute(fileName, .{ .mode = .read_only });
    defer file.close();

    // Read the contents
    const buffer_size = 4 * 1024 * 1024 * 1024;
    const file_buffer = try file.readToEndAlloc(allocator, buffer_size);
    defer allocator.free(file_buffer);
    try decomiple_buffer(file_buffer);
}

fn decomiple_buffer(buffer: []const u8) !void {
    std.debug.print("File Size: {}\n", .{buffer.len});
}
