@kwdef mutable struct MapData{T} <: AbstractData
    id::String
    data::Vector{T} = []
end

function Base.convert(::Type{MapData{T}}, id::AbstractString) where {T}
    return MapData{T}(id = id)
end

function Base.getindex(parameter::MapData{T}, i::Integer) where {T}
    return parameter.data[i]
end

function Base.length(parameter::MapData{T}) where {T}
    return length(parameter.data)
end

function Base.isempty(parameter::MapData{T}) where {T}
    return isempty(parameter.data)
end

function initialize!(parameter::MapData{T}, collection::AbstractCollection, db::DatabaseSQLite; kwargs...) where {T}
    return nothing
end

function update!(parameter::MapData{T}, collection::AbstractCollection, db::DatabaseSQLite; kwargs...) where {T}
    return nothing
end

function finalize!(parameter::MapData{T}) where {T}
    return nothing
end
