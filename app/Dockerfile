# ── Stage 1: Builder ──────────────────────────────────────────────────────
FROM python:3.12-alpine AS builder

WORKDIR /build

# Alpine uses apk instead of apt-get
RUN apk add --no-cache gcc musl-dev libffi-dev

COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# ── Stage 2: Final hardened image ─────────────────────────────────────────
FROM python:3.12-alpine AS final

LABEL org.opencontainers.image.title="devsecops-app"
LABEL org.opencontainers.image.description="DevSecOps Pipeline App"

# Install curl for health check only
RUN apk add --no-cache curl

# Create non-root user (Alpine syntax)
RUN addgroup -S appgroup && adduser -S -G appgroup appuser

WORKDIR /app

# Copy installed deps from builder stage
COPY --from=builder /install /usr/local

# Copy app source with correct ownership
COPY --chown=appuser:appgroup app.py .

# Lock down permissions
RUN chmod -R 550 /app && \
    mkdir -p /tmp && \
    chmod 1777 /tmp && \
    chown appuser:appgroup /tmp

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    APP_ENV=production \
    PORT=5000

USER appuser
EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1

CMD ["gunicorn", \
     "--bind", "0.0.0.0:5000", \
     "--workers", "2", \
     "--threads", "4", \
     "--timeout", "60", \
     "--access-logfile", "-", \
     "--error-logfile", "-", \
     "app:app"]