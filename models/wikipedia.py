from django.db import models

from superlachaise.models import model_validators

class WikipediaPage(models.Model):

    # <language>|<title>
    id = models.CharField(primary_key=True, db_index=True, max_length=1024, validators=[model_validators.validate_wikipedia_id])

    language = models.CharField(blank=True, max_length=1024)
    title = models.CharField(blank=True, max_length=1024)

    default_sort = models.CharField(default='', blank=True, max_length=1024)
    extract = models.TextField(default='', blank=True)

    redirect = models.ForeignKey('WikipediaPage', null=True, blank=True, on_delete=models.SET_NULL)

    WIKIPEDIA_URL_FORMAT = "https://{language}.wikipedia.org/wiki/{title}"
    def wikipedia_url(self):
        if self.language and self.title:
            return WikipediaPage.WIKIPEDIA_URL_FORMAT.format(language=self.language, title=self.title)

    def __str__(self):
        return self.id

    class Meta:
        ordering = ['default_sort', 'id']
        verbose_name = 'Wikipedia page'
        verbose_name_plural = 'Wikipedia pages'
