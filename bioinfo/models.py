from django.db import models
from wagtail.models import Page
from wagtail.fields import StreamField
from wagtail import blocks
from wagtail.images.blocks import ImageChooserBlock
from wagtail.admin.panels import FieldPanel
from develop.models import InteractiveEmbedBlock

class BioinfoProjectIndexPage(Page):
    intro = models.TextField(blank=True)
    content_panels = Page.content_panels + [FieldPanel('intro')]

class BioinfoProjectPage(Page):
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
        ('text', blocks.RichTextBlock(label="Текст")),
        ('image_with_text', blocks.StructBlock([
            ('image', ImageChooserBlock(label="Картинка")),
            ('text', blocks.TextBlock(label="Текст")),
        ], label="Картинка с текстом")),
        ('gallery', blocks.ListBlock(ImageChooserBlock(), label="Галерея")),
        ('interactive', InteractiveEmbedBlock()),
    ], use_json_field=True)
    content_panels = Page.content_panels + [
        FieldPanel('short_description'),
        FieldPanel('preview'),
        FieldPanel('body')
    ]
