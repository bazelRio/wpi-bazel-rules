load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def wpilib_native_dependency(
        artifact_base_name,
        version,
        url,
        sha,
        platform_libraries,
        prefix = "",
        header_patches = [],
        static_only = False,
        disable_sha = False,
        shared_lib_srcs = 'glob(["**/*.dll", "**/*.so*", "**/*.dylib"])',
        additional_library_build_content = ""):
    header_url = "{url}/{artifact_base_name}/{version}/{artifact_base_name}-{version}-headers.zip".format(
        url = url,
        artifact_base_name = artifact_base_name,
        version = version,
    )

    http_archive(
        name = prefix + artifact_base_name + "-headers",
        url = header_url,
        sha256 = None if disable_sha else sha,
        build_file_content = """
package(default_visibility = ["//visibility:public"])
cc_library(
    name = "headers",
    hdrs = glob(["**/*.h", "**/*.hpp"]),
    includes = ["."],
    #{}
)
""".format(header_url),
        patches = header_patches,
        patch_args = ["-p1"],
    )

    static_identifier = "static" if static_only else ""
    for arch, arch_sha in platform_libraries:
        lib_url = "{url}/{artifact_base_name}/{version}/{artifact_base_name}-{version}-{arch}{static_identifier}.zip".format(
            url = url,
            artifact_base_name = artifact_base_name,
            version = version,
            arch = arch,
            static_identifier = static_identifier,
        )
        http_archive(
            name = prefix + "{}-{}-libs".format(artifact_base_name, arch),
            url = lib_url,
            sha256 = None if disable_sha else arch_sha,
            build_file_content = """
package(default_visibility = ["//visibility:public"])
#{}
cc_library(
    name = "libs",
    srcs = glob(["**/*.lib", "**/*.a"]),
)
filegroup(
    name = "shared_libs",
    srcs = {},
)
""".format(lib_url, shared_lib_srcs) + additional_library_build_content,
        )

def wpilib_java_vendor_library(vendor_name, url, version, java_deps, jni_deps, disable_sha = False):
    java_artifacts = []

    for group_id, artifact_id in java_deps:
        java_artifacts.append("{}:{}:{}".format(group_id, artifact_id, version))

    for group_id, artifact_id, arch, arch_sha in jni_deps:
        lib_url = "{url}/{group_as_dir}/{artifact_id}/{version}/{artifact_id}-{version}-{arch}.zip".format(
            url = url,
            group_as_dir = group_id.replace(".", "/"),
            version = version,
            artifact_id = artifact_id,
            arch = arch,
        )

        lib_name = "{}__{}__{}-{}-jni-lib".format(vendor_name, group_id.replace(".", "_"), artifact_id.replace("-", "_"), arch)

        http_archive(
            name = lib_name,
            url = lib_url,
            sha256 = None if disable_sha else arch_sha,
            build_file_content = """
package(default_visibility = ["//visibility:public"])
#{}
cc_library(
    name = "libs",
    srcs = glob(["**/*.lib", "**/*.a"]),
)
filegroup(
    name = "shared_libs",
    srcs = glob(["**/*.dll", "**/*.so*", "**/*.dylib"]),
)
""".format(lib_url),
        )

    return java_artifacts, [url]

ALL_PLATFORMS = [
    "@bazel_tools//src/conditions:windows",
    "@bazel_tools//src/conditions:linux_x86_64",
    "@bazel_tools//src/conditions:darwin",
    "@wpi_bazel_rules//toolchains/conditions:raspbian",
    "@wpi_bazel_rules//toolchains/conditions:bionic",
    "@wpi_bazel_rules//toolchains/conditions:roborio",
]

def make_cpp_alias(name, supported_platforms = ALL_PLATFORMS):
    lib_name = name

    LOOKUP = {
        "@bazel_tools//src/conditions:windows": "windowsx86-64",
        "@bazel_tools//src/conditions:linux_x86_64": "linuxx86-64",
        "@bazel_tools//src/conditions:darwin": "osxx86-64",
        "@wpi_bazel_rules//toolchains/conditions:raspbian": "linuxraspbian",
        "@wpi_bazel_rules//toolchains/conditions:bionic": "linuxaarch64bionic",
        "@wpi_bazel_rules//toolchains/conditions:roborio": "linuxathena",
    }

    lib_select = {key: "@" + lib_name + "-" + LOOKUP[key] + "-libs//:libs" for key in supported_platforms}
    shared_lib_select = {key: "@" + lib_name + "-" + LOOKUP[key] + "-libs//:shared_libs" for key in supported_platforms}

    native.alias(
        name = lib_name + "-libs",
        actual = select(lib_select),
        visibility = ["//visibility:public"],
    )

    native.alias(
        name = lib_name + "-shared-libs",
        actual = select(shared_lib_select),
        visibility = ["//visibility:public"],
    )

def make_jni_alias(name):
    lib_name = name

    native.alias(
        name = lib_name + "-jni-lib",
        actual = select({
            "@bazel_tools//src/conditions:windows": "@" + lib_name + "-windowsx86-64-jni-lib//:shared_libs",
            "@bazel_tools//src/conditions:linux_x86_64": "@" + lib_name + "-linuxx86-64-jni-lib//:shared_libs",
            "@bazel_tools//src/conditions:darwin": "@" + lib_name + "-osxx86-64-jni-lib//:shared_libs",
        }),
        visibility = ["//visibility:public"],
    )
