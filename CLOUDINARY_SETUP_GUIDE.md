# Cloudinary Image Setup Guide for Vendors

## 📸 How to Add Product Images Using Cloudinary

### Step 1: Get Cloudinary Account
1. Go to [cloudinary.com](https://cloudinary.com)
2. Sign up for a free account
3. Login to your dashboard

### Step 2: Upload Images to Cloudinary
1. Click "Media Library" in Cloudinary dashboard
2. Click "Upload" button
3. Select your product images
4. Wait for upload to complete

### Step 3: Get Image URLs
1. Click on an uploaded image
2. Look for the "URL" field
3. Copy the full URL (example: `https://res.cloudinary.com/your-cloud/image/upload/v1234567890/product1.jpg`)
4. Repeat for multiple images (you can add up to 3 images per product)

### Step 4: Add Product in Vendor Dashboard
1. Open your Vendor Dashboard
2. Go to "Products" tab
3. Click "+ Add Product" button
4. Fill in the form:
   ```
   Image URL 1: https://res.cloudinary.com/your-cloud/image/upload/v123/product-main.jpg
   Image URL 2: https://res.cloudinary.com/your-cloud/image/upload/v123/product-side.jpg (optional)
   Image URL 3: https://res.cloudinary.com/your-cloud/image/upload/v123/product-back.jpg (optional)
   
   Product Name: Chicken Shawarma
   Description: Delicious grilled chicken with tahini sauce
   Price: 1200
   Stock Quantity: 50
   Category: Food
   Unit: piece
   Discount Price: 1000 (optional)
   ```
5. Click "Add Product"
6. Your product will appear in the list with images!

## 🎯 Tips for Best Results

### Image Requirements:
- **Format**: JPG, PNG, WebP
- **Size**: Recommended 800x800px or larger
- **Aspect Ratio**: Square (1:1) works best
- **File Size**: Under 2MB for faster loading

### Cloudinary URL Format:
✅ **Correct URLs:**
```
https://res.cloudinary.com/demo/image/upload/sample.jpg
https://res.cloudinary.com/your-cloud/image/upload/v1234567890/products/shawarma.jpg
```

❌ **Incorrect URLs:**
```
C:/Users/Pictures/image.jpg  (local path - won't work)
www.example.com/image.jpg    (missing https://)
```

## 🔥 Quick Cloudinary Tips

### Optimize Images Automatically
Cloudinary URLs support transformations. You can optimize images by modifying the URL:

**Original:**
```
https://res.cloudinary.com/demo/image/upload/sample.jpg
```

**Optimized (auto quality, 600px width):**
```
https://res.cloudinary.com/demo/image/upload/w_600,q_auto/sample.jpg
```

### Free Tier Limits
- **Storage**: 25 GB
- **Bandwidth**: 25 GB/month
- **Transformations**: 25,000/month

Perfect for small to medium-sized vendor stores!

## 📱 Image Display in App

Your product images will appear in:
1. ✅ Products list (vendor dashboard)
2. ✅ Product details page
3. ✅ Customer home feed
4. ✅ Category product listings
5. ✅ Cart items

## 🆘 Troubleshooting

### Image Not Showing?
- ✅ Check URL is HTTPS (not HTTP)
- ✅ Verify URL starts with `https://res.cloudinary.com/`
- ✅ Make sure image is public in Cloudinary
- ✅ Try opening URL in browser to test

### Slow Loading?
- ✅ Use Cloudinary's automatic optimization: `q_auto`
- ✅ Resize images: add `w_600` to URL
- ✅ Compress before upload

### Need Multiple Images?
- ✅ Upload all images to Cloudinary first
- ✅ Copy each URL
- ✅ Paste in Image URL 1, 2, and 3 fields
- ✅ You can use 1, 2, or all 3 fields

## 🎨 Example Product with 3 Images

```
Product: Premium Chicken Shawarma
Image 1: https://res.cloudinary.com/mystore/image/upload/v123/shawarma-front.jpg
Image 2: https://res.cloudinary.com/mystore/image/upload/v123/shawarma-side.jpg
Image 3: https://res.cloudinary.com/mystore/image/upload/v123/shawarma-plate.jpg
Price: 1500 SDG
Stock: 100
```

Result: Customers see a gallery of 3 images when viewing your product!

## 📞 Support

If you need help:
1. Contact app support from Profile > Support
2. Share your Cloudinary URL for troubleshooting
3. Check VENDOR_DASHBOARD_UPDATES.md for technical details
