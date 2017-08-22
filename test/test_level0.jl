using Base.Test

using TALib
using TALib: TA_RetCode, TA_SUCCESS, _TA_COS

@testset "level 0" begin
    epsilon = 1e-10
    eps_price = 1e-6

    N_INDICATORS = 158
    @test length(D_INDICATORS) == N_INDICATORS
    @test length(INDICATORS) == N_INDICATORS
    @test length(D_GROUPS) == 10

    inReal = [0, pi/2, pi, 3pi/2, 0, pi/2, pi, 3pi/2]
    N = length(inReal)
    start_idx = 0
    end_idx = N - 1
    outBegIdx = Ref{Cint}(0)
    outNbElement = Ref{Cint}(0)
    outReal = fill(NaN, N)
    ret_code = _TA_COS(start_idx, end_idx, inReal, outBegIdx, outNbElement, outReal)
    errorCode = TA_RetCode(ret_code)
    println(outBegIdx[])
    println(outReal)
    outReal = circshift(outReal, outBegIdx[])
    println(outReal)
    @test errorCode == TA_SUCCESS::TA_RetCode
    println("angles: $inReal")
    println("COS(angles): $outReal")
    @test sum(outReal) ≈ 0 atol=epsilon
    @test outReal == cos.(inReal)


    #=
    filename = joinpath(basepath(), "ford_2012.csv")
    data = readdlm(filename, ',', skipstart=1)

    typealias Price Float64
    typealias Volume Int

    dt = Date[]
    opn = Price[]
    hig = Price[]
    low = Price[]
    cls = Price[]
    price = Price[]
    vol = Volume[]

    for i in 1:size(data, 1)
        push!(dt, Date(data[i, 1]))
        push!(opn, data[i, 2])
        push!(hig, data[i, 3])
        push!(low, data[i, 4])
        push!(cls, data[i, 5])
    end

    println(dt)
    println(opn)
    println(hig)
    println(low)
    println(cls)
    =#

end
