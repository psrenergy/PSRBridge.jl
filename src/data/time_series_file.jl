@kwdef mutable struct TimeSeriesFileData{T} <: AbstractData
    id::String
    path::String
end

function Base.convert(::Type{TimeSeriesFileData{T}}, id::AbstractString) where {T}
    return TimeSeriesFileData{T}(id = id)
end

function Base.getindex(parameter::TimeSeriesFileData{T}, i::Integer) where {T}
    return parameter.data[i]
end

function Base.length(parameter::TimeSeriesFileData{T}) where {T}
    return length(parameter.data)
end

function Base.isempty(parameter::TimeSeriesFileData{T}) where {T}
    return isempty(parameter.data)
end

function initialize!(parameter::TimeSeriesFileData{T}, collection::AbstractCollection, db::DatabaseSQLite; kwargs...) where {T}
    parameter.path = PSRDatabaseSQLite.read_time_series_file(db, collection.id, parameter.id)
    return nothing
end

function update!(parameter::TimeSeriesFileData{T}, collection::AbstractCollection, db::DatabaseSQLite; kwargs...) where {T}
    return nothing
end

function finalize!(parameter::TimeSeriesFileData{T}) where {T}
    return nothing
end
