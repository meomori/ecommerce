class CartController < ApplicationController
  
  before_action :authenticate_user!, except: [:add_to_cart, :view_order]
  
  

        
  def add_to_cart

  	#brings over one record of our line item table
			line_item = LineItem.where(product_id: params[:product_id].to_i).first

		#An object is blank if it’s false, empty, or a whitespace string. For example, false, ”, ‘ ’, nil, [], and {} are all blank.	So, if not records are returned, we will create a new record.  Otherwise, we only update
			if line_item.blank? 

		  	line_item = LineItem.create(product_id: params[:product_id].to_i, quantity: params[:quantity].to_i)
		  	line_item.update(line_item_total: line_item.quantity * line_item.product.price)
		  else
		  
		  	new_quantity = line_item.quantity + params[:quantity].to_i
		  	line_item.update(quantity: new_quantity) 

		  	#can't update line_item_total until after committing the update to quantity
		  	line_item.update(line_item_total: line_item.quantity * line_item.product.price)
	  	end	

  	redirect_back(fallback_location: root_path)
  end

  def view_order
    @line_items = LineItem.all
    @cart_total = 0
    
    @line_items.each do |item|
      @cart_total += item.line_item_total
    end
  end

  def checkout
    line_items = LineItem.all
    @order = Order.create(user_id: current_user.id, subtotal: 0)

    line_items.each do |line_item|
      line_item.product.update(quantity: (line_item.product.quantity - line_item.quantity))
      @order.order_items[line_item.product_id] = line_item.quantity 
      @order.subtotal += line_item.line_item_total
    end
    @order.save

    @order.update(sales_tax: (@order.subtotal * 0.08))
    @order.update(grand_total: (@order.sales_tax + @order.subtotal))

    line_items.destroy_all
  end
  
  def order_complete
    @order = Order.find(params[:order_id])
    @amount = (@order.grand_total.to_f.round(2) * 100).to_i

    customer = Stripe::Customer.create(
      :email => current_user.email,
      :card => params[:stripeToken]
    )

    charge = Stripe::Charge.create(
      :customer => customer.id,
      :amount => @amount,
      :description => 'Rails Stripe customer',
      :currency => 'usd'
    )

    rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to cart_path
  end
end
