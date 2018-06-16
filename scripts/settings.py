import os
import dj_database_url

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SECRET_KEY = 'neverusethis'
DEBUG = True
ALLOWED_HOSTS = []
INSTALLED_APPS = ['scripts']
MIDDLEWARE = []
ROOT_URLCONF = 'scripts.urls'
DATABASES = {'default': dj_database_url.config()}
