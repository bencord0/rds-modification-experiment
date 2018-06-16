from django.db import models


class Entry(models.Model):
    timestamp = models.DateTimeField(auto_now_add=True)
