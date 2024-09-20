class CreatePollingStatuses < ActiveRecord::Migration[7.0]
  def change
    create_table :polling_statuses do |t|
      t.string :usage_worker_checked_identifier
      t.timestamps
    end
  end
end
