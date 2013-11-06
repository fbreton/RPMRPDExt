require 'json'
require 'rest-client'
require 'uri'
require 'base64'
require 'xmlsimple'

module RlmUtilities
  class << self

    #############################Getter methods#############################################

  	def get_all_packages(rlm_base_url, rlm_username, rlm_password)
  		get_all_items_list(rlm_base_url, rlm_username, rlm_password, "package list")
  	end

    def get_all_repos(rlm_base_url, rlm_username, rlm_password)
      get_all_items_list(rlm_base_url, rlm_username, rlm_password, "repo list", "Ready")
    end

  	def get_all_routes(rlm_base_url, rlm_username, rlm_password)
  		get_all_items_list(rlm_base_url, rlm_username, rlm_password, "route list")
  	end    

  	def get_all_environments(rlm_base_url, rlm_username, rlm_password, request_environment = "")
  		hash_response = get_all_items_list(rlm_base_url, rlm_username, rlm_password, "environment list")[0]
        environments = {}
		hash_temp ={}
        hash_response.each { |value, id| 
          if value != nil && id != nil
            if value == request_environment
              hash_temp["#{request_environment}(inherited from request)"] = "#{id}|#{value}"
            else
              environments[value] = "#{id}|#{value}"
            end
          end
        }
        return [hash_temp.merge(environments)]
  	end  

    def get_all_roles(rlm_base_url, rlm_username, rlm_password)
        get_all_items_list(rlm_base_url, rlm_username, rlm_password, "role list")
    end

    def get_all_bridges(rlm_base_url, rlm_username, rlm_password)
        get_all_items_list(rlm_base_url, rlm_username, rlm_password, "bridge list")
    end

    def get_channel_by_env(rlm_base_url, rlm_username, rlm_password, environment) 
      raise "Error: An environment name has to be provided" if environment.blank?

      get_all_items_list(rlm_base_url, rlm_username, rlm_password, "environment channel list", environment)

    end

    def get_all_blueprints(rlm_base_url, rlm_username, rlm_password)
        get_all_items_list(rlm_base_url, rlm_username, rlm_password, "blueprint list")
    end

  	def get_package_instances(rlm_base_url, rlm_username, rlm_password, package = nil)
  		get_all_package_items_list(rlm_base_url, rlm_username, rlm_password, package, "instance package list", "Ready")
  	end

    def get_repo_instances(rlm_base_url, rlm_username, rlm_password, package = nil)
      get_all_package_items_list(rlm_base_url, rlm_username, rlm_password, package, "instance repo list", "Ready", nil, "0")
    end

  	def get_package_properties(rlm_base_url, rlm_username, rlm_password, package = nil)
  		get_all_package_items_list(rlm_base_url, rlm_username, rlm_password, package, "package property list")
  	end

  	def get_package_content_references(rlm_base_url, rlm_username, rlm_password, package = nil)
  		get_all_package_items_list(rlm_base_url, rlm_username, rlm_password, package, "package reference list")
  	end

    def get_package_instance_properties(rlm_base_url, rlm_username, rlm_password, instance = nil)
      get_all_package_items_list(rlm_base_url, rlm_username, rlm_password, instance, "instance property list")
    end

    def get_repo_instance_properties(rlm_base_url, rlm_username, rlm_password, instance = nil)
      get_all_package_items_list(rlm_base_url, rlm_username, rlm_password, instance, "instance property list")
    end   

    def get_repo_properties(rlm_base_url, rlm_username, rlm_password, instance = nil)
      get_all_package_items_list(rlm_base_url, rlm_username, rlm_password, instance, "repo property list")
    end   

    def get_package_instance_content_references(rlm_base_url, rlm_username, rlm_password, instance = nil)
      get_all_package_items_list(rlm_base_url, rlm_username, rlm_password, instance, "instance artifact list")
    end    

    def get_repo_instance_content_references(rlm_base_url, rlm_username, rlm_password, instance = nil)
      get_all_package_items_list(rlm_base_url, rlm_username, rlm_password, instance, "instance artifact list")
    end

    def get_root_repo_instance_content_references(rlm_base_url, rlm_username, rlm_password, instance = nil)
      repo_instance_references = get_all_package_items_list(rlm_base_url, rlm_username, rlm_password, instance, "instance artifact list", nil, "tree")
      reference_name = {}
      if repo_instance_references
        repo_instance_references.each do |hsh|
          hsh.each do |ref_name, reference_id|
            reference_name[ref_name.split("=")[0]] = "#{reference_id}=#{ref_name.split("=")[1]}"
          end
        end
      end
      return reference_name
    end

    def get_root_repo_content_references(rlm_base_url, rlm_username, rlm_password, instance = nil)
      repo_instance_references = get_all_package_items_list(rlm_base_url, rlm_username, rlm_password, instance, "repo artifact list", nil, "tree")
      reference_name = {}
      puts "repo_instance_references==========#{repo_instance_references.inspect}\n\n\n"
      if repo_instance_references
        repo_instance_references.each do |hsh|
          hsh.each do |ref_name, reference_id|
            unless ref_name.nil?
              reference_name[ref_name.split("=")[0]] = "#{reference_id}=#{ref_name.split("=")[1]}"
            end
          end
        end
      end
      return reference_name
    end

    def get_package_instance_status(rlm_base_url, rlm_username, rlm_password, package_instance)
      get_status(rlm_base_url, rlm_username, rlm_password, "instance status", package_instance)
    end

    def get_repo_instance_status(rlm_base_url, rlm_username, rlm_password, package_instance)
      get_status(rlm_base_url, rlm_username, rlm_password, "instance status", package_instance)
    end

    def get_deploy_status(rlm_base_url, rlm_username, rlm_password, deploy_instance)
      get_status(rlm_base_url, rlm_username, rlm_password, "deploy status", deploy_instance)
    end

    # def get_package_instance_environments(rlm_base_url, rlm_username, rlm_password, package_instance)
    #   get_environments_by(package_instance, rlm_base_url, rlm_username, rlm_password, "instance environment list")
    # end

    def get_route_environments(rlm_base_url, rlm_username, rlm_password, route, request_environment)
      get_environments_by(route, rlm_base_url, rlm_username, rlm_password, "route environment list", request_environment)
      # route_type = get_route_type(rlm_base_url, rlm_username, rlm_password, "route type", route)
      # unless route_type == "Strict"
      #   get_environments_by(route, rlm_base_url, rlm_username, rlm_password, "route environment list")
      # else
      #   []
      # end      
    end

    def get_route_type(rlm_base_url, rlm_username, rlm_password, command, route)
      route_type = get_status(rlm_base_url, rlm_username, rlm_password, command, route)
    end

    def get_all_instance_routes(rlm_base_url, rlm_username, rlm_password, instance)
      url = "#{rlm_base_url}/index.php/api/processRequest.xml"
      request_doc_xml = Builder::XmlMarkup.new
      request_doc_xml.q(:auth => "#{rlm_username} #{rlm_password}") do
        request_doc_xml.request(:command => "instance route get") do
          request_doc_xml.arg "#{instance}"
        end
      end      

      xml_response = RestClient.post url, request_doc_xml, :content_type => :xml, :accept => :xml
      xml_to_hash_response = XmlSimple.xml_in(xml_response)

      # Check the result code and message in the response
      if xml_to_hash_response["result"][0]["rc"] != "0" || xml_to_hash_response["result"][0]["message"] != "Ok"
        raise "Error while posting to URL #{url}: #{xml_to_hash_response["result"][0]["message"]}"
      else
        response = {}
        hash_response = xml_to_hash_response["result"][0]["response"] 
        return [] if hash_response.first == "No route assigned to that instance" 
        hash_response.map{|hsh| response[hsh["value"]] = hsh["id"] }
        return [response]
      end      
    end

  	def get_all_items_list(rlm_base_url, rlm_username, rlm_password, command, argument = nil)
      url = "#{rlm_base_url}/index.php/api/processRequest.xml"
      request_doc_xml = Builder::XmlMarkup.new
      request_doc_xml.q(:auth => "#{rlm_username} #{rlm_password}") do
        request_doc_xml.request(:command => "#{command}") do
          request_doc_xml.arg "#{argument}" if argument.present?
        end
      end 

      xml_response = RestClient.post url, request_doc_xml, :content_type => :xml, :accept => :xml
      xml_to_hash_response = XmlSimple.xml_in(xml_response)
      # Check the result code and message in the response
      if xml_to_hash_response["result"][0]["rc"] != "0" || xml_to_hash_response["result"][0]["message"] != "Ok"
        raise "Error while posting to URL #{url}: #{xml_to_hash_response["result"][0]["message"]}"
      else
        # This should return response in the following format 
        # [{"id"=>"1", "value"=>"Sample File Deploy Project"}, {"id"=>"2", "value"=>"package 2"}]
        response = {}
        hash_response = []
        hash_response = xml_to_hash_response["result"][0]["response"].sort_by{|hsh| hsh["value"]}
        hash_response.map{|hsh| response[hsh["value"]] = hsh["id"] }
        return [response]
      end  		
  	end  	

  	def get_all_package_items_list(rlm_base_url, rlm_username, rlm_password, package, command, status = nil, type = nil, frozen = nil)
  		if package.present?
          url = "#{rlm_base_url}/index.php/api/processRequest.xml"
          request_doc_xml = Builder::XmlMarkup.new
          request_doc_xml.q(:auth => "#{rlm_username} #{rlm_password}") do
            request_doc_xml.request(:command => "#{command}") do
              request_doc_xml.arg "#{package}"
              request_doc_xml.arg "#{status}" if status.present?
              request_doc_xml.arg "#{frozen}" if frozen.present?
            end
          end 

          xml_response = RestClient.post url, request_doc_xml, :content_type => :xml, :accept => :xml
          xml_to_hash_response = XmlSimple.xml_in(xml_response)

          # Check the result code and message in the response
          if xml_to_hash_response["result"][0]["rc"] != "0" || xml_to_hash_response["result"][0]["message"] != "Ok"
            raise "Error while posting to URL #{url}: #{xml_to_hash_response["result"][0]["message"]}"
          else
            # seperate resource automation output for table type arguments          
            if ["package reference list", "instance artifact list"].include?(command) && type.nil?
              format_and_display_output_as_table_format(xml_to_hash_response, 'Reference Name', 'Reference URL')
            elsif ["package property list", "instance property list"].include?(command) && type.nil?
              format_and_display_output_as_table_format(xml_to_hash_response, 'Property Name', 'Value set in Q')
            else
              response = {}
              hash_response = xml_to_hash_response["result"][0]["response"]
              hash_response.map{|hsh| response[hsh["value"]] = hsh["id"] }
              return [response]            
            end
		  end
  		else
  			raise "No vaild package name/ID provided."
  		end  		
  	end

    # Here package_instance_id_or_name could be only id OR package_name:instance_name
    def get_status(rlm_base_url, rlm_username, rlm_password, command, package_instance_id_or_name)
      url = "#{rlm_base_url}/index.php/api/processRequest.xml"
      request_doc_xml = Builder::XmlMarkup.new
      request_doc_xml.q(:auth => "#{rlm_username} #{rlm_password}") do
        request_doc_xml.request(:command => "#{command}") do
          request_doc_xml.arg "#{package_instance_id_or_name}"
        end
      end 

      xml_response = RestClient.post url, request_doc_xml, :content_type => :xml, :accept => :xml
      xml_to_hash_response = XmlSimple.xml_in(xml_response)

      # Check the result code and message in the response
      if xml_to_hash_response["result"][0]["rc"] != "0" || xml_to_hash_response["result"][0]["message"] != "Ok"
        raise "Error while posting to URL #{url}: #{xml_to_hash_response["result"][0]["message"]}"
      else
        hash_response = xml_to_hash_response["result"][0]["response"] 
        # hash_response = [{"id"=>"74", "value"=>"Error:new-ip-package:0.0.0.22"}]

        instance_status = hash_response.first["value"].split(":").first rescue nil
        # instance_status = "Error"

        return instance_status
      end      
    end

    def get_environments_by(entity_argument, rlm_base_url, rlm_username, rlm_password, command, request_environment)
      url = "#{rlm_base_url}/index.php/api/processRequest.xml"
      request_doc_xml = Builder::XmlMarkup.new
      request_doc_xml.q(:auth => "#{rlm_username} #{rlm_password}") do
        request_doc_xml.request(:command => "#{command}") do
          request_doc_xml.arg "#{entity_argument}" if entity_argument.present?
        end
      end
      xml_response = RestClient.post url, request_doc_xml, :content_type => :xml, :accept => :xml
      xml_to_hash_response = XmlSimple.xml_in(xml_response)

      # Check the result code and message in the response
      if xml_to_hash_response["result"][0]["rc"] != "0" || xml_to_hash_response["result"][0]["message"] != "Ok"
        raise "Error while posting to URL #{url}: #{xml_to_hash_response["result"][0]["message"]}"
      else
        environments = {}
        hash_response = xml_to_hash_response["result"][0]["response"]
        hash_response.map{|hsh| 
          if hsh["value"] != nil && hsh["id"] != nil
            if hsh["value"] == request_environment
              env_val = "#{request_environment}(inherited from request)"
              env_id = "#{hsh["id"]}-inherited"
            else
              env_val = hsh["value"]
              env_id = hsh["id"]
            end
            environments[env_val] = env_id 
          end
        }
        return [environments]
      end      
    end

    def get_instance_logs(rlm_base_url, rlm_username, rlm_password, package_instance_id, command)
      url = "#{rlm_base_url}/index.php/api/processRequest.xml"
      request_doc_xml = Builder::XmlMarkup.new
      request_doc_xml.q(:auth => "#{rlm_username} #{rlm_password}") do
        request_doc_xml.request(:command => "#{command}") do
          request_doc_xml.arg "#{package_instance_id}"
        end
      end 

      xml_response = RestClient.post url, request_doc_xml, :content_type => :xml, :accept => :xml
      xml_to_hash_response = XmlSimple.xml_in(xml_response)

      # Check the result code and message in the response
      if xml_to_hash_response["result"][0]["rc"] != "0" || xml_to_hash_response["result"][0]["message"] != "Ok"
        raise "Error while posting to URL #{url}: #{xml_to_hash_response["result"][0]["message"]}"
      else
        hash_response = xml_to_hash_response["result"][0]["response"] 

        instance_logs = hash_response.first.empty? ? nil : hash_response.try(:to_yaml)
        # instance_status = "Error"

        return instance_logs
      end      
    end

    def get_deployment_logs(rlm_base_url, rlm_username, rlm_password, deployment_id)
      deployment_log = ""
      deploy_proc_hash_response = get_hash_response(rlm_base_url, rlm_username, rlm_password, deployment_id, "deploy processes")
      process_ids = []
      return nil if deploy_proc_hash_response.nil?
      deploy_proc_hash_response.map{|process| process_ids << process["id"]}
      return nil if process_ids.blank?
      activity_ids = []
      process_ids.each do |process_id|
        proc_activity_hash_response = get_hash_response(rlm_base_url, rlm_username, rlm_password, process_id, "process activity list")
        proc_activity_hash_response.map{|activity| activity_ids << activity["id"]} unless proc_activity_hash_response.nil?
      end
      return nil if activity_ids.blank?
      task_ids = []
      activity_ids.each do |activity_id|
        proc_task_hash_response = get_hash_response(rlm_base_url, rlm_username, rlm_password, activity_id, "process task list")
        proc_task_hash_response.map{|task| task_ids << task["id"]} unless proc_task_hash_response.nil?
      end
      return nil if task_ids.blank?
      task_ids.each do |task_id|
        proc_task_list_hash_response = get_hash_response(rlm_base_url, rlm_username, rlm_password, task_id, "process task log")
        unless proc_task_list_hash_response.nil?
          deployment_log += proc_task_list_hash_response.try(:to_yaml) 
          deployment_log += "\n\n"
        end
      end
      deployment_log = deployment_log.empty? ? nil : deployment_log
      return deployment_log
    end

    def get_hash_response(rlm_base_url, rlm_username, rlm_password, deployment_id, command)
      url = "#{rlm_base_url}/index.php/api/processRequest.xml"
      request_doc_xml = Builder::XmlMarkup.new
      request_doc_xml.q(:auth => "#{rlm_username} #{rlm_password}") do
        request_doc_xml.request(:command => "#{command}") do
          request_doc_xml.arg "#{deployment_id}"
        end
      end 

      xml_response = RestClient.post url, request_doc_xml, :content_type => :xml, :accept => :xml
      xml_to_hash_response = XmlSimple.xml_in(xml_response)

      # Check the result code and message in the response
      if xml_to_hash_response["result"][0]["rc"] != "0" || xml_to_hash_response["result"][0]["message"] != "Ok"
        raise "Error while posting to URL #{url}: #{xml_to_hash_response["result"][0]["message"]}"
      else
        hash_response = xml_to_hash_response["result"][0]["response"] 
        hash_response = hash_response.first.empty? ? nil : hash_response        
      end      
      return hash_response
    end

    #############################Setter methods#############################################
    def set_method (rlm_base_url, rlm_username, rlm_password, command, arglist)
       url = "#{rlm_base_url}/index.php/api/processRequest.xml"
       request_doc_xml = Builder::XmlMarkup.new
       request_doc_xml.q(:auth => "#{rlm_username} #{rlm_password}") do
         request_doc_xml.request(:command => "#{command}") do
           arglist.each {|arg| request_doc_xml.arg "#{arg}"}
         end
       end	   
       xml_response = RestClient.post url, request_doc_xml, :content_type => :xml, :accept => :xml
       xml_to_hash_response = XmlSimple.xml_in(xml_response)
       # Check the result code and message in the response
       if xml_to_hash_response["result"][0]["rc"] != "0" || xml_to_hash_response["result"][0]["message"] != "Ok"
         raise "Error while posting to URL #{url}: #{xml_to_hash_response["result"][0]["message"]}"
       else
         response = {}
         hash_response = xml_to_hash_response["result"][0]["response"]
         return hash_response
       end
    end

    # Accept package as id or package name
    def create_package_instance(rlm_base_url, rlm_username, rlm_password, package, locked_status="No", instance_name = nil)
      if package.present?
        url = "#{rlm_base_url}/index.php/api/processRequest.xml"
        if locked_status == "No"
          command = "instance create package"
        else
          command = "instance create locked package"
        end
        request_doc_xml = Builder::XmlMarkup.new
        request_doc_xml.q(:auth => "#{rlm_username} #{rlm_password}") do
          request_doc_xml.request(:command => "#{command}") do
            request_doc_xml.arg "#{package}"
            request_doc_xml.arg "#{instance_name}" if instance_name
          end
        end
        xml_response = RestClient.post url, request_doc_xml, :content_type => :xml, :accept => :xml
        xml_to_hash_response = XmlSimple.xml_in(xml_response)
        # Check the result code and message in the response
        if xml_to_hash_response["result"][0]["rc"] != "0" || xml_to_hash_response["result"][0]["message"] != "Ok"
          raise "Error while posting to URL #{url}: #{xml_to_hash_response["result"][0]["message"]}"
        else
          response = {}
          hash_response = xml_to_hash_response["result"][0]["response"]
          # package_instance_id = hash_response.first.empty? ? nil : hash_response[0]["id"]          
          
          return hash_response
        end
      else
        raise "No vaild package name/ID provided."
      end     
    end

    def create_bridge(rlm_base_url, rlm_username, rlm_password, bridge, role, agent, agentserver, bridgeos)
      raise "No valid bridge name provided" if bridge.blank?	
      raise "No valid role id provided, should be an integer" if !(role.is_a? Integer)
      raise "No valid agent provided" if agent.blank?
      raise "No valid agent server name provided" if agentserver.blank?
      raise "No valid bridge os name provide" if bridgeos.blank?

      return set_method(rlm_base_url, rlm_username, rlm_password, "bridge add", [bridge,role,"-d","#{agent}://#{agentserver}",bridgeos])
    end
	
    def create_channel(rlm_base_url, rlm_username, rlm_password, blueprint, bridge, channel)
      raise "No valid bridge name provided" if bridge.blank?	
      raise "No valid blueprint name provided" if blueprint.blank?
      raise "No valid channel name provided" if channel.blank?

      return set_method(rlm_base_url, rlm_username, rlm_password, "channel add", [blueprint,bridge,channel])
    end

    def add_channel_to_env(rlm_base_url, rlm_username, rlm_password, environment, channel)
      raise "No valid environment name" if environment.blank?
	  return set_method(rlm_base_url, rlm_username, rlm_password, "environment channel add",[environment, channel])
    end

    def delete_bridge(rlm_base_url, rlm_username, rlm_password, bridge)
      raise "No valid bridge name provided" if bridge.blank?
      return set_method(rlm_base_url, rlm_username, rlm_password, "bridge delete", [bridge])
    end

    def delete_channel_from_env(rlm_base_url, rlm_username, rlm_password, environment, channel)
      raise "No valid environment name provided" if environment.blank?	
      raise "No valid channel name provided" if channel.blank?

      return set_method(rlm_base_url, rlm_username, rlm_password, "environment channel delete", [environment, channel])
    end
	
    def delete_channel(rlm_base_url, rlm_username, rlm_password, channel)
      raise "No valid channel name provided" if channel.blank?

      return set_method(rlm_base_url, rlm_username, rlm_password, "channel delete", [channel])
    end

    def create_repo_instance(rlm_base_url, rlm_username, rlm_password, repo, locked_status="No", instance_name = nil)
      if repo.present?
        url = "#{rlm_base_url}/index.php/api/processRequest.xml"
        if locked_status == "No"
          command = "instance create repo"
        else
          command = "instance create locked repo"
        end
        request_doc_xml = Builder::XmlMarkup.new
        request_doc_xml.q(:auth => "#{rlm_username} #{rlm_password}") do
          request_doc_xml.request(:command => "#{command}") do
            request_doc_xml.arg "#{repo}"
            request_doc_xml.arg "#{instance_name}" if instance_name
          end
        end
        xml_response = RestClient.post url, request_doc_xml, :content_type => :xml, :accept => :xml
        xml_to_hash_response = XmlSimple.xml_in(xml_response)
        # Check the result code and message in the response
        if xml_to_hash_response["result"][0]["rc"] != "0" || xml_to_hash_response["result"][0]["message"] != "Ok"
          raise "Error while posting to URL #{url}: #{xml_to_hash_response["result"][0]["message"]}"
        else
          hash_response = xml_to_hash_response["result"][0]["response"]
          # package_instance_id = hash_response.first.empty? ? nil : hash_response[0]["id"]          
          
          return hash_response
        end
      else
        raise "No vaild Repo name/ID provided."
      end     
    end    


    def deploy_package_instance(rlm_base_url, rlm_username, rlm_password, instance, route, environment)
      url = "#{rlm_base_url}/index.php/api/processRequest.xml"
      request_doc_xml = Builder::XmlMarkup.new
      request_doc_xml.q(:auth => "#{rlm_username} #{rlm_password}") do
        request_doc_xml.request(:command => "instance deploy") do
          request_doc_xml.arg "#{instance}"
          request_doc_xml.arg "#{route}"
          request_doc_xml.arg "#{environment}" if environment.present?
        end
      end 
      puts "request_doc_xml===#{request_doc_xml.inspect}"

      xml_response = RestClient.post url, request_doc_xml, :content_type => :xml, :accept => :xml
      xml_to_hash_response = XmlSimple.xml_in(xml_response)

      # Check the result code and message in the response
      if xml_to_hash_response["result"][0]["rc"] != "0" || xml_to_hash_response["result"][0]["message"] != "Ok"
        raise "Error while posting to URL #{url}: #{xml_to_hash_response["result"][0]["message"]}: #{xml_to_hash_response["result"][0]["response"][0]["value"]}"
      else
        hash_response = xml_to_hash_response["result"][0]["response"] 

        deploy_instance_id = hash_response.first.empty? ? nil : hash_response[0]["id"]

        return deploy_instance_id
      end      
    end


    #################################Convertors####################################################

    def format_and_display_output_as_table_format(hash_response, table_header_1, table_header_2)
      response = hash_response["result"][0]["response"]
      # totalItems = response.size
      totalItems = 0
      per_page = 10
      table_data =[ ['', table_header_1, table_header_2] ]
      response = response.first.empty? ? nil : response
      unless response.nil?
        response.each do |ref|
          name = ref["value"].split("=").first
          url = ref["value"].split("=").last
          # id = ref["id"]
          id = name
          table_data << [id, name, url]
          totalItems = totalItems + 1
        end        
      else
        return []
        # table_data << ['', '', '']
      end
      return {:totalItems => totalItems, :perPage => per_page, :data => table_data }
    end


    def rlm_set_q_property_value(rlm_base_url, rlm_username, rlm_password, entity, command, property_name, property_value)
      url = "#{rlm_base_url}/index.php/api/processRequest.xml"
      request_doc_xml = Builder::XmlMarkup.new
      request_doc_xml.q(:auth => "#{rlm_username} #{rlm_password}") do
        request_doc_xml.request(:command => "#{command}") do
          request_doc_xml.arg "#{entity}"
          request_doc_xml.arg "#{property_name}"
          request_doc_xml.arg "#{property_value}"
        end
      end 

      xml_response = RestClient.post url, request_doc_xml, :content_type => :xml, :accept => :xml
      xml_to_hash_response = XmlSimple.xml_in(xml_response)

      # Check the result code and message in the response
      if xml_to_hash_response["result"][0]["rc"] != "0" || xml_to_hash_response["result"][0]["message"] != "Ok"
        raise "Error while posting to URL #{url}: #{xml_to_hash_response["result"][0]["message"]}"
      else
        # Property update successful
        return true
      end      
    end
    

  end
end  