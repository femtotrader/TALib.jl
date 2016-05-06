include("src/TALib.jl")

using TALib

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

print("Shutdown: ")
retCode = Shutdown()
println(retCode)
