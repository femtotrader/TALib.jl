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

function write_xml(filename)
    s_xml = FunctionDescriptionXML()
    f = open(filename, "w")
    write(f, s_xml)
    close(f)
end

function main()
    path = joinpath(basepath(), "generated")
    
    filename = joinpath(path, "ta_func_api.xml")
    println("# Write XML file to '$filename'")
    write_xml(filename)

    filename = joinpath(path, "ta_func_api.json")
    println("# Write JSON file to '$filename'")
    write_json(filename)
end

main()
