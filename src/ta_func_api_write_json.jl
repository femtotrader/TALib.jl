using LightXML
using XMLconvert  # https://github.com/bcbi/XMLconvert.jl

include("constants.jl")
include("path.jl")
include("describe.jl")

function write_json(filename)
    s_xml = FunctionDescriptionXML()
    xdoc = parse_string(s_xml)
    xroot = root(xdoc)
    xdict = xml2dict(xroot)
    json_string = xml2json(xroot)
    f = open(filename, "w")
    write(f, json_string)
    close(f)
end

filename = basepath() * "generated/ta_func_api.json"
println("# Write JSON file to '$filename'")
write_json(filename)
