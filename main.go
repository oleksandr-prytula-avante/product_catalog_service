package main

import (
	"fmt"
	"net/http"
	"os"
)

func handler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintln(w, "Hello, World! Port: "+os.Getenv("APP_PORT"))
}

func main() {
	http.HandleFunc("/", handler)
	port := os.Getenv("APP_PORT")

	fmt.Printf("Server running on :%s\n", port)

	if err := http.ListenAndServe(":"+port, nil); err != nil {
		fmt.Printf("server failed: %v\n", err)
		os.Exit(1)
	}
}
