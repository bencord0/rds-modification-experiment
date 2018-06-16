from django.db.utils import InterfaceError as dj_InterfaceError, OperationalError
from psycopg2 import InterfaceError as pg_InterfaceError


DBErrors = (
    dj_InterfaceError,
    pg_InterfaceError,
    OperationalError,
)


def reset_db_connection():
    from django import db
    db.close_old_connections()
