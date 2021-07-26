load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

BUILD_FILE = """

filegroup(
    name = "tools",
    srcs = glob(["bionic/bin/aarch64-bionic-linux-gnu-*"]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "includes",
    srcs = glob([
        "bionic/sys-root/usr/lib/gcc/aarch64-linux-gnu/8/include/**",
        "bionic/sys-root/usr/lib/gcc/aarch64-linux-gnu/8/include-fixed/**",
        "bionic/sys-root/usr/include/c++/8/**",
        "bionic/sys-root/usr/include/aarch64-linux-gnu/c++/8/**",
        "bionic/sys-root/usr/include/c++/8/backward/**",
        "bionic/sys-root/usr/include/aarch64-linux-gnu/**",
        "bionic/sys-root/usr/include/**",
    ]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "everything",
    srcs = [":tools", ":includes"],
    visibility = ["//visibility:public"],
)


"""

def configure_bionic_toolchain():
    http_archive(
        name = "bionic-compiler-win",
        sha256 = "d2109a24142b0d835c59d4d019033b620428a1795ce08cc02395df40722fdb86",
        url = "https://github.com/wpilibsuite/aarch64-bionic-toolchain/releases/download/v1.1.1/Bionic-Windows-Toolchain-8.3.0.zip",
        build_file_content = BUILD_FILE,
    )
    http_archive(
        name = "bionic-compiler-linux",
        sha256 = "b8b6c83ac706b978c3e39f13a0eb49971c9ec531a9810b35bedba19cdb56cbe9",
        url = "https://github.com/wpilibsuite/aarch64-bionic-toolchain/releases/download/v1.1.1/Bionic-Linux-Toolchain-8.3.0.tar.gz",
        build_file_content = BUILD_FILE,
    )
    http_archive(
        name = "bionic-compiler-osx",
        sha256 = "eb52230f333c048cea3cfb5af1633b5022c036d832513b8c39cbf92afb2108d6",
        url = "https://github.com/wpilibsuite/aarch64-bionic-toolchain/releases/download/v1.1.1/Bionic-Mac-Toolchain-8.3.0.tar.gz",
        build_file_content = BUILD_FILE,
    )
