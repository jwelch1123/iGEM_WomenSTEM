# Define here the models for your scraped items
#
# See documentation in:
# https://docs.scrapy.org/en/latest/topics/items.html

import scrapy


class GetEmailsItem(scrapy.Item):
    company_name  = scrapy.Field()
    company_url   = scrapy.Field()
    company_email = scrapy.Field()
    contact_flag  = scrapy.Field()
