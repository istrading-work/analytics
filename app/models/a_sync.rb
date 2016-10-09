class ASync < ApplicationRecord

  scope :last_syncs, -> {
    from(
      '(
      select * from (SELECT * FROM "a_syncs" WHERE kind = "history" order by id desc limit 1)  
      union 
      select * from (SELECT * FROM "a_syncs" WHERE kind = "orders" order by id desc limit 1)
      union 
      select * from (SELECT * FROM "a_syncs" WHERE kind = "users" order by id desc limit 1)
      union 
      select * from (SELECT * FROM "a_syncs" WHERE kind = "shops" order by id desc limit 1)
      union 
      select * from (SELECT * FROM "a_syncs" WHERE kind = "statuses" order by id desc limit 1)
      union 
      select * from (SELECT * FROM "a_syncs" WHERE kind = "status-groups" order by id desc limit 1)
      union 
      select * from (SELECT * FROM "a_syncs" WHERE kind = "delivery-types" order by id desc limit 1)
      ) "a_syncs"
    ')
  }  
end
