using Base.Test
epsilon = 1e-10
eps_price = 1e-6

using TALib
using TALib: basepath

using DataFrames

filename = joinpath(basepath(), "ford_2012.csv")
df = readtable(filename)
df[:Date] = Date(df[:Date])

indic = MA(df)
@test_approx_eq_eps indic[end, :Real] 11.546 eps_price

indic = MA(df, price=:Open)
@test_approx_eq_eps indic[end, :Real] 11.4613333 eps_price

indic = BBANDS(df)
@test_approx_eq_eps indic[end, :UpperBand] 13.13191 eps_price
@test_approx_eq_eps indic[end, :MiddleBand] 12.75400 eps_price
@test_approx_eq_eps indic[end, :LowerBand] 12.37609 eps_price
