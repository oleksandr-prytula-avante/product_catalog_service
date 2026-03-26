# product_catalog_service

Product Catalog Service is a Go-based backend project for managing products and pricing data with Google Cloud Spanner.

This repository currently includes:
- A minimal HTTP service entry point in app/main.go
- Local development orchestration with Docker Compose
- Cloud Spanner emulator and initialization scripts
- Atlas-based database migration workflow
- Database schema for products and outbox events

The project is intended as a foundation for implementing a production-style product catalog domain with clean architecture, pricing rules, and reliable event publishing.
