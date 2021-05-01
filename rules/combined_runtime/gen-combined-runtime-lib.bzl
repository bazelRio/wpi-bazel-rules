load("@rules_java//java:defs.bzl", "java_import")

def generate_combined_runtime_lib(name, json_file, deps = []):
    native.genrule(
        name = name + "-gen",
        srcs = select({
            "@bazel_tools//src/conditions:windows": ["@wpi_bazel_rules//rules/combined_runtime:windows_jni_loader"] + deps,
            "//conditions:default": deps,
        }),
        outs = [name + "-combined-libs.jar"],
        cmd = "$(locations @wpi_bazel_rules//rules/combined_runtime:create_combined_runtime) $@ " + json_file + " $(SRCS)",
        tools = ["@wpi_bazel_rules//rules/combined_runtime:create_combined_runtime"],
        visibility = ["//visibility:public"],
    )

    java_import(
        name = name,
        jars = [":" + name + "-gen"],
        visibility = ["//visibility:public"],
    )
