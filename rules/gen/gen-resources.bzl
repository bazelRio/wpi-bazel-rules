def _generate_resource_impl(ctx):
    outputs = []

    prefix = ctx.attr.prefix
    namespace = ctx.attr.namespace

    if ctx.attr.use_stringview:
      include_file = "<string_view>"
      return_type = "std::string_view"
    else:
      include_file = "<wpi/StringRef.h>"
      return_type = "wpi::StringRef"

    for input_file in ctx.attr.resource_files:
        input_file = input_file[input_file.rfind("/") + 1:]
        func_name = "GetResource_" + input_file.replace("-", "_").replace(".", "_")

        out = ctx.actions.declare_file(input_file + ".cpp")
        content = """#include <stddef.h>
#include ${include_file}
extern "C" {
static const unsigned char contents[] = { ${data} };
const unsigned char* ${prefix}_${func_name}(size_t* len) {
  *len = ${data_size};
  return contents;
}
}
namespace ${namespace} {
${return_type} ${func_name}() {
  return ${return_type}(reinterpret_cast<const char*>(contents), ${data_size});
}
}

      """.replace("${data}", "0x00").replace("${data_size}", "1").replace("${func_name}", func_name).replace("${prefix}", prefix).replace("${namespace}", namespace).replace("${include_file}", include_file).replace("${return_type}", return_type)

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
        "use_stringview": attr.bool(default = True)
    },
)
