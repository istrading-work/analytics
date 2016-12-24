class SyncController < ApplicationController

  def betapro
    #bs = BetaproService.new
    #@export_log = bs.export_to_betapro_by_status
    #@import_log = bs.import_to_crm
  end
  
  def export_to_betapro
    bs = BetaproService.new
    @export_log = bs.export_to_betapro_by_status
  end
  
end
