
  class OrderRunner
    require 'json'

    def self.process_orders json_file
      # Process external data
      file = File.read(json_file)
      data = JSON.parse(file)

      # Setup env
      orders = []
      products = []
      purchase_orders = []

      # Ingest data
      json_products = data["products"]

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

      json_orders.each do |o|
        order = Order.new(id: o["orderId"], status: o["status"], items: parse_items(o["items"]), date_created: o["dateCreated"])

        orders << order
      end

      p 'Ingested Orders'
      p orders
      p 'Ingested Products'
      p products

      orders.each do |order|
        order.items.each do |item|
          product = products.detect { |p| p.id == item.product_id }
          if item.quantity <= product.quantity_on_hand 
            product.quantity_on_hand = product.quantity_on_hand - item.quantity
            order.status = 'Pending'
          else
            purchase_orders << PurchaseOrder.new(id: rand(8), status: 'Unfulfilled')
            order.status = 'Unfulfilled'
          end
        end
      end

      p 'Processed Orders'
      p orders
      p 'Processed Products'
      p products
      p 'Generated Purchase Orders'
      p purchase_orders

      return orders
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
    def initialize params
      @id = params[:id]
      @status = params[:status]
    end
  end