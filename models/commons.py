from django.db import models

from superlachaise.models import model_validators

class CommonsCategory(models.Model):

    # title (without "Category:")
    id = models.CharField(primary_key=True, db_index=True, max_length=1024)

    wikitext = models.TextField(default='', blank=True)

    COMMONS_URL_FORMAT = "https://commons.wikimedia.org/wiki/Category:{id}"
    def commons_url(self):
        if self.id:
            return CommonsCategory.COMMONS_URL_FORMAT.format(id=self.id)

    def __str__(self):
        return self.id

    class Meta:
        ordering = ['id']
        verbose_name = 'Commons category'
        verbose_name_plural = 'Commons categories'
