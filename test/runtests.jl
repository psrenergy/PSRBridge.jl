using PSRBridge

using DataFrames
using Dates
import PSRClassesInterface as PSRI
using Random
using Serialization
using Test
using TimerOutputs

const PSRDatabaseSQLite = PSRI.PSRDatabaseSQLite
const DatabaseSQLite = PSRI.PSRDatabaseSQLite.DatabaseSQLite

const ITERATIONS = 10
const THERMAL_PLANT_SIZE = 20
const HYDRO_PLANT_SIZE = 20
const DATE_TIMES = [DateTime(year, month, 1) for month in 1:12 for year in 2000:2005]

include("build.jl")

@collection @kwdef mutable struct HydroPlant <: AbstractCollection
    id::String = "HydroPlant"
    label::StaticVectorData{String} = "label"

    static_vector_float::StaticVectorData{Float64} = "static_vector_float"
    static_vector_int::StaticVectorData{Int} = "static_vector_int"
    static_vector_bool::StaticVectorData{Bool} = "static_vector_bool"

    time_series_float::TimeSeriesVectorData{Float64} = "time_series_float"
    time_series_int::TimeSeriesVectorData{Int} = "time_series_int"
    time_series_bool::TimeSeriesVectorData{Bool} = "time_series_bool"

    adjusted_vector_float::AdjustedVectorData{Float64} = AdjustedVectorData{Float64}()
    adjusted_vector_int::AdjustedVectorData{Int} = AdjustedVectorData{Int}()
    adjusted_vector_bool::AdjustedVectorData{Bool} = AdjustedVectorData{Bool}()

    _internal_data::String = "internal_data"

    # bus_index::MapData = ("Bus", "id")
    # agent_index::MapData = ("Agent", "id")
    # gauging_station_index::MapData = ("GaugingStation", "id")
    # turbine_to_index::MapData = ("HydroPlant", "turbine_to")
    # spill_to_index::MapData = ("HydroPlant", "spill_to")
end

function add_hydro_plant!(db::DatabaseSQLite; kwargs...)
    PSRI.create_element!(db, "HydroPlant"; kwargs...)
    return nothing
end

function PSRBridge.adjust!(collection::HydroPlant, collections::AbstractCollections, db::DatabaseSQLite; kwargs...)
    return nothing
end

@collection @kwdef mutable struct ThermalPlant <: AbstractCollection
    id::String = "ThermalPlant"
    label::StaticVectorData{String} = "label"

    static_vector_float::StaticVectorData{Float64} = "static_vector_float"
    static_vector_int::StaticVectorData{Int} = "static_vector_int"
    static_vector_bool::StaticVectorData{Bool} = "static_vector_bool"

    time_series_float::TimeSeriesVectorData{Float64} = "time_series_float"
    time_series_int::TimeSeriesVectorData{Int} = "time_series_int"
    time_series_bool::TimeSeriesVectorData{Bool} = "time_series_bool"

    adjusted_vector_float::AdjustedVectorData{Float64} = AdjustedVectorData{Float64}()
    adjusted_vector_int::AdjustedVectorData{Int} = AdjustedVectorData{Int}()
    adjusted_vector_bool::AdjustedVectorData{Bool} = AdjustedVectorData{Bool}()

    _internal_data::String = "internal_data"
end

function add_thermal_plant!(db::DatabaseSQLite; kwargs...)
    PSRI.create_element!(db, "ThermalPlant"; kwargs...)
    return nothing
end

function PSRBridge.adjust!(collection::ThermalPlant, collections::AbstractCollections, db::DatabaseSQLite; kwargs...)
    size = length(collection)

    for i in 1:size
        collection.adjusted_vector_float[i] = collections.thermal_plant.time_series_float[i] + collections.hydro_plant.time_series_float[i]
        collection.adjusted_vector_int[i] = collections.thermal_plant.time_series_int[i] + collections.hydro_plant.time_series_int[i]
        collection.adjusted_vector_bool[i] = collections.thermal_plant.time_series_bool[i] && collections.hydro_plant.time_series_bool[i]
    end

    return nothing
end

@kwdef mutable struct Collections <: AbstractCollections
    hydro_plant::HydroPlant = HydroPlant()
    thermal_plant::ThermalPlant = ThermalPlant()
end

@kwdef mutable struct Inputs <: AbstractInputs
    db::DatabaseSQLite
    collections::Collections = Collections()
end

function test_all()
    path = joinpath(@__DIR__, "db.sqlite")
    build_database(path)

    db = PSRI.load_study(PSRI.PSRDatabaseSQLiteInterface(), path, read_only = true)

    inputs = Inputs(; db = db)
    cache = Cache(verbose = false)

    @timeit "initialize!" initialize!(inputs)

    @test thermal_plant_id(inputs) == "ThermalPlant"
    @test hydro_plant_id(inputs) == "HydroPlant"

    @test_throws UndefVarError thermal_plant__internal_data(inputs)
    @test_throws UndefVarError hydro_plant__internal_data(inputs)

    @test length(inputs.collections.hydro_plant) == HYDRO_PLANT_SIZE
    @test length(inputs.collections.thermal_plant) == THERMAL_PLANT_SIZE

    @test hydro_plant_length(inputs.collections) == HYDRO_PLANT_SIZE
    @test thermal_plant_length(inputs.collections) == THERMAL_PLANT_SIZE

    @test hydro_plant_length(inputs) == HYDRO_PLANT_SIZE
    @test thermal_plant_length(inputs) == THERMAL_PLANT_SIZE

    @test hydro_plant_indices(inputs) == [i for i in 1:HYDRO_PLANT_SIZE]
    @test thermal_plant_indices(inputs) == [i for i in 1:HYDRO_PLANT_SIZE]

    labels = [build_hydro_plant_label(i) for i in 1:HYDRO_PLANT_SIZE]
    @test hydro_plant_label(inputs.collections.hydro_plant) == labels
    @test hydro_plant_label(inputs.collections) == labels
    @test hydro_plant_label(inputs) == labels

    labels = [build_thermal_plant_label(i) for i in 1:THERMAL_PLANT_SIZE]
    @test thermal_plant_label(inputs.collections.thermal_plant) == labels
    @test thermal_plant_label(inputs.collections) == labels
    @test thermal_plant_label(inputs) == labels

    for i in 1:HYDRO_PLANT_SIZE
        label = build_hydro_plant_label(i)
        @test hydro_plant_label(inputs.collections.hydro_plant, i) == label
        @test hydro_plant_label(inputs.collections, i) == label
        @test hydro_plant_label(inputs, i) == label

        static_vector_float = build_float(i)
        @test hydro_plant_static_vector_float(inputs.collections.hydro_plant, i) == static_vector_float
        @test hydro_plant_static_vector_float(inputs.collections, i) == static_vector_float
        @test hydro_plant_static_vector_float(inputs, i) == static_vector_float

        static_vector_int = build_int(i)
        @test hydro_plant_static_vector_int(inputs.collections.hydro_plant, i) == static_vector_int
        @test hydro_plant_static_vector_int(inputs.collections, i) == static_vector_int
        @test hydro_plant_static_vector_int(inputs, i) == static_vector_int

        static_vector_bool = build_bool(i)
        @test hydro_plant_static_vector_bool(inputs.collections.hydro_plant, i) == static_vector_bool
        @test hydro_plant_static_vector_bool(inputs.collections, i) == static_vector_bool
        @test hydro_plant_static_vector_bool(inputs, i) == static_vector_bool
    end

    for i in 1:THERMAL_PLANT_SIZE
        label = build_thermal_plant_label(i)
        @test thermal_plant_label(inputs.collections.thermal_plant, i) == label
        @test thermal_plant_label(inputs.collections, i) == label
        @test thermal_plant_label(inputs, i) == label

        static_vector_float = build_float(i)
        @test thermal_plant_static_vector_float(inputs.collections.thermal_plant, i) == static_vector_float
        @test thermal_plant_static_vector_float(inputs.collections, i) == static_vector_float
        @test thermal_plant_static_vector_float(inputs, i) == static_vector_float

        static_vector_int = build_int(i)
        @test thermal_plant_static_vector_int(inputs.collections.thermal_plant, i) == static_vector_int
        @test thermal_plant_static_vector_int(inputs.collections, i) == static_vector_int
        @test thermal_plant_static_vector_int(inputs, i) == static_vector_int

        static_vector_bool = build_bool(i)
        @test thermal_plant_static_vector_bool(inputs.collections.thermal_plant, i) == static_vector_bool
        @test thermal_plant_static_vector_bool(inputs.collections, i) == static_vector_bool
        @test thermal_plant_static_vector_bool(inputs, i) == static_vector_bool
    end

    @show Base.doc(thermal_plant_label)

    for _ in 1:ITERATIONS
        for date_time in DATE_TIMES
            @timeit "not cached - update!" update!(inputs, date_time = date_time)

            for i in 1:HYDRO_PLANT_SIZE
                time_series_float = build_float(date_time)
                @test hydro_plant_time_series_float(inputs.collections.hydro_plant, i) == time_series_float
                @test hydro_plant_time_series_float(inputs.collections, i) == time_series_float
                @test hydro_plant_time_series_float(inputs, i) == time_series_float

                time_series_int = build_int(date_time)
                @test hydro_plant_time_series_int(inputs.collections.hydro_plant, i) == time_series_int
                @test hydro_plant_time_series_int(inputs.collections, i) == time_series_int
                @test hydro_plant_time_series_int(inputs, i) == time_series_int

                time_series_bool = build_bool(date_time)
                @test hydro_plant_time_series_bool(inputs.collections.hydro_plant, i) == time_series_bool
                @test hydro_plant_time_series_bool(inputs.collections, i) == time_series_bool
                @test hydro_plant_time_series_bool(inputs, i) == time_series_bool
            end

            for i in 1:THERMAL_PLANT_SIZE
                time_series_float = build_float(date_time)
                @test thermal_plant_time_series_float(inputs.collections.thermal_plant, i) == time_series_float
                @test thermal_plant_time_series_float(inputs.collections, i) == time_series_float
                @test thermal_plant_time_series_float(inputs, i) == time_series_float

                time_series_int = build_int(date_time)
                @test thermal_plant_time_series_int(inputs.collections.thermal_plant, i) == time_series_int
                @test thermal_plant_time_series_int(inputs.collections, i) == time_series_int
                @test thermal_plant_time_series_int(inputs, i) == time_series_int

                time_series_bool = build_bool(date_time)
                @test thermal_plant_time_series_bool(inputs.collections.thermal_plant, i) == time_series_bool
                @test thermal_plant_time_series_bool(inputs.collections, i) == time_series_bool
                @test thermal_plant_time_series_bool(inputs, i) == time_series_bool

                adjusted_vector_float = build_float(date_time) + build_float(date_time)
                @test thermal_plant_adjusted_vector_float(inputs.collections.thermal_plant, i) == adjusted_vector_float
                @test thermal_plant_adjusted_vector_float(inputs.collections, i) == adjusted_vector_float
                @test thermal_plant_adjusted_vector_float(inputs, i) == adjusted_vector_float

                adjusted_vector_int = build_int(date_time) + build_int(date_time)
                @test thermal_plant_adjusted_vector_int(inputs.collections.thermal_plant, i) == adjusted_vector_int
                @test thermal_plant_adjusted_vector_int(inputs.collections, i) == adjusted_vector_int
                @test thermal_plant_adjusted_vector_int(inputs, i) == adjusted_vector_int

                adjusted_vector_bool = build_bool(date_time) && build_bool(date_time)
                @test thermal_plant_adjusted_vector_bool(inputs.collections.thermal_plant, i) == adjusted_vector_bool
                @test thermal_plant_adjusted_vector_bool(inputs.collections, i) == adjusted_vector_bool
                @test thermal_plant_adjusted_vector_bool(inputs, i) == adjusted_vector_bool
            end
        end
    end

    for _ in 1:ITERATIONS
        for date_time in DATE_TIMES
            key = Dates.format(date_time, "yyyymmdd")
            @timeit "cached - update!" update!(inputs, cache, key; date_time = date_time)

            for i in 1:HYDRO_PLANT_SIZE
                time_series_float = build_float(date_time)
                @test hydro_plant_time_series_float(inputs.collections.hydro_plant, i) == time_series_float
                @test hydro_plant_time_series_float(inputs.collections, i) == time_series_float
                @test hydro_plant_time_series_float(inputs, i) == time_series_float

                time_series_int = build_int(date_time)
                @test hydro_plant_time_series_int(inputs.collections.hydro_plant, i) == time_series_int
                @test hydro_plant_time_series_int(inputs.collections, i) == time_series_int
                @test hydro_plant_time_series_int(inputs, i) == time_series_int

                time_series_bool = build_bool(date_time)
                @test hydro_plant_time_series_bool(inputs.collections.hydro_plant, i) == time_series_bool
                @test hydro_plant_time_series_bool(inputs.collections, i) == time_series_bool
                @test hydro_plant_time_series_bool(inputs, i) == time_series_bool
            end

            for i in 1:THERMAL_PLANT_SIZE
                time_series_float = build_float(date_time)
                @test thermal_plant_time_series_float(inputs.collections.thermal_plant, i) == time_series_float
                @test thermal_plant_time_series_float(inputs.collections, i) == time_series_float
                @test thermal_plant_time_series_float(inputs, i) == time_series_float

                time_series_int = build_int(date_time)
                @test thermal_plant_time_series_int(inputs.collections.thermal_plant, i) == time_series_int
                @test thermal_plant_time_series_int(inputs.collections, i) == time_series_int
                @test thermal_plant_time_series_int(inputs, i) == time_series_int

                time_series_bool = build_bool(date_time)
                @test thermal_plant_time_series_bool(inputs.collections.thermal_plant, i) == time_series_bool
                @test thermal_plant_time_series_bool(inputs.collections, i) == time_series_bool
                @test thermal_plant_time_series_bool(inputs, i) == time_series_bool
            end
        end
    end

    @timeit "finalize!" begin
        finalize!(inputs)
        finalize!(cache)
    end

    PSRDatabaseSQLite.close!(db)

    rm(path)

    return nothing
end

reset_timer!()
test_all()
print_timer()
