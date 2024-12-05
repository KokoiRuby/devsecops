package main

import (
	"encoding/json"
	"log"
	"math/rand"
	"net/http"
	"strconv"
	"time"

	"github.com/prometheus/client_golang/prometheus/promhttp"

	"github.com/gorilla/mux"
	"github.com/prometheus/client_golang/prometheus"
)

type ResponseWriter struct {
	http.ResponseWriter
	statusCode int
}

func NewResponseWriter(w http.ResponseWriter) *ResponseWriter {
	return &ResponseWriter{w, http.StatusOK}
}

func (rw *ResponseWriter) WriteHeader(code int) {
	rw.statusCode = code
	rw.ResponseWriter.WriteHeader(code)
}

// metrics, type & labels

// metric: req count
var totalRequests = prometheus.NewCounterVec(
	prometheus.CounterOpts{
		Name: "total_http_requests",
		Help: "Total number of HTTP requests",
	},
	[]string{"path", "method"})

// metric: http status code
var responseStatus = prometheus.NewCounterVec(
	prometheus.CounterOpts{
		Name: "response_status",
		Help: "Status code of HTTP responses",
	},
	[]string{"status"})

// metric: http resp time
var httpResponseTime = prometheus.NewHistogramVec(
	prometheus.HistogramOpts{
		Name: "http_response_time_seconds",
		Help: "Response time of HTTP requests",
		// default: []float64{0.1, 0.2, 0.5, 1.0, 2.0, 5.0, 10.0}
		// Buckets: []float64{0.1, 0.105, 0.11, 0.125, 0.15, 0.2},
	},
	[]string{"path"})

// prometheus middleware
func prometheusMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		log.Printf("Received request for path: %s", r.URL.Path)

		// get path from route
		route := mux.CurrentRoute(r)
		path, _ := route.GetPathTemplate()

		// record http resp time histogram
		timer := prometheus.NewTimer(httpResponseTime.WithLabelValues(path))

		// random dely 100ms ~ 200ms
		randomDelay := rand.New(rand.NewSource(time.Now().UnixNano()))
		time.Sleep(time.Duration(randomDelay.Intn(100)+100) * time.Microsecond)

		rw := NewResponseWriter(w)
		next.ServeHTTP(rw, r)

		statusCode := rw.statusCode

		// counter ++
		responseStatus.WithLabelValues(strconv.Itoa(statusCode)).Inc()
		totalRequests.WithLabelValues(path, r.Method).Inc()

		// histogram
		timer.ObserveDuration()
	})
}

func init() {
	err := prometheus.Register(totalRequests)
	if err != nil {
		return
	}
	err = prometheus.Register(responseStatus)
	if err != nil {
		return
	}
	err = prometheus.Register(httpResponseTime)
	if err != nil {
		return
	}
}

func main() {
	router := mux.NewRouter()

	// prom middleware given path & handler, each req will be handled by pm middleware = interceptor
	router.Use(prometheusMiddleware)
	router.Path("/metrics").Handler(promhttp.Handler())

	router.HandleFunc("/api/health", healthHandler)
	router.HandleFunc("/api/pay", payHandler)
	router.HandleFunc("/api/cart", cartHandler)
	router.HandleFunc("/api/error", errorHandler)

	//router.HandleFunc("/test/qps_high", qpsTestHandler)
	//router.HandleFunc("/test/error", errorTestHandler)

	err := http.ListenAndServe(":1314", router)
	log.Fatal(err)
}

// handlers
func healthHandler(w http.ResponseWriter, r *http.Request) {
	err := json.NewEncoder(w).Encode(map[string]bool{"ok": true})
	if err != nil {
		return
	}
}

func payHandler(w http.ResponseWriter, r *http.Request) {
	err := json.NewEncoder(w).Encode(map[string]bool{"pay": true})
	if err != nil {
		return
	}
}

func cartHandler(w http.ResponseWriter, r *http.Request) {
	err := json.NewEncoder(w).Encode(map[string]bool{"cart": true})
	if err != nil {
		return
	}
}

func errorHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusInternalServerError)
	err := json.NewEncoder(w).Encode(map[string]string{"message": "bad request"})
	if err != nil {
		return
	}
}

// hpa demo1
//func qpsTestHandler(w http.ResponseWriter, r *http.Request) {
//	cmd := exec.Command("hey", "-c", "15", "-z", "1m", "http://localhost:1314/api/pay")
//	out, err := cmd.Output()
//	if err != nil {
//		fmt.Println(err)
//	}
//	fmt.Fprint(w, string(out))
//}
//

// keda demo1
//func errorTestHandler(w http.ResponseWriter, r *http.Request) {
//	cmd := exec.Command("hey", "-c", "15", "-z", "1m", "http://localhost:1314/api/error")
//	out, err := cmd.Output()
//	if err != nil {
//		fmt.Println(err)
//	}
//	fmt.Fprint(w, string(out))
//}
