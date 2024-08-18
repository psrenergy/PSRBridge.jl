function build_thermal_plant_label(i::Integer)
    return "Thermal Plant $i"
end

function build_thermal_plant_shutdown_cost(i::Integer)
    return Float64(i)
end

function build_thermal_plant_max_startups(i::Integer)
    return i
end

function build_hydro_plant_label(i::Integer)
    return "Hydro Plant $i"
end

function build_hydro_plant_initial_volume(i::Integer)
    return Float64(i)
end

function build_hydro_plant_has_commitment(i::Integer)
    return i % 2 == 0
end

function build_hydro_plant_existing(date_time::DateTime)
    return Dates.month(date_time) % 2 == 0
end

function build_hydro_plant_max_generation(date_time::DateTime)
    return Float64(Dates.month(date_time))
end

function build_database(path::AbstractString)
    if isfile(path)
        rm(path; force = true)
    end

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

    for i in 1:THERMAL_PLANT_SIZE
        add_thermal_plant!(
            db;
            label = build_thermal_plant_label(i),
            shutdown_cost = build_thermal_plant_shutdown_cost(i),
            max_startups = build_thermal_plant_max_startups(i),
        )
    end

    for i in 1:HYDRO_PLANT_SIZE
        add_hydro_plant!(db;
            label = build_hydro_plant_label(i),
            initial_volume = build_hydro_plant_initial_volume(i),
            has_commitment = build_hydro_plant_has_commitment(i) ? 1 : 0,
            parameters = DataFrame(;
                date_time = DATE_TIMES,
                existing = [build_hydro_plant_existing(date_time) ? 1 : 0 for date_time in DATE_TIMES],
                max_generation = [build_hydro_plant_max_generation(date_time) for date_time in DATE_TIMES],
            ),
        )
    end

    PSRDatabaseSQLite.close!(db)

    return nothing
end
