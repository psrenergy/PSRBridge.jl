@kwdef mutable struct MapData <: AbstractData
    collection_to::String
    id::String
    data::Vector{Int} = []
end

function Base.convert(::Type{MapData}, tuple::Tuple{String, String})
    return MapData(collection_to = tuple[1], id = tuple[2])
end

function Base.getindex(parameter::MapData, i::Integer)
    return parameter.data[i]
end

function Base.length(parameter::MapData)
    return length(parameter.data)
end

function Base.isempty(parameter::MapData)
    return isempty(parameter.data)
end

function Base.iterate(parameter::MapData)
    return iterate(parameter.data)
end

function Base.iterate(parameter::PSRBridge.MapData, i::Integer)
    return iterate(parameter.data, i)
end

function raw_data(parameter::MapData)
    return parameter.data
end

function initialize!(parameter::MapData, collection::AbstractCollection, db::DatabaseSQLite; kwargs...)
    parameter.data = PSRI.get_map(db, collection.id, parameter.collection_to, parameter.id)
    return nothing
end

function update!(parameter::MapData, collection::AbstractCollection, db::DatabaseSQLite; kwargs...)
    return nothing
end

function finalize!(parameter::MapData)
    return nothing
end
