# PersonalPage

A modular personal portfolio website built with **Django**, **Wagtail CMS**, and **AJAX navigation**. Designed for developers and researchers to showcase projects, including interactive Unity games and WebAssembly applications.

## Key Features

- **SPA-like Project Transitions**: Projects transition smoothly from list to a full-screen detailed view using AJAX and the Dimension template's logic, preserving pagination state.
- **Interactive Project Embeds**: Support for Unity WebGL and C/C++ (via WebAssembly) interactive applications.
- **Secure ZIP Uploads**: Upload project builds as `.zip` archives directly through Wagtail admin. The system securely extracts them and finds the `index.html` automatically.
- **Modular Architecture**: Separate Django apps for different disciplines:
  - `develop`: Software development and general projects.
  - `ml`: Machine Learning and Data Science research.
  - `bioinfo`: Bioinformatics and Computational Biology.
  - `printing`: 3D Printing and Digital Fabrication.
- **PostgreSQL Integration**: Optimized for production-ready PostgreSQL databases.
- **Lazy Loading**: Interactive projects only load after a user clicks "Play", saving bandwidth and server resources.
- **Custom Deployment Scripts**: Ready-to-use scripts for managing Gunicorn and Caddy on macOS (Mac Mini).

## Project Structure

```text
├── personalpage/         # Project core configuration (settings, URLs)
├── develop/              # Develop app (Main models and InteractiveApp snippet)
├── ml/                   # Machine Learning app
├── bioinfo/              # Bioinformatics app
├── printing/             # 3D Printing app
├── scripts/              # Deployment scripts (start.sh, restart.sh, stop.sh)
├── static/               # Global static files (CSS, JS, Images, Dimension assets)
├── templates/            # Django/Wagtail templates
├── media/                # User-uploaded media and extracted ZIP apps
├── Caddyfile             # Configuration for Caddy web server
└── manage.py             # Django management script
```

## Setup & Installation

### 1. Requirements
- Python 3.10+
- PostgreSQL
- [Caddy](https://caddyserver.com/) (for deployment)

### 2. Local Installation
1.  **Clone the repository**:
    ```bash
    git clone https://github.com/chesterzed/PersonalPage.git
    cd PersonalPage
    ```

2.  **Install dependencies**:
    ```bash
    pip install -r requirements.txt
    ```

3.  **Configure Environment**:
    Create a `.env` file based on `.env.example`:
    ```env
    SECRET_KEY=your-secret-key
    DEBUG=True
    ALLOWED_HOSTS=127.0.0.1,localhost
    DB_NAME=MyPortfolio
    DB_USER=admin
    DB_PASSWORD=admin
    ```

4.  **Database Setup**:
    Ensure PostgreSQL is running and create the database and user:
    ```sql
    CREATE DATABASE "MyPortfolio";
    CREATE USER admin WITH PASSWORD 'admin';
    GRANT ALL PRIVILEGES ON DATABASE "MyPortfolio" TO admin;
    ```

5.  **Run Migrations**:
    ```bash
    python manage.py migrate
    ```

6.  **Create Superuser**:
    ```bash
    python manage.py createsuperuser
    ```

### 3. Usage
1.  **Start the server**:
    ```bash
    python manage.py runserver
    ```
2.  **Access the site**: `http://127.0.0.1:8000/`

## Deployment (Mac Mini)

1.  **Permissions**: Make scripts executable: `chmod +x scripts/*.sh`
2.  **Start Services**: Run `./scripts/start.sh`
3.  **Caddy Configuration**:
    - Add the block from the provided `Caddyfile` to your system's main Caddy configuration.
    - Update paths in `Caddyfile` to match your Mac Mini username (`/Users/chesterzed/...`).
4.  **Environment**: Ensure `.env` has `DEBUG=False` and your local IP in `ALLOWED_HOSTS`.

## Interactive Projects Workflow
1. Build your Unity project for **WebGL** or C project for **WebAssembly** (using Emscripten).
2. Archive the build output (containing `index.html`) into a `.zip` file.
3. Upload the ZIP via Wagtail Admin -> Snippets -> Interactive Apps.
4. Link the uploaded app in your Project Page via the "Интерактивный проект" block.

## License
Based on the Dimension template by HTML5 UP. Django and Wagtail are BSD-licensed.
