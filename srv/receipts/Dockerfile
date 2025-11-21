FROM python:3.12-slim

WORKDIR /app

# Phase 1: Install minimal dependencies (PostgreSQL client only)
# Phase 3 will add: tesseract-ocr, poppler-utils for AI extraction
RUN apt-get update && apt-get install -y \
    libpq-dev \
    gcc \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python packages
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create non-root user
RUN useradd -m -u 1000 phoenix && chown -R phoenix:phoenix /app
USER phoenix

# Health check endpoint
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health').read()" || exit 1

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "4"]
