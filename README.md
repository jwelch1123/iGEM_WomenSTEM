# iGEM_WomenSTEM
Projects Related to the After iGEM Women in STEM Initiative


## Intro
This repo holds my work for the After iGEM Women in STEM Initiative. [After iGEM](https://igem.org/After_iGEM) is an organization promoting synthetic biology across all sectors. The [Women in STEM Initiative](https://igem.org/After_iGEM/Initiatives/Women-in-STEM) is a group working to increase representation of women in SynBio and STEM. 

## Scraping Golden for Synbio Companies
One aspect of the initiative is survey based data collection from companies in the SynBio industry. To generate leads, I built a web scraper for a Golden.com page listing [Synthetic Biology Companies](https://golden.com/list-of-synthetic-biology-companies/), which provided similar other data to our other lead generation strategies.

## Contact Information Scraping via Webscraping
In order to contact a variety of SynBio companies, I built a webscraper which used the urls generated by the golden_spider to find contact information from each company. This second spider traverses each companies URL, attempts to find a listed email or the company contact page (where another email might be found). 

This was used for as a rough first pass. Many false "emails" were found so there was a need to manually curate the list. Generally if an email couldn't be found there was not one provided so we needed to visit the company contact page to communicate with them. 

## UNESCO

As part of the Women in STEM Data Team, we wanted to analyze and communicate findings about the state of Women in STEM worldwide. Our collaborators suggested UNESCO as a well regarded resourse. I assembled an R notebook to help with some data assembly and cleaning. This was useful for me to generate simpler tables for our communication team but not user friendly. 

## UNESCO Shiny App
To create a user friendly experience for manipulating the data I created a shiny app which allows simple data manipulation of some of the UNESCO database. You can access the [app here](https://jwelch1123.shinyapps.io/AiWistem_unesco/), and download country, year, and indicator codes (types of information).

One area of improvement is visualization of the Indicator Codes, there are thousands of codes but I couldn't find a resonable way to display them in shiny. 


You can find out more about the Women in STEM Initiative and After iGEM [here](https://igem.org/After_iGEM) and on most social media sites.
