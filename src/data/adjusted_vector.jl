@kwdef mutable struct AdjustedVectorData{T} <: AbstractData
    id::String
    data::Vector{T} = []
end

function Base.convert(::Type{AdjustedVectorData{T}}, id::AbstractString) where {T}
    return AdjustedVectorData{T}(id = id)
end

function Base.getindex(parameter::AdjustedVectorData{T}, i::Integer) where {T}
    return parameter.data[i]
end

function Base.length(parameter::AdjustedVectorData{T}) where {T}
    return length(parameter.data)
end

function Base.isempty(parameter::AdjustedVectorData{T}) where {T}
    return isempty(parameter.data)
end

function initialize!(parameter::AdjustedVectorData{T}, collection::AbstractCollection, db::DatabaseSQLite; kwargs...) where {T}
    size = PSRI.max_elements(db, collection.id)
    parameter.data = Vector{T}(undef, size)
    return nothing
end

function update!(parameter::AdjustedVectorData{T}, collection::AbstractCollection, db::DatabaseSQLite; kwargs...) where {T}
    return nothing
end

function finalize!(parameter::AdjustedVectorData{T}) where {T}
    return nothing
end
