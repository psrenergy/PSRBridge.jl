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

function file_size(cache::Cache)
    return Base.summarysize(cache.path)
end

function files(cache::Cache)
    return readdir(cache.path)
end

function finalize!(cache::Cache)
    if isdir(cache.path)
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

function build_filename(collection::AbstractCollection; kwargs...)
    dict = Dict(kwargs)
    sorted = sort(collect(dict), by = x -> x[1])

    vector = String[]
    for (key, value) in sorted
        formatted_value = format_value(value)
        push!(vector, "$key$formatted_value")
    end

    return collection.id * "-" * join(vector, "-") * ".bin"
end

function update!(collection::AbstractCollection, db::DatabaseSQLite, cache::Cache; kwargs...)
    filename = build_filename(collection; kwargs...)
    path = joinpath(cache.path, filename)

    if isfile(path)
        collection = Serialization.deserialize(path)
    else
        update!(collection, db; kwargs...)
        Serialization.serialize(path, collection)
    end

    return nothing
end

function update!(collections::AbstractCollections, db::DatabaseSQLite, cache::Cache; kwargs...)
    type = typeof(collections)

    for field_name in fieldnames(type)
        field = getfield(collections, field_name)
        update!(field, db, cache; kwargs...)
    end

    return nothing
end

function update!(inputs::AbstractInputs, db::DatabaseSQLite, cache::Cache; kwargs...)
    update!(inputs.collections, db, cache; kwargs...)
    return nothing
end
