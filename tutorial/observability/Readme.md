## Overview

:confused: **What is Observability?**

A measure of how well the internal state of a system can be inferred from its external outputs.

Simply speaking, **outputs → (internal) state**.

### History

**Monolithic**

- Agent
- Logfile-based
- System-level metrics such as cpu/mem, # of proc, resp time
- Zabbix, New Relic, Datadog

**Microservice**

:confounded: Challenges

- **Difficult to trace** the complete chain of requests & pinpoint specific serice or step where bottlenecks/errors occurs
- **Logs are distrubuted** across multiple nodes, complexity in collection, aggregation and analysis.
- Network latency, and communication failures arising from inter-service calls are **not easily observable**.

:smiley: Observability = Traces + Metrics + Logs

### vs.

**Monitoring**: a subset of Observability, it collects & displays the metrics (together with alarms).

**APM**: a subset of Monitoring, specifically focuses on perf of app.

### Arch

(Sources) → **Colletion** (Trace/Metirc/Log) → **Monitoring** (categorized Dashboards) → **Analysis** (Chain)

### Tracing

It aims to capture events in a **sequential flow** that depicts the **causal relationship** between the events **in a single user request**.

**Trace Context** (Propagation) meta in each requst trace as identifier.

Carrier: HTTP header, gRPC metadata, RPC custom field



![Context propagation in a fictional e-commerce web application. Trace context or request identifier is passed along the execution flow.](https://signoz.io/img/blog/2022/02/context_propagation_in_distributed_systems.webp)

#### [Jaeger](https://www.jaegertracing.io/)

`uber-trace-id: {trace-id}:{span-id}:{parent-span-id}:{flags}`

- `trace-id`: a unique identifier for the entire trace.
- `span-id`:  a unique identifier for a specific **span (action/process/step)** within the trace.
- `parent-span-id`: identifies the parent span of the current span.
- `flags` provide additional information about the trace. for example whether should be sampled or if it's a debug trace.

```bash
Trace: 1234567890abcdef
├── Span: 1 (GET /api/v1/orders)
│   ├── Span: 2 (Fetch order details)
│   │   ├── Span: 3 (Database query: SELECT * FROM orders)
│   │   └── Span: 4 (Cache lookup: orders_cache)
│   └── Span: 5 (Process order)
│       └── Span: 6 (Payment service call)
│           └── Span: 7 (Payment processing)
└── Span: 8 (Log order event)
```

```bash
A (Client) 
  |
  v
B (Service: GET /api/v1/orders)
  |
  v
C (Service: Fetch order details)
  |        \
  v         v
D (Service: Database query)    E (Service: Cache lookup)
  |
  v
F (Service: Process order)
  |
  v
G (Service: Payment service call)
  |
  v
H (Service: Payment processing)
  |
  v
I (Service: Log order event)

```

#### [Zipkin](https://zipkin.io/)

`X-B3-*`

- `X-B3-TraceId`: a unique identifier for the entire trace.
- `X-B3-SpanId`:  a unique identifier for a specific **span (action/process/step)** within the trace.
- `X-B3-ParentSpanId`: identifies the parent span of the current span.
- `X-B3-Sampled`: a sampling indicator.
- `X-B3-Flags`: provide additional information about the trace.
- `b3`: compresss all B3 tracing info into a single header, formatted as traceid-spanid-parentspanid-sampled.

### Metrics

Google 4 Golden Signals

- **Latency**: The time it takes to process a request.
- **Traffic**: The amount of demand on the system, often measured in requests/transactions per second (RPS/TPS) or data in bytes.
- **Errors**： The rate of failed requests, typically measured as a percentage of total requests.
- **Saturation**： The degree to which the system is being utilized, often represented as a percentage of capacity.

Service Quality Management

- SLI: **indicator** to quantify a particular aspect of service performance. For example: 4 golden signals.
- SLO: **object** defines the level of service that should be achieved. For example: P95 should be 300ms, availability should reach 3 9's.
- SLA: **agreement** btw a customer and a service provider that outlines the expected level of service, responsibilities, and remedies. 

#### [Prometheus](https://prometheus.io/)

### Logs

#### [Elastic](https://www.elastic.co/downloads/elasticsearch)

#### [Loki](https://github.com/grafana/loki)

## [OpenTelemetry](https://opentelemetry.io/)

[OpenTracing](https://opentracing.io/) + [OpenCensus](https://opencensus.io/), which aims to **standardize** tracing + metrics + logs.

It provides **unified API & SDK** to simplify the collection of observability data **across different languages and platforms**.

It does not consider how the data will be used, stored, displayed, or alerted = **Backend-agnostic**.

**Integration**: OTel SDK, OpenTelemetry Collector.

:smiley: Grafana family: Tempo, Prometheus, Loki, Grafana.

![OpenTelemetry Reference Architecture](https://opentelemetry.io/img/otel-diagram.svg)

### Signals

#### [Traces](https://opentelemetry.io/docs/concepts/signals/traces/)

- `context`: an immutable object on every span.
  - The Trace ID representing the trace that the span is a part of
  - The span’s Span ID
  - Trace Flags, a binary encoding containing information about the trace
  - Trace State, a list of key-value pairs that can carry vendor-specific trace information
- `atributes`: key-value pairs that contain metadata that you can use to annotate a Span.
- `events`:  a structured log message on a Span, typically used to denote a meaningful, singular point in time.
- `links`: allow you can associate with span(s), implying a causal relationship (not parent-child).
- `status`:
  - `Unset`: operation it tracked successfully completed without an error.
  - `Error`: some error occurred in the operation it tracks.
  - `OK`: span was explicitly marked as error-free by the developer of an application.

```json
{
  "name": "hello",
  "context": {
    "trace_id": "5b8aa5a2d2c872e8321cf37308d69df2",
    "span_id": "051581bf3cb55c13"
  },
  "parent_id": null,
  "start_time": "2022-04-29T18:52:58.114201Z",
  "end_time": "2022-04-29T18:52:58.114687Z",
  "attributes": {
    "http.route": "some_route1"
  },
  "events": [
    {
      "name": "Guten Tag!",
      "timestamp": "2022-04-29T18:52:58.114561Z",
      "attributes": {
        "event_attributes": 1
      }
    }
  ]
}

```

#### [Metrics](https://opentelemetry.io/docs/concepts/signals/metrics/)

[Instrument](https://opentelemetry.io/docs/concepts/signals/metrics/#metric-instruments) for capturing the metrics.



##### [Data Model](https://opentelemetry.io/docs/specs/otel/metrics/data-model/)

It is designed as a standard for **transporting** metric data.

- [Event Model](https://opentelemetry.io/docs/specs/otel/metrics/data-model/) is where recording of data happens.
  - Its foundation is made of [Instruments](https://opentelemetry.io/docs/specs/otel/metrics/api/#instrument), which are used to record data observations via events by `ValueRecorder`.
  - Raw events will be transformed in fashion before sending to other systems.
    - [Sum](https://github.com/open-telemetry/opentelemetry-proto/blob/c5c8b28012583fda55b0cb16f73a820722171d49/opentelemetry/proto/metrics/v1/metrics.proto#L247): represents an *Aggregation Temporality* of delta or cumulative - (start,end] time window.
    - [Gauge](https://github.com/open-telemetry/opentelemetry-proto/blob/c5c8b28012583fda55b0cb16f73a820722171d49/opentelemetry/proto/metrics/v1/metrics.proto#L241): represents a (last) sampled value at a given time.
    - [Histogram](https://github.com/open-telemetry/opentelemetry-proto/blob/c5c8b28012583fda55b0cb16f73a820722171d49/opentelemetry/proto/metrics/v1/metrics.proto#L260): conveys a population of recorded measurements in a compressed format.

![Events → Data Stream → Timeseries Diagram](https://opentelemetry.io/docs/specs/otel/metrics/img/model-layers.png)

![Events → Streams](https://opentelemetry.io/docs/specs/otel/metrics/img/model-event-layer.png)

:confused: **How to associate Metrics with Traces?**

:smile: By annotating trace_id & span_id.

:confused: **How to associate Logs with Traces?**

:smile: By printing trace_id & span_id from SpanContext.

#### [Logs](https://opentelemetry.io/docs/concepts/signals/logs/)

A **log** is a timestamped text record, either structured (recommended) or unstructured, with optional metadata.

### Components

#### [Collector](https://opentelemetry.io/docs/collector/)

It offers a **vendor-agnostic** implementation of how to receive, process and export telemetry data.

**Pipeline** = **Reciver** x O → (Fan-in) → **Processor** (on Traces/Metrics/Logs) x P → (Fan-out) → **Exporter** x Q.

![OpenTelemetry Collector diagram with Jaeger, OTLP and Prometheus integration](https://opentelemetry.io/docs/collector/img/otel-collector.svg)

### [Data Flow](https://opentelemetry.io/docs/demo/collector-data-flow-dashboard/)

Typical

![OpenTelemetry Collector Data Flow Overview](https://opentelemetry.io/docs/demo/collector-data-flow-dashboard/otelcol-data-flow-overview.png)

### [Integration](https://opentelemetry.io/ecosystem/integrations/)

[Zero-code](https://opentelemetry.io/docs/concepts/instrumentation/zero-code/) = agent-like

[APIs & SDKs](https://opentelemetry.io/docs/languages/)

### [Sampling](https://opentelemetry.io/docs/concepts/sampling/)

1% is acceptable.

When & When not.

Head or Tail.