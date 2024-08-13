
@kwdef mutable struct TimeSeriesData{T} <: AbstractData
    id::String
    data::Vector{T} = []
end

function Base.convert(::Type{TimeSeriesData{T}}, id::String) where {T}
    return TimeSeriesData{T}(id = id)
end

function Base.getindex(parameter::TimeSeriesData{T}, i::Integer) where {T}
    return parameter.data[i]
end

function Base.length(parameter::TimeSeriesData{T}) where {T}
    return length(parameter.data)
end

function Base.isempty(parameter::TimeSeriesData{T}) where {T}
    return isempty(parameter.data)
end

function initialize!(parameter::TimeSeriesData{T}, collection::AbstractCollection, db::DatabaseSQLite; kwargs...) where {T}
    return nothing
end

function update!(parameter::TimeSeriesData{T}, collection::AbstractCollection, db::DatabaseSQLite; kwargs...) where {T}
    dict = Dict(kwargs)

    if !haskey(dict, :date_time)
        error("Missing date_time in kwargs")
    end

    date_time = dict[:date_time]

    @timeit "read_time_series_row" parameter.data = PSRDatabaseSQLite.read_time_series_row(
        db,
        collection.id,
        parameter.id;
        date_time = date_time,
    )

    return nothing
end

function finalize!(parameter::TimeSeriesData{T}) where {T}
    return nothing
end
