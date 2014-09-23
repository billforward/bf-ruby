module BillForward
  # This entity exposes the following child entities via method_missing:
  # 
  # InvoiceLine[]     .invoiceLines
  # TaxLine[]         .taxLines
  # InvoicePayment[]  .invoicePayments
  class Invoice < MutableEntity
  	@resource_path = BillForward::ResourcePath.new('invoices', 'invoice')

    class << self
      def create(entity = nil)
        raise DenyMethod.new 'Create support is denied for this entity; '+
          'Invoices are generated instead by the BillForward Engines.'
      end
    end

  protected
    def unserialize_all(hash)
      super
      unserialize_array_of_entities('invoiceLines', InvoiceLine, hash)
      unserialize_array_of_entities('taxLines', TaxLine, hash)
      unserialize_array_of_entities('invoicePayments', InvoicePayment, hash)
    end
  end
end