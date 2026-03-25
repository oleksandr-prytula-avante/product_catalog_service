package main

import (
	"fmt"
	"net/http"
	"os"
)

func handler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintln(w, "Hello, World! Port: "+os.Getenv("PORT"))
}

func main() {
	http.HandleFunc("/", handler)
	port := os.Getenv("PORT")

	fmt.Printf("Server running on :%s\n", port)
	http.ListenAndServe(":"+port, nil)
}
