###
# Package:
#   name: RLM Package
#   position: A1:B1
#   type: in-external-single-select
#   external_resource: rlm_packages
#   required: yes
# Locked:
#   name: Lock instances to prevent changes
#   type: in-list-single
#   list_pairs: 0,No|1,Yes|
#   position: E1:F1
#   required: yes
# Contents:
#   name: Package references
#   type: in-external-single-select
#   external_resource: rlm_package_content_references
#   position: A3:F3
#   required: yes
# Route:
#   name: Route
#   type: in-external-single-select
#   external_resource: rlm_routes
#   position: A5:B5
#   required: yes
# Environment:
#   name: Environment
#   type: in-external-single-select
#   external_resource: rlm_route_environments
#   position: E5:F5
#   required: yes
# Set Properties:
#   name: Set Properties
#   type: in-external-single-select
#   external_resource: rlm_package_properties
#   position: A7:F7
#   required: no
# Package Instance:
#   name: Package instance name
#   type: out-text
#   position: A1:F1
# Package Instance Log:
#   name: Package instance Logs
#   type: out-file
#   position: A2:F2
# Package Instances:
#   name: Package instances
#   type: out-url
#   position: A3:F3
# Deployment Log File:
#   name: Package Deployment Logs
#   type: out-file
#   position: A4:F4
# Deployment Log URL:
#   name: Package Deployment URL
#   type: out-url
#   position: A5:F5
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


	def attach_logs(instance_id, command, result_dir, pack_response_argument)
		instance_logs = RlmUtilities.get_instance_logs(RLM_BASE_URL, RLM_USERNAME, RLM_PASSWORD, instance_id, command)
		if instance_logs
		  rlm_instance_logs = File.join(result_dir, "rlm_instance_logs")
		  unless File.directory?(rlm_instance_logs)
		    Dir.mkdir(rlm_instance_logs, 0700)
		  end

		  log_file_path = File.join(rlm_instance_logs, "#{instance_id}.txt")
		  fh = File.new(log_file_path, "w")
		  fh.write(instance_logs)
		  fh.close

		  pack_response pack_response_argument, log_file_path
		end	
	end

	def attach_deployment_logs(instance_id, result_dir, pack_response_argument)		
		instance_logs = RlmUtilities.get_deployment_logs(RLM_BASE_URL, RLM_USERNAME, RLM_PASSWORD, instance_id)
		if instance_logs
		  rlm_instance_logs = File.join(result_dir, "rlm_instance_logs")
		  unless File.directory?(rlm_instance_logs)
		    Dir.mkdir(rlm_instance_logs, 0700)
		  end

		  log_file_path = File.join(rlm_instance_logs, "#{instance_id}.txt")
		  fh = File.new(log_file_path, "w")
		  fh.write(instance_logs)
		  fh.close

		  pack_response pack_response_argument, log_file_path
		end	
	end

	#######################Get package Id and package name	
	package_id = params["Package"].split("|")[0]
	package_name = params["Package"].split("|")[1]


	#####################Set Q prop values from BRPM####################################################
	begin
	  params.each_pair do |k,v|
	    if (k =~ /^#{"DE_"}/) && !v.blank? && params["Set Properties"].present? && params["Set Properties"].split(",").include?(k.gsub("DE_", ""))
	      write_to("Setting value for property: #{k.gsub("DE_", "")}")
	      RlmUtilities.rlm_set_q_property_value(RLM_BASE_URL, RLM_USERNAME, RLM_PASSWORD, package_id, "package property add", k.gsub("DE_", ""), v)
	    end
	  end
	rescue Exception => e1
		write_to("Could not set property values: #{e1.message}")
		raise "Error while setting property values."		
	end

	########################Create package instance#################################################
	package_instance_response = RlmUtilities.create_package_instance(RLM_BASE_URL, RLM_USERNAME, RLM_PASSWORD, package_id, params["Locked"])
	package_instance_id = package_instance_response[0]["id"] rescue nil
	if package_instance_id.nil?
		write_to("Operation failed: package instance creation failed.")
		raise "Error while creating the package instance."		
	else
		pack_response "Package Instance", "#{package_instance_response[0]["value"].split(" ")[5]}:#{package_instance_response[0]["value"].split(" ")[2]}" rescue nil
		write_to("package instance created successfully...")
	end

	########################Check the status of package instance created###############################	
	delay = 5 # This delay is required as after creating the instance, status may not immedietly go to constructing
	begin
		sleep(delay)
		package_instance_status = RlmUtilities.get_package_instance_status(RLM_BASE_URL, RLM_USERNAME, RLM_PASSWORD, package_instance_id)
		delay = 10		
	end while (package_instance_status != "Ready" && package_instance_status != "Error")

	if package_instance_status == "Error" || package_instance_status != "Ready"
		attach_logs(package_instance_id, "instance log", params["SS_automation_results_dir"], "Package Instance Log")
		write_to "Operation failed: There were some problem while creating the package instance."
		exit(1)
	else
		pack_response "Package Instances", "#{RLM_BASE_URL}/index.php/delivery/wiz_app_actions/instances/#{package_id}/Asset"
		attach_logs(package_instance_id, "instance log", params["SS_automation_results_dir"], "Package Instance Log")
		write_to("package instance is now in Ready state.")
	end

	################Code to check if environment is changed through choose template or in the new Request template ##########
	if params["Environment"].include?("inherited")	
		rlm_environments = RlmUtilities.get_route_environments( RLM_BASE_URL, RLM_USERNAME, RLM_PASSWORD, params["Route"], params["SS_environment"])
		if rlm_environments.present? && rlm_environments.first.keys.include?("#{params["SS_environment"]}(inherited from request)")
			new_env_id = rlm_environments.first["#{params["SS_environment"]}(inherited from request)"].split("-")[0] rescue nil
		end		
	end

	new_env_id = new_env_id.nil? ? params["Environment"].split("-")[0] : new_env_id
	
	# This means Instance is successfully created and now is in ready state
	########################Instance Deployment stage begins###############################	
	deployment_instance_id = RlmUtilities.deploy_package_instance(RLM_BASE_URL, RLM_USERNAME, RLM_PASSWORD, package_instance_id, params["Route"], new_env_id)
	if deployment_instance_id.nil?
		write_to("Operation failed: Cannot deploy instance.")
		raise "Error while deploying the package instance."		
	else
		write_to("package instance deployment is now started.")
	end

	########################Check the status of deployment###############################	
	delay = 5 # This delay is required as after creating the instance, status may not immedietly go to constructing
	begin
		sleep(delay)
		deploy_status = RlmUtilities.get_deploy_status(RLM_BASE_URL, RLM_USERNAME, RLM_PASSWORD, deployment_instance_id)
		delay = 10		
	end while (deploy_status != "pass" && deploy_status != "fail" && deploy_status != "cancelled")
	
	if deploy_status == "fail" ||  deploy_status == "cancelled" || deploy_status != "pass"
		attach_logs(deployment_instance_id, "process task log", params["SS_automation_results_dir"], "Deployment Log File")
		write_to "Operation failed: There were some problem while deploying the package instance."
		exit(1)
	else
		write_to("package instance deployed successfully.")
		pack_response "Deployment Log URL", "#{RLM_BASE_URL}/index.php/delivery/wiz_action_results/view/#{deployment_instance_id}"
		attach_deployment_logs(deployment_instance_id, params["SS_automation_results_dir"], "Deployment Log File")
	end

rescue Exception => e
	write_to("Operation failed: #{e.message}, Backtrace:\n#{e.backtrace.inspect}")
end