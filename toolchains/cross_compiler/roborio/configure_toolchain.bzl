load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

BUILD_FILE = """

filegroup(
    name = "tools",
    srcs = glob(["frc2021/roborio/bin/arm-frc2021-linux-gnueabi-*"]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "includes",
    srcs = glob([
        "frc2021/roborio/arm-frc2021-linux-gnueabi/usr/lib/gcc/arm-frc2021-linux-gnueabi/7.3.0/include/**",
        "frc2021/roborio/arm-frc2021-linux-gnueabi/usr/lib/gcc/arm-frc2021-linux-gnueabi/7.3.0/include-fixed/**",
        "frc2021/roborio/arm-frc2021-linux-gnueabi/usr/include/c++/7.3.0/**",
        "frc2021/roborio/arm-frc2021-linux-gnueabi/usr/include/c++/7.3.0/arm-frc2021-linux-gnueabi/**",
        "frc2021/roborio/arm-frc2021-linux-gnueabi/usr/include/c++/7.3.0/backward/**",
        "frc2021/roborio/arm-frc2021-linux-gnueabi/usr/include/**",
    ]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "everything",
    srcs = [":tools", ":includes"],
    visibility = ["//visibility:public"],
)


"""

def configure_roborio_toolchain():
    http_archive(
        name = "roborio-compiler-win",
        sha256 = "f3e9ba32b63d3cd26e242feeb14e878fecbda86c19c12b98c3084c629e06acb3",
        url = "https://github.com/wpilibsuite/roborio-toolchain/releases/download/v2021-2/FRC-2021-Windows-Toolchain-7.3.0.zip",
        build_file_content = BUILD_FILE,
    )
    http_archive(
        name = "roborio-compiler-linux",
        sha256 = "00cc58bf0607d71e725919d28e22714ce1920692c4864bc86353fc8139cbf7b7",
        url = "https://github.com/wpilibsuite/roborio-toolchain/releases/download/v2021-2/FRC-2021-Linux-Toolchain-7.3.0.tar.gz",
        build_file_content = BUILD_FILE,
    )
    http_archive(
        name = "roborio-compiler-osx",
        sha256 = "0822ff945ff422b176571cebe7b2dfdc0ef6bf685d3b6f6833db8dc218d992ae",
        url = "https://github.com/wpilibsuite/roborio-toolchain/releases/download/v2021-2/FRC-2021-Mac-Toolchain-7.3.0.tar.gz",
        build_file_content = BUILD_FILE,
    )
