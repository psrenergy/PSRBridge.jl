struct Cache
    verbose::Bool
    path::String

    function Cache(; verbose::Bool = false)
        path = joinpath(tempdir(), randstring(16))

        if isdir(path)
            rm(path; recursive = true)
        end

        if verbose
            println("Initialize cache: $path")
        end

        mkdir(path)

        return new(verbose, path)
    end
end

function finalize!(cache::Cache)
    if isdir(cache.path)
        if cache.verbose
            println("Finalizing cache: $(cache.path)")
        end

        rm(cache.path; recursive = true)
    end
    return nothing
end

function format_value(value::Any)
    return "$value"
end

function format_value(value::DateTime)
    return Dates.format(value, "yyyymmddHHMMSS")
end

function build_filename(kwargs...)
    dict = Dict(kwargs)
    sorted = sort(collect(dict), by = x -> x[1])

    vector = String[]
    for (key, value) in sorted
        formatted_value = format_value(value)
        push!(vector, "$key$formatted_value")
    end

    return join(vector, "-") * ".bin"
end

function update!(inputs::AbstractInputs, cache::Cache; kwargs...)
    filename = build_filename(kwargs...)
    path = joinpath(cache.path, filename)

    if isfile(path)
        if cache.verbose
            println("Loading cache ($(Base.summarysize(path)) kb): $path")
        end
        inputs.collections = Serialization.deserialize(path)
    else
        update!(inputs.collections, inputs.db; kwargs...)
        Serialization.serialize(path, inputs.collections)

        if cache.verbose
            println("Saving cache ($(Base.summarysize(path)) kb): $path")
        end
    end
    return nothing
end
