###
# Package:
#   name: RLM Package
#   position: A1:F1
#   type: in-external-single-select
#   external_resource: rlm_packages
#   required: yes
###

require 'yaml'
require 'script_support/rlm_utilities'

RLM_USERNAME = SS_integration_username
RLM_PASSWORD = decrypt_string_with_prefix(SS_integration_password_enc)
RLM_BASE_URL = SS_integration_dns

def execute(script_params, parent_id, offset, max_records)
	package_id = script_params["Package"].split("|")[0]
	rlm_package_properties = RlmUtilities.get_package_properties( RLM_BASE_URL, RLM_USERNAME, RLM_PASSWORD, package_id)
	return rlm_package_properties
end

def import_script_parameters
  { "render_as" => "Table" }
end