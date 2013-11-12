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
	result = RlmUtilities.get_all_env_properties(RLM_BASE_URL, RLM_USERNAME, RLM_PASSWORD,sub_tokens(script_params,script_params["Environment"].split("|")[1]))
    rlm_properties = {"Select" => ""}
    result[0].each {|key,value| rlm_properties[key.split("=")[0]] = "#{value}|#{key.split("=")[0]}"}
    return [rlm_properties]
end

def import_script_parameters
  { "render_as" => "List" }
end