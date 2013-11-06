###
# Environment:
#   name: Environment name
#   type: in-external-single-select
#   external_resource: rlm_environments
#   position: A1:B1
#   required: yes
###

require 'yaml'
require 'script_support/rlm_utilities'

RLM_USERNAME = SS_integration_username
RLM_PASSWORD = decrypt_string_with_prefix(SS_integration_password_enc)
RLM_BASE_URL = SS_integration_dns

def execute(script_params, parent_id, offset, max_records)
	rlm_channels = RlmUtilities.get_channel_by_env(RLM_BASE_URL, RLM_USERNAME, RLM_PASSWORD,sub_tokens(script_params,script_params["Environment"].split("|")[1]))
    rlm_channels[0].each_key {|key| rlm_channels[0][key]="#{rlm_channels[0][key]}|#{key}"}
	rlm_channels.unshift({"MapFromBRPMServers" => "0|rpm{servers}"})
	return rlm_channels
end

def import_script_parameters
  { "render_as" => "List" }
end