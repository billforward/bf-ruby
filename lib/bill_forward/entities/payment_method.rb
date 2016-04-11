module BillForward
  class PaymentMethod < MutableEntity
    @resource_path = BillForward::ResourcePath.new("payment-methods", "paymentMethod")

    class << self
      def get_by_link_id(id, query_params = {}, custom_client = nil)
        raise ArgumentError.new("id cannot be nil") if id.nil?

        endpoint = sprintf('link-id/%s',
                           ERB::Util.url_encode(id)
        )

        self.request_first('get', endpoint, query_params, custom_client)
      end

      def get_by_account_id(id, query_params = {}, custom_client = nil)
        raise ArgumentError.new("id cannot be nil") if id.nil?

        endpoint = sprintf('account/%s',
                           ERB::Util.url_encode(id)
        )

        self.request_many('get', endpoint, query_params, custom_client)
      end
    end
  end
end