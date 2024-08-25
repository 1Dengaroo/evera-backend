# db/seeds.rb

products = [
  {
    name: "Washed Blue T-Shirt",
    description: "Our Every Washed T-Shirt Collection. Hand made and...",
    price: 49.99,
    active: true,
    product_type: "unisex",
    cover_image: "https://nowhereclo.com/cdn/shop/files/1_48cd4d9d-7139-467c-8701-8b183176c213.jpg?v=1718731804&width=990",
    sub_images: [
      "https://www.dropbox.com/scl/fi/zde7bhkwh43o3c71pq9hq/Untitled-1-3_ba3f0ced-1fff-44b6-8a4d-2313ea2e6aa3.webp?rlkey=yexul3cqvm18zbqrndwchl9ey&st=pjoq1r8k&raw=1",
      "https://nowhereclo.com/cdn/shop/files/Untitled-1-7.jpg?v=1718909515&width=990",
      "https://nowhereclo.com/cdn/shop/files/1_48cd4d9d-7139-467c-8701-8b183176c213.jpg?v=1718731804&width=990"
    ],
    sizes: ["XS", "S", "M", "L", "XL", "XXL"],
    quantity: 20
  },
  {
    name: "INACTIVE Washed Blue T-Shirt",
    description: "Our Every Washed T-Shirt Collection. Hand made and...",
    price: 49.99,
    active: false,
    product_type: "unisex",
    cover_image: "https://nowhereclo.com/cdn/shop/files/Untitled-1-7.jpg?v=1718909515&width=990",
    sub_images: [
      "https://www.dropbox.com/scl/fi/zde7bhkwh43o3c71pq9hq/Untitled-1-3_ba3f0ced-1fff-44b6-8a4d-2313ea2e6aa3.webp?rlkey=yexul3cqvm18zbqrndwchl9ey&st=pjoq1r8k&raw=1",
      "https://nowhereclo.com/cdn/shop/files/Untitled-1-7.jpg?v=1718909515&width=990",
      "https://nowhereclo.com/cdn/shop/files/1_48cd4d9d-7139-467c-8701-8b183176c213.jpg?v=1718731804&width=990"
    ],
    sizes: ["XS", "S", "M", "L", "XL", "XXL"],
    quantity: 20
  },
  {
    name: "INACTIVE Nowhere Baseball Hat (Black/Cream)",
    description: "The Nowhere Baseball Hat in Cream/Black, our newly...",
    price: 29.99,
    active: false,
    product_type: "unisex",
    cover_image: "https://nowhereclo.com/cdn/shop/files/1_48cd4d9d-7139-467c-8701-8b183176c213.jpg?v=1718731804&width=990",
    sub_images: [
      "https://nowhereclo.com/cdn/shop/files/Untitled-1-5-2_86d8cb9f-ebc4-4eb9-a1d6-73108de7ce63.jpg?v=1720716812&width=990",
      "https://nowhereclo.com/cdn/shop/files/Untitled-1-3-2_3.jpg?v=1722109591&width=990",
      "https://nowhereclo.com/cdn/shop/files/Untitled-1-6_69158948-e1b8-4f57-a48d-4c2a6d6580e7.jpg?v=1720716278&width=990"
    ],
    sizes: [],
    quantity: 50
  },
  {
    name: "Nowhere Baseball Hat (Black/Cream)",
    description: "The Nowhere Baseball Hat in Cream/Black, our newly...",
    price: 29.99,
    active: true,
    product_type: "unisex",
    cover_image: "https://nowhereclo.com/cdn/shop/files/Untitled-1-5-2_86d8cb9f-ebc4-4eb9-a1d6-73108de7ce63.jpg?v=1720716812&width=990",
    sub_images: [
      "https://nowhereclo.com/cdn/shop/files/Untitled-1-5-2_86d8cb9f-ebc4-4eb9-a1d6-73108de7ce63.jpg?v=1720716812&width=990",
      "https://nowhereclo.com/cdn/shop/files/Untitled-1-3-2_3.jpg?v=1722109591&width=990",
      "https://nowhereclo.com/cdn/shop/files/Untitled-1-6_69158948-e1b8-4f57-a48d-4c2a6d6580e7.jpg?v=1720716278&width=990"
    ],
    sizes: [],
    quantity: 47
  },
  {
    name: "Washed Blue T-Shirt",
    description: "Our Every Washed T-Shirt Collection. Hand made and...",
    price: 49.99,
    active: true,
    product_type: "unisex",
    cover_image: "https://www.dropbox.com/scl/fi/zde7bhkwh43o3c71pq9hq/Untitled-1-3_ba3f0ced-1fff-44b6-8a4d-2313ea2e6aa3.webp?rlkey=yexul3cqvm18zbqrndwchl9ey&st=pjoq1r8k&raw=1",
    sub_images: [
      "https://www.dropbox.com/scl/fi/zde7bhkwh43o3c71pq9hq/Untitled-1-3_ba3f0ced-1fff-44b6-8a4d-2313ea2e6aa3.webp?rlkey=yexul3cqvm18zbqrndwchl9ey&st=pjoq1r8k&raw=1",
      "https://nowhereclo.com/cdn/shop/files/Untitled-1-7.jpg?v=1718909515&width=990",
      "https://nowhereclo.com/cdn/shop/files/1_48cd4d9d-7139-467c-8701-8b183176c213.jpg?v=1718731804&width=990"
    ],
    sizes: ["XS", "S", "M", "L", "XL", "XXL"],
    quantity: 16
  }
]

products.each do |product|
  Product.create!(product)
end
