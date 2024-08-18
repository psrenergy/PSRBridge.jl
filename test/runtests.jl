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

const THERMAL_PLANT_SIZE = 20
const HYDRO_PLANT_SIZE = 20
const DATE_TIMES = [DateTime(2025, month, 1) for month in 1:12]

include("build.jl")

@collection @kwdef mutable struct HydroPlant <: AbstractCollection
    id::String = "HydroPlant"

    label::StaticVectorData{String} = "label"
    initial_volume::StaticVectorData{Float64} = "initial_volume"
    has_commitment::StaticVectorData{Bool} = "has_commitment"

    existing::TimeSeriesData{Bool} = "existing"
    max_generation::TimeSeriesData{Float64} = "max_generation"

    # non_controllable_spillage::StaticVectorData{Bool} = "non_controllable_spillage"

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

function adjust!(collection::HydroPlant, collections::AbstractCollections, db::DatabaseSQLite; kwargs...)
    return nothing
end

@collection @kwdef mutable struct ThermalPlant <: AbstractCollection
    id::String = "ThermalPlant"

    label::StaticVectorData{String} = "label"
    shutdown_cost::StaticVectorData{Float64} = "shutdown_cost"
    max_startups::StaticVectorData{Int} = "max_startups"

    # has_commitment::StaticVectorData{Bool} = "has_commitment"

    # existing::TimeSeriesData{Bool} = "existing"
    # min_generation::TimeSeriesData{Float64} = "min_generation"
    # max_generation::TimeSeriesData{Float64} = "max_generation"
    # om_cost::TimeSeriesData{Float64} = "om_cost"
    # startup_cost::TimeSeriesData{Float64} = "startup_cost"
end

function add_thermal_plant!(db::DatabaseSQLite; kwargs...)
    PSRI.create_element!(db, "ThermalPlant"; kwargs...)
    return nothing
end

function adjust!(collection::ThermalPlant, collections::AbstractCollections, db::DatabaseSQLite; kwargs...)
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

    for i in 1:HYDRO_PLANT_SIZE
        label = build_hydro_plant_label(i)
        @test hydro_plant_label(inputs.collections.hydro_plant, i) == label
        @test hydro_plant_label(inputs.collections, i) == label
        @test hydro_plant_label(inputs, i) == label

        initial_volume = Float64(i)
        @test hydro_plant_initial_volume(inputs.collections.hydro_plant, i) == initial_volume
        @test hydro_plant_initial_volume(inputs.collections, i) == initial_volume
        @test hydro_plant_initial_volume(inputs, i) == initial_volume

        has_commitment = build_hydro_plant_has_commitment(i)
        @test hydro_plant_has_commitment(inputs.collections.hydro_plant, i) == has_commitment
        @test hydro_plant_has_commitment(inputs.collections, i) == has_commitment
        @test hydro_plant_has_commitment(inputs, i) == has_commitment
    end

    for i in 1:THERMAL_PLANT_SIZE
        label = build_thermal_plant_label(i)
        @test thermal_plant_label(inputs.collections.thermal_plant, i) == label
        @test thermal_plant_label(inputs.collections, i) == label
        @test thermal_plant_label(inputs, i) == label

        shutdown_cost = build_thermal_plant_shutdown_cost(i)
        @test thermal_plant_shutdown_cost(inputs.collections.thermal_plant, i) == shutdown_cost
        @test thermal_plant_shutdown_cost(inputs.collections, i) == shutdown_cost
        @test thermal_plant_shutdown_cost(inputs, i) == shutdown_cost

        max_startups = build_thermal_plant_max_startups(i)
        @test thermal_plant_max_startups(inputs.collections.thermal_plant, i) == max_startups
        @test thermal_plant_max_startups(inputs.collections, i) == max_startups
        @test thermal_plant_max_startups(inputs, i) == max_startups
    end

    @show Base.doc(thermal_plant_label)

    iterations = 10

    for _ in 1:iterations
        for date_time in DATE_TIMES
            @timeit "not cached - update!" update!(inputs, date_time = date_time)

            for i in 1:HYDRO_PLANT_SIZE
                existing = build_hydro_plant_existing(date_time)
                @test hydro_plant_existing(inputs.collections.hydro_plant, i) == existing
                @test hydro_plant_existing(inputs.collections, i) == existing
                @test hydro_plant_existing(inputs, i) == existing

                max_generation = build_hydro_plant_max_generation(date_time)
                @test hydro_plant_max_generation(inputs.collections.hydro_plant, i) == max_generation
                @test hydro_plant_max_generation(inputs.collections, i) == max_generation
                @test hydro_plant_max_generation(inputs, i) == max_generation
            end
        end
    end

    for _ in 1:iterations
        for date_time in DATE_TIMES
            @timeit "cached - update!" update!(inputs, cache, date_time = date_time)

            for i in 1:HYDRO_PLANT_SIZE
                existing = build_hydro_plant_existing(date_time)
                @test hydro_plant_existing(inputs.collections.hydro_plant, i) == existing
                @test hydro_plant_existing(inputs.collections, i) == existing
                @test hydro_plant_existing(inputs, i) == existing

                max_generation = build_hydro_plant_max_generation(date_time)
                @test hydro_plant_max_generation(inputs.collections.hydro_plant, i) == max_generation
                @test hydro_plant_max_generation(inputs.collections, i) == max_generation
                @test hydro_plant_max_generation(inputs, i) == max_generation
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
