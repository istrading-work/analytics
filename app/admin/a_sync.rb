ActiveAdmin.register ASync do

  actions :index, :destroy
  
  index do |el|
    selectable_column
    column 'Тип', :kind
    column 'Статус', :resolution do |s|
      if s.done 
        s.status ? status_tag('OK', :yes) : status_tag('BAD', :no) 
      else
        (Time.now - s.updated_at) > 60 ? status_tag('BAD', :no) : status_tag('In Progress')
      end
    end
    column 'Прогресс', :p do |s|
      s.total_pages  ? (100* s.page / s.total_pages).round(0).to_s + '%' : (s.total_orders ? (100* s.order_index / s.total_orders).round(0).to_s + '%' : s.status ? '100%': '')
            
    end
    column 'Старт', :created_at
    column 'Стоп', :updated_at
    column 'Обновлений', :total_changed
    actions
  end

  filter :kind
  filter :created_at, label: 'Start', as: :date_range
  
  scope :all
  scope :last_syncs, default: true
  
end
