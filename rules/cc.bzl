load("@rules_cc//cc:defs.bzl", "cc_binary", "cc_import", "cc_library", "cc_test")

############################################
# Compiler options for C++
############################################

# Windows
WINDOWS_WARNING_ARGS = ["/W3"]
WINDOWS_WARNINGS_AS_ERROR_ARGS = ["/WX"]
UNIX_WARNING_ARGS = ["-Wall", "-Wextra"]
UNIX_WARNINGS_AS_ERROR_ARGS = ["-Werror"]

WINDOWS_COMPILER_ARGS = [
    "/EHsc",
    "/FS",
    "/Zc:inline",
    "/wd4244",
    "/wd4267",
    "/wd4146",
    "/wd4996",
    "/Zc:throwingNew",
    "/D_CRT_SECURE_NO_WARNINGS",
    "/std:c++17",
    "/bigobj",
    "/permissive-",
]
WINDOWS_C_COMPILER_ARGS = ["/FS", "/Zc:inline", "/D_CRT_SECURE_NO_WARNINGS"]
WINDOWS_LINKER_ARGS = ["/DEBUG:FULL", "/PDBALTPATH:%_PDB%"]

# Linux
LINUX_CROSS_COMPILER_ARGS = ["-std=c++17", "-Wformat=2", "-pedantic", "-Wno-psabi", "-Wno-unused-parameter", "-Wno-error=deprecated-declarations", "-fPIC", "-rdynamic", "-pthread"]
LINUX_CROSS_C_COMPILER_ARGS = ["-Wformat=2", "-pedantic", "-Wno-psabi", "-Wno-unused-parameter", "-fPIC", "-rdynamic", "-pthread"]
LINUX_CROSS_LINKER_ARGS = ["-rdynamic", "-pthread", "-latomic"]

LINUX_COMPILER_ARGS = ["-std=c++17", "-Wformat=2", "-pedantic", "-Wno-psabi", "-Wno-unused-parameter", "-Wno-error=deprecated-declarations", "-fPIC", "-rdynamic", "-pthread"]
LINUX_C_COMPILER_ARGS = ["-Wformat=2", "-pedantic", "-Wno-psabi", "-Wno-unused-parameter", "-fPIC", "-rdynamic", "-pthread"]
LINUX_LINKER_ARGS = ["-rdynamic", "-pthread", "-ldl", "-latomic"]

# Mac
MAC_COMPILER_ARGS = [
    "-std=c++17",
    "-pedantic",
    "-fPIC",
    #"-Wno-unused-parameter", "-Wno-error=deprecated-declarations", "-Wno-missing-field-initializers", "-Wno-unused-private-field",
    "-Wno-unused-const-variable",
    "-Wno-error=c11-extensions",
    "-pthread",
]
MAC_C_COMPILER_ARGS = ["-pedantic", "-fPIC", "-Wno-unused-parameter", "-Wno-missing-field-initializers", "-Wno-unused-private-field"]
MAC_LINKER_ARGS = ["-framework", "CoreFoundation", "-framework", "AVFoundation", "-framework", "Foundation", "-framework", "CoreMedia", "-framework", "CoreVideo"]

def _get_default_cxx_opts():
    return select({
        "@bazel_tools//src/conditions:windows": WINDOWS_COMPILER_ARGS + WINDOWS_WARNING_ARGS + WINDOWS_WARNINGS_AS_ERROR_ARGS,
        "@bazel_tools//src/conditions:linux_x86_64": LINUX_COMPILER_ARGS + UNIX_WARNING_ARGS + UNIX_WARNINGS_AS_ERROR_ARGS,
        "@bazel_tools//src/conditions:darwin": MAC_COMPILER_ARGS,  #  + UNIX_WARNING_ARGS + UNIX_WARNINGS_AS_ERROR_ARGS,

        # Arguments handled by hermetic toolchain
        "@wpi_bazel_rules//toolchains/conditions:roborio": [],
        "@wpi_bazel_rules//toolchains/conditions:bionic": [],
        "@wpi_bazel_rules//toolchains/conditions:raspbian": [],
    })

def _get_default_linker_opts():
    return select({
        "@bazel_tools//src/conditions:windows": WINDOWS_LINKER_ARGS,
        "@bazel_tools//src/conditions:linux_x86_64": LINUX_LINKER_ARGS,
        "@bazel_tools//src/conditions:darwin": MAC_LINKER_ARGS,

        # Arguments handled by hermetic toolchain
        "@wpi_bazel_rules//toolchains/conditions:roborio": [],
        "@wpi_bazel_rules//toolchains/conditions:bionic": [],
        "@wpi_bazel_rules//toolchains/conditions:raspbian": [],
    })

def _get_default_features():
    return []

def get_wpigui_linker_flags(console = True):
    WINDOWS_FLAGS = [
        "-DEFAULTLIB:Gdi32.lib",
        "-DEFAULTLIB:Shell32.lib",
        "-DEFAULTLIB:d3d11.lib",
        "-DEFAULTLIB:d3dcompiler.lib",
    ]

    DARWIN_FLAGS = [
        "-framework",
        "Metal",
        "-framework",
        "MetalKit",
        "-framework",
        "Cocoa",
        "-framework",
        "IOKit",
        "-framework",
        "CoreFoundation",
        "-framework",
        "CoreVideo",
        "-framework",
        "QuartzCore",
    ]

    if not console:
        WINDOWS_FLAGS.append("-SUBSYSTEM:WINDOWS")

    return select({
        "@bazel_tools//src/conditions:windows": WINDOWS_FLAGS,
        "@bazel_tools//src/conditions:linux_x86_64": ["-lX11"],
        "@bazel_tools//src/conditions:darwin": DARWIN_FLAGS,
    })

def __make_shared_lib_name(name):
    return name

def __make_static_lib_name(name):
    return name + "_staticxx"

def __make_shared_import_name(name):
    return name + "-xxil"

def __make_shared_import_target_name(name):
    return name + "-xxdi"

def __make_shared_import_final_name(name):
    return name + "-xxif"

def convert_to_shared_libs(wpideps):
    return [__make_shared_lib_name(x) for x in wpideps]

def convert_to_final_libs(wpideps):
    return [__make_shared_import_final_name(x) for x in wpideps]

def convert_to_final_static_libs(wpideps):
    return [__make_static_lib_name(x) for x in wpideps]

# https://github.com/bazelbuild/bazel/blob/26c7e10739907332e70d31e68d2bd2ff2e9a84fb/examples/windows/dll
def wpilib_cc_shared_library(
        name,
        srcs = [],
        hdrs = [],
        deps = [],
        raw_deps = [],
        wpi_shared_deps = [],
        copts = [],
        tags = [],
        linkopts = [],
        win_def_file = None,
        strip_include_prefix = None,
        visibility = None,
        export_symbols = True,
        **kwargs):
    if deps:
        fail("Change me")
    if win_def_file:
        fail("Nope")

    deps = raw_deps + convert_to_final_libs(wpi_shared_deps)

    static_lib_name = __make_static_lib_name(name)
    shared_lib_name = __make_shared_lib_name(name)
    import_lib_name = __make_shared_import_name(name)
    import_target_name = __make_shared_import_target_name(name)
    final_lib_name = __make_shared_import_final_name(name)
    headers_name = name + "_headersy"

    cc_library(
        name = headers_name,
        hdrs = hdrs,
        copts = copts + _get_default_cxx_opts(),
        linkopts = linkopts + _get_default_linker_opts(),
        features = _get_default_features(),
        strip_include_prefix = strip_include_prefix,
        tags = tags,
    )

    # Build the static library
    cc_library(
        name = static_lib_name,
        srcs = srcs,
        deps = deps + [headers_name],
        copts = copts + _get_default_cxx_opts(),
        tags = tags,
        linkopts = linkopts + _get_default_linker_opts(),
        features = _get_default_features(),
        visibility = visibility,
        **kwargs
    )

    features = []
    if export_symbols:
        features.append("windows_export_all_symbols")

    # Build the shared library
    cc_binary(
        name = shared_lib_name,
        srcs = srcs,
        deps = deps + [headers_name],
        tags = tags,
        copts = copts + _get_default_cxx_opts(),
        linkopts = linkopts + _get_default_linker_opts(),
        features = features + _get_default_features(),
        linkshared = 1,
        visibility = visibility,
        **kwargs
    )

    # Get the import library for the dll
    native.filegroup(
        name = import_lib_name,
        srcs = [":" + shared_lib_name],
        output_group = "interface_library",
        tags = tags,
    )

    # Because we cannot directly depend on cc_binary from other cc rules in deps attribute,
    # we use cc_import as a bridge to depend on the dll.
    cc_import(
        name = import_target_name,
        tags = tags,
        interface_library = select({
            "@bazel_tools//src/conditions:windows": ":" + import_lib_name,
            "@wpi_bazel_rules//toolchains/conditions:raspbian": None,
            "@wpi_bazel_rules//toolchains/conditions:bionic": None,
            "@wpi_bazel_rules//toolchains/conditions:roborio": None,
            "//conditions:default": None,
        }),
        shared_library = ":" + shared_lib_name,
    )

    # Create a new cc_library to also include the headers needed for the shared library
    cc_library(
        name = final_lib_name,
        hdrs = hdrs,
        visibility = visibility,
        copts = copts + _get_default_cxx_opts(),
        linkopts = linkopts + _get_default_linker_opts(),
        features = _get_default_features(),
        tags = tags,
        deps = deps + [
            ":" + import_target_name,
        ],
        strip_include_prefix = strip_include_prefix,
    )

def wpilib_cc_library(
        name,
        copts = [],
        linkopts = [],
        deps = [],
        wpi_shared_deps = [],
        raw_deps = [],
        **kwargs):
    if deps:
        fail("No more")

    deps = convert_to_final_libs(wpi_shared_deps) + raw_deps

    cc_library(
        name = name,
        deps = deps,
        copts = copts + _get_default_cxx_opts(),
        linkopts = linkopts + _get_default_linker_opts(),
        features = _get_default_features(),
        **kwargs
    )

def wpilib_cc_test(
        name,
        copts = [],
        deps = [],
        tags = [],
        raw_deps = [],
        wpi_shared_deps = [],
        linkopts = [],
        link_wpi_shared_deps_statically = True,
        **kwargs):
    if deps:
        fail("No more")

    if link_wpi_shared_deps_statically:
        deps = convert_to_final_static_libs(wpi_shared_deps) + raw_deps
    else:
        deps = convert_to_final_libs(wpi_shared_deps) + raw_deps

    cc_test(
        name = name,
        copts = copts + _get_default_cxx_opts(),
        linkopts = linkopts + _get_default_linker_opts(),
        features = _get_default_features(),
        deps = deps + ["@gtest//:gtest"],
        tags = tags + ["no-roborio", "no-bionic", "no-raspbian"],
        **kwargs
    )

def wpilib_cc_binary(
        name,
        copts = [],
        deps = [],
        linkopts = [],
        raw_deps = [],
        wpi_shared_deps = [],
        **kwargs):
    if deps:
        fail("No more")

    deps = raw_deps + convert_to_final_libs(wpi_shared_deps)

    cc_binary(
        name = name,
        copts = copts + _get_default_cxx_opts(),
        linkopts = linkopts + _get_default_linker_opts(),
        features = _get_default_features(),
        deps = deps,
        **kwargs
    )

#######################################################
# Default macros that assume a standard gradle layout #
#######################################################
DEFAULT_HEADER_GLOB_PATTERN = [
    "src/main/native/include/**/*",
]

DEFAULT_SOURCES_GLOB_PATTERN = [
    "src/main/native/cpp/**/*.cpp",
    "src/main/native/cpp/**/*.h",
]

def default_wpilib_cc_library(
        name,
        srcs = [],
        hdrs = [],
        strip_include_prefix = None,
        additional_srcs = [],
        **kwargs):
    if srcs or hdrs or strip_include_prefix:
        fail("You cannot use the default rule and specify srcs")

    wpilib_cc_library(
        name = name,
        srcs = additional_srcs + native.glob(DEFAULT_SOURCES_GLOB_PATTERN, exclude = ["src/main/native/cpp/jni/**"]),
        hdrs = native.glob(DEFAULT_HEADER_GLOB_PATTERN),
        strip_include_prefix = "src/main/native/include",
        **kwargs
    )

def default_wpilib_cc_shared_library(
        name,
        srcs = [],
        hdrs = [],
        strip_include_prefix = None,
        additional_srcs = [],
        **kwargs):
    if srcs or hdrs or strip_include_prefix:
        fail("You cannot use the default rule and specify srcs")

    wpilib_cc_shared_library(
        name = name,
        srcs = additional_srcs + native.glob(DEFAULT_SOURCES_GLOB_PATTERN, exclude = ["src/main/native/cpp/jni/**"]),
        hdrs = native.glob(DEFAULT_HEADER_GLOB_PATTERN),
        strip_include_prefix = "src/main/native/include",
        **kwargs
    )

def default_wpilib_cc_test(
        name,
        srcs = [],
        **kwargs):
    if srcs:
        fail("You cannot use the default rule and specify srcs")

    wpilib_cc_test(
        name = name,
        srcs = native.glob(["src/test/native/cpp/**/*.cpp", "src/test/native/cpp/**/*.h"]),
        **kwargs
    )

def default_wpilib_cc_dev_main(
        name,
        srcs = [],
        **kwargs):
    if srcs:
        fail("You cannot use the default rule and specify srcs")

    wpilib_cc_binary(
        name = name,
        srcs = ["src/dev/native/cpp/main.cpp"],
        **kwargs
    )
