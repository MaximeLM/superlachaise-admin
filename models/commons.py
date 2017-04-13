from django.db import models

from superlachaise.models import model_validators

class CommonsCategory(models.Model):

    # title (without "Category:")
    id = models.CharField(primary_key=True, db_index=True, max_length=1024)

    default_sort = models.CharField(default='', max_length=1024, blank=True)
    image = models.CharField(default='', max_length=1024, blank=True)

    redirect = models.ForeignKey('CommonsCategory', null=True, blank=True, on_delete=models.SET_NULL)

    COMMONS_URL_FORMAT = "https://commons.wikimedia.org/wiki/Category:{id}"
    def commons_url(self):
        if self.id:
            return CommonsCategory.COMMONS_URL_FORMAT.format(id=self.id)

    def __str__(self):
        return self.id

    class Meta:
        ordering = ['default_sort', 'id']
        verbose_name = 'Commons category'
        verbose_name_plural = 'Commons categories'

class CommonsFile(models.Model):

    # title (without "File:")
    id = models.CharField(primary_key=True, db_index=True, max_length=1024)

    license = models.CharField(default='', max_length=1024, blank=True)
    author = models.CharField(default='', max_length=1024, blank=True)

    COMMONS_URL_FORMAT = "https://commons.wikimedia.org/wiki/File:{id}"
    def commons_url(self):
        if self.id:
            return CommonsFile.COMMONS_URL_FORMAT.format(id=self.id)

    def __str__(self):
        return self.id

    class Meta:
        ordering = ['id']
        verbose_name = 'Commons file'
        verbose_name_plural = 'Commons files'
