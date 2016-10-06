class AddLastUpdatedAtToACrmHistory < ActiveRecord::Migration[5.0]
  def change
    add_column :a_crm_histories, :last_updated_at, :datetime
  end
end
