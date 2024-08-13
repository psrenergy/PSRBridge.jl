function initialize!(inputs::AbstractInputs, db::DatabaseSQLite; kwargs...)
    type = typeof(inputs)

    for field_name in fieldnames(type)
        field = getfield(inputs, field_name)
        initialize!(field, db; kwargs...)
    end
    return nothing
end

function update!(inputs::AbstractInputs, db::DatabaseSQLite; kwargs...)
    type = typeof(inputs)

    for field_name in fieldnames(type)
        field = getfield(inputs, field_name)
        update!(field, db; kwargs...)
    end
    return nothing
end

function finalize!(inputs::AbstractInputs)
    type = typeof(inputs)

    for field_name in fieldnames(type)
        field = getfield(inputs, field_name)
        finalize!(field)
    end
    return nothing
end
