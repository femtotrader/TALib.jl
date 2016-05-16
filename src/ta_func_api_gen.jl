include("TALib.jl")
include("tools.jl")
include("constants.jl")

using TALib
using DataStructures

for filename in ["ta_func_api_gen_level0.jl", "ta_func_api_gen_level1.jl", "ta_func_api_gen_level2_dataframe.jl"]
    include(filename)
end

function generate_header()
    "# Auto generated file"
end

function generate_footer()
    "# end of auto generated file"
end

function generate_code(d::OrderedDict{Symbol,Any}, _generate_header::Function, _generate_code::Function, _generate_footer::Function)
    s_code = _generate_header()
    s_code *= "\n"
    for symb in keys(d)
        #println("## Generate code for $symb")
        s_code *= _generate_code(d, symb)
    end
    s_code *= "\n"
    s_code *= _generate_footer()
    s_code
end

function generate_all_code(d::OrderedDict{Symbol,Any})
    path = "src/generated/"
    println("# Generate level 0 code")
    filename = path * "ta_func_api_code_level0.jl"
    s_code = generate_code(d, generate_header, generate_ta_func_raw, generate_footer)
    f = open(filename, "w")
    write(f, s_code)
    close(f)

    println("# Generate level 1 code")
    filename = path * "ta_func_api_code_level1.jl"
    s_code = generate_code(d, generate_header, generate_ta_func_with_arrays, generate_footer)
    f = open(filename, "w")
    write(f, s_code)
    close(f)

    println("# Generate level 2 code - DataFrames")
    filename = path * "ta_func_api_code_level2_dataframes.jl"
    s_code = generate_code(d, generate_header_ta_func_with_dataframes, generate_ta_func_with_dataframes, generate_footer)
    f = open(filename, "w")
    write(f, s_code)
    close(f)
end

generate_all_code(D_INDICATORS)
