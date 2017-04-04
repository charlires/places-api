package handler

import (
	"net/http"
)

type DemoController struct {
}

func (t DemoController) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.Write([]byte("{\"status\":\"Ok!\"}"))
}
