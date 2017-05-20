from django.db import models

from superlachaise.models import model_validators

class CommonsCategory(models.Model):

    # title (without "Category:")
    id = models.CharField(primary_key=True, db_index=True, max_length=1024)

    default_sort = models.CharField(default='', max_length=1024, blank=True)
    wikitext = models.TextField(default='', blank=True)

    redirect = models.ForeignKey('CommonsCategory', null=True, blank=True, on_delete=models.SET_NULL)

    main_commons_file = models.ForeignKey('CommonsFile', null=True, blank=True, on_delete=models.SET_NULL)
    commons_files = models.ManyToManyField('CommonsFile', blank=True, related_name="commons_categories")

    COMMONS_CATEGORY_URL_FORMAT = "https://commons.wikimedia.org/wiki/Category:{id}"
    def commons_url(self):
        if self.id:
            return CommonsCategory.COMMONS_CATEGORY_URL_FORMAT.format(id=self.id)

    COMMONS_IMAGE_URL_FORMAT = "https://commons.wikimedia.org/wiki/File:{id}"
    def main_image_commons_url(self):
        if self.main_image:
            return CommonsCategory.COMMONS_IMAGE_URL_FORMAT.format(id=self.main_image)

    def __str__(self):
        return self.id

    class Meta:
        ordering = ['default_sort', 'id']
        verbose_name = 'Commons category'
        verbose_name_plural = 'Commons categories'

class CommonsFile(models.Model):

    # title (without "File:")
    id = models.CharField(primary_key=True, db_index=True, max_length=1024)

    author = models.CharField(default='', max_length=1024, blank=True)
    license = models.CharField(default='', max_length=1024, blank=True)

    image_url = models.TextField(default='', blank=True)
    thumbnail_url_template = models.TextField(default='', blank=True)

    COMMONS_CATEGORY_URL_FORMAT = "https://commons.wikimedia.org/wiki/File:{id}"
    def commons_url(self):
        if self.id:
            return CommonsFile.COMMONS_CATEGORY_URL_FORMAT.format(id=self.id)

    def __str__(self):
        return self.id

    class Meta:
        ordering = ['id']
        verbose_name = 'Commons file'
        verbose_name_plural = 'Commons files'
