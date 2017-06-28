def consolidate_cart(cart)
  consolidate_cart_items = {}

  cart.each do |cart_item|
    count = 1
    cart_item.each do |item_name, item_attributes|
      if consolidate_cart_items.key?(item_name) && consolidate_cart_items[item_name].key?(:count)
        consolidate_cart_items[item_name][:count] += 1
      else
        consolidate_cart_items[item_name] = item_attributes
        consolidate_cart_items[item_name][:count] = count
      end
    end
  end

  consolidate_cart_items
end

def apply_coupons(cart, coupons)
  item_coupons = {}
  coupons.each do |coupon|
    item_name = coupon[:item]

    item_coupons[item_name] = {count: 0} unless item_coupons.key?(item_name)
    item_coupons[item_name][:count] += 1

    if cart.key?(item_name) && cart[item_name][:count] >= coupon[:num]
      item_count = cart[item_name][:count] - coupon[:num]

      discount_item_name = "#{item_name} W/COUPON"
      cart[discount_item_name] = {
        :price => coupon[:cost],
        :count => item_coupons[item_name][:count],
        :clearance => cart[item_name][:clearance]
      }

      cart[item_name][:count] = item_count
    end
  end
  cart
end

def apply_clearance(cart)
  cart.collect do |item_name, item_attributes|
    if item_attributes[:clearance]
      item_attributes[:price] *= 0.8
      item_attributes[:price] = item_attributes[:price].round(2)
    end
  end
  cart
end

def checkout(cart, coupons)
  cart = consolidate_cart(cart)
  cart = apply_coupons(cart, coupons)
  cart = apply_clearance(cart)

  total_price_cart = {}

  cart.each do |item_name, item_attributes|
    total_price_cart[item_name] = item_attributes[:price] * item_attributes[:count]
  end

  total_price_cart = total_price_cart.values.reduce(:+)
  if total_price_cart > 100
    total_price_cart *= 0.9
  end

  total_price_cart.round(2)
end
