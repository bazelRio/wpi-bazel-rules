load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

BUILD_FILE = """

filegroup(
    name = "tools",
    srcs = glob(["raspbian10/bin/arm-raspbian10-linux-gnueabihf-*"]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "includes",
    srcs = glob([
        "raspbian10/sys-root/usr/lib/gcc/arm-linux-gnueabihf/8/include/**",
        "raspbian10/sys-root/usr/lib/gcc/arm-linux-gnueabihf/8/include-fixed/**",
        "raspbian10/sys-root/usr/include/c++/8/**",
        "raspbian10/sys-root/usr/include/arm-linux-gnueabihf/c++/8/**",
        "raspbian10/sys-root/usr/include/c++/8/backward/**",
        "raspbian10/sys-root/usr/include/arm-linux-gnueabihf/**",
        "raspbian10/sys-root/usr/include/**",
    ]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "everything",
    srcs = [":tools", ":includes"],
    visibility = ["//visibility:public"],
)


"""

def configure_raspbian_toolchain():
    http_archive(
        name = "raspbian-compiler-win",
        sha256 = "3f49461d4f7d2a0ccd3f4e56815dab01c6c3af544467ee3035e23c6a330d7988",
        url = "https://github.com/wpilibsuite/raspbian-toolchain/releases/download/v2.1.0/Raspbian10-Windows-Toolchain-8.3.0.zip",
        build_file_content = BUILD_FILE,
    )
    http_archive(
        name = "raspbian-compiler-linux",
        sha256 = "b27e20d3cb2b79d4aaaaf378001a8d70f934931481eabe7832943a9330aca7fa",
        url = "https://github.com/wpilibsuite/raspbian-toolchain/releases/download/v2.1.0/Raspbian10-Linux-Toolchain-8.3.0.tar.gz",
        build_file_content = BUILD_FILE,
    )
    http_archive(
        name = "raspbian-compiler-osx",
        sha256 = "8bd7e6ca3d042695d618b1b15ce0e51c3cb78525b82104746e3f2b90d3da359a",
        url = "https://github.com/wpilibsuite/raspbian-toolchain/releases/download/v2.1.0/Raspbian10-Mac-Toolchain-8.3.0.tar.gz",
        build_file_content = BUILD_FILE,
    )
