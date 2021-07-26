load("@local_roborio//:configure_toolchain.bzl", "configure_roborio_toolchain")
load("@local_raspbian//:configure_toolchain.bzl", "configure_raspbian_toolchain")
load("@local_bionic//:configure_toolchain.bzl", "configure_bionic_toolchain")

def configure_toolchains():
    configure_roborio_toolchain()
    configure_raspbian_toolchain()
    configure_bionic_toolchain()
