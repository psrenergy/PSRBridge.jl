
@kwdef mutable struct TimeSeriesVectorData{T} <: AbstractData
    id::String
    data::Vector{T} = []
end

function Base.convert(::Type{TimeSeriesVectorData{T}}, id::AbstractString) where {T}
    return TimeSeriesVectorData{T}(id = id)
end

function Base.getindex(parameter::TimeSeriesVectorData{T}, i::Integer) where {T}
    return parameter.data[i]
end

function Base.length(parameter::TimeSeriesVectorData{T}) where {T}
    return length(parameter.data)
end

function Base.isempty(parameter::TimeSeriesVectorData{T}) where {T}
    return isempty(parameter.data)
end

function initialize!(parameter::TimeSeriesVectorData{T}, collection::AbstractCollection, db::DatabaseSQLite; kwargs...) where {T}
    return nothing
end

function update!(parameter::TimeSeriesVectorData{T}, collection::AbstractCollection, db::DatabaseSQLite; kwargs...) where {T}
    dict = Dict(kwargs)

    if !haskey(dict, :date_time)
        error("Missing date_time in kwargs")
    end

    date_time = dict[:date_time]

    parameter.data = PSRDatabaseSQLite.read_time_series_row(
        db,
        collection.id,
        parameter.id;
        date_time = date_time,
    )

    return nothing
end

function finalize!(parameter::TimeSeriesVectorData{T}) where {T}
    return nothing
end
