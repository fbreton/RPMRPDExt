RPMRPDExt
=========

Resource automation and automation script extension for RPM and RPD integration. This extension provide automation to 
create and delete topology component.

Install
=======

On your BRPM installation in directory <BRPM install dir>/WEB-INF/lib/script_support, save/rename script_helper.rb
and rlm_utilities.rb.
Copy script_helper.rb and rlm_utilities.rb to <BRPM install dir>/WEB-INF/lib/script_support
Files in automation directories need to be copied on BRPM server to:
  <BRPM install dir>/WEB-INF/lib/script_support/LIBRARY/automation/RLM Deployment Engine
Files resource_automation need to be copied on BRPM server to:
  <BRPM install dir>/WEB-INF/lib/script_support/LIBRARY/resource_automation/RLM Deployment Engine

Then you may need to restart BRPM.

Setup
=====

You need to create an integration server pointing to your BRPD server to point the API (if not already done):
  Server Name:  <up to you>
  Server URL:   <BRPD API url; example: http://brpd:9090/brlm>
  Username:     <BRPD user>
  password:     <password of previously defined user>
  
You need to import in automation (Environment -> Automation):
  1. The resource automation script that you associate with previously defined integration server:
      rlm_bridges.rb: provide list of bridges
      rlm_environments.rb: provide list of environments
      rlm_blueprints.rb: provide list of blueprints also named channel templates
      rlm_roles.rb: provide list of roles
      rlm_environment_channels.rb: provide list of channels for a defined environment
      
  2. The automation scripts that you associate with previously defined integration server
      rlm_create_bridges.rb: create bridge(s)
      rlm_create_channel.rb: create channel and associate it to an environment
      rlm_delete_channel.rb: dissociate channel(s) from a specific enviroment and delete it
      rlm_delete_bridge.rb: delete bridge(s)
      
Remark
=======
script_helper.rb has been modified to provide a function to substitute rpm{property} by the value of the property. 
So fo example in field Bridge of rlm_create_bridges automation you can type rpm{servers} to get server list part of 
component associated with the step.

Improvments
===========
Add more automation to also manage creation and deletion of environment and route.
