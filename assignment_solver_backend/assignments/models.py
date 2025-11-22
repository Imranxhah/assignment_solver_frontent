from django.db import models

class AppVersion(models.Model):
    platform = models.CharField(max_length=10, choices=[('android', 'Android'), ('ios', 'iOS')])
    version_name = models.CharField(max_length=20)  # e.g., "1.0.1"
    version_code = models.IntegerField()            # e.g., 2
    force_update = models.BooleanField(default=False)
    release_notes = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('platform', 'version_name')
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.platform} - {self.version_name} ({self.version_code})"