###
# Bridges:
#   name: Server names
#   position: A1:C1
#   type: in-external-multi-select
#   external_resource: rlm_bridges
#   required: yes
# Result:
#   name: Result create bridges
#   type: out-table
#   position: A1:F1
# 
###

begin
  require 'lib/script_support/rlm_utilities'
  require 'yaml'
  require 'uri'
  require 'active_support/all'

  params["direct_execute"] = true

  RLM_USERNAME = SS_integration_username
  RLM_PASSWORD = decrypt_string_with_prefix(SS_integration_password_enc)
  RLM_BASE_URL = SS_integration_dns

  #######################Initiate variables
  bridgename = params["Bridges"]
  target_count = 0
  table_data = [['','Result']]
  bridgename.split(",").each do |aux|
    sub_tokens(params,aux.split("|")[1]).split(",").collect{|s| s.strip}.each do |bridge|
      result = RlmUtilities.delete_bridge(RLM_BASE_URL, RLM_USERNAME, RLM_PASSWORD, bridge)
      table_data << ['',result[0]["value"]]
      target_count = target_count + 1
    end
  end
  pack_response "Result", {:totalItems => target_count, :perPage => '10', :data => table_data }
	
rescue Exception => e
	write_to("Operation failed: #{e.message}, Backtrace:\n#{e.backtrace.inspect}")
end