const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const limine = b.dependency("limine", .{});

    b.addNamedLazyPath("limine", limine.path("."));
    b.addNamedLazyPath("limine-bios.sys", limine.path("limine-bios.sys"));

    const wrapper = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("wrapper.zig"),
        .link_libc = true,
    });
    wrapper.addIncludePath(limine.path("."));
    wrapper.addCSourceFile(.{
        .file = limine.path("limine.c"),
        .flags = &.{ "-std=c99", "-Dmain=limine_main" },
    });
    const wrapper_exe = b.addExecutable(.{
        .name = "limine-install",
        .root_module = wrapper,
    });

    b.installArtifact(wrapper_exe);

    const step = b.step("buildnoemit", "build without installing (checks compile errors)");
    step.dependOn(&wrapper_exe.step);
}
