load("@wpi_bazel_rules//rules:cc.bzl", "default_wpilib_cc_dev_main", "default_wpilib_cc_shared_library", "default_wpilib_cc_test")
load("@wpi_bazel_rules//rules:java.bzl", "default_java_dev_main", "default_java_library", "default_java_test")
load("@wpi_bazel_rules//rules:jni.bzl", "wpilib_jni_library")

def jni_project(
        name,
        cc_additional_srcs = [],
        cc_raw_deps = [],
        cc_shared_deps = [],
        cc_includes = [],
        cc_test_deps = [],
        export_cc_symbols = True,
        export_jni_symbols = True,
        java_additional_srcs = [],
        java_deps = [],
        java_raw_jni_deps = [],
        java_shared_jni_deps = [],
        java_additional_java_jni_files = [],
        java_dev_main_class = None,
        java_has_test = True):
    jni_name = name + "jni"

    default_wpilib_cc_shared_library(
        name = name,
        additional_srcs = cc_additional_srcs,
        raw_deps = cc_raw_deps,
        wpi_shared_deps = cc_shared_deps,
        includes = cc_includes,
        export_symbols = export_cc_symbols,
        defines = ["WPILIB_EXPORTS"],
        visibility = ["//visibility:public"],
    )

    default_wpilib_cc_test(
        name = "cpp-test",
        raw_deps = cc_test_deps,
        wpi_shared_deps = [":" + name],
    )

    default_java_library(
        name = "java",
        deps = java_deps,
        additional_srcs = java_additional_srcs,
        visibility = ["//visibility:public"],
    )

    wpilib_jni_library(
        name = jni_name,
        java_lib = ":java",
        jni_files = java_additional_java_jni_files + native.glob(["src/main/java/**/*JNI.java"]),
        srcs = native.glob([
            "src/main/native/cpp/jni/**/*.cpp",
            "src/main/native/cpp/jni/**/*.h",
        ]),
        wpi_maybe_shared_deps = [":" + name],
        visibility = ["//visibility:public"],
        export_symbols = export_jni_symbols,
    )

    if java_has_test:
        default_java_test(
            name = "java-test",
            deps = [":java"],
            raw_jni_deps = java_raw_jni_deps,
            wpi_shared_deps = [
                ":" + name,
                ":" + jni_name,
            ] + cc_shared_deps + java_shared_jni_deps,
        )

    default_wpilib_cc_dev_main(
        name = "DevMainCpp",
        wpi_shared_deps = [":" + name],
    )

    default_java_dev_main(
        name = "DevMainJava",
        main_class = java_dev_main_class,
        deps = [":java"],
        wpi_shared_deps = [
            ":" + name,
            ":" + jni_name,
        ] + cc_shared_deps,
    )
