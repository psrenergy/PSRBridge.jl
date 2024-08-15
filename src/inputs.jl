function initialize!(inputs::AbstractInputs, db::DatabaseSQLite; kwargs...)
    initialize!(inputs.collections, db; kwargs...)
    return nothing
end

function update!(inputs::AbstractInputs, db::DatabaseSQLite; kwargs...)
    update!(inputs.collections, db; kwargs...)
    return nothing
end

function finalize!(inputs::AbstractInputs)
    finalize!(inputs.collections)
    return nothing
end
