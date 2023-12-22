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
}
