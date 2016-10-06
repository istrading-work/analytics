# encoding: utf-8

AStatusLink.delete_all
AStatusGroup.delete_all

a_status_groups = [
  { "id": 1, "name": "Холд"    },
  { "id": 2, "name": "Принят"  },
  { "id": 3, "name": "В пути"  },
  { "id": 4, "name": "В ПО"    },
  { "id": 5, "name": "Выкуплен"},
  { "id": 6, "name": "Оплачен" },
  { "id": 7, "name": "Отмена"  },
  { "id": 8, "name": "Возврат" }
]

a_status_links = [
  # Холд
  [ 1, "reprisa-0" ],       [ 1, "processing" ],     [ 1, "order-in-work" ], [ 1, "correct" ], [ 1, "no-call" ], [ 1, "reprisa-11" ],
  [ 1, "client-thinks" ],   [ 1, "not-responding" ], [ 1, "no-answer" ],     [ 1, "validation-before-sending" ],
  
  # Принят
  [ 2, "kompliektatsiia" ], [ 2, "reprisa-5" ],      [ 2, "reprisa-10" ],    [ 2, "assembled" ], [ 2, "reworker-5" ],
  [ 2, "reworker-1" ],      [ 2, "reworker-2" ],     [ 2, "reworker-15" ],   [ 2, "reworker-3" ],
  [ 2, "reworker-4" ],      [ 2, "complete-order" ],
  
  # В пути
  [ 3, "reworker-7" ],      [ 3, "reworker-6" ],
  
  # В ПО
  [ 4, "reworker-8" ], [ 4, "niedozvon-pri-obzvonie-na-vykup"], [ 4, "pieriezvonit-pozzhie" ], [ 4, "uzhie-vykupili" ],
  
  # Выкуплен
  [ 5, "reworker-9" ],
  
  # Оплачен
  [ 6, "reworker-10" ],
  
  # Отмена
  [ 7, "reworker-11" ], [ 7, "cancel-at-registration" ], [ 7, "cancel-after-complete" ],
  
  # Возврат
  [ 8, "reworker-12" ], [ 8, "reworker-13" ], [ 8, "reworker-17" ], [ 8, "otkaz-ot-vykupa" ]
]

a_status_groups.each { |item| AStatusGroup.create( item ) }
a_status_links.each  { |item|  AStatusLink.create( :a_status_group_id => item[0], :a_crm_status_id => item[1] ) }

puts "Success: analytics status group data loaded"