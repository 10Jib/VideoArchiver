import json
import re
import time
import itertools as it

import requests
from lxml import html as lh

def lambda_handler(event, context):
    # asserts url and event are present and valid
    print("Loggingtest")
    current_date = time.strftime("%Y-%m-%d")
    
    platform = re.findall(r"^(?:https?:\/\/)?(?:www\.)?([^\/]+)", event['target'])[0]
    if platform in ['twitch.tv']:
        name = re.findall(r"^(?:https?:\/\/)?(?:www\.[^\/]+)?\/([^\/]+)", event['target'])[0]
    
    #http://localhost:8050/render.html
    resp = requests.post(f"http://{event['url']}:8050/render.html", json={
    'wait': 0.5,
    'url': event['target']
    })
    resp.raise_for_status()
    
    print("got response")
    tree = lh.fromstring(resp.text)
    print("prased tree")
    
    titles = [x.attrib['title'] for x in tree.xpath('//a[contains(@class, "tw-link")]/h3')]
    vidLinks = [f"https://www.twitch.tv{stem.attrib['href']}" for stem in tree.xpath('//div[@class="Layout-sc-1xcs6mc-0 iPAXTU"]//a[h3]')]
    metaData = [(x, y, z) for x, y, z in grouper(tree.xpath('.//div[contains(@class, "tw-media-card-stat")]/text()'), 3)]
    
    
    data = []
    for i, title in enumerate(titles):
        # could be named tupples or something
        data.append({"title":title,
                     "link":vidLinks[i],
                     "timestr":metaData[i][0],
                     "viewstr":metaData[i][1],
                     "fromstr":metaData[i][2],
                     "platform":platform,
                     "ID":name,
                     "mineTime":current_date})
                 
    if data:
        return {
            'statusCode': 200,
            'Links': json.dumps(data)
        }
        
    else:
        print("no vids")
        return {
            'statusCode': 400
        }
        
def grouper(inputs, n, fillvalue=None):
    iters = [iter(inputs)] * n
    return it.zip_longest(*iters, fillvalue=fillvalue)