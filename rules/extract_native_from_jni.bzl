def __copy_jni_files_impl(ctx):
    all_input_files = [
        f
        for t in ctx.attr.jni_deps
        for f in t.files.to_list()
    ]

    all_outputs = []
    for jni_dep in all_input_files:
        out = ctx.actions.declare_file(ctx.attr.output_directory + "/" + jni_dep.short_path)
        all_outputs.append(out)
        ctx.actions.run_shell(
            outputs = [out],
            inputs = depset([jni_dep]),
            arguments = [jni_dep.path, out.path],
            command = "cp $1 $2",
        )

    return [
        DefaultInfo(
            files = depset(all_outputs),
            runfiles = ctx.runfiles(files = all_outputs),
        ),
    ]

__copy_jni_files = rule(
    implementation = __copy_jni_files_impl,
    attrs = {
        "jni_deps": attr.label_list(mandatory = True),
        "output_directory": attr.string(mandatory = True),
    },
)

def extract_files_from_jni_jar(name, jni_deps, output_directory = "extracted_jni"):
    __copy_jni_files(
        name = name,
        jni_deps = jni_deps,
        output_directory = output_directory,
    )
