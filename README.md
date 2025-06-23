# 🐳 Dockerized Django Project with PostgreSQL and Nginx

This project provides a minimal setup of a Django web application containerized using Docker and Docker Compose. It includes:

- **Django** (Python web framework)
- **PostgreSQL** (relational database)
- **Nginx** (web server for reverse proxying)

---

## 🚀 Quick Start Guide

### 1. 📥 Clone the `lesson-4` branch

### 2. 🛠️ Build and start the containers

Once you've cloned the repository and navigated to the project root, build and launch all the containers:

```bash
docker-compose build
docker-compose up -d
```

### 3. ⚙️ Apply Django migrations

Once the containers are running, apply the initial database migrations to set up the necessary tables in PostgreSQL:

```bash
docker-compose exec django python manage.py migrate
```

### 4. 🌐 Access the application in your browser

After applying migrations, your application should be up and running.

Open your browser and go to: http://localhost

You should see the default Django welcome page with the message:

> **"The installation worked successfully! Congratulations!"**

This confirms that:
- The Django server is running inside Docker
- Nginx is correctly proxying traffic to the Django container
- The PostgreSQL database is reachable (assuming migrations completed)

If you see a **502 Bad Gateway** or other error:
- Wait 5–10 seconds and refresh — Django may still be starting
- Check logs for issues:

```bash
docker-compose logs nginx
docker-compose logs django
```