function initialize!(collection::AbstractCollection, db::DatabaseSQLite; kwargs...)
    type = typeof(collection)

    for field_name in fieldnames(type)
        if field_name == :id
            continue
        end

        field = getfield(collection, field_name)
        initialize!(field, collection, db; kwargs...)
    end
    return nothing
end

function update!(collection::AbstractCollection, db::DatabaseSQLite; kwargs...)
    type = typeof(collection)

    for field_name in fieldnames(type)
        if field_name == :id
            continue
        end

        field = getfield(collection, field_name)
        update!(field, collection, db; kwargs...)
    end
    return nothing
end

function finalize!(collection::AbstractCollection)
    type = typeof(collection)

    for field_name in fieldnames(type)
        if field_name == :id
            continue
        end

        field = getfield(collection, field_name)
        finalize!(field)
    end
    return nothing
end

Base.length(collection::AbstractCollection) = length(collection.label)

Base.isempty(collection::AbstractCollection) = isempty(collection.label)
