"""
    uncamel(s)

Convert a camel case string to a underscored spaced / lowercased string.

# Examples
```julia
julia> uncamel("CamelCase")
camel_case
```
"""
function uncamel(s)
    final = ""
    for item in s
        if isupper(item)
            final *= ("_" * string(lowercase(item)))
        else
            final *= string(item)
        end
    end
    if final[1] == '_'
        final = final[2:end]
    end
    final
end

"""
    cleanup(s)

Cleanup string from prefix

# Examples
```julia
julia> cleanup("optInCamelCase")
CamelCase
```

"""
function cleanup_prefix(s)
    for prefix in ["in", "optIn", "outReal"]
        if startswith(s, prefix) && s != prefix
            N = length(prefix)
            s = s[N+1:end]
        end
    end
end

"""
    fix_varname(s)

Lower case and replace spaces by underscores

# Examples
```julia
julia> fix_varname("Time Period")
time_period
```

"""
function fix_varname(s)
    s = lowercase(s)
    s = replace(s, " ", "_")
    s = replace(s, "-", "_")
    s
end

"""
    replace_var(s)

Replace a variable with a more appropriate name (using a dict)

# Examples
```julia
julia> replace_var("Open")
price_open
```
"""
function replace_var(s)
    d = Dict{ASCIIString, ASCIIString}(
        "Open" => "price_open",
        "High" => "price_high",
        "Low" => "price_low",
        "Close" => "price_close",
        "Volume" => "volume",
    )
    get(d, s, s)
end
