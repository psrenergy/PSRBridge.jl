@kwdef mutable struct StaticData{T} <: AbstractData
    id::String
    data::Vector{T} = []
end

function Base.convert(::Type{StaticData{T}}, id::String) where {T}
    return StaticData{T}(id = id)
end

function Base.getindex(parameter::StaticData{T}, i::Integer) where {T}
    return parameter.data[i]
end

function Base.length(parameter::StaticData{T}) where {T}
    return length(parameter.data)
end

function Base.isempty(parameter::StaticData{T}) where {T}
    return isempty(parameter.data)
end

function initialize!(parameter::StaticData{T}, collection::AbstractCollection, db::DatabaseSQLite; kwargs...) where {T}
    parameter.data = PSRI.get_parms(db, collection.id, parameter.id)
    return nothing
end

function update!(parameter::StaticData{T}, collection::AbstractCollection, db::DatabaseSQLite; kwargs...) where {T}
    return nothing
end

function finalize!(parameter::StaticData{T}) where {T}
    return nothing
end
