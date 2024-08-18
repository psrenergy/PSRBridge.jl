using PSRBridge

using Dates
import PSRClassesInterface as PSRI
using Random
using Serialization
using Test
using TimerOutputs

const PSRDatabaseSQLite = PSRI.PSRDatabaseSQLite
const DatabaseSQLite = PSRI.PSRDatabaseSQLite.DatabaseSQLite


@collection @kwdef mutable struct HydroPlant <: AbstractCollection
    id::String = "HydroPlant"
    label::StaticVectorData{String} = "label"
    initial_volume::StaticVectorData{Float64} = "initial_volume"
    has_commitment::StaticVectorData{Bool} = "has_commitment"
    # non_controllable_spillage::StaticVectorData{Bool} = "non_controllable_spillage"

    # existing::TimeSeriesData{Float64} = "existing"
    # production_factor::TimeSeriesData{Float64} = "production_factor"
    # min_generation::TimeSeriesData{Float64} = "min_generation"
    # max_generation::TimeSeriesData{Float64} = "max_generation"
    # min_turbining::TimeSeriesData{Float64} = "min_turbining"
    # max_turbining::TimeSeriesData{Float64} = "max_turbining"
    # min_volume::TimeSeriesData{Float64} = "min_volume"
    # max_volume::TimeSeriesData{Float64} = "max_volume"
    # min_outflow::TimeSeriesData{Float64} = "min_outflow"
    # om_cost::TimeSeriesData{Float64} = "om_cost"

    # bus_index::MapData = ("Bus", "id")
    # agent_index::MapData = ("Agent", "id")
    # gauging_station_index::MapData = ("GaugingStation", "id")
    # turbine_to_index::MapData = ("HydroPlant", "turbine_to")
    # spill_to_index::MapData = ("HydroPlant", "spill_to")
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

function build_thermal_plant_label(i::Integer)
    return "Thermal Plant $i"
end

function build_hydro_plant_label(i::Integer)
    return "Hydro Plant $i"
end

function test_all()
    thermal_plant_size = 20
    hydro_plant_size = 20

    path = joinpath(@__DIR__, "db.sqlite")
    path_schema = joinpath(@__DIR__, "schema.sql")

    db = PSRDatabaseSQLite.create_empty_db_from_schema(
        path,
        path_schema;
        force = true,
    )

    PSRDatabaseSQLite.create_element!(
        db,
        "Configuration";
        label = "Bridge",
    )

    for i in 1:thermal_plant_size
        PSRDatabaseSQLite.create_element!(
            db,
            "ThermalPlant";
            label = build_thermal_plant_label(i),
            shutdown_cost = Float64(i),
            max_startups = i,
        )
    end

    for i in 1:hydro_plant_size
        PSRDatabaseSQLite.create_element!(
            db,
            "HydroPlant";
            label = build_hydro_plant_label(i),
            initial_volume = Float64(i),
        )
    end

    iterations = 2

    inputs = Inputs(; db = db)
    cache = Cache(verbose = true)

    @timeit "initialize!" initialize!(inputs)

    for i in 1:hydro_plant_size
        label = build_hydro_plant_label(i)
        @test hydro_plant_label(inputs.collections.hydro_plant, i) == label
        @test hydro_plant_label(inputs.collections, i) == label
        @test hydro_plant_label(inputs, i) == label

        initial_volume = Float64(i)
        @test hydro_plant_initial_volume(inputs.collections.hydro_plant, i) == initial_volume
        @test hydro_plant_initial_volume(inputs.collections, i) == initial_volume
        @test hydro_plant_initial_volume(inputs, i) == initial_volume
    end

    for i in 1:thermal_plant_size
        label = build_thermal_plant_label(i)
        @test thermal_plant_label(inputs.collections.thermal_plant, i) == label
        @test thermal_plant_label(inputs.collections, i) == label
        @test thermal_plant_label(inputs, i) == label

        shutdown_cost = Float64(i)
        @test thermal_plant_shutdown_cost(inputs.collections.thermal_plant, i) == shutdown_cost
        @test thermal_plant_shutdown_cost(inputs.collections, i) == shutdown_cost
        @test thermal_plant_shutdown_cost(inputs, i) == shutdown_cost

        max_startups = i
        @test thermal_plant_max_startups(inputs.collections.thermal_plant, i) == max_startups
        @test thermal_plant_max_startups(inputs.collections, i) == max_startups
        @test thermal_plant_max_startups(inputs, i) == max_startups
    end

    @show Base.doc(thermal_plant_label)

    @timeit "not cached" begin
        for _ in 1:iterations
            for month in 1:12
                @timeit "update!" update!(inputs, date_time = DateTime(2025, month, 1))
            end
        end
    end

    @timeit "cached" begin
        for _ in 1:iterations
            for month in 1:12
                @timeit "update!" update!(inputs, cache, date_time = DateTime(2025, month, 1))
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
