# frozen_string_literal: true

products = [
  {
    name: 'New Venture Short-Sleeve Knit Polo Shirt',
    description: 'Effortlessly elevated. Made of soft, naturally thermoregulating merino wool, this knit polo delivers a polished look that is always on point.',
    price: 118.00,
    active: true,
    product_type: 'unisex',
    cover_image: 'https://images.lululemon.com/is/image/lululemon/LM3FCJS_032489_1?$product_tile$&wid=750&op_usm=0.8,1,10,0&fmt=webp&qlt=80,1&fit=constrain,0&op_sharpen=0&resMode=sharp2&iccEmbed=0&printRes=72',
    sub_images: [
      'https://images.lululemon.com/is/image/lululemon/LM3FCJS_032489_2?wid=1600&op_usm=0.5,2,10,0&fmt=webp&qlt=80,1&fit=constrain,0&op_sharpen=0&resMode=sharp2&iccEmbed=0&printRes=72',
      'https://images.lululemon.com/is/image/lululemon/LM3FCJS_032489_3?wid=1600&op_usm=0.5,2,10,0&fmt=webp&qlt=80,1&fit=constrain,0&op_sharpen=0&resMode=sharp2&iccEmbed=0&printRes=72',
      'https://images.lululemon.com/is/image/lululemon/LM3FCJS_032489_4?wid=1600&op_usm=0.5,2,10,0&fmt=webp&qlt=80,1&fit=constrain,0&op_sharpen=0&resMode=sharp2&iccEmbed=0&printRes=72'
    ],
    sizes: %w[XS S M L XL XXL],
    quantity: 9999
  },
  {
    name: 'Nowhere Baseball Hat (Black/Cream)',
    description: 'The Nowhere Baseball Hat in Cream/Black, our newly...',
    price: 29.99,
    active: true,
    product_type: 'unisex',
    cover_image: 'https://nowhereclo.com/cdn/shop/files/Untitled-1-5-2_86d8cb9f-ebc4-4eb9-a1d6-73108de7ce63.jpg?v=1720716812&width=990',
    sub_images: [
      'https://nowhereclo.com/cdn/shop/files/Untitled-1-5-2_86d8cb9f-ebc4-4eb9-a1d6-73108de7ce63.jpg?v=1720716812&width=990',
      'https://nowhereclo.com/cdn/shop/files/Untitled-1-3-2_3.jpg?v=1722109591&width=990',
      'https://nowhereclo.com/cdn/shop/files/Untitled-1-6_69158948-e1b8-4f57-a48d-4c2a6d6580e7.jpg?v=1720716278&width=990'
    ],
    sizes: [],
    quantity: 9999
  },
  {
    name: 'Washed Blue T-Shirt',
    description: 'Our Every Washed T-Shirt Collection. Hand made and...',
    price: 49.99,
    active: true,
    product_type: 'unisex',
    cover_image: 'https://nowhereclo.com/cdn/shop/files/1_48cd4d9d-7139-467c-8701-8b183176c213.jpg?v=1718731804&width=990',
    sub_images: [
      'https://nowhereclo.com/cdn/shop/files/1_48cd4d9d-7139-467c-8701-8b183176c213.jpg?v=1718731804&width=990',
      'https://nowhereclo.com/cdn/shop/files/Untitled-1-7.jpg?v=1718909515&width=990',
      'https://nowhereclo.com/cdn/shop/files/1_48cd4d9d-7139-467c-8701-8b183176c213.jpg?v=1718731804&width=990'
    ],
    sizes: %w[XS S M L XL XXL],
    quantity: 9999
  },
  {
    name: 'New Venture Classic-Fit Long-Sleeve Shirt',
    description: 'This shirts destination? Wherever youre going. Stretchy, easy-care fabric on this commute-friendly button-up helps you arrive ready for anything.',
    price: 118.00,
    active: true,
    product_type: 'unisex',
    cover_image: 'https://images.lululemon.com/is/image/lululemon/LM3FCJS_032489_1?$product_tile$&wid=750&op_usm=0.8,1,10,0&fmt=webp&qlt=80,1&fit=constrain,0&op_sharpen=0&resMode=sharp2&iccEmbed=0&printRes=72',
    sub_images: [
      'https://images.lululemon.com/is/image/lululemon/LM3EI9S_067789_2?wid=1600&op_usm=0.5,2,10,0&fmt=webp&qlt=80,1&fit=constrain,0&op_sharpen=0&resMode=sharp2&iccEmbed=0&printRes=72',
      'https://images.lululemon.com/is/image/lululemon/LM3EI9S_067789_3?wid=1600&op_usm=0.5,2,10,0&fmt=webp&qlt=80,1&fit=constrain,0&op_sharpen=0&resMode=sharp2&iccEmbed=0&printRes=72',
      'https://images.lululemon.com/is/image/lululemon/LM3EI9S_067789_4?wid=1600&op_usm=0.5,2,10,0&fmt=webp&qlt=80,1&fit=constrain,0&op_sharpen=0&resMode=sharp2&iccEmbed=0&printRes=72'
    ],
    sizes: %w[XS S M L XL XXL],
    quantity: 9999
  },
  {
    name: 'Commission Long-Sleeve Shirt',
    description: 'Inspired by everyday adventure, this easy-care and classic-fit shirt is made for all-day comfort.',
    price: 118.00,
    active: true,
    product_type: 'unisex',
    cover_image: 'https://images.lululemon.com/is/image/lululemon/LM3FPCS_066848_1?wid=1600&op_usm=0.5,2,10,0&fmt=webp&qlt=80,1&fit=constrain,0&op_sharpen=0&resMode=sharp2&iccEmbed=0&printRes=72',
    sub_images: [
      'https://images.lululemon.com/is/image/lululemon/LM3FPCS_066848_2?wid=1600&op_usm=0.5,2,10,0&fmt=webp&qlt=80,1&fit=constrain,0&op_sharpen=0&resMode=sharp2&iccEmbed=0&printRes=72',
      'https://images.lululemon.com/is/image/lululemon/LM3FPCS_066848_3?wid=1600&op_usm=0.5,2,10,0&fmt=webp&qlt=80,1&fit=constrain,0&op_sharpen=0&resMode=sharp2&iccEmbed=0&printRes=72',
      'https://images.lululemon.com/is/image/lululemon/LM3FPCS_066848_4?wid=1600&op_usm=0.5,2,10,0&fmt=webp&qlt=80,1&fit=constrain,0&op_sharpen=0&resMode=sharp2&iccEmbed=0&printRes=72'
    ],
    sizes: %w[XS S M L XL XXL],
    quantity: 9999
  }
]

products.each do |product|
  Product.create!(product)
end
