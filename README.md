# PersonalPage

A modular personal portfolio website built with **Django**, **Wagtail CMS**, and **AJAX pagination**.

## Features

- **Modular Architecture**: Separate Django apps for different directions:
  - `develop`: Software development and general projects.
  - `ml`: Machine Learning and Data Science research.
  - `bioinfo`: Bioinformatics and Computational Biology.
  - `printing`: 3D Printing and Digital Fabrication.
- **Wagtail CMS**: Flexible content management with StreamFields for building project pages.
- **AJAX Pagination**: Projects load dynamically in the "Projects" section without page refresh.
- **Responsive Design**: Based on the elegant [Dimension](https://html5up.net/dimension) template by HTML5 UP.
- **Shared Layout**: Uses a `base.html` with inheritance, while providing unique backgrounds for each module.
- **Environment Management**: Secure configuration using `.env` files.

## Project Structure

```text
├── .env                  # Environment variables (SECRET_KEY, DEBUG, etc.)
├── .gitignore            # Git ignore rules for Django, IDEs, etc.
├── personalpage/         # Project core configuration
├── develop/              # Develop app (Wagtail integration)
├── ml/                   # Machine Learning app
├── bioinfo/              # Bioinformatics app
├── printing/             # 3D Printing app
├── static/               # Global static files (CSS, JS, Images)
├── templates/            # Shared templates (base.html and subfolders)
├── media/                # User-uploaded media (Wagtail images)
└── manage.py             # Django management script
```

## Setup & Installation

### 1. Requirements
- Python 3.10+
- [Poetry](https://python-poetry.org/docs/#installation)

### 2. Installation
1.  **Clone the repository**:
    ```bash
    git clone https://github.com/chesterzed/PersonalPage.git
    cd PersonalPage
    ```

2.  **Install dependencies and create virtual environment**:
    ```bash
    poetry install
    ```

3.  **Activate virtual environment**:
    ```bash
    poetry shell
    ```

4.  **Configure environment**:
    Create a `.env` file in the root directory (use `.env.example` as a template):
    ```env
    SECRET_KEY=your-secret-key
    DEBUG=True
    ALLOWED_HOSTS=127.0.0.1,localhost
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
3.  **Access the CMS**: `http://127.0.0.1:8000/cms/`

## Contributing
Feel free to fork this project and adapt it for your own personal portfolio.

## License
Based on the Dimension template by HTML5 UP, released under the Creative Commons license. Django and Wagtail are BSD-licensed.
