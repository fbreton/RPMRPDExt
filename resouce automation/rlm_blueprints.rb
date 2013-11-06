require 'yaml'
require 'script_support/rlm_utilities'

RLM_USERNAME = SS_integration_username
RLM_PASSWORD = decrypt_string_with_prefix(SS_integration_password_enc)
RLM_BASE_URL = SS_integration_dns

def execute(script_params, parent_id, offset, max_records)
    rlm_blueprints = RlmUtilities.get_all_blueprints(RLM_BASE_URL, RLM_USERNAME, RLM_PASSWORD)
    rlm_blueprints[0].each_key {|key| rlm_blueprints[0][key]="#{rlm_blueprints[0][key]}|#{key}"}
    rlm_blueprints.unshift({"Select" => nil, "MapFromBRPMblueprint" => "0|rpm{blueprint}"})
    return rlm_blueprints
end

def import_script_parameters
  { "render_as" => "List" }
end