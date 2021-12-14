import re

def on_post_page(output, **kwargs):
    return re.sub(
        r'href="([^"]+)#open-in-new-tab"',
        r'href="\1" target="_blank"',
        output
    )