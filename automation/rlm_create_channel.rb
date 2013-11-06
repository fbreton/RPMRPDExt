###
# Channel:
#   name: Channel name
#   position: A1:B1
#   type: in-text
#   required: yes
# Bridge:
#   name: Server name
#   position: E1:F1
#   type: in-external-single-select
#   external_resource: rlm_bridges
#   required: yes
# Blueprint:
#   name: Blueprint name
#   type: in-external-single-select
#   external_resource: rlm_blueprints
#   position: A3:B3
#   required: yes
# Environment:
#   name: Environment name
#   type: in-external-single-select
#   external_resource: rlm_environments
#   position: E3:F3
#   required: yes
# Result:
#   name: Result create channel
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
  bridgename = sub_tokens(params,params["Bridge"].split("|")[1]).split(",").collect{|s| s.strip}
  channelname = sub_tokens(params,params["Channel"]).split("|")
  if channelname.length > 1
    channelname = channelname[1].split(",").collect{|s| s.strip}
  else
   channelname = channelname[0].split(",").collect{|s| s.strip}
  end
  env = params["Environment"].split("|")[1]
  blueprint = sub_tokens(params,params["Blueprint"].split("|")[1])

  table_data = [['','Result']]
  target_count = 0
  bridgename.each do |aux|
    result = RlmUtilities.create_channel(RLM_BASE_URL, RLM_USERNAME, RLM_PASSWORD, blueprint, aux, channelname[target_count])
    table_data << ['',result[0]["value"]]
    result = RlmUtilities.add_channel_to_env(RLM_BASE_URL, RLM_USERNAME, RLM_PASSWORD, env, channelname[target_count])
    target_count = target_count + 1
  end
  pack_response "Result", {:totalItems => target_count, :perPage => '10', :data => table_data }
	
rescue Exception => e
	write_to("Operation failed: #{e.message}, Backtrace:\n#{e.backtrace.inspect}")
end