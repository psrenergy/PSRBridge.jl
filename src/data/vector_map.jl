@kwdef mutable struct VectorMapData <: AbstractData
    collection_to::String
    id::String
    data::Vector{Vector{Int}} = []
end

function Base.convert(::Type{VectorMapData}, tuple::Tuple{String, String})
    return VectorMapData(collection_to = tuple[1], id = tuple[2])
end

function Base.getindex(parameter::VectorMapData, i::Integer)
    return parameter.data[i]
end

function Base.length(parameter::VectorMapData)
    return length(parameter.data)
end

function Base.isempty(parameter::VectorMapData)
    return isempty(parameter.data)
end

function Base.iterate(parameter::VectorMapData)
    return iterate(parameter.data)
end

function Base.iterate(parameter::PSRBridge.VectorMapData, i::Integer)
    return iterate(parameter.data, i)
end

function raw_data(parameter::VectorMapData)
    return parameter.data
end

function initialize!(parameter::VectorMapData, collection::AbstractCollection, db::DatabaseSQLite; kwargs...)
    parameter.data = PSRI.get_vector_map(db, collection.id, parameter.collection_to, parameter.id)
    return nothing
end

function update!(parameter::VectorMapData, collection::AbstractCollection, db::DatabaseSQLite; kwargs...)
    return nothing
end

function finalize!(parameter::VectorMapData)
    return nothing
end
