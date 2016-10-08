"""
    generate_ta_func_raw(d, symb)

Generate function code (level 0)

# Examples
```julia
julia> generate_ta_func_raw(d, :MAC)
"..."
```
"""
function generate_ta_func_raw(d::OrderedDict{Symbol,Any}, symb_func::Symbol)
    func_info = d[symb_func]

    s_doc_Index = ""
    s_doc_RequiredInputArguments = ""
    s_doc_OptionalInputArguments = ""
    s_doc_OutputArguments = ""
    
    params = String[]
    ctypes = String[]
    for arg = ["startIdx", "endIdx"]
        varname = uncamel(arg)
        vartyp = "Cint"
        push!(params, varname)
        push!(ctypes, vartyp)
        s_doc_Index *= "\n        - $arg::$vartyp"
    end

    for arg = func_info["RequiredInputArguments"]
        varname = replace_var(arg["Name"])
        vartyp = d_typ_to_c[arg["Type"]]
        push!(params, string(varname))
        push!(ctypes, string(vartyp))
        s_doc_RequiredInputArguments *= "\n        - $varname::$vartyp"
    end

    for arg = func_info["OptionalInputArguments"]
        varname = fix_varname(arg["Name"])
        vartyp = d_typ_to_c[arg["Type"]]
        push!(params, varname)
        push!(ctypes, string(vartyp))
        s_doc_OptionalInputArguments *= "\n        - $varname::$vartyp"
    end

    for arg = ["outBegIdx", "outNbElement"]
        varname = arg #uncamel(arg)
        push!(params, varname)
        push!(ctypes, "Ref{Cint}")
    end

    for arg = func_info["OutputArguments"]
        varname = arg["Name"]
        vartyp = d_typ_to_c[arg["Type"]]
        push!(params, varname)
        push!(ctypes, string(vartyp))
        s_doc_OutputArguments *= "\n        - $varname::$vartyp"
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
        (:$c_funcname, libta_lib), $ret_typ, 
        ($ctypes),
        $params
    )
end"

s
end
