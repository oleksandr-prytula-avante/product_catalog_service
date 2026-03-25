env "local" {
  url = getenv("ATLAS_DB_URL")
  dev = getenv("ATLAS_DEV_URL")

  migration {
    dir = "file://migrations"
  }
}