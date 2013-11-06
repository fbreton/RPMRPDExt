###
# Environment:
#   name: Environment name
#   type: in-external-single-select
#   external_resource: rlm_environments
#   position: A1:B1
#   required: yes
# Channel:
#   name: Channel name
#   position: E1:F1
#   type: in-external-multi-select
#   external_resource: rlm_environment_channels
#   required: yes
# Result:
#   name: Result delete channel
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
  channelname = params["Channel"].split(",")
  env = params["Environment"].split("|")[1]

  table_data = [['','Result']]
  target_count = 0
  channelname.each do |aux|
    sub_tokens(params,aux.split("|")[1]).split(",").collect{|s| s.strip}.each do |channel|
      result = RlmUtilities.delete_channel_from_env(RLM_BASE_URL, RLM_USERNAME, RLM_PASSWORD, env, channel)
      result = RlmUtilities.delete_channel(RLM_BASE_URL, RLM_USERNAME, RLM_PASSWORD, channel)
      table_data << ['',result[0]["value"]]
      target_count = target_count + 1
    end
  end
  pack_response "Result", {:totalItems => target_count, :perPage => '10', :data => table_data }
	
rescue Exception => e
	write_to("Operation failed: #{e.message}, Backtrace:\n#{e.backtrace.inspect}")
end