include("src/TALib.jl")

using TALib
using DataFrames

for f in [GetVersionString, GetVersionMajor, GetVersionMinor, GetVersionBuild, GetVersionDate, GetVersionTime]
    print(string(f) * ": ")
    println(f())
end

print("Initialize: ")
retCode = Initialize()
println(retCode)

println("Input")
inReal = [0, pi/2, pi, 3pi/2, 0, pi/2, pi, 3pi/2]
println(inReal)

println("COS")
outReal = COS(inReal)
println(outReal)

println("ACOS")
outReal = ACOS(outReal)
println(outReal)

println("SIN")
outReal = SIN(inReal)
println(outReal)

println("ASIN")
outReal = ASIN(outReal)
println(outReal)

println("TAN")
outReal = TAN(inReal)
println(outReal)

println("ATAN")
outReal = ATAN(outReal)
println(outReal)

filename = "test/ford_2012.csv"
println("Read '$filename'")
dfOHLCV = readtable(filename)
dfOHLCV[:Date] = Date(dfOHLCV[:Date])
println(dfOHLCV)
price = Array(dfOHLCV[:Close])
println(price)

println("MA")
outReal = MA(price)
println(outReal)

#using PyPlot
#plot(dfOHLCV[:Date], dfOHLCV[:Close])
#=
plot(dfOHLCV[:Date], dfOHLCV[:Open],
     dfOHLCV[:Date], dfOHLCV[:High],
     dfOHLCV[:Date], dfOHLCV[:Low],
     dfOHLCV[:Date], dfOHLCV[:Close],
)
=#

#angles = readdlm("test/angles.csv")
#angles = reshape(angles, length(angles))  # convert Array{Float64,2} to Array{Float64,1}

print("Shutdown: ")
retCode = Shutdown()
println(retCode)
