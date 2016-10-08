module TALib

using DataStructures

pkg_name = "TALib"
depsjl = joinpath(dirname(@__FILE__), "..", "deps", "deps.jl")
println(depsjl)
if isfile(depsjl)
    include(depsjl)
else
    error("$pkg_name not properly installed. Please run Pkg.build(\"$pkg_name\")")
end

include("constants.jl")
include("path.jl")

include("describe.jl")
D_INDICATORS, INDICATORS, D_GROUPS = get_ta_func_constants()
export FunctionDescriptionXML

include("tools.jl")

function _ta_check_success(function_name::String, ret_code::TA_RetCode)
    errorCode = TA_RetCode(ret_code)

    if errorCode == TA_SUCCESS::TA_RetCode
        return true
    else
        error("$function_name function failed with error code $errorCode")
    end
end

for f in [:GetVersionString, :GetVersionMajor, :GetVersionMinor, :GetVersionBuild, :GetVersionDate, :GetVersionTime]
    f_str = string(f)
    f_ta_str = "TA_" * f_str
    @eval begin
        function ($f)()
            unsafe_string(ccall(($f_ta_str, libta_lib), Cstring, ()))
        end
    end

    @eval begin
        export ($f)
    end

end

# ===

for f in [:Initialize, :Shutdown]
    f_str = string(f)
    f_ta_str = "TA_" * f_str
    @eval begin
        function ($f)()
            ta_func = () -> ccall( ($f_ta_str, libta_lib), TA_RetCode, ())
            ret_code = ta_func()
            _ta_check_success($f_str, ret_code)
        end
    end

    @eval begin
        export ($f)
    end
end

# ===

code_generators = ["ta_func_api_code_level0", 
    "ta_func_api_code_level1", 
    "ta_func_api_code_level2_dataframes", 
    "ta_func_api_code_level2_timearrays"]

import_generated = true
for code_generator in code_generators
    filename = joinpath(basepath(), "generated", code_generator * ".jl")
    if !isfile(filename)
        import_generated = false
        warn("code generation is required for $filename")
        break
    end
end
if !import_generated
    warn("code generation is required to use TALib.jl")
    include("ta_func_api_gen.jl")
end

for code_generator in code_generators
    filename = joinpath("generated", code_generator * ".jl")
    try
        #info("include $filename")
        include(filename)
    catch
        error("$filename doesn't exist")
    end
end

for f in INDICATORS
    @eval begin
        export ($f)
    end
end

export D_INDICATORS, INDICATORS, D_GROUPS




end # module

