# == Schema Information
#
# Table name: a_crm_users
#
#  id         :integer          not null, primary key
#  first_name :string
#  last_name  :string
#  email      :string
#  is_manager :boolean
#  is_active  :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ACrmUser < ApplicationRecord
  self.primary_key = 'id'
  
  has_many :a_crm_orders
  
  def name
    "#{last_name} #{first_name}"
  end
  
  scope :active, -> { where( :is_active => true) }

  #scope :active_managers, -> { where( :is_active => true, :is_manager => true, :email => '<> "ksenia@istrading.ru"'  ) }
  scope :active_managers, -> { where('is_active="t"  AND is_manager="t" AND email <> "ksenia@istrading.ru"') }
  
  def self.rate(p_date1, p_date2)
    st_ave = ACrmOrder.rate(p_date1, p_date2)
    h = {}
    kf={}
    active_managers.each do |m|
      st = m.a_crm_orders.rate(p_date1, p_date2)
      kf[m.name]={}
      st.each do |k,v|
        ka=ka2=kb=0
        ka  = ((v['ap']+0.0)/st_ave[k]['ap'])    if st_ave[k]['ap']>0
        ka2 = ((v['a2p']+0.0)/st_ave[k]['a2p'])  if st_ave[k]['a2p']>0
        kb  = ((v['bp']+0.0)/st_ave[k]['bp'])    if st_ave[k]['bp']>0
        kb=1 if kb==0

        bch = v['ch']
        if v['bch_prev']>0
          bch = v['bch_prev']
        elsif v['bch']>0
          bch = v['bch']
        end
        ch = (v['ch']+bch)/2
        
        km = ka*ka2*kb
        
        tc = v['total_count']
        ac = v['approve_count']
        
        km_max = 1 + ac*0.1
        km = km_max if km>km_max        
       
        koeff = 1
        z_max = 200
        
        if k == 'Бриджи Hot Shapers'
          koeff = 1.7
        elsif k == 'Пояс Hot Shaper'
          koeff = 1.5
        elsif k == 'Золотые цепочки'
          koeff = 1.3
        elsif k == 'Золотые цепочки (женские)'
          koeff = 1
        elsif k == 'Red Diamond'
          koeff = 1.5
        elsif k == 'Gelmifort'
          koeff = 1.4
        elsif k == 'Айфоны'
          koeff = 0.5
          z_max = 135
        elsif k == 'Айфоны 7'
          koeff = 0.5
          z_max = 135
        elsif k == 'Мон. чай - от курения'
          koeff = 1.6
        end
        
        koeff = (koeff+0.0) / 100
        
        z = 50+koeff*(v['ch']+bch)/2 * km  
        z = z_max if z>z_max
        z = z.round(0)
        
        kf[m.name][k]=[ tc, ka, ka2, kb, km, ac*km, tc*km*z, ac]
      end
    end

    kf.each do |k,v|
      s1 = s2 = 0
      v.each do |k2, v2|
        s1 += v2[0]
        s2 += v2[6]
      end
      s1>0 ? r = (s2+0.0)/s1 : r=0
      r = r.round(0)
      h[k] = r if r>0
    end
    h = h.sort_by {|k,v| v}.reverse
    
    base = h[0][1]

    h2 = []
    h.each do |v|
     b1 = (100*(v[1]+0.0)/base).round(0)
     b2 = b1/10 + 1
     b2=10 if b2==11
     h2.push [ v[0], b1, b2 ]
    end
    h2
  end
  
end
