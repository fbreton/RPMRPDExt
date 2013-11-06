require 'yaml'
require 'script_support/rlm_utilities'

RLM_USERNAME = SS_integration_username
RLM_PASSWORD = decrypt_string_with_prefix(SS_integration_password_enc)
RLM_BASE_URL = SS_integration_dns

def execute(script_params, parent_id, offset, max_records)
	rlm_bridges = RlmUtilities.get_all_bridges(RLM_BASE_URL, RLM_USERNAME, RLM_PASSWORD)
    rlm_bridges[0].each_key {|key| rlm_bridges[0][key]="#{rlm_bridges[0][key]}|#{key}"}
	rlm_bridges.unshift({"MapFromBRPMServers" => "0|rpm{servers}"})
	return rlm_bridges
end

def import_script_parameters
  { "render_as" => "List" }
end