# Stage 1: Build
FROM python:3.10-slim AS builder

WORKDIR /app

# Copy only the requirements file first to leverage Docker cache
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . .

# Stage 2: Runtime
FROM python:3.10-slim

WORKDIR /app

# Copy installed dependencies from the builder stage
COPY --from=builder /usr/local/lib/python3.10/site-packages /usr/local/lib/python3.10/site-packages
COPY --from=builder /app .

# Copy opentelemetry-instrument
COPY --from=builder /usr/local/bin/opentelemetry-instrument /usr/local/bin/opentelemetry-instrument

EXPOSE 8000

CMD ["python", "main.py"]
