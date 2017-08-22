using Base.Test

using TALib
using TALib: basepath

using DataFrames

@testset "level 2 dataframes" begin

    epsilon = 1e-10
    eps_price = 1e-6

    filename = joinpath(basepath(), "ford_2012.csv")
    df = readtable(filename)
    df[:Date] = Date(df[:Date])

    indic = MA(df)
    @test indic[end, :Real] ≈ 11.546 atol=eps_price

    indic = MA(df, price=:Open)
    @test indic[end, :Real] ≈ 11.4613333 atol=eps_price

    indic = BBANDS(df)
    @test indic[end, :UpperBand] ≈ 13.13191 atol=eps_price  # UpperBand
    @test indic[end, :MiddleBand] ≈ 12.75400 atol=eps_price  # MiddleBand
    @test indic[end, :LowerBand] ≈ 12.37609 atol=eps_price  # LowerBand

end
