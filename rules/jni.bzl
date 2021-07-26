load("@wpi_bazel_rules//rules:cc.bzl", "wpilib_cc_shared_library")
load("@rules_java//java:defs.bzl", "java_library")

def _impl(ctx):
    # https://github.com/bazelbuild/rules_scala/pull/286/files
    ctx.actions.run(
        inputs = [ctx.attr.lib[JavaInfo].outputs.native_headers],
        tools = [ctx.executable._zipper],
        outputs = ctx.outputs.outs,
        executable = ctx.executable._zipper.path,
        arguments = ["xf", ctx.attr.lib[JavaInfo].outputs.native_headers.path, "-d", ctx.outputs.outs[0].dirname],
    )

extract_native_header_jar = rule(
    implementation = _impl,
    attrs = {
        "lib": attr.label(mandatory = True, allow_single_file = True),
        "outs": attr.output_list(),
        # https://github.com/bazelbuild/bazel/issues/2414
        "_zipper": attr.label(executable = True, cfg = "host", default = Label("@bazel_tools//tools/zip:zipper"), allow_files = True),
    },
    output_to_genfiles = True,
)

def wpilib_jni_library(
        name,
        java_lib,
        jni_files,
        deps = [],
        srcs = [],
        hdrs = [],
        raw_deps = [],
        wpi_maybe_shared_deps = [],
        strip_include_prefix = None,
        export_symbols = True,
        **kwargs):
    if deps:
        fail("No longer supported")

    java_library(
        name = name + "-jni-only",
        srcs = jni_files,
        deps = [java_lib],
    )

    jni_files = [name + "_jniheaders/" + f[14:-5].replace("/", "_") + ".h" for f in jni_files]

    extract_native_header_jar(
        name = name + "extract_headers",
        outs = jni_files,
        lib = name + "-jni-only",
    )

    wpilib_cc_shared_library(
        name = name,
        srcs = srcs,
        hdrs = hdrs + [":" + f for f in jni_files],
        raw_deps = raw_deps + ["@wpi_bazel_rules//toolchains/jni"],
        wpi_shared_deps = wpi_maybe_shared_deps,
        strip_include_prefix = strip_include_prefix,
        includes = [name + "_jniheaders/"],
        export_symbols = export_symbols,
        **kwargs
    )
