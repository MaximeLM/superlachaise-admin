from django.db import models

from superlachaise.models import model_validators

class WikipediaPage(models.Model):

    # <language>|<title>
    id = models.CharField(primary_key=True, db_index=True, max_length=1024, validators=[model_validators.validate_wikipedia_id])

    default_sort = models.CharField(default='', max_length=255, blank=True)
    extract = models.TextField(default='', blank=True)
    wikidata_entry = models.ForeignKey('WikidataEntry', null=True, blank=True, on_delete=models.SET_NULL)

    def id_parts(self):
        if self.id and len(self.id.split('|')) == 2:
            return self.id.split('|')

    WIKIPEDIA_URL_FORMAT = "https://{language}.wikipedia.org/wiki/{title}"
    def wikipedia_url(self):
        id_parts = self.id_parts()
        if id_parts:
            return WikipediaPage.WIKIPEDIA_URL_FORMAT.format(language=id_parts[0], title=id_parts[1])

    def __str__(self):
        return self.id

    class Meta:
        ordering = ['id']
        verbose_name = 'Wikipedia page'
        verbose_name_plural = 'Wikipedia pages'
