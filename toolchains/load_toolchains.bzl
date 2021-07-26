def configure_cross_compiler_impl(repository_ctx):
    compiler_name = repository_ctx.attr.compiler

    substitutions = {
        "{bin_subfolder}": repository_ctx.attr.bin_subfolder,
        "{binary_prefix}": repository_ctx.attr.bin_prefix,
        "{sysroot}": repository_ctx.attr.sysroot_subfolder,
        "{cxx_version}": repository_ctx.attr.cxx_version,
        "{sysroot_include_folder}": repository_ctx.attr.sysroot_include_folder,
        "{compiler}": compiler_name,
        "{command_prefix}": "",
        "{exe_suffix}": "",
        "{wrapper_extension}": "",
        "{tool_platform_suffix}": "",
        "{sep}": "/",
        "{arg_passthrough}": '"$@"',
    }

    if repository_ctx.os.name.startswith("windows"):
        substitutions["{command_prefix}"] = "@echo off\n"
        substitutions["{tool_platform_suffix}"] = ".exe"
        substitutions["{compiler_repo}"] = compiler_name + "-compiler-win"
        substitutions["{sep}"] = "\\"
        substitutions["{bin_subfolder}"] = substitutions["{bin_subfolder}"].replace("/", "\\")

        substitutions["{arg_passthrough}"] = "%*"
        substitutions["{wrapper_extension}"] = ".bat"
    elif repository_ctx.os.name == "mac os x":
        substitutions["{compiler_repo}"] = compiler_name + "-compiler-osx"
    elif repository_ctx.os.name == "linux":
        substitutions["{compiler_repo}"] = compiler_name + "-compiler-linux"
    else:
        fail("Unknown os " + repository_ctx.os.name)

    BINARIES = [
        "ar",
        "cpp",
        "gcc",
        "gcov",
        "ld",
        "nm",
        "objdump",
        "strip",
    ]

    for binary in BINARIES:
        bin_substitution = dict(substitutions)
        bin_substitution["{binary_target}"] = binary
        repository_ctx.template(
            "bin/" + binary + substitutions["{wrapper_extension}"],
            repository_ctx.path(Label("@wpi_bazel_rules//toolchains/cross_compiler:command_wrapper.tpl")),
            substitutions = bin_substitution,
        )

    repository_ctx.template(
        "BUILD.bazel",
        repository_ctx.path(Label("@wpi_bazel_rules//toolchains/cross_compiler:BUILD.tpl")),
        substitutions = substitutions,
    )

    repository_ctx.template(
        "configure_toolchain.bzl",
        repository_ctx.path(Label("@wpi_bazel_rules//toolchains/cross_compiler/" + compiler_name + ":configure_toolchain.bzl")),
        substitutions = substitutions,
    )

    repository_ctx.template(
        "cc-toolchain-config.bzl",
        repository_ctx.path(Label("@wpi_bazel_rules//toolchains/cross_compiler:cc-toolchain-config.bzl")),
        substitutions = substitutions,
    )

    repository_ctx.template(
        "toolchain.bzl",
        repository_ctx.path(Label("@wpi_bazel_rules//toolchains/cross_compiler:toolchain.tpl")),
        substitutions = substitutions,
    )

configure_cross_compiler = repository_rule(
    implementation = configure_cross_compiler_impl,
    configure = True,
    attrs = {
        "compiler": attr.string(mandatory = True),
        "bin_subfolder": attr.string(mandatory = True),
        "bin_prefix": attr.string(mandatory = True),
        "sysroot_subfolder": attr.string(mandatory = True),
        "cxx_version": attr.string(mandatory = True),
        "sysroot_include_folder": attr.string(mandatory = True),
    },
)

def load_toolchains():
    configure_cross_compiler(
        name = "local_roborio",
        compiler = "roborio",
        bin_subfolder = "frc2021/roborio/bin",
        bin_prefix = "arm-frc2021-linux-gnueabi-",
        sysroot_subfolder = "frc2021/roborio/arm-frc2021-linux-gnueabi",
        cxx_version = "7.3.0",
        sysroot_include_folder = "arm-frc2021-linux-gnueabi",
    )

    configure_cross_compiler(
        name = "local_raspbian",
        compiler = "raspbian",
        bin_subfolder = "raspbian10/bin",
        bin_prefix = "arm-raspbian10-linux-gnueabihf-",
        sysroot_subfolder = "raspbian10/sys-root",
        cxx_version = "8",
        sysroot_include_folder = "arm-linux-gnueabihf",
    )

    configure_cross_compiler(
        name = "local_bionic",
        compiler = "bionic",
        bin_subfolder = "bionic/bin",
        bin_prefix = "aarch64-bionic-linux-gnu-",
        sysroot_subfolder = "bionic/sys-root",
        cxx_version = "8",
        sysroot_include_folder = "aarch64-linux-gnu",
    )
