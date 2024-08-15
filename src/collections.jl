function initialize!(collections::AbstractCollections, db::DatabaseSQLite; kwargs...)
    type = typeof(collections)

    for field_name in fieldnames(type)
        field = getfield(collections, field_name)
        initialize!(field, db; kwargs...)
    end
    return nothing
end

function update!(collections::AbstractCollections, db::DatabaseSQLite; kwargs...)
    type = typeof(collections)

    for field_name in fieldnames(type)
        field = getfield(collections, field_name)
        update!(field, db; kwargs...)
    end
    return nothing
end

function finalize!(collections::AbstractCollections)
    type = typeof(collections)

    for field_name in fieldnames(type)
        field = getfield(collections, field_name)
        finalize!(field)
    end
    return nothing
end
