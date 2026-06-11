from django.db import models
from wagtail.models import Page
from wagtail.fields import StreamField
from wagtail import blocks
from wagtail.images.blocks import ImageChooserBlock
from wagtail.admin.panels import FieldPanel

class PrintingProjectIndexPage(Page):
    intro = models.TextField(blank=True)
    content_panels = Page.content_panels + [FieldPanel('intro')]

class PrintingProjectPage(Page):
    body = StreamField([
        ('text', blocks.RichTextBlock(label="Текст")),
        ('image_with_text', blocks.StructBlock([
            ('image', ImageChooserBlock(label="Картинка")),
            ('text', blocks.TextBlock(label="Текст")),
        ], label="Картинка с текстом")),
        ('gallery', blocks.ListBlock(ImageChooserBlock(), label="Галерея")),
    ], use_json_field=True)
    content_panels = Page.content_panels + [FieldPanel('body')]
