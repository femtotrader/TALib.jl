#=

Work In Progress

=#

include("constants.jl")
include("path.jl")
include("tools.jl")
include("describe.jl")

using DataFrames

d_var_symb = Dict{ASCIIString,Symbol}(
    "inReal" => :price,
    "Open" => _OPEN,
    "High" => _HIGH,
    "Low" => _LOW,
    "Close" => _CLOSE,
    "Volume" => _VOLUME,
)

function replace_var_to_symbol(s)
    get(d_var_symb, s, s)
end

function generate_header_ta_func_with_dataframes()
    s_code = generate_header()
    s_code *= "\n"
    s_code *= "using DataFrames"
    s_code *= "\n"
    s_code
end

function generate_ta_func_with_dataframes(d::OrderedDict{Symbol,Any}, symb_func::Symbol)


    func_info = d[symb_func]

    s_doc_RequiredInputArguments = ""
    s_doc_OptionalInputArguments = ""
    s_doc_OutputArguments = ""

    params_lv1_with_values = ""
    
    params_lv1 = ASCIIString[]
    params_lv2 = ASCIIString[]
    params_RequiredInputArguments = ASCIIString[]
    params_OptionalInputArguments = ASCIIString[]
    params_OutputArguments = ASCIIString[]

    lst_args_name = AbstractString[]
    for arg = func_info["RequiredInputArguments"]
        push!(lst_args_name, arg["Name"])
    end
    N = length(lst_args_name)
    arg_typ = DataFrames.DataFrame
    ret_typ = DataFrames.DataFrame
    d_colnames = OrderedDict()
    if lst_args_name==["inReal0", "inReal1"]
        Ndf_input = 2
        args = Symbol[:df, :df2]
        d_colnames = OrderedDict(
            :df=>[:price],
            :df2=>[:price]
        )
    else
        Ndf_input = 1
        args = Symbol[:df]
        for arg = func_info["RequiredInputArguments"]
            colname = string(replace_var_to_symbol(arg["Name"]))
            push!(params_lv1, colname)
            push!(params_RequiredInputArguments, colname)
            #s_doc_RequiredInputArguments *= "\n            - $colname"
        end
        d_colnames[:df] = params_lv1
    end

    params_lv2_with_types = ""

    index = 1
    for (arg, params) in d_colnames
        s_doc_RequiredInputArguments *= "\n        - $arg::$arg_typ with:"
        if index != 1
            params_lv1_with_values *= ", "
            params_lv2_with_types *= ", "
        end

        for (j, colname) in enumerate(params)
            if j != 1
                params_lv1_with_values *= ", "
            end
            if string(colname) == "price"
                colname = string(colname)
                params_lv1_with_values *= "Array($arg[$colname])"
            else
                params_lv1_with_values *= "Array($arg[:$colname])"
            end
            s_doc_RequiredInputArguments *= "\n            - $colname"
        end

        params_lv2_with_types *=  "$arg::$arg_typ"
        index += 1
    end

    if length(params_lv1_with_values) > 1
        params_lv1_with_values *= ", "
    end


    for arg = func_info["OptionalInputArguments"]
        varname = fix_varname(arg["Name"])
        vartyp = d_typ_to_jl[arg["Type"]]
        def_val = arg["DefaultValue"]
        push!(params_lv1, varname)
        push!(params_OptionalInputArguments, varname)
        s_doc_OptionalInputArguments *= "\n        - $varname=$vartyp($def_val)"
    end

    s_doc_OutputArguments *= "\n        - $ret_typ with:"
    for arg = func_info["OutputArguments"]
        varname = cleanup_prefix(arg["Name"])
        push!(params_OutputArguments, varname)
        s_doc_OutputArguments *= "\n            - $varname"
    end

    #params_lv1 = join(params_lv1, ", ")


    for (index, arg) in enumerate(func_info["RequiredInputArguments"])
        #if index != 1
        #    params_lv2_with_types *= ", "
        #end
        varname = string(replace_var_to_symbol(arg["Name"]))
        vartyp = d_typ_to_jl[arg["Type"]]
    end
    for (index, arg) in enumerate(func_info["OptionalInputArguments"])
        if index != 1
            params_lv2_with_types *= ", "
            params_lv1_with_values *= ", "
        else
            params_lv2_with_types *= "; "
        end
        varname = fix_varname(arg["Name"])
        vartyp = d_typ_to_jl[arg["Type"]]
        def_val = arg["DefaultValue"]
        params_lv2_with_types *= "$varname=$vartyp($def_val)"
        params_lv1_with_values *= "$varname=$varname"
    end

    funcname = string(symb_func)
    first_req_input_array = string(replace_var_to_symbol(func_info["RequiredInputArguments"][1]["Name"]))

    s = "

\"\"\"
    $funcname($params_lv2_with_types, price=:$(_PRICE))

$(func_info["ShortDescription"]) ($(func_info["CamelCaseName"]))

    $(func_info["GroupId"])

    Level: 2 - DataFrame

Arguments:

    RequiredInputArguments:$(s_doc_RequiredInputArguments)

    OptionalInputArguments:$(s_doc_OptionalInputArguments)


Returns:$(s_doc_OutputArguments)

\"\"\"
function $funcname($params_lv2_with_types, price=:$(_PRICE))
    result = $funcname($params_lv1_with_values)
    dfOut = DataFrame()
    idx = names(df)[1]
    dfOut[idx] = Array(df[idx])
"

for (i, arg) in enumerate(params_OutputArguments)
    s *= "    dfOut[:$arg] = result[:, $i]"
    s *= "\n"
end

s *= "    dfOut
end"

s

end