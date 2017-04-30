from django.db import models

from superlachaise.models import model_validators

class WikipediaPage(models.Model):

    # <language>|<title>
    id = models.CharField(primary_key=True, db_index=True, max_length=1024, validators=[model_validators.validate_wikipedia_id])

    default_sort = models.CharField(default='', blank=True, max_length=1024)

    redirect = models.ForeignKey('WikipediaPage', null=True, blank=True, on_delete=models.SET_NULL)

    def id_parts(self):
        """ Returns (language, title) from id """
        if self.id:
            split_id = self.id.split('|')
            if len(split_id) == 2:
                return (split_id[0], split_id[1])
        return (None, None)

    WIKIPEDIA_URL_FORMAT = "https://{language}.wikipedia.org/wiki/{title}"
    def wikipedia_url(self):
        (language, title) = self.id_parts()
        if language and title:
            return WikipediaPage.WIKIPEDIA_URL_FORMAT.format(language=language, title=title)

    def __str__(self):
        return self.id

    class Meta:
        ordering = ['default_sort', 'id']
        verbose_name = 'Wikipedia page'
        verbose_name_plural = 'Wikipedia pages'
