from django.db import models
from django.conf import settings
from wagtail.models import Page
from wagtail.fields import StreamField
from wagtail import blocks
from wagtail.images.blocks import ImageChooserBlock
from wagtail.snippets.blocks import SnippetChooserBlock
from wagtail.snippets.models import register_snippet
from wagtail.admin.panels import FieldPanel
from django.core.validators import FileExtensionValidator
import os
import zipfile
import uuid

class DevelopProjectIndexPage(Page):
    intro = models.TextField(blank=True)

    content_panels = Page.content_panels + [
        FieldPanel('intro'),
    ]

    def get_context(self, request):
        context = super().get_context(request)
        context['projects'] = DevelopProjectPage.objects.child_of(self).live()
        return context

@register_snippet
class InteractiveApp(models.Model):
    title = models.CharField(max_length=255, verbose_name="Название приложения")
    zip_file = models.FileField(
        upload_to='apps_zips/',
        validators=[FileExtensionValidator(allowed_extensions=['zip'])],
        verbose_name="Архив (.zip) с игрой/приложением"
    )
    folder_name = models.CharField(max_length=255, blank=True, editable=False)

    panels = [
        FieldPanel('title'),
        FieldPanel('zip_file'),
    ]

    def __str__(self):
        return self.title

    def save(self, *args, **kwargs):
        if not self.folder_name:
            self.folder_name = str(uuid.uuid4())
            
        super().save(*args, **kwargs)
        self._extract_zip()

    def _extract_zip(self):
        if not self.zip_file:
            return
            
        zip_path = self.zip_file.path
        extract_path = os.path.join(settings.MEDIA_ROOT, 'apps_extracted', self.folder_name)
        
        os.makedirs(extract_path, exist_ok=True)
        
        # Защита от опасных скриптов
        dangerous_exts = {'.py', '.php', '.exe', '.sh', '.bat', '.cgi', '.pl', '.jsp', '.asp', '.aspx', '.rb', '.phtml'}
        
        try:
            with zipfile.ZipFile(zip_path, 'r') as zip_ref:
                for member in zip_ref.namelist():
                    # Защита от Directory Traversal
                    if '..' in member or member.startswith('/'):
                        continue
                    
                    ext = os.path.splitext(member)[1].lower()
                    if ext in dangerous_exts:
                        continue
                        
                    zip_ref.extract(member, extract_path)
        except zipfile.BadZipFile:
            pass

    def get_index_url(self):
        extract_path = os.path.join(settings.MEDIA_ROOT, 'apps_extracted', self.folder_name)
        for root, dirs, files in os.walk(extract_path):
            if 'index.html' in files:
                rel_path = os.path.relpath(os.path.join(root, 'index.html'), settings.MEDIA_ROOT)
                return settings.MEDIA_URL + rel_path.replace('\\', '/')
        return ""

class InteractiveEmbedBlock(blocks.StructBlock):
    title = blocks.CharBlock(required=False, label="Название")
    preview = ImageChooserBlock(label="Превью (картинка)")
    app = SnippetChooserBlock('develop.InteractiveApp', label="Приложение (ZIP архив)")
    aspect_ratio = blocks.ChoiceBlock(choices=[
        ('56.25%', '16:9'),
        ('75%', '4:3'),
        ('100%', '1:1'),
        ('400px', 'Фиксированная высота (400px)'),
    ], default='56.25%', label="Соотношение сторон / Высота")

    class Meta:
        template = 'blocks/interactive_embed.html'
        icon = 'code'
        label = 'Интерактивный проект (Unity/Wasm)'

class DevelopProjectPage(Page):
    release_date = models.DateField(blank=True, null=True, verbose_name="Дата релиза")
    start_date = models.DateField(blank=True, null=True, verbose_name="Дата начала")
    end_date = models.DateField(blank=True, null=True, verbose_name="Дата конца")
    short_description = models.TextField(blank=True, verbose_name="Краткое описание")
    preview = models.ForeignKey(
        'wagtailimages.Image',
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name='+',
        verbose_name="Превью"
    )
    body = StreamField([
        ('text', blocks.RichTextBlock(label="Просто текст")),
        ('image_with_text', blocks.StructBlock([
            ('image', ImageChooserBlock(label="Картинка")),
            ('text', blocks.TextBlock(label="Текст")),
        ], label="Картинка с текстом")),
        ('gallery', blocks.ListBlock(
            ImageChooserBlock(), label="Галерея"
        )),
        ('interactive', InteractiveEmbedBlock()),
    ], use_json_field=True)

    content_panels = Page.content_panels + [
        FieldPanel('release_date'),
        FieldPanel('start_date'),
        FieldPanel('end_date'),
        FieldPanel('short_description'),
        FieldPanel('preview'),
        FieldPanel('body'),
    ]
