import os
import json
import re

def analyze_app(base_dir):
    screens = []
    
    for item in os.listdir(base_dir):
        item_path = os.path.join(base_dir, item)
        if os.path.isdir(item_path):
            html_file = os.path.join(item_path, "code.html")
            if os.path.exists(html_file):
                with open(html_file, "r", encoding="utf-8") as f:
                    content = f.read()
                    
                # Extract title
                title_match = re.search(r'<title>(.*?)</title>', content)
                title = title_match.group(1) if title_match else item
                
                # Extract links
                links = re.findall(r'href=["\']([^"\']+\.html)["\']', content)
                links.extend(re.findall(r'onclick=["\']window\.location\.href=[\'"]([^\'"]+\.html)[\'"]', content))
                
                class_name = "".join(x.capitalize() for x in item.split("_")) + "Screen"
                
                screens.append({
                    "dir_name": item,
                    "class_name": class_name,
                    "title": title,
                    "links": list(set(links))
                })
    
    with open("analysis.json", "w") as f:
        json.dump(screens, f, indent=2)

if __name__ == "__main__":
    analyze_app(".")
