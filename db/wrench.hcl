database {
  driver = "spanner"
  source = "spanner://projects/${getenv("SPANNER_PROJECT_ID")}/instances/${getenv("SPANNER_INSTANCE_ID")}/databases/${getenv("SPANNER_DATABASE_ID")}" 
  emulator_host = getenv("SPANNER_EMULATOR_HOST")
}

migrations {
  dir = "db/migrations"
}