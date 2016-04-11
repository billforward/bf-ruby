module BillForward
  class Refund < MutableEntity
    @resource_path = BillForward::ResourcePath.new("refunds", "refund")

    class << self
      def get_by_invoice_id(id, query_params = {}, custom_client = nil)
        raise ArgumentError.new("id cannot be nil") if id.nil?

        endpoint = sprintf('invoice/%s',
                           ERB::Util.url_encode(id)
        )

        self.request_many('get', endpoint, query_params, custom_client)
      end
    end
  end
end