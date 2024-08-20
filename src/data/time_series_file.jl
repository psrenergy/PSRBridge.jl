@kwdef mutable struct TimeSeriesFileData <: AbstractData
    id::String
    path::String = ""
end

function Base.convert(::Type{TimeSeriesFileData}, id::AbstractString)
    return TimeSeriesFileData(id = id)
end

function Base.call(parameter::TimeSeriesFileData)
    return parameter.path
end

function initialize!(parameter::TimeSeriesFileData, collection::AbstractCollection, db::DatabaseSQLite; kwargs...)
    parameter.path = PSRDatabaseSQLite.read_time_series_file(db, collection.id, parameter.id)
    return nothing
end

function update!(parameter::TimeSeriesFileData, collection::AbstractCollection, db::DatabaseSQLite; kwargs...)
    return nothing
end

function finalize!(parameter::TimeSeriesFileData)
    return nothing
end
