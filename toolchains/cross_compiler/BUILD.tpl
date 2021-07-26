load(":toolchain.bzl", "create_cross_compile_toolchain")

filegroup(
    name = "temp",
    srcs = glob(["**"]),
        visibility = ["//visibility:public"],
)


create_cross_compile_toolchain(compiler_dep="{compiler_repo}", sysroot_subfolder = "{sysroot}", cpu="{compiler}", wrapper_extension="{wrapper_extension}")