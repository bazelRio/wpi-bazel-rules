load("@rules_java//java:defs.bzl", "java_binary", "java_library", "java_test")
load("@wpi_bazel_rules//rules:flat_copy_files.bzl", "flat_copy_files")
load("@wpi_bazel_rules//rules:cc.bzl", "convert_to_shared_libs")

def __absolute_label(label):
    if label.startswith("@") or label.startswith("/"):
        return label
    if label.startswith(":"):
        return native.repository_name() + "//" + native.package_name() + label
    return "@" + native.repository_name() + "//" + native.package_name() + ":" + label

def __prepare_jni_deps(name, jni_deps, win_destination_suffix):
    if not jni_deps:
        return [], None, {}

    flat_copy_files(
        name = name + "_jni_deps",
        targeted_filegroups = jni_deps,
        output_directory = select({
            "@bazel_tools//src/conditions:windows": name + ".exe.runfiles" + win_destination_suffix,
            "@bazel_tools//src/conditions:linux_x86_64": "extracted_native",
            "@bazel_tools//src/conditions:darwin": "extracted_native",
        }),
        tags = ["no-roborio", "no-bionic", "no-raspbian"],
    )

    full_extracted_native_dir = native.package_name() + "/extracted_native"
    prepared_targets = [":" + name + "_jni_deps"]
    jvm_flags = select({
        "@bazel_tools//src/conditions:windows": ["-Djava.library.path=."],
        "@bazel_tools//src/conditions:linux_x86_64": ["-Djava.library.path=" + full_extracted_native_dir],
        "@bazel_tools//src/conditions:darwin": ["-Djava.library.path=" + full_extracted_native_dir],
    })

    env_dict = {
        "@bazel_tools//src/conditions:windows": {},
        "//conditions:default": {"LD_LIBRARY_PATH": full_extracted_native_dir},
    }

    return prepared_targets, jvm_flags, env_dict

def wpilib_java_binary(name, data = [], jni_deps = [], env = None, raw_jni_deps = [], env_dict = None, wpi_shared_deps = [], **kwargs):
    if jni_deps:
        fail("nope")

    if env:
        fail("nope")

    jni_deps = convert_to_shared_libs(wpi_shared_deps) + raw_jni_deps

    prepared_jni_deps, jvm_flags, jni_env_dict = __prepare_jni_deps(name, jni_deps, "")
    if env_dict:
        for key in env_dict:
            if key in jni_env_dict:
                env_dict[key].update(jni_env_dict[key])
    else:
        env_dict = jni_env_dict

    java_binary(
        name = name,
        data = data + prepared_jni_deps,
        jvm_flags = jvm_flags,
        env = select(env_dict) if env_dict else None,
        **kwargs
    )

def wpilib_junit5_test(
        name,
        deps = [],
        data = [],
        wpi_shared_deps = [],
        raw_jni_deps = [],
        jni_deps = [],
        runtime_deps = [],
        args = [],
        package = "edu",
        **kwargs):
    if jni_deps:
        fail("no more")

    jni_deps = convert_to_shared_libs(wpi_shared_deps) + raw_jni_deps

    prepared_jni_deps, jvm_flags, env_dict = __prepare_jni_deps(name, jni_deps, "/__main__")

    junit_deps = [
        "@maven//:org_junit_jupiter_junit_jupiter_api",
        "@maven//:org_junit_jupiter_junit_jupiter_params",
        "@maven//:org_junit_jupiter_junit_jupiter_engine",
    ]

    junit_runtime_deps = [
        "@maven//:org_junit_platform_junit_platform_commons",
        "@maven//:org_junit_platform_junit_platform_console",
        "@maven//:org_junit_platform_junit_platform_engine",
        "@maven//:org_junit_platform_junit_platform_launcher",
        "@maven//:org_junit_platform_junit_platform_suite_api",
    ]

    java_test(
        name = name,
        deps = deps + junit_deps,
        data = data + prepared_jni_deps,
        runtime_deps = runtime_deps + junit_runtime_deps,
        args = args + ["--select-package", package],
        main_class = "org.junit.platform.console.ConsoleLauncher",
        use_testrunner = False,
        jvm_flags = jvm_flags,
        env = select(env_dict) if env_dict else None,
        tags = ["no-roborio", "no-bionic", "no-raspbian"],
        **kwargs
    )

def default_java_library(
        name,
        srcs = [],
        additional_srcs = [],
        **kwargs):
    if srcs:
        fail("You cannot use the default rule and specify srcs")

    java_library(
        name = name,
        srcs = additional_srcs + native.glob(["src/main/java/**/*.java"]),
        resources = native.glob(["src/main/resources/**"]),
        **kwargs
    )

def default_java_test(
        name,
        srcs = [],
        **kwargs):
    if srcs:
        fail("You cannot use the default rule and specify srcs")

    wpilib_junit5_test(
        name = name,
        srcs = native.glob(["src/test/java/**/*.java"]),
        resources = native.glob(["src/test/resources/**"]),
        **kwargs
    )

def default_java_dev_main(
        name,
        srcs = [],
        **kwargs):
    if srcs:
        fail("You cannot use the default rule and specify srcs")

    wpilib_java_binary(
        name = name,
        srcs = native.glob(["src/dev/java/**/*.java"]),
        resources = native.glob(["src/dev/resources/**"]),
        **kwargs
    )
