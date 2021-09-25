load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

BUILD_FILE = """

filegroup(
    name = "tools",
    srcs = glob(["frc{year}/roborio/bin/arm-frc{year}-linux-gnueabi-*"]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "includes",
    srcs = glob([
        "frc{year}/roborio/arm-frc{year}-linux-gnueabi/usr/lib/gcc/arm-frc{year}-linux-gnueabi/7.3.0/include/**",
        "frc{year}/roborio/arm-frc{year}-linux-gnueabi/usr/lib/gcc/arm-frc{year}-linux-gnueabi/7.3.0/include-fixed/**",
        "frc{year}/roborio/arm-frc{year}-linux-gnueabi/usr/include/c++/7.3.0/**",
        "frc{year}/roborio/arm-frc{year}-linux-gnueabi/usr/include/c++/7.3.0/arm-frc{year}-linux-gnueabi/**",
        "frc{year}/roborio/arm-frc{year}-linux-gnueabi/usr/include/c++/7.3.0/backward/**",
        "frc{year}/roborio/arm-frc{year}-linux-gnueabi/usr/include/**",
    ]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "everything",
    srcs = [":tools", ":includes"],
    visibility = ["//visibility:public"],
)


"""

def configure_roborio_toolchain(version):
    if version == "v2021-2":
        http_archive(
            name = "roborio-compiler-win",
            sha256 = "f3e9ba32b63d3cd26e242feeb14e878fecbda86c19c12b98c3084c629e06acb3",
            url = "https://github.com/wpilibsuite/roborio-toolchain/releases/download/v2021-2/FRC-2021-Windows-Toolchain-7.3.0.zip",
            build_file_content = BUILD_FILE.format(year = 2021),
        )
        http_archive(
            name = "roborio-compiler-linux",
            sha256 = "00cc58bf0607d71e725919d28e22714ce1920692c4864bc86353fc8139cbf7b7",
            url = "https://github.com/wpilibsuite/roborio-toolchain/releases/download/v2021-2/FRC-2021-Linux-Toolchain-7.3.0.tar.gz",
            build_file_content = BUILD_FILE.format(year = 2021),
        )
        http_archive(
            name = "roborio-compiler-osx",
            sha256 = "0822ff945ff422b176571cebe7b2dfdc0ef6bf685d3b6f6833db8dc218d992ae",
            url = "https://github.com/wpilibsuite/roborio-toolchain/releases/download/v2021-2/FRC-2021-Mac-Toolchain-7.3.0.tar.gz",
            build_file_content = BUILD_FILE.format(year = 2021),
        )
    elif version == "v2022-1":
        http_archive(
            name = "roborio-compiler-win",
            sha256 = "3a8815d9c715e7f0f5d2106e4f16282863a3ff63121d259703b281881daea683",
            url = "https://github.com/wpilibsuite/roborio-toolchain/releases/download/v2022-1/FRC-2022-Windows64-Toolchain-7.3.0.zip",
            build_file_content = BUILD_FILE.format(year = 2022),
        )
        http_archive(
            name = "roborio-compiler-linux",
            sha256 = "b27cde302e46d11524aedf664129bc3ac7df02a78d0f9e4ab3f1feb40d667ab4",
            url = "https://github.com/wpilibsuite/roborio-toolchain/releases/download/v2022-1/FRC-2022-Linux-Toolchain-7.3.0.tar.gz",
            build_file_content = BUILD_FILE.format(year = 2022),
        )
        http_archive(
            name = "roborio-compiler-osx",
            sha256 = "47d29989d2618c0fc439b72e8d3d734b93952da4136dd05a7648af19662700b7",
            url = "https://github.com/wpilibsuite/roborio-toolchain/releases/download/v2022-1/FRC-2022-Mac-Toolchain-7.3.0.tar.gz",
            build_file_content = BUILD_FILE.format(year = 2022),
        )
