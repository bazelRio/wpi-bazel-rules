
import sys
import hashlib
import zipfile


def sanitize_path(lib):
    split_path = lib.split("/")
    remapped_name = "/".join(split_path[2:])

    if "WindowsLoaderHelper.dll" in lib:
        remapped_name = "windows/x86-64/shared/WindowsLoaderHelper.dll"

    return remapped_name

def create_json_file(libraries, json_output_file):
    the_hash = hashlib.md5()

    library_content = ""

    for lib in libraries:
        the_hash.update(open(lib, 'rb').read())
        library_content += '\n       "/' + sanitize_path(lib) + '",'

    library_content = library_content[:-1]

    content = """
{
   "versions": [],
   "windows": {
     "x86-64": [
       $(LIBRARIES)
     ]
   },
   "hash": "$(HASH)"
}
    """.replace("$(LIBRARIES)", library_content).replace("$(HASH)", the_hash.hexdigest())

    with open(json_output_file, 'w') as f:
        f.write(content)


def zip_libraries(libraries, json_file, output_file):

    with zipfile.ZipFile(output_file, "w") as zf:
        zf.write(json_file)

        for lib in libraries:
            zf.write(lib, sanitize_path(lib))


def main(argv):
    output_file = argv[0]
    json_output_file = argv[1]
    libraries = argv[2:]

    create_json_file(libraries, json_output_file)
    zip_libraries(libraries, json_output_file, output_file)


if __name__ == "__main__":
    main(sys.argv[1:])
