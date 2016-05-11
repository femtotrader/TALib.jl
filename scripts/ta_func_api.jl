include("../src/TALib.jl")

using TALib
using LightXML

s_xml = FunctionDescriptionXML()

#println(s_xml)
#println(typeof(s_xml))

xdoc = parse_string(s_xml)

# get the root element
xroot = root(xdoc)

println(name(xroot))  # this should print: bookstore

# traverse all its child nodes and print element names
for c in child_nodes(xroot)  # c is an instance of XMLNode
    #println(c)
    println(nodetype(c))
    if is_elementnode(c)
        e = XMLElement(c)  # this makes an XMLElement instance
        println(name(e))
    end
end

using JSON
using DataStructures
#filename = "ta_func_api.json"
filename = "scripts/ta_func_api.json"
lst_ta_func = JSON.parsefile(filename)["FinancialFunctions"]["FinancialFunction"]

d_typ = Dict(
   "Integer" => "Cint",
   "Double" => "Cdouble",
   "Integer Array" => "Ptr{Cint}",
   "Double Array" => "Ptr{Cdouble}",
   "MA Type" => "TA_MAType",
   "Open" => "Ptr{Cdouble}",
   "High" => "Ptr{Cdouble}",
   "Low" => "Ptr{Cdouble}",
   "Close" => "Ptr{Cdouble}",
   "Volume" => "Ptr{Cdouble}",
)

#d = Dict{AbstractString,Any}()
d = OrderedDict{Symbol,Any}()
for func_info = lst_ta_func
    funcname = func_info["Abbreviation"]
    delete!(func_info, "Abbreviation")
    for key = ["RequiredInputArgument", "OutputArgument", "OptionalInputArgument"]
        if haskey(func_info, key * "s")
            if typeof(func_info[key * "s"][key]) == Dict{AbstractString,Any}
                func_info[key * "s"] = [func_info[key * "s"][key]]  # list of only ONE element
            else
                func_info[key * "s"] = func_info[key * "s"][key]
            end
        else
            func_info[key * "s"] = []
        end
        for arg = func_info[key * "s"]
            if !haskey(d_typ, arg["Type"])
                error("$(arg["Type"]) is not a supported type")
            end
        end
    end
    d[symbol(funcname)] = func_info
end

f = open("new_ta_func_api.json", "w")
JSON.print(f, d)
close(f)



function proto(d, s_func::Symbol)
    func_info = d[s_func]
#d[s_func]["RequiredInputArguments"]["RequiredInputArgument"]["Type"]
#d[s_func]["RequiredInputArguments"]["RequiredInputArgument"]["Name"]
#d[s_func]["OutputArguments"]["OutputArgument"]
#d[s_func]["OutputArguments"]["OutputArgument"]["Type"]
#d[s_func]["OutputArguments"]["OutputArgument"]["Name"]

    params = "startIdx, endIdx"
    ctypes = "Cint, Cint"
    for arg = func_info["RequiredInputArguments"]
        params *= (", " * arg["Name"])
        ctypes *= (", " * d_typ[arg["Type"]])
    end
    for arg = func_info["OptionalInputArguments"]
        params *= (", " * varname(arg["Name"]))
        ctypes *= (", " * d_typ[arg["Type"]])
    end
    params *= ", outBegIdx, outNBElement"
    ctypes *= ", Ref{Cint}, Ref{Cint}"
    for arg = func_info["OutputArguments"]
        params *= (", " * arg["Name"])
        ctypes *= (", " * d_typ[arg["Type"]])
    end

#_TA_BBANDS(startIdx, endIdx, inReal, timeperiod, nbdevup, nbdevdn, matype, outBegIdx, outNBElement, outRealUpperBand, outRealMiddleBand, outRealLowerBand)

    params * "\n" * ctypes

    funcname = "_TA_" * string(s_func)
    ret_typ = "TA_RetCode"
    s = "

\"\"\"
    $funcname($params)

$(func_info["ShortDescription"]) ($(func_info["CamelCaseName"]))

    $(func_info["GroupId"])

Arguments:
    Indexes:
        - startIdx::Cint - start index
        - endIdx::Cint - end index

    RequiredInputArguments:
        - ToDo

    OptionalInputArguments:
        - ToDo

    OutputArguments:
        - ToDo

Returns:
    - ::$ret_typ

\"\"\"
function $funcname($params)
    ccall(
        (:TA_BBANDS, TA_LIB_PATH), $ret_typ, 
        ($ctypes),
        $params
    )
end"

s
end

