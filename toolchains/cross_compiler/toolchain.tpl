load(":cc-toolchain-config.bzl", "cc_toolchain_config")
load("@rules_cc//cc:defs.bzl", "cc_toolchain", "cc_toolchain_suite")


def create_cross_compile_toolchain(compiler_dep, cpu, sysroot_subfolder, wrapper_extension):

    # compiler = "Hello"
    tag = "{}".format(cpu)


    builtin_sysroot = "external/{}/{}".format(compiler_dep, sysroot_subfolder)

    cc_toolchain_config_name = "cc-toolchain_config-{}".format(tag)

    compiler_files_name = "compiler_files-{}".format(tag)
    cc_toolchain_name = "cc-compiler-{}".format(tag)
    toolchain_name = "cc-toolchain-{}".format(tag)
    cc_toolchain_suite_name = "compiler"

    sysroot_everything = "@{}//:everything".format(compiler_dep)

    print("**", sysroot_everything)
    toolchain_key = cpu
    
    cxx_builtin_include_directories = [
            "external/{compiler_repo}/{sysroot}/usr/lib/gcc/{sysroot_include_folder}/{cxx_version}/include",
            "external/{compiler_repo}/{sysroot}/usr/lib/gcc/{sysroot_include_folder}/{cxx_version}/include-fixed",
            "external/{compiler_repo}/{sysroot}/usr/include/{sysroot_include_folder}/c++/{cxx_version}",
            "external/{compiler_repo}/{sysroot}/usr/include/c++/{cxx_version}",
            "external/{compiler_repo}/{sysroot}/usr/include/c++/{cxx_version}/{sysroot_include_folder}",
            "external/{compiler_repo}/{sysroot}/usr/include/c++/{cxx_version}/backward",
            "external/{compiler_repo}/{sysroot}/usr/include/{sysroot_include_folder}",
            "external/{compiler_repo}/{sysroot}/usr/include",
    ]
    
    cc_toolchain_config(
        name = cc_toolchain_config_name,
        cpu = cpu,
        compiler = "hello",
        toolchain_identifier = toolchain_name,
        # builtin_sysroot = builtin_sysroot,
        wrapper_extension=wrapper_extension,
        cxx_builtin_include_directories=cxx_builtin_include_directories
    )

    native.filegroup(
        name = compiler_files_name,
        srcs = native.glob(["bin/**"]) + [
            sysroot_everything
        ] ,
    )

    cc_toolchain(
        name = cc_toolchain_name,
        all_files = compiler_files_name,
        ar_files = compiler_files_name,
        as_files = compiler_files_name,
        compiler_files =  compiler_files_name,
        dwp_files = compiler_files_name,
        # dynamic_runtime_lib = [],
        linker_files =  compiler_files_name,
        objcopy_files = compiler_files_name,
        # static_runtime_lib = [],
        strip_files = compiler_files_name,
        supports_param_files = True,
        toolchain_config = cc_toolchain_config_name,
        visibility = ["//visibility:public"],
    )

    native.toolchain(
        name = toolchain_name,
        exec_compatible_with = ["@bazel_tools//platforms/linux"],
        target_compatible_with = ["@bazel_tools//platforms/linux"],
        toolchain = cc_toolchain_name,
        toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
    )
    
    cc_toolchain_suite(
        name = cc_toolchain_suite_name,
        toolchains = {
            toolchain_key: cc_toolchain_name,
        },
        tags = ["manual"],
    )
