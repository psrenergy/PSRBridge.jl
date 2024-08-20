@kwdef mutable struct StaticVectorData{T} <: AbstractData
    id::String
    data::Vector{T} = []
end

function Base.convert(::Type{StaticVectorData{T}}, id::AbstractString) where {T}
    return StaticVectorData{T}(id = id)
end

function Base.getindex(parameter::StaticVectorData{T}, i::Integer) where {T}
    return parameter.data[i]
end

function Base.length(parameter::StaticVectorData{T}) where {T}
    return length(parameter.data)
end

function Base.isempty(parameter::StaticVectorData{T}) where {T}
    return isempty(parameter.data)
end

function initialize!(parameter::StaticVectorData{T}, collection::AbstractCollection, db::DatabaseSQLite; kwargs...) where {T}
    parameter.data = PSRI.get_parms(db, collection.id, parameter.id) .|> T
    return nothing
end

function update!(parameter::StaticVectorData{T}, collection::AbstractCollection, db::DatabaseSQLite; kwargs...) where {T}
    return nothing
end

function finalize!(parameter::StaticVectorData{T}) where {T}
    return nothing
end
