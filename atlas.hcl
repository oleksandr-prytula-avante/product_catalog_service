env "local" {
  url = "spanner://projects/${getenv("PROJECT_ID")}/instances/${getenv("INSTANCE")}/databases/${getenv("DATABASE")}?emulator=true"
  dev = "spanner://projects/${getenv("PROJECT_ID")}/instances/${getenv("INSTANCE")}/databases/${getenv("DATABASE")}?emulator=true"

  migration {
    dir = "file://migrations"
  }
}