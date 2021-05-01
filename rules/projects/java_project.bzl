load("@wpi_bazel_rules//rules:java.bzl", "default_java_dev_main", "default_java_library", "default_java_test")

def java_project(
        name,
        additional_srcs = [],
        deps = [],
        test_deps = [],
        raw_jni_deps = [],
        wpi_shared_deps = [],
        dev_main_main_class = None,
        has_test = True):
    default_java_library(
        name = name,
        additional_srcs = additional_srcs,
        deps = deps,
        visibility = ["//visibility:public"],
    )

    if has_test:
        default_java_test(
            name = "java-test",
            deps = [":" + name] + test_deps,
            raw_jni_deps = raw_jni_deps,
            wpi_shared_deps = wpi_shared_deps,
        )

    default_java_dev_main(
        name = "DevMainJava",
        main_class = dev_main_main_class,
        deps = [":" + name],
        wpi_shared_deps = wpi_shared_deps,
    )
