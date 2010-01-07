class CreateInvoices < ActiveRecord::Migration
  def self.up
    create_table :invoices do |t|
      t.decimal :amount, :scale => 2
      t.string :description
      t.datetime :paid_at
      t.string :auth_code
      t.string :gateway_txn_id
      t.string :error_message

      t.timestamps
    end
  end

  def self.down
    drop_table :invoices
  end
end
