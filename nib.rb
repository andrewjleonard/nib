
  class OrderRunner
    require 'json'

    def self.process_orders json_file
      # Process external data
      file = File.read(json_file)
      data = JSON.parse(file)

      # Ingest data
      json_products = data["products"]

      products = []

      json_products.each do |p|
        product = Product.new()
        product.id = p["productId"]        
        product.description = p["description"]
        product.quantity_on_hand = p["quantityOnHand"]
        product.reorder_threshold = p["reorderThreshold"]
        product.reorder_amount = p["reorderAmount"]
        product.delivery_lead_time = p["deliveryLeadTime"]

        products << product
      end


      json_orders = data["orders"]

      orders = []

      json_orders.each do |o|
        order = Order.new(id: o["orderId"], status: o["status"], items: parse_items(o["items"]), date_created: o["dateCreated"])

        orders << order
      end
      p 'Ingested Orders'
      p orders
      p 'Ingested Products'
      p products

      # loop through orders
      #   loop through items for order
      #     find the item product in the products array
      #     if order item quantity < available product quantity
      #       update available product quantity ready for next iteration
      #       set order status ‘Fulfilled’
      #     else
      #       PurchaseOrder.new()
      #       set order status ‘Unfulfilled’
      #     end
      #   end
      # end

      # return orders

    end
    def self.parse_items json_items
      json_items.map{ |ji| Item.new({order_id: ji["orderId"], product_id: ji["productId"], quantity: ji["quantity"], cost_per_item: ji["costPerItem"]})}
    end
  end

  class Order
    attr_accessor :id, :date_created, :status, :items
    def initialize params
      @id = params[:id]
      @status = params[:status]
      @items = params[:items]
      @date_created = params[:date_created]
    end
  end

  class Item
    attr_accessor :product_id, :order_id, :quantity, :cost_per_item
    def initialize params
      @cost_per_item = params[:cost_per_item]
      @quantity = params[:quantity]
      @order_id = params[:order_id]
      @product_id = params[:product_id]
    end
  end

  class Product
    attr_accessor :id, :status, :description, :quantity_on_hand, :reorder_threshold, :reorder_amount, :delivery_lead_time
  end

  class PurchaseOrder
    attr_accessor :id, :status
  end


