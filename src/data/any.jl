function raw_data(parameter::Any)
    return parameter
end

function initialize!(parameter::Any, collection::AbstractCollection, db::DatabaseSQLite; kwargs...)
    return nothing
end

function update!(parameter::Any, collection::AbstractCollection, db::DatabaseSQLite; kwargs...)
    return nothing
end

function finalize!(parameter::Any)
    return nothing
end
