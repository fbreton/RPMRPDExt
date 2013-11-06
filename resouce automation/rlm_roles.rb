require 'yaml'
require 'script_support/rlm_utilities'

RLM_USERNAME = SS_integration_username
RLM_PASSWORD = decrypt_string_with_prefix(SS_integration_password_enc)
RLM_BASE_URL = SS_integration_dns

def execute(script_params, parent_id, offset, max_records)
	rlm_roles = RlmUtilities.get_all_roles(RLM_BASE_URL, RLM_USERNAME, RLM_PASSWORD)
	rlm_roles.unshift({"Select" => nil, "Unassigned" => "0"})
	return rlm_roles
end

def import_script_parameters
  { "render_as" => "List" }
end