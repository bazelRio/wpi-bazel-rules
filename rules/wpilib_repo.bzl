load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@rules_jvm_external//:defs.bzl", "maven_install")

def wpilib_native_dependency(artifact_base_name, version, url, sha, platform_libraries, static_only = False, disable_sha = False, shared_lib_srcs = 'glob(["**/*.dll", "**/*.so*", "**/*.dylib"])'):
    header_url = "{url}/{artifact_base_name}/{version}/{artifact_base_name}-{version}-headers.zip".format(
        url = url,
        artifact_base_name = artifact_base_name,
        version = version,
    )

    http_archive(
        name = artifact_base_name + "-headers",
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
            name = "{}-{}-libs".format(artifact_base_name, arch),
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
""".format(lib_url, shared_lib_srcs),
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

        lib_name = "{}__{}__{}".format(vendor_name, group_id.replace(".", "_"), artifact_id.replace("-", "_"))

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

def make_cpp_alias(lib_name):
    native.alias(
        name = lib_name + "-libs",
        actual = select({
            "@bazel_tools//src/conditions:windows": "@" + lib_name + "-windowsx86-64-libs//:libs",
            "@bazel_tools//src/conditions:linux_x86_64": "@" + lib_name + "-linuxx86-64-libs//:libs",
            "@bazel_tools//src/conditions:darwin": "@" + lib_name + "-osxx86-64-libs//:libs",
        }),
        visibility = ["//visibility:public"],
    )

    native.alias(
        name = lib_name + "-shared-libs",
        actual = select({
            "@bazel_tools//src/conditions:windows": "@" + lib_name + "-windowsx86-64-libs//:shared_libs",
            "@bazel_tools//src/conditions:linux_x86_64": "@" + lib_name + "-linuxx86-64-libs//:shared_libs",
            "@bazel_tools//src/conditions:darwin": "@" + lib_name + "-osxx86-64-libs//:shared_libs",
        }),
        visibility = ["//visibility:public"],
    )
