const std = @import("std");

extern fn limine_main(argc: c_int, argv: [*]const [*:0]const u8) c_int;

fn usage(self_exe: [:0]const u8) u8 {
    std.debug.print(
        \\USAGE: {s} [flags] -o <out file> -i <image file> [-p <gpt partition index>]
        \\Printing limine bios-install usage:
    , .{self_exe});
    _ = limine_main(3, (&[_][*:0]const u8{ "limine", "bios-install", "--help" }).ptr);
    return 1;
}

pub fn main() !u8 {
    // we link libc so we can use std.os.argv but we'll use ArgIterator anyway
    var arena: std.heap.ArenaAllocator = .init(std.heap.smp_allocator);
    defer arena.deinit();
    const gpa = arena.allocator();

    var args: std.process.ArgIterator = try .initWithAllocator(gpa);

    var passthruargs: std.ArrayListUnmanaged([*:0]const u8) = .{};
    try passthruargs.appendSlice(gpa, &.{ "limine", "bios-install" });

    var outfile: ?[:0]const u8 = null;
    var infile: ?[:0]const u8 = null;
    var partidx: ?[*:0]const u8 = null;
    const self_exe = args.next() orelse @panic("didnt get self-exe argument!");

    while (args.next()) |arg| {
        if (std.mem.eql(u8, "-o", arg)) {
            outfile = args.next() orelse return usage(self_exe);
        } else if (std.mem.eql(u8, "-i", arg)) {
            infile = args.next() orelse return usage(self_exe);
        } else if (std.mem.eql(u8, "-p", arg)) {
            partidx = (args.next() orelse return usage(self_exe)).ptr;
        } else if (std.mem.eql(u8, "-h", arg)) {
            return usage(self_exe);
        } else {
            try passthruargs.append(gpa, arg.ptr);
        }
    }

    const of = outfile orelse return usage(self_exe);
    const inf = infile orelse return usage(self_exe);

    try passthruargs.ensureUnusedCapacity(gpa, 2);
    passthruargs.appendAssumeCapacity(of.ptr);
    if (partidx) |p| {
        passthruargs.appendAssumeCapacity(p);
    }

    const d = std.fs.cwd();
    try d.copyFile(inf, d, of, .{});
    const a = passthruargs.items;
    return @intCast(limine_main(@intCast(a.len), a.ptr));
}
