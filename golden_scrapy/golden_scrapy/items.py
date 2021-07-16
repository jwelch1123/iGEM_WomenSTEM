# Define here the models for your scraped items
#
# See documentation in:
# https://docs.scrapy.org/en/latest/topics/items.html

import scrapy


class GoldenScrapyItem(scrapy.Item):
    name        = scrapy.Field()
    description = scrapy.Field()
    indsutry    = scrapy.Field()
    websites    = scrapy.Field()
    primary_url = scrapy.Field()
    location    = scrapy.Field()
    meta_url    = scrapy.Field()
    page        = scrapy.Field()