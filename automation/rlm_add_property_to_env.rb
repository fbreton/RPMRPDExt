###
# Environment:
#   name: Environment name
#   type: in-external-single-select
#   external_resource: rlm_environments
#   position: A1:B1
#   required: yes
# Property:
#   name: Property name
#   position: E1:F1
#   type: in-external-single-select
#   external_resource: rlm_environment_properties
#   required: yes
# Value:
#   name: Property value
#   position: A3:F3
#   type: in-text
#   required: yes
# Result:
#   name: Result create channel
#   type: out-text
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
  property = params["Property"].split("|")[1]
  env = params["Environment"].split("|")[1]
  value = sub_tokens(params,params["Value"])

  result = RlmUtilities.add_property_to_env(RLM_BASE_URL, RLM_USERNAME, RLM_PASSWORD, env, property, value)[0]["value"]
  pack_response "Result", result
	
rescue Exception => e
	write_to("Operation failed: #{e.message}, Backtrace:\n#{e.backtrace.inspect}")
end