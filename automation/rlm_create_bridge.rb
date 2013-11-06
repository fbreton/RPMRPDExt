###
# Bridge:
#   name: Server name
#   position: A1:B1
#   type: in-text
#   required: yes
# OS:
#   name: Operating system
#   type: in-list-single
#   list_pairs: 0,Unix|1,Windows
#   position: E1:F1
#   required: yes
# Agent:
#   name: Agent name
#   type: in-list-single
#   list_pairs: 0,nsh|1,puppet|2,chef|3,ssh
#   position: A3:B3
#   required: yes
# AgentServer:
#   name: Agent server name
#   type: in-text
#   position: E3:F3
#   required: yes
# Role:
#   name: Role Name
#   position: A5:E5
#   type: in-external-single-select
#   external_resource: rlm_roles
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
  bridgename = sub_tokens(params,params["Bridge"]).split(",").collect{|s| s.strip}
  agentserver = params["AgentServer"]
  roleid = params["Role"].to_i
  osname = params["OS"]
  agent=params["Agent"]
  table_data = [['','Result']]
  target_count = 0
  bridgename.each do |aux|
    result = RlmUtilities.create_bridge(RLM_BASE_URL, RLM_USERNAME, RLM_PASSWORD, aux, roleid, agent, agentserver, osname)
    table_data << ['',result[0]["value"]]
    target_count = target_count + 1
  end
  pack_response "Result", {:totalItems => target_count, :perPage => '10', :data => table_data }
	
rescue Exception => e
	write_to("Operation failed: #{e.message}, Backtrace:\n#{e.backtrace.inspect}")
end