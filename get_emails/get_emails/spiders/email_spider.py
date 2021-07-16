from scrapy import Spider, Request
from get_emails.items import GetEmailsItem
import re
import pandas as pd

class email_spider(Spider):
    name = 'email_spider'
    start_urls = ['https://www.modernmeadow.com/']
    
    def parse(self, reponse):
       
        golden_csv   = pd.read_csv("../golden_scrapy/golden_synbio_companies.csv")
        golden_csv.fillna("",inplace=True)

        company_list = golden_csv.name
        url_list     = golden_csv.primary_url
        
        # name_url_list = zip(golden_csv.name, golden_csv.primary_url)
        
        name_url_list = zip(company_list, url_list)
        
        for name_url in name_url_list:
            name, url = name_url
            if url:
                yield Request(url=url, 
                          callback=self.get_url,
                          meta = {'contact_flag': False,
                                  'company_name': name,
                                  'company_url' : url})
    
    
    def get_url(self, response):        
        
        try:
            emails = re.findall(r'[\w\.-]+@[\w\.-]+', response.body.decode())
        except:
            emails = "error"
        
        email_item = GetEmailsItem()
        email_item["company_name"]  = response.meta['company_name']
        email_item["company_url"]   = response.meta['company_url']
        email_item["company_email"] = emails
        email_item["contact_flag"]  = response.meta['contact_flag']
        yield email_item
        
        # this isnt being called?
        if response.meta['contact_flag'] == False:
            try:
                # There isnt a good way to do case insensitive searches, but this shouldn't match much else.
                contact_url = response.xpath(".//a[contains(text(),'ontact')]/@href").extract() + \
                              response.xpath(".//span[contains(text(),'ontact')]/../@href").extract() + \
                              response.xpath(".//strong[contains(text(),'ontact')]/../@href").extract()
                contact_url = contact_url if isinstace(contact_url,list) else [contact_url]
                
                for url in contact_url:
                    if "http" not in url:
                        url = response.meta['company_url'] + url
                    yield Request(url=url,
                                  callback=self.get_url,
                                  meta = {'contact_flag': True,
                                          'company_name': response.meta['company_name'],
                                          'company_url' : response.meta['company_url']})
            except:
                pass
            
            