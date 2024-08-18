function initialize!(collections::AbstractCollections, db::DatabaseSQLite; kwargs...)
    field_names = fieldnames(typeof(collections))

    for field_name in field_names
        field = getfield(collections, field_name)
        initialize!(field, db; kwargs...)
    end
    return nothing
end

function update!(collections::AbstractCollections, db::DatabaseSQLite; kwargs...)
    field_names = fieldnames(typeof(collections))

    for field_name in field_names
        field = getfield(collections, field_name)
        update!(field, db; kwargs...)
    end

    for field_name in field_names
        field = getfield(collections, field_name)
        adjust!(field, collections, db; kwargs...)
    end

    return nothing
end

function finalize!(collections::AbstractCollections)
    field_names = fieldnames(typeof(collections))

    for field_name in field_names
        field = getfield(collections, field_name)
        finalize!(field)
    end
    return nothing
end
