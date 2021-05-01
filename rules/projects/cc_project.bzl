load("@wpi_bazel_rules//rules:cc.bzl", "default_wpilib_cc_dev_main", "default_wpilib_cc_library", "default_wpilib_cc_shared_library", "default_wpilib_cc_test")

def cc_project(
        name,
        additional_srcs = [],
        raw_deps = [],
        test_libraries = [],
        wpi_shared_deps = [],
        test_linkopts = [],
        build_as_shared = False,
        has_test = True):


    if build_as_shared:
        test_raw_deps = test_libraries
        test_wpi_shared_deps = [":" + name]

        default_wpilib_cc_shared_library(
            name = name,
            additional_srcs = additional_srcs,
            raw_deps = raw_deps,
            wpi_shared_deps = wpi_shared_deps,
            visibility = ["//visibility:public"],
        )
    else:
        test_raw_deps = [":" + name] + test_libraries
        test_wpi_shared_deps = []

        default_wpilib_cc_library(
            name = name,
            additional_srcs = additional_srcs,
            raw_deps = raw_deps,
            wpi_shared_deps = wpi_shared_deps,
            visibility = ["//visibility:public"],
        )

    if has_test:
        default_wpilib_cc_test(
            name = name + "-test",
            raw_deps = test_raw_deps,
            wpi_shared_deps = test_wpi_shared_deps,
            linkopts = test_linkopts,
        )

    default_wpilib_cc_dev_main(
        name = "DevMainCpp",
        raw_deps = test_raw_deps,
        wpi_shared_deps = test_wpi_shared_deps,
        linkopts = test_linkopts,
    )
