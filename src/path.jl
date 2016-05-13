"""
    basepath()

Returns base path as String
"""
function basepath()
    basepath = Base.source_dir()
    if typeof(basepath) == Void
        basepath = ""
    else
        basepath = basepath * "/"
    end
end
