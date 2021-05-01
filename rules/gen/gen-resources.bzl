def _generate_resource_impl(ctx):
    outputs = []

    prefix = ctx.attr.prefix
    namespace = ctx.attr.namespace

    for input_file in ctx.attr.resource_files:
        input_file = input_file[input_file.rfind("/") + 1:]
        func_name = "GetResource_" + input_file.replace("-", "_").replace(".", "_")

        out = ctx.actions.declare_file(input_file + ".cpp")
        content = """#include <stddef.h>
#include <wpi/StringRef.h>
extern "C" {
static const unsigned char contents[] = { ${data} };
const unsigned char* ${prefix}_${func_name}(size_t* len) {
  *len = ${data_size};
  return contents;
}
}
namespace ${namespace} {
wpi::StringRef ${func_name}() {
  return wpi::StringRef(reinterpret_cast<const char*>(contents), ${data_size});
}
}

      """.replace("${data}", "0x00").replace("${data_size}", "1").replace("${func_name}", func_name).replace("${prefix}", prefix).replace("${namespace}", namespace)

        ctx.actions.write(
            output = out,
            content = content,
        )

        outputs.append(out)

    return [DefaultInfo(files = depset(outputs))]

generate_resources = rule(
    implementation = _generate_resource_impl,
    attrs = {
        "resource_files": attr.string_list(mandatory = True),
        "prefix": attr.string(mandatory = True),
        "namespace": attr.string(mandatory = True),
    },
)
