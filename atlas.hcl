env "local" {
  url = "spanner://projects/${getenv("SPANNER_PROJECT_ID")}/instances/${getenv("SPANNER_INSTANCE")}/databases/${getenv("SPANNER_DATABASE")}?emulator=true"
  dev = "spanner://projects/${getenv("SPANNER_PROJECT_ID")}/instances/${getenv("SPANNER_INSTANCE")}/databases/${getenv("SPANNER_DATABASE")}?emulator=true"

  migration {
    dir = "file://db/migrations"
  }
}
