module TALib

export GetVersionString, GetVersionMajor, GetVersionMinor, GetVersionBuild,
    GetVersionDate, GetVersionTime,
    Initialize, Shutdown,
    COS, SIN, ACOS, ASIN, TAN, ATAN

const TA_LIB_PATH = "/usr/local/lib/libta_lib.0.0.0.dylib"

include("constants.jl")

function _ta_check_success(function_name::ASCIIString, ret_code::Integer)
    errorCode = RetCode(ret_code)
    # raises ERROR: LoadError: ArgumentError: invalid value for Enum ERROR: ....
    # when retCode is not a possible value

    #=
    try # ToFix: ERROR: LoadError: UndefVarError: errorCode not defined
        errorCode = ERROR(ret_code)
    catch e
        if isa(e, ArgumentError)
            errorCode = TA_UNKNOWN_ERR::RetCode
        else
            throw(e)
        end
    #finally
    #    errorCode = TA_UNKNOWN_ERR::RetCode
    end
    =#

    if errorCode == TA_SUCCESS::RetCode
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

for f in [:GetVersionString, :GetVersionMajor, :GetVersionMinor, :GetVersionBuild, :GetVersionDate, :GetVersionTime]
    f_str = string(f)
    f_ta_str = "TA_" * f_str
    @eval begin
        function ($f)()
            bytestring(ccall(($f_ta_str, TA_LIB_PATH), Cstring, ()))
        end
    end
end

for f in [:Initialize, :Shutdown]
    f_str = string(f)
    f_ta_str = "TA_" * f_str
    @eval begin
        function ($f)()
            ta_func = () -> ccall( ($f_ta_str, TA_LIB_PATH), Cint, ())
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
    retCode = _TA_COS(0, N - 1, inReal, Ref{Cint}(0), Ref{Cint}(0), outReal)
    _ta_check_success("COS", retCode)
    outReal
end
=#


for f in [:COS, :SIN, :ACOS, :ASIN, :TAN, :ATAN]
    f_str = string(f)
    f_ta_str = "TA_" * f_str
    @eval begin
        function ($f)(inReal::Array{Float64,1})
            N = length(inReal)
            #outReal = zeros(N)
            outReal = fill(NaN, N)
            ta_func = (startIdx, endIdx, inReal, outBegIdx, outNBElement, outReal) -> ccall(
                ($f_ta_str, TA_LIB_PATH), Cint, 
                (Cint, Cint, Ptr{Cdouble}, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}), 
                startIdx, endIdx, inReal, outBegIdx, outNBElement, outReal
            )
            ret_code = ta_func(0, N - 1, inReal, Ref{Cint}(0), Ref{Cint}(0), outReal)
            _ta_check_success($f_str, ret_code)
            outReal
        end
    end

end


end # module

