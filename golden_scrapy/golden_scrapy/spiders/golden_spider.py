from scrapy import Spider, Request
from golden_scrapy.items import GoldenScrapyItem


class golden_spider(Spider):
    name = 'golden_spider'
    allowed_urls = ['https://golden.com/list-of-synthetic-biology-companies/']
    start_urls = ['https://golden.com/list-of-synthetic-biology-companies/']
    golden_url = 'https://golden.com/list-of-synthetic-biology-companies/'


    
    def parse(self, reponse):
        golden_url = 'https://golden.com/list-of-synthetic-biology-companies/'
        url_list = [golden_url] + [golden_url+ str(x) for x in list(range(2,21))]
    
        for i, url in enumerate(url_list):
            yield Request(url=url, callback = self.page_parse, meta = {'page':i+1})
    
    
    def page_parse(self, response):
        golden_url = 'https://golden.com/list-of-synthetic-biology-companies/'
        rows = response.xpath(".//div[contains(@class,'QueryTable__row')]")
        
        
        for row in rows:
            
            
            name        = row.xpath("./div[1]//span/a/span/text()").extract()
            description = row.xpath("./div[2]//p/span/text()").extract() 
            description = "".join(description)
            industry    = row.xpath("./div[3]//div[@class='EntityDisplay']//a/span/text()").extract()
            websites    = row.xpath("./div[4]//span/a/@href").extract()
            try:
                primary_url = websites[0]
            except:
                primary_url = websites
            location    = row.xpath("./div[5]//a/span/text()").extract()
            
            
            golden_item = GoldenScrapyItem()
            golden_item["name"]        = name
            golden_item["description"] = description
            golden_item["indsutry"]    = industry
            golden_item["websites"]    = websites
            golden_item["primary_url"] = primary_url
            golden_item["location"]    = location
            golden_item["meta_url"]    = golden_url
            golden_item["page"]        = response.meta['page']
            yield golden_item