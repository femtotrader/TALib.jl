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