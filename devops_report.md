# DevOps Report – Flask + PostgreSQL CRUD Application

---

## 1. Technologies Used

- **Python 3.9** – Core backend language
- **Flask** – Web framework for API and web interface
- **Flask-SQLAlchemy** – ORM to interact with PostgreSQL database
- **PostgreSQL 16** – Relational database
- **Docker & Docker Compose** – Containerization for consistent environments
- **GitHub Actions** – CI/CD pipeline automation
- **Pytest** – Testing framework for unit and integration tests
- **Flake8** – Code linting for quality assurance
- **Bandit** – Security scanning for common Python vulnerabilities
- **Flask-CORS** – Handling cross-origin requests

---

## 2. Pipeline Design

The CI/CD pipeline is implemented using **GitHub Actions** and triggers on `push` or `pull_request` events to the `main` branch.  

**Pipeline Stages:**

[Code Commit / PR]
|
v
[Build & Install Python Dependencies]
|
v
[Linting & Security Scan (Flake8 & Bandit)]
|
v
[Test with PostgreSQL Container (Pytest)]
|
v
[Docker Build & Push to Docker Hub]



**Stage Details:**

1. **Build & Install**
   - Checks out the repository.
   - Sets up Python 3.9 environment.
   - Installs dependencies from `requirements.txt`.
   - Verifies Flask installation.

2. **Lint & Security Scan**
   - Installs Flake8 and Bandit.
   - Runs Flake8 to check Python code quality (`E501` ignored for long lines).
   - Runs Bandit for static security analysis of `app.py`.

3. **Testing**
   - Starts a PostgreSQL 16 service via GitHub Actions.
   - Waits until the database is healthy (`pg_isready`).
   - Installs testing dependencies (`pytest`, `psycopg2-binary`).
   - Runs tests defined in `tests/test_app.py` to ensure API routes work correctly.

4. **Docker Build & Push**
   - Runs only on the `main` branch.
   - Logs in to Docker Hub using `DOCKER_USERNAME` and `DOCKER_PASSWORD` from GitHub Secrets.
   - Builds Docker image for the Flask app.
   - Tags image with `latest` and commit SHA.
   - Pushes images to Docker Hub.

---

## 3. Secret Management Strategy

- **GitHub Secrets**:
  - `DOCKER_USERNAME` – Docker Hub username.
  - `DOCKER_PASSWORD` – Docker Hub password.
  - Used only in the Docker push step.
  
- **Environment Variables in Docker Compose**:
  - `POSTGRES_USER` – Database username
  - `POSTGRES_PASSWORD` – Database password
  - `POSTGRES_DB` – Database name
  - `DATABASE_URL` – Connection string for Flask

- Secrets are never stored in the repository and are injected securely into the pipeline and containers.

---

## 4. Testing Process

- **Unit Tests**:  
  - Located in `tests/test_app.py`.
  - Tests the `/` route returns `status_code 200`.
  
- **Integration Tests**:
  - Tests endpoints with a live PostgreSQL container.
  - Covers all CRUD operations (`GET`, `POST`, `PUT`, `DELETE`) for user data.

- **Linting & Security**:
  - Flake8 checks for code style violations.
  - Bandit scans for common security issues in Python code.

- **Pipeline Testing Flow**:
  - Build stage ensures dependencies are correct.
  - Linting and security stage ensures code quality.
  - Test stage ensures functionality works with a database.
  - Docker build stage ensures application can be containerized successfully.

---

## 5. Lessons Learned

1. **CI/CD Automation**:
   - Separating pipeline stages improves reliability and debugging.
   - Using `needs:` in GitHub Actions ensures proper stage execution order.

2. **Dockerization**:
   - Separating app and database containers simplifies dependency management.
   - Health checks (`pg_isready`) ensure containers start in correct order.

3. **Secret Management**:
   - GitHub Secrets securely manage Docker credentials.
   - Environment variables in Docker provide flexible configuration.

4. **Testing & Quality**:
   - Running tests with a live database simulates production closely.
   - Linting and static analysis reduce potential runtime errors.

5. **Pipeline Reliability**:
   - Tagging Docker images with commit SHA improves traceability.
   - Automated builds on every commit help catch issues early.

---

## 6. Pipeline Diagram (Text Representation)

 +------------+
 |  Git Push  |
 +-----+------+
       |
       v
 +------------+
 |   Build    |
 |  Install   |
 +-----+------+
       |
       v
 +------------+
 |   Lint     |
 |  Security  |
 +-----+------+
       |
       v
 +------------+
 |   Test     |
 | (Postgres) |
 +-----+------+
       |
       v
 +----------------+
 | Docker Build & |
 |     Push       |
 +----------------+



---

## 7. Conclusion

The project demonstrates:

- Full **DevOps integration** for a Flask + PostgreSQL app.
- **Secure and reliable CI/CD pipeline** with automated testing.
- **Dockerized environment** for reproducible deployments.
- Best practices in **secret management**, **linting**, and **security scanning**.