import time

from django.core.management.base import BaseCommand

from scripts.db import DBErrors, reset_db_connection
from scripts.models import Entry


class Command(BaseCommand):
    help = 'Workload to read from the database'

    def handle(self, *args, **options):
        while True:
            try:
                print(Entry.objects.last().timestamp)
            except DBErrors:
                reset_db_connection()

            try:
                time.sleep(1)
            except KeyboardInterrupt:
                break
