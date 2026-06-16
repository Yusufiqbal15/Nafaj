import sys

filepath = r"c:\Users\yusuf\Downloads\stitch_nafaj_driver_dashboard\stitch_nafaj_driver_dashboard\nafaj\lib\screens\nafaj_category_grid_blinkit_style.dart"
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# Make _buildCategoryItem clickable
content = content.replace(
    'Widget _buildCategoryItem(String title, Color bgColor, String imgUrl) {',
    'Widget _buildCategoryItem(BuildContext context, String title, Color bgColor, String imgUrl) {\n    return GestureDetector(\n      onTap: () => Navigator.pushNamed(context, \'/product_feed_orange_header\'),\n      child: _buildCategoryItemContent(title, bgColor, imgUrl),\n    );\n  }\n\n  Widget _buildCategoryItemContent(String title, Color bgColor, String imgUrl) {'
)

# Add context back to calls
content = content.replace('_buildCategoryItem(', '_buildCategoryItem(context, ')

# Make _buildPromoCard clickable and add quick order
content = content.replace(
    'Widget _buildPromoCard(String title, List<Color> gradients, IconData icon, Color textColor) {',
    'Widget _buildPromoCard(BuildContext context, String title, List<Color> gradients, IconData icon, Color textColor, {String? routeName}) {\n    return GestureDetector(\n      onTap: () => Navigator.pushNamed(context, routeName ?? \'/product_feed_orange_header\'),\n      child: _buildPromoCardContent(title, gradients, icon, textColor),\n    );\n  }\n\n  Widget _buildPromoCardContent(String title, List<Color> gradients, IconData icon, Color textColor) {'
)

content = content.replace('_buildPromoCard(', '_buildPromoCard(context, ')

# Add the quick order card to the Promos list
# Original code:
#                       _buildPromoCard(
#                         'Refreshing Hibiscus\n& Local Juices',
#                         [Colors.indigo[500]!, Colors.purple[600]!],
#                         Icons.liquor_rounded,
#                         Colors.indigo[600]!,
#                       ),
#                     ],
replacement = """                      _buildPromoCard(context, 
                        'Refreshing Hibiscus\\n& Local Juices',
                        [Colors.indigo[500]!, Colors.purple[600]!],
                        Icons.liquor_rounded,
                        Colors.indigo[600]!,
                      ),
                      const SizedBox(width: 12),
                      _buildPromoCard(context, 
                        'Quick Order\\nSend Packages Now',
                        [Colors.teal[500]!, Colors.green[600]!],
                        Icons.local_shipping_rounded,
                        Colors.teal[600]!,
                        routeName: '/quick_order_package_details'
                      ),
                    ],"""

# remove the first _buildPromoCard(context... that we just added since we'll find the old one
# Let's do a regex or just simple string replace
import re
content = re.sub(
    r"_buildPromoCard\(context,\s*'Refreshing Hibiscus\\n& Local Juices',\s*\[Colors\.indigo\[500\]!,\s*Colors\.purple\[600\]!\],\s*Icons\.liquor_rounded,\s*Colors\.indigo\[600\]!,\s*\),\s*\]",
    replacement,
    content
)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated file.")
