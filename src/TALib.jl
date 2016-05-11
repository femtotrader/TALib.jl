module TALib


to_export = [:GetVersionString, :GetVersionMajor, :GetVersionMinor, :GetVersionBuild,
    :FunctionDescriptionXML,
    :GetVersionDate, :GetVersionTime,
    :Initialize, :Shutdown,
    :COS, :SIN, :ACOS, :ASIN, :TAN, :ATAN, 
    :MA, :BBANDS
]

include("constants.jl")

for f in to_export
    @eval begin
        export ($f)
    end
end

using DataFrames


function _ta_check_success(function_name::ASCIIString, ret_code::TA_RetCode)
    errorCode = TA_RetCode(ret_code)

    if errorCode == TA_SUCCESS::TA_RetCode
        return true
    else
        error("$function_name function failed with error code $errorCode")
    end
end

#=
function Initialize()
    ta_func = () -> ccall((:TA_Initialize, TA_LIB_PATH), Cint, ())
    retCode = ta_func()
    _ta_check_success("Initialize", retCode)
end

function Shutdown()
    ta_func = () -> ccall((:TA_Shutdown, TA_LIB_PATH), Cint, ())
    retCode = ta_func()
    _ta_check_success("Shutdown", retCode)
end

function GetVersionString()
    bytestring(ccall((:TA_GetVersionString, TA_LIB_PATH), Cstring, ()))
end
=#

for f in [:GetVersionString, :GetVersionMajor, :GetVersionMinor, :GetVersionBuild, :GetVersionDate, :GetVersionTime, :FunctionDescriptionXML]
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
_TA_COS(startIdx, endIdx, inReal, outBegIdx, outNBElement, outReal) = ccall( 
    (:TA_COS, TA_LIB_PATH), Cint, 
    (Cint, Cint, Ptr{Cdouble}, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}), 
    startIdx, endIdx, inReal, outBegIdx, outNBElement, outReal
)

function COS(inReal::Array{Float64,1})
    N = length(inReal)
    outReal = zeros(N)
    ret_code = _TA_COS(0, N - 1, inReal, Ref{Cint}(0), Ref{Cint}(0), outReal)
    _ta_check_success("COS", ret_code)
    outReal
end


function COS(inReal::Array{Float64,1})
    N = length(inReal)
    #outReal = zeros(N)
    outReal = fill(NaN, N)
    ta_func = (startIdx, endIdx, inReal, outBegIdx, outNBElement, outReal) -> ccall(
        (:TA_COS, TA_LIB_PATH), Cint, 
        (Cint, Cint, Ptr{Cdouble}, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}), 
        startIdx, endIdx, inReal, outBegIdx, outNBElement, outReal
    )
    startIdx = 0
    endIdx = N - 1
    outBegIdx = Ref{Cint}(0)
    outNbElement = Ref{Cint}(0)
    ret_code = ta_func(startIdx, endIdx, inReal, outBegIdx, outNbElement, outReal)    
    _ta_check_success("COS", ret_code)
    outReal
end


=#

# ===

# TA_RetCode TA_COS( int startIdx, int endIdx, const double inReal[], int *outBegIdx, int *outNBElement, double outReal[] )
# same for SIN, COS...

for f in [:COS, :SIN, :ACOS, :ASIN, :TAN, :ATAN]
    f_str = string(f)
    f_ta_str = "TA_" * f_str
    ta_func = symbol("_TA_" * f_str)
    @eval begin
        function ($ta_func)(startIdx, endIdx, inReal, outBegIdx, outNBElement, outReal)
            ccall(
                ($f_ta_str, TA_LIB_PATH), TA_RetCode, 
                (Cint, Cint, Ptr{Cdouble}, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}), 
                startIdx, endIdx, inReal, outBegIdx, outNBElement, outReal
            )
        end

        function ($f)(inReal::Array{Float64,1})
            N = length(inReal)
            #outReal = zeros(N)
            outReal = fill(NaN, N)
            startIdx = 0
            endIdx = N - 1
            outBegIdx = Ref{Cint}(0)
            outNbElement = Ref{Cint}(0)
            ret_code = $ta_func(startIdx, endIdx, inReal, outBegIdx, outNbElement, outReal)
            _ta_check_success($f_str, ret_code)
            outReal
        end
    end

end

# ===

# TA_RetCode TA_MA( int startIdx, int endIdx, const double inReal[], int optInTimePeriod, TA_MAType optInMAType, int *outBegIdx, int *outNBElement, double outReal[] )

function _TA_MA(startIdx, endIdx, inReal, timeperiod, matype, outBegIdx, outNBElement, outReal)
    ccall(
        (:TA_MA, TA_LIB_PATH), TA_RetCode, 
        (Cint, Cint, Ptr{Cdouble}, Cint, TA_MAType, Ref{Cint}, Ref{Cint}, Ptr{Cdouble}), 
        startIdx, endIdx, inReal, timeperiod, matype, outBegIdx, outNBElement, outReal
    )
end

function MA(inReal::Array{Float64,1}; timeperiod::Integer=30, matype::TA_MAType=TA_MAType_SMA)
    N = length(inReal)
    outReal = fill(NaN, N)
    startIdx = 0
    endIdx = N - 1
    ptr_outBegIdx = Ref{Cint}(0)
    ptr_outNbElement = Ref{Cint}(0)
    ret_code = _TA_MA(startIdx, endIdx, inReal, timeperiod, matype, ptr_outBegIdx, ptr_outNbElement, outReal)    
    _ta_check_success("MA", ret_code)
    circshift(outReal, ptr_outBegIdx[])
end

PRICE=:Close

function MA(dfOHLCV::DataFrames.DataFrame; timeperiod::Integer=30, matype::TA_MAType=TA_MAType_SMA, price=PRICE)
    price = Array(dfOHLCV[price])
    indic = MA(price, timeperiod=timeperiod, matype=matype)
    df = DataFrame()
    df[:Date] = Array(dfOHLCV[:Date])
    df[:Value] = indic
    df
end

# ===

# TA_RetCode TA_BBANDS( int startIdx, int endIdx, const double inReal[], int optInTimePeriod, double optInNbDevUp, double optInNbDevDn, TA_MAType optInMAType, int *outBegIdx, int *outNBElement, double outRealUpperBand[], double outRealMiddleBand[], double outRealLowerBand[] )

function _TA_BBANDS(startIdx, endIdx, inReal, timeperiod, nbdevup, nbdevdn, matype, outBegIdx, outNBElement, outRealUpperBand, outRealMiddleBand, outRealLowerBand)
    ccall(
        (:TA_BBANDS, TA_LIB_PATH), TA_RetCode, 
        (Cint, Cint, Ptr{Cdouble}, Cint, Cdouble, Cdouble, TA_MAType, Ref{Cint}, Ref{Cint}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}),
        startIdx, endIdx, inReal, timeperiod, nbdevup, nbdevdn, matype, outBegIdx, outNBElement, outRealUpperBand, outRealMiddleBand, outRealLowerBand
    )
end

function BBANDS(inReal::Array{Float64,1}; timeperiod::Integer=30, nbdevup::AbstractFloat=2.0, nbdevdn::AbstractFloat=2.0, matype::TA_MAType=TA_MAType_SMA)
    N = length(inReal)
    startIdx = 0
    endIdx = N - 1
    ptr_outBegIdx = Ref{Cint}(0)
    ptr_outNbElement = Ref{Cint}(0)
    outRealUpperBand = fill(NaN, N)
    outRealMiddleBand = fill(NaN, N)
    outRealLowerBand = fill(NaN, N)
    ret_code = _TA_BBANDS(startIdx, endIdx, inReal, timeperiod, nbdevup, nbdevdn, matype, ptr_outBegIdx, ptr_outNbElement, outRealUpperBand, outRealMiddleBand, outRealLowerBand)
    _ta_check_success("BBANDS", ret_code)
    outRealUpperBand = circshift(outRealUpperBand, ptr_outBegIdx[])
    outRealMiddleBand = circshift(outRealMiddleBand, ptr_outBegIdx[])
    outRealLowerBand = circshift(outRealLowerBand, ptr_outBegIdx[])
    outRealUpperBand, outRealMiddleBand, outRealLowerBand
end


function BBANDS(dfOHLCV::DataFrames.DataFrame; timeperiod::Integer=30, nbdevup::AbstractFloat=2.0, nbdevdn::AbstractFloat=2.0, matype::TA_MAType=TA_MAType_SMA, price=PRICE)
    price = Array(dfOHLCV[price])
    outRealUpperBand, outRealMiddleBand, outRealLowerBand = BBANDS(price, timeperiod=timeperiod, nbdevup=nbdevup, nbdevdn=nbdevdn, matype=matype)
    df = DataFrame()
    df[:Date] = Array(dfOHLCV[:Date])
    df[:UpperBand] = outRealUpperBand
    df[:MiddleBand] = outRealMiddleBand
    df[:LowerBand] = outRealLowerBand
    df
end



end # module

