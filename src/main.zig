const std = @import("std");
const info = @import("build_info");
const cli = @import("zig-cli");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

var config = struct {
    help: bool = false,
}{};
var help = cli.Option{
    .long_name = "help",
    .help = "Prints help information",
    .short_alias = 'h',
    .value_ref = cli.mkRef(&config.help),
};
var app = &cli.App{
    .author = "Zhuo Nengwen",
    .command = cli.Command{
        .name = "dcu2pas",
        .options = &.{
            &help,
        },
        .target = cli.CommandTarget{
            .action = cli.CommandAction{ .exec = run_decompile },
        },
    },
    .version = info.build_date ++ "-" ++ info.git_commit,
};

pub fn main() !void {
    defer std.debug.assert(gpa.deinit() == .ok);
    return cli.run(app, allocator);
}

fn run_decompile() !void {}
