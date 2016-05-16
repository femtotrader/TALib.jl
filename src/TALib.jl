module TALib

using JSON
using DataStructures

to_export = [:GetVersionString, :GetVersionMajor, :GetVersionMinor, :GetVersionBuild,
    :FunctionDescriptionXML,
    :GetVersionDate, :GetVersionTime,
    :Initialize, :Shutdown,
]

include("constants.jl")
include("path.jl")
include("describe.jl")

import_generated = true
for filename in ["ta_func_api_code_level0.jl", 
            "ta_func_api_code_level1.jl",
            "ta_func_api_code_level2_dataframes.jl"]
    filename = "generated/" * filename
    try
        include(filename)
    catch
        warn("$filename doesn't exist")
        import_generated = false
    end
end
if import_generated
    for f in [to_export; INDICATORS]
        @eval begin
            export ($f)
        end
    end
else
    warn("code generation is required to use TALib.jl")
    warn("You need to run: ./generate_code.sh")
end

using DataFrames

export D_INDICATORS, INDICATORS, D_GROUPS

function _ta_check_success(function_name::ASCIIString, ret_code::TA_RetCode)
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
            bytestring(ccall(($f_ta_str, TA_LIB_PATH), Cstring, ()))
        end
    end
end

# ===

for f in [:Initialize, :Shutdown]
    f_str = string(f)
    f_ta_str = "TA_" * f_str
    @eval begin
        function ($f)()
            ta_func = () -> ccall( ($f_ta_str, TA_LIB_PATH), TA_RetCode, ())
            ret_code = ta_func()
            _ta_check_success($f_str, ret_code)
        end
    end
end

#=

function MA(dfOHLCV::DataFrames.DataFrame; time_period=Integer(30), ma_type=TA_MAType(0), price=_PRICE)
    price = Array(dfOHLCV[price])
    indic = MA(price, time_period=time_period, ma_type=ma_type)
    df = DataFrame()
    idx = names(dfOHLCV)[1]
    df[idx] = Array(dfOHLCV[idx])
    df[:Value] = indic
    df
end


function BBANDS(dfOHLCV::DataFrames.DataFrame; time_period=Integer(30), deviations_up=AbstractFloat(2.0), deviations_down=AbstractFloat(2.0), ma_type=TA_MAType(0), price=_PRICE)
    price = Array(dfOHLCV[price])
    result = BBANDS(price, time_period=time_period, deviations_up=deviations_up, deviations_down=deviations_down, ma_type=ma_type)
    df = DataFrame()
    idx = names(dfOHLCV)[1]
    df[idx] = Array(dfOHLCV[idx])
    df[:UpperBand] = result[:, 1]
    df[:MiddleBand] = result[:, 2]
    df[:LowerBand] = result[:, 3]
    df
end

=#


end # module

