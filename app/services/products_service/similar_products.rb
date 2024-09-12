# frozen_string_literal: true

module ProductsService
  class SimilarProducts
    def self.call(product)
      active_products = Product.where(active: true).where.not(id: product.id)
      
      lcs_scores = active_products.map do |other_product|
        {
          product: other_product,
          lcs_score: longest_common_subsequence(product.name, other_product.name)
        }
      end

      top_similar_products = lcs_scores.sort_by { |p| -p[:lcs_score] }.first(4)
      top_similar_products.map { |entry| entry[:product] }
    end

    def self.longest_common_subsequence(str1, str2)
      m = str1.length
      n = str2.length

      dp = Array.new(m + 1) { Array.new(n + 1, 0) }

      (1..m).each do |i|
        (1..n).each do |j|
          if str1[i - 1] == str2[j - 1]
            dp[i][j] = dp[i - 1][j - 1] + 1
          else
            dp[i][j] = [dp[i - 1][j], dp[i][j - 1]].max
          end
        end
      end

      dp[m][n]
    end
  end
end
