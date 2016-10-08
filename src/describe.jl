using DataStructures
using XMLDict

function FunctionDescriptionXML()
    unsafe_string(ccall(("TA_FunctionDescriptionXML", libta_lib), Cstring, ()))
end


function _list2ordereddict(lst_ta_func)
    d = OrderedDict{Symbol,Any}()
    for func_info in lst_ta_func
        funcname = func_info["Abbreviation"]
        delete!(func_info, "Abbreviation")
        l = []  # length of RequiredInputArguments, OptionalInputArguments, OutputArguments
        for key in ["RequiredInputArgument", "OptionalInputArgument", "OutputArgument"]
            if haskey(func_info, key * "s")
                if typeof(func_info[key * "s"][key]) <: Associative  # if it's a dict like
                    func_info[key * "s"] = [func_info[key * "s"][key]]  # list of only ONE element
                else
                    func_info[key * "s"] = func_info[key * "s"][key]
                end
            else
                func_info[key * "s"] = []
            end

            for arg in func_info[key * "s"]
                if !haskey(d_typ_to_c, arg["Type"])
                    error("$(arg["Type"]) is not a supported type")
                end
            end

            push!(l, length(func_info[key * "s"]))

        end
        #func_info["Length"] = l
        d[Symbol(funcname)] = func_info
    end
    d
end

#=
function get_dict_of_ta_func(filename::String)
    if !isfile(filename)
        error("$filename doesn't exist")
    end
    lst_ta_func = JSON.parsefile(filename)["FinancialFunctions"]["FinancialFunction"]
    _list2ordereddict(lst_ta_func)
end
=#

function get_dict_of_ta_func()
    s_xml = FunctionDescriptionXML()
    d_xml = xml_dict(s_xml)["FinancialFunctions"]["FinancialFunction"]
    _list2ordereddict(d_xml)
end

function get_ta_func_constants()
    #indicators = get_dict_of_ta_func(joinpath(basepath(), "generated", "ta_func_api.json"))
    d_indicators = get_dict_of_ta_func()
    indicators = Symbol[func for func in keys(d_indicators)]

    d_groups = Dict{String, Array{Symbol,1}}()
    for (func, val) in d_indicators
        key = val["GroupId"]
        if !haskey(d_groups, key)
            d_groups[key] = Symbol[func]
        else
            push!(d_groups[key], func)
        end
    end
    d_indicators, indicators, d_groups
end
