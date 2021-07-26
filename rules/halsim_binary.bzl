load("@wpi_bazel_rules//rules:cc.bzl", "convert_to_shared_libs", "wpilib_cc_binary")
load("@wpi_bazel_rules//rules:java.bzl", "wpilib_java_binary")
load("@wpi_bazel_rules//rules:flat_copy_files.bzl", "flat_copy_files")

def __prep_halsim_environment(halsim_deps):
    if not halsim_deps:
        return [], []

    actual_targets = convert_to_shared_libs(halsim_deps)

    target_basenames = []
    for target in actual_targets:
        lbl = Label(target)
        target_basenames.append(lbl.name)

    return target_basenames, actual_targets

def wpilib_java_halsim_binary(name, tags = [], halsim_deps = [], wpi_shared_deps = [], **kwargs):
    env_dict = None

    target_basenames, _ = __prep_halsim_environment(halsim_deps)

    if halsim_deps:
        env_dict = {
            "@bazel_tools//src/conditions:windows": {
                "HALSIM_EXTENSIONS": ";".join(target_basenames),
            },
            "//conditions:default": {
                "HALSIM_EXTENSIONS": ":".join(target_basenames),
            },
        }

    wpilib_java_binary(
        name = name,
        env_dict = env_dict,
        wpi_shared_deps = wpi_shared_deps + halsim_deps,
        tags = tags + ["no-roborio", "no-bionic", "no-raspbian"],
        **kwargs
    )

def wpilib_cc_halsim_binary(
        name,
        halsim_deps = [],
        data = [],
        tags = [],
        **kwargs):
    env = {}

    copied_halsim_dep_target = []
    if halsim_deps:
        target_basenames, actual_targets = __prep_halsim_environment(halsim_deps)

        flat_copy_files(
            name = name + "_copy_halsim",
            targeted_filegroups = actual_targets,
            output_directory = select({
                "@bazel_tools//src/conditions:windows": name + ".exe.runfiles",
                "@bazel_tools//src/conditions:linux_x86_64": ".",
                "@bazel_tools//src/conditions:darwin": ".",
            }),
            tags = tags + ["no-roborio", "no-bionic", "no-raspbian"],
        )
        copied_halsim_dep_target = [":" + name + "_copy_halsim"]

        env = select({
            "@bazel_tools//src/conditions:windows": {
                "HALSIM_EXTENSIONS": ";".join(target_basenames),
            },
            "//conditions:default": {
                "HALSIM_EXTENSIONS": ":".join(["./" + native.package_name() + "/lib" + x + ".so" for x in target_basenames]),
            },
        })

    wpilib_cc_binary(
        name = name,
        data = data + select({
            "@bazel_tools//src/conditions:windows": copied_halsim_dep_target,
            "@bazel_tools//src/conditions:linux_x86_64": copied_halsim_dep_target,
            "@bazel_tools//src/conditions:darwin": copied_halsim_dep_target,
            "@wpi_bazel_rules//toolchains/conditions:raspbian": [],
            "@wpi_bazel_rules//toolchains/conditions:bionic": [],
            "@wpi_bazel_rules//toolchains/conditions:roborio": [],
        }),
        env = env,
        tags = tags + ["no-roborio", "no-bionic", "no-raspbian"],
        **kwargs
    )
