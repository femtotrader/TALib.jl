include("../src/TALib.jl")
include("../src/tools.jl")

using JSON
using DataStructures
#filename = "ta_func_api.json"
filename = "scripts/ta_func_api.json"
lst_ta_func = JSON.parsefile(filename)["FinancialFunctions"]["FinancialFunction"]

d_typ_to_c = Dict(
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
    l = []  # length of RequiredInputArguments, OptionalInputArguments, OutputArguments
    for key = ["RequiredInputArgument", "OptionalInputArgument", "OutputArgument"]
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
            if !haskey(d_typ_to_c, arg["Type"])
                error("$(arg["Type"]) is not a supported type")
            end
        end

        push!(l, length(func_info[key * "s"]))

    end
    #func_info["Length"] = l
    d[symbol(funcname)] = func_info
end

function write_json_file(d, filename="new_ta_func_api.json")
    f = open(filename, "w")
    JSON.print(f, d)
    close(f)
end

write_json_file(d)

"""
    generate_ta_func_raw(d, symb)

Generate function code (level 0)

# Examples
```julia
julia> generate_ta_func_raw(d, :MAC)
"..."
```
"""
function generate_ta_func_raw(d, symb_func::Symbol)
    func_info = d[symb_func]

    s_doc_Index = ""
    s_doc_RequiredInputArguments = ""
    s_doc_OptionalInputArguments = ""
    s_doc_OutputArguments = ""
    
    params = ASCIIString[]
    ctypes = ASCIIString[]
    for arg = ["startIdx", "endIdx"]
        varname = uncamel(arg)
        typ = "Cint"
        push!(params, varname)
        push!(ctypes, typ)
        s_doc_Index *= "\n        - " * arg * "::" * typ
    end

    for arg = func_info["RequiredInputArguments"]
        varname = replace_var(arg["Name"])
        push!(params, varname)
        push!(ctypes, d_typ_to_c[arg["Type"]])
        s_doc_RequiredInputArguments *= "\n        - " * varname * "::" * d_typ_to_c[arg["Type"]]
    end

    for arg = func_info["OptionalInputArguments"]
        varname = fix_varname(arg["Name"])
        push!(params, varname)
        push!(ctypes, d_typ_to_c[arg["Type"]])
        s_doc_OptionalInputArguments *= "\n        - " * varname * "::" * d_typ_to_c[arg["Type"]]
    end

    for arg = ["outBegIdx", "outNBElement"]
        varname = arg #uncamel(arg)
        push!(params, varname)
        push!(ctypes, "Ref{Cint}")
    end

    for arg = func_info["OutputArguments"]
        varname = arg["Name"]
        push!(params, varname)
        push!(ctypes, d_typ_to_c[arg["Type"]])
        s_doc_OutputArguments *= "\n        - " * varname * "::" * d_typ_to_c[arg["Type"]]
    end

    params = join(params, ", ")
    ctypes = join(ctypes, ", ")

    funcname = "_TA_" * string(symb_func)
    c_funcname = "TA_" * string(symb_func)
    ret_typ = "TA_RetCode"
    s = "

\"\"\"
    $funcname($params)

$(func_info["ShortDescription"]) ($(func_info["CamelCaseName"]))

    $(func_info["GroupId"])

    Level: 0 - raw

Arguments:

    Indexes:$(s_doc_Index)

    RequiredInputArguments:$(s_doc_RequiredInputArguments)

    OptionalInputArguments:$(s_doc_OptionalInputArguments)

    OutputArguments:$(s_doc_OutputArguments)

Returns:

    ::$ret_typ

\"\"\"
function $funcname($params)
    ccall(
        (:$c_funcname, TA_LIB_PATH), $ret_typ, 
        ($ctypes),
        $params
    )
end"

s
end


"""
    generate_ta_func_with_arrays(d, symb)

Generate function code (level 1) with arrays as input / output

# Examples
```julia
julia> generate_ta_func_with_arrays(d, :MAC)
"..."
```
"""
function generate_ta_func_with_arrays(d, symb_func::Symbol)

    func_info = d[symb_func]

    s_doc_RequiredInputArguments = ""
    s_doc_OptionalInputArguments = ""
    s_doc_OutputArguments = ""
    
    params = ASCIIString[]
    ctypes = ASCIIString[]

    for arg = func_info["RequiredInputArguments"]
        varname = arg["Name"]
        push!(params, varname)
        push!(ctypes, d_typ_to_c[arg["Type"]])
        s_doc_RequiredInputArguments *= "\n        - " * varname * "::" * d_typ_to_c[arg["Type"]]
    end

    for arg = func_info["OptionalInputArguments"]
        varname = fix_varname(arg["Name"])
        push!(params, varname)
        push!(ctypes, d_typ_to_c[arg["Type"]])
        s_doc_OptionalInputArguments *= "\n        - " * varname * "::" * d_typ_to_c[arg["Type"]]
    end

    for arg = ["outBegIdx", "outNBElement"]
        varname = arg #uncamel(arg)
        push!(params, varname)
        push!(ctypes, "Ref{Cint}")
    end

    for arg = func_info["OutputArguments"]
        varname = arg["Name"]
        push!(params, varname)
        push!(ctypes, d_typ_to_c[arg["Type"]])
        s_doc_OutputArguments *= "\n        - " * varname * "::" * d_typ_to_c[arg["Type"]]
    end

    params = join(params, ", ")
    ctypes = join(ctypes, ", ")

    funcname = string(symb_func)
    ret_typ = "???"
    s = "

\"\"\"
    $funcname($params)

$(func_info["ShortDescription"]) ($(func_info["CamelCaseName"]))

    $(func_info["GroupId"])

    Level: 1 - Arrays

Arguments:

    RequiredInputArguments:$(s_doc_RequiredInputArguments)

    OptionalInputArguments:$(s_doc_OptionalInputArguments)


Returns:$(s_doc_OutputArguments)

\"\"\"
function $funcname($params)

end"

s

end

function generate_ta_func_with_dataframes(d, symb_func::Symbol)

end



for s in keys(d)
    println(generate_ta_func_raw(d, s))
    #println(generate_ta_func_with_arrays(d, s))
    #println(generate_ta_func_with_dataframes(d, s))
end

#println(repeat("=", 10))


