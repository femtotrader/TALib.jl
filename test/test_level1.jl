using Base.Test

using TALib
using TALib: basepath
using TALib: TA_MAType_SMA

using DataFrames

@testset "level 1" begin
    epsilon = 1e-10
    eps_price = 1e-6

    @test Initialize()

    for f in [GetVersionString, GetVersionMajor, GetVersionMinor, GetVersionBuild, GetVersionDate, GetVersionTime]
        print(string(f) * ": ")
        println(f())
    end

    @test length(GetVersionString()) > 3
    @test GetVersionMajor() == "0"

    s_xml = FunctionDescriptionXML()
    s_xml_expected_header = "<?xml version=\"1.0\" encoding=\"utf-8\" ?>"
    N = length(s_xml_expected_header)
    @test s_xml[1:N] == s_xml_expected_header

    angles = [0, pi/2, pi, 3pi/2, 0, pi/2, pi, 3pi/2]

    outReal = COS(angles)
    @test sum(outReal) ≈ 0 atol=epsilon
    @test outReal == cos(angles)
    @test COS([float(pi)])[1] == -1
    @test ACOS([0.0])[1] == pi / 2
    outReal = ACOS(angles)

    outReal = SIN(angles)
    @test sum(outReal) ≈ 0 atol=epsilon
    @test outReal == sin(angles)
    @test SIN([float(pi/2)])[1] == 1
    @test ASIN([1.0])[1] == pi / 2

    outReal = ASIN(angles)
    outReal = TAN(angles)
    outReal = ATAN(angles)

    filename = joinpath(basepath(), "ford_2012.csv")
    dfOHLCV = readtable(filename)
    dfOHLCV[:Date] = Date(dfOHLCV[:Date])
    dt = Array(dfOHLCV[:Date])
    opn = Array(dfOHLCV[:Open])
    hig = Array(dfOHLCV[:High])
    low = Array(dfOHLCV[:Low])
    cls = Array(dfOHLCV[:Close])
    price = Array(dfOHLCV[:Close])
    vol = Array(dfOHLCV[:Volume])

    @test price[1] == 11.13
    @test price[end] == 12.95

    indic = MA(price)
    @test indic[end] ≈ 11.546 atol=eps_price

    time_period = 10
    indic = MA(price, time_period=time_period, ma_type=TA_MAType_SMA)
    @test indic[end] ≈ 12.219 atol=eps_price
    @test sum(isnan(indic)) == time_period - 1

    indic = BBANDS(price)
    time_period = 5
    @test indic[end, 1] ≈ 13.13191 atol=eps_price  # UpperBand
    @test indic[end, 2] ≈ 12.75400 atol=eps_price  # MiddleBand
    @test indic[end, 3] ≈ 12.37609 atol=eps_price  # LowerBand

    @test sum(isnan(indic)) == (time_period - 1) * 3

    time_period = 10
    indic = BBANDS(price, time_period=time_period, deviations_up=2.0, deviations_down=2.0, ma_type=TA_MAType_SMA)
    @test indic[end, 1] ≈ 13.34468 atol=eps_price  # UpperBand
    @test indic[end, 2] ≈ 12.21900 atol=eps_price  # MiddleBand
    @test indic[end, 3] ≈ 11.09332 atol=eps_price  # LowerBand

    @test sum(isnan(indic)) == (time_period - 1) * 3

    @test Shutdown()

end
