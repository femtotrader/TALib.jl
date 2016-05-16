using DataStructures
using JSON

function FunctionDescriptionXML()
    bytestring(ccall(("TA_FunctionDescriptionXML", TA_LIB_PATH), Cstring, ()))
end

function create_dict_of_ta_func(filename="")
    d = OrderedDict{Symbol,Any}()
    if filename == ""
        filename = basepath() * "generated/ta_func_api.json"
    end
    if !isfile(filename)
        warn("$filename doesn't exist")
        return d
    end
    lst_ta_func = JSON.parsefile(filename)["FinancialFunctions"]["FinancialFunction"]
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
    d
end

D_INDICATORS = create_dict_of_ta_func()
INDICATORS = Symbol[func for func in keys(D_INDICATORS)]

D_GROUPS = D_GROUPS = Dict{ASCIIString, Array{Symbol,1}}()
for (func, val) in D_INDICATORS
    key = val["GroupId"]
    if !haskey(D_GROUPS, key)
        D_GROUPS[key] = Symbol[func]
    else
        push!(D_GROUPS[key], func)
    end
end