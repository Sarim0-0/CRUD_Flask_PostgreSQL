FROM python:3.9-slim  # Base image
WORKDIR /app  # Set work dir
COPY . /app  # Copy code
RUN pip install --no-cache-dir -r requirements.txt  # Install deps
EXPOSE 5000  # Port
CMD ["python", "app.py"]  # Run command