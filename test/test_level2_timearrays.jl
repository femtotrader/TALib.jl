using Base.Test

# see https://github.com/JuliaQuant/MarketData.jl
# and https://github.com/JuliaStats/TimeSeries.jl

using TALib
using TALib: basepath

using TimeSeries

@testset "level 2 timearrays" begin
    epsilon = 1e-10
    eps_price = 1e-6

    filename = joinpath(basepath(), "ford_2012.csv")
    ohlcv = readtimearray(filename)

    indic = MA(ohlcv)
    @test_approx_eq_eps indic["Real"][end].values[1] 11.546 eps_price

    indic = MA(ohlcv, price=:Open)
    @test_approx_eq_eps indic["Real"][end].values[1] 11.4613333 eps_price

    indic = BBANDS(ohlcv)
    @test_approx_eq_eps indic["UpperBand"][end].values[1] 13.13191 eps_price
    @test_approx_eq_eps indic["MiddleBand"][end].values[1] 12.75400 eps_price
    @test_approx_eq_eps indic["LowerBand"][end].values[1] 12.37609 eps_price

end
