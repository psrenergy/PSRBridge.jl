struct Cache
    path::String

    function Cache()
        path = joinpath(tempdir(), randstring(16))

        if isdir(path)
            rm(path; recursive = true)
        end

        mkdir(path)

        return new(path)
    end
end

function finalize!(cache::Cache)
    if isdir(cache.path)
        rm(cache.path; recursive = true)
    end
    return nothing
end

function build_filename(collection::AbstractCollection; kwargs...)
    dict = Dict(kwargs)
    sorted = sort(collect(dict), by = x -> x[1])

    vector = String[]
    for (key, value) in sorted
        if isa(value, DateTime)
            push!(vector, "$key$(Dates.format(value, "yyyymmddHHMMSS"))")
        else
            push!(vector, "$key$value")
        end
    end

    return collection.id * "-" * join(vector, "-") * ".bin"
end

function update!(collection::AbstractCollection, db::DatabaseSQLite, cache::Cache; kwargs...)
    filename = build_filename(collection; kwargs...)
    path = joinpath(cache.path, filename)

    if isfile(path)
        @timeit "deserialize" collection = Serialization.deserialize(path)
    else
        update!(collection, db; kwargs...)
        @timeit "serialize" Serialization.serialize(path, collection)
    end

    return nothing
end

function update!(inputs::AbstractInputs, db::DatabaseSQLite, cache::Cache; kwargs...)
    type = typeof(inputs)

    for field_name in fieldnames(type)
        field = getfield(inputs, field_name)
        update!(field, db, cache; kwargs...)
    end

    return nothing
end
