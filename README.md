# Flask + PostgreSQL CRUD Application

This is a simple CRUD web application built with **Flask** and **PostgreSQL**, containerized with **Docker**, and integrated with a **CI/CD pipeline** for automated testing, linting, and Docker image deployment.

---

## Features

- **CRUD operations** for user data (`name` and `age`)
- RESTful API endpoints for data:
  - `GET /data` – Get all users
  - `POST /data` – Add a new user
  - `GET /data/<id>` – Get a specific user
  - `PUT /data/<id>` – Update a user
  - `DELETE /data/<id>` – Delete a user
- Web interface to view a welcome page
- PostgreSQL database backend
- Cross-Origin Resource Sharing (CORS) enabled
- Dockerized app with separate app and DB containers
- CI/CD pipeline using GitHub Actions

---

## Tech Stack

- **Python 3.9**
- **Flask** – Web framework
- **Flask-SQLAlchemy** – ORM for database interaction
- **PostgreSQL 16** – Relational database
- **Docker & Docker Compose** – Containerization
- **GitHub Actions** – CI/CD automation
- **Pytest** – Testing framework
- **Flake8 & Bandit** – Linting and security scanning
- **Flask-CORS** – Handling cross-origin requests

---

## Getting Started

### Prerequisites

- Docker & Docker Compose installed
- Git installed
- (Optional) Python 3.9 installed if running locally without Docker

---

### Running with Docker

1. Clone the repository:
   git clone <repo-url>
   cd <repo-folder>

2. Start the application:
    docker-compose up --build

3. Access the app:
    Web interface: http://localhost:5000
    API endpoints: http://localhost:5000/data