"""
    basepath()

Returns base path as String
"""
function basepath()
    path = Base.source_dir()
    if typeof(path) == Void
        path = ""
    else
        path
    end
end
