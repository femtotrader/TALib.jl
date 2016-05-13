"""
    generate_ta_func_with_arrays(d, symb)

Generate function code (level 1) with arrays as input / output

# Examples
```julia
julia> generate_ta_func_with_arrays(d, :MAC)
"..."
```
"""
function generate_ta_func_with_arrays(d::OrderedDict{Symbol,Any}, symb_func::Symbol)

    func_info = d[symb_func]

    s_doc_RequiredInputArguments = ""
    s_doc_OptionalInputArguments = ""
    s_doc_OutputArguments = ""
    
    params_lv0 = ASCIIString[]
    params_lv1 = ASCIIString[]
    params_RequiredInputArguments = ASCIIString[]
    params_OptionalInputArguments = ASCIIString[]
    params_OutputArguments = ASCIIString[]

    jltypes = ASCIIString[]

    for arg = ["startIdx", "endIdx"]
        varname = uncamel(arg)
        push!(params_lv0, varname)
    end

    for arg = func_info["RequiredInputArguments"]
        varname = replace_var(arg["Name"])
        push!(params_lv0, varname)
        push!(params_lv1, varname)
        push!(params_RequiredInputArguments, varname)
        push!(jltypes, d_typ_to_jl[arg["Type"]])
        s_doc_RequiredInputArguments *= "\n        - " * varname * "::" * d_typ_to_jl[arg["Type"]]
    end

    for arg = func_info["OptionalInputArguments"]
        varname = fix_varname(arg["Name"])
        push!(params_lv0, varname)
        push!(params_lv1, varname)
        push!(params_OptionalInputArguments, varname)
        push!(jltypes, d_typ_to_jl[arg["Type"]])
        s_doc_OptionalInputArguments *= "\n        - " * varname * "=" * d_typ_to_jl[arg["Type"]] * "(" * string(arg["DefaultValue"]) * ")"
    end

    for arg = ["outBegIdx", "outNbElement"]
        varname = arg #uncamel(arg)
        push!(params_lv0, varname)
        push!(jltypes, "Ref{Cint}")
    end

    for arg = func_info["OutputArguments"]
        varname = arg["Name"]
        push!(params_lv0, varname)
        push!(params_OutputArguments, varname)
        push!(jltypes, d_typ_to_jl[arg["Type"]])
        s_doc_OutputArguments *= "\n        - " * varname * "::" * d_typ_to_jl[arg["Type"]]
    end

    params_lv0 = join(params_lv0, ", ")
    params_lv1 = join(params_lv1, ", ")

    params_lv1_with_types = ""
    for (index, arg) in enumerate(func_info["RequiredInputArguments"])
        if index != 1
            params_lv1_with_types *= ", "
        end
        varname = replace_var(arg["Name"])
        params_lv1_with_types *= varname * "::" * d_typ_to_jl[arg["Type"]]
    end
    for (index, arg) in enumerate(func_info["OptionalInputArguments"])
        if index != 1
            params_lv1_with_types *= ", "
        else
            params_lv1_with_types *= "; "
        end
        varname = fix_varname(arg["Name"])
        params_lv1_with_types *= varname * "=" * d_typ_to_jl[arg["Type"]] * "(" * string(arg["DefaultValue"]) * ")"
    end

    jltypes = join(jltypes, ", ")

    funcname = string(symb_func)
    first_req_input_array = replace_var(func_info["RequiredInputArguments"][1]["Name"])

    s = "

\"\"\"
    $funcname($params_lv1_with_types)

$(func_info["ShortDescription"]) ($(func_info["CamelCaseName"]))

    $(func_info["GroupId"])

    Level: 1 - Arrays

Arguments:

    RequiredInputArguments:$(s_doc_RequiredInputArguments)

    OptionalInputArguments:$(s_doc_OptionalInputArguments)


Returns:$(s_doc_OutputArguments)

\"\"\"
function $funcname($params_lv1_with_types)
    N = length($first_req_input_array)
    start_idx = 0
    end_idx = N - 1
    outBegIdx = Ref{Cint}(0)
    outNbElement = Ref{Cint}(0)"
indent = "    "

for arg = params_OutputArguments
    varname = arg
    s *= "\n"
    s *= indent * "$(varname) = fill(NaN, N)"
end

s *= "\n"
s *= indent * "ret_code = _TA_$funcname($params_lv0)"
s *= "\n"
s *= indent * "_ta_check_success(\"$funcname\", ret_code)"

for arg = params_OutputArguments
    s *= "\n"
    s *= indent * "$arg = circshift($arg, outBegIdx[])"
end

s *= "\n"
if length(params_OutputArguments) == 1
    s *= indent * params_OutputArguments[1]
else
    s *= indent * "[" * join(params_OutputArguments, " ") * "]"  # output as Array{Any,2}
    #s *= indent * join(params_OutputArguments, ", ")  # output as tuple of array
end
s *= "\n"
s *= "end"


s

end
