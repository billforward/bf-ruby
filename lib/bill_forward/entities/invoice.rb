module BillForward
  # This entity exposes the following child entities via method_missing:
  # 
  # InvoiceLine[]         .invoiceLines
  # TaxLine[]             .taxLines
  # InvoicePayment[]      .invoicePayments
  # Refund[]              .invoiceRefunds
  # CreditNote[]          .invoiceCreditNotes
  # SubscriptionCharge[]  .charges
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
      unserialize_array_of_entities('invoiceRefunds', Refund, hash)
      unserialize_array_of_entities('invoiceCreditNotes', CreditNote, hash)
      unserialize_array_of_entities('charges', SubscriptionCharge, hash)
    end
  end
end