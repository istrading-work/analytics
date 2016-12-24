=begin
def get_address(index)
  uri = URI.parse("https://www.pochta.ru/portal-portlet/delegate/postoffice-api/method/offices.find.byCode?postalCode=#{index}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)
  data = JSON.parse(response.body)
  data['office']['addressSource']
end
=end

=begin
    request = 
      '<?xml version="1.0" encoding="UTF-8"?>
      <soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:oper="http://russianpost.org/operationhistory" xmlns:data="http://russianpost.org/operationhistory/data" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
        <soap:Header/>
        <soap:Body>
           <oper:getOperationHistory>
              <data:OperationHistoryRequest>
                 <data:Barcode>14084006734100</data:Barcode>  
                 <data:MessageType>0</data:MessageType>
                 <data:Language>RUS</data:Language>
              </data:OperationHistoryRequest>
              <data:AuthorizationHeader soapenv:mustUnderstand="1">
                 <data:login>otTpioIEGKraEy</data:login>
                 <data:password>Bc4OsLIWTl2T</data:password>
              </data:AuthorizationHeader>
           </oper:getOperationHistory>
        </soap:Body>
      </soap:Envelope>'

    client = Savon.client do
      wsdl "https://tracking.russianpost.ru/tracking-web-static/rtm34_wsdl.xml"
      endpoint "https://tracking.russianpost.ru/rtm34"
      soap_version 2
    end
          
    response = client.call(:get_operation_history, xml: request)
    history = response.body[:get_operation_history_response][:operation_history_data][:history_record]
    history.each do |h|
      dest_address = h[:address_parameters][:destination_address]
      oper_address = h[:address_parameters][:operation_address]
      operation = h[:operation_parameters]
      puts dest_address, oper_address, operation
      puts "------------------"
    end
  #puts get_address(308011)
=end