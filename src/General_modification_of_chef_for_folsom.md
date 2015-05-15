./cookbooks/keystone/templates/default/keystone.conf.erb 
    
       [policy]
       #driver = keystone.policy.backends.simple.SimpleMatch
      ** driver = keystone.policy.backends.rules.Policy**
    
    

./cookbooks/glance/recipes/api.rb 
    
    #creates db and user
    ##returns connection info
    ##defined in osops-utils/libraries
    **mysql_info = create_db_and_user("mysql",**
     ** node["glance"]["db"]["name"],**
     ** node["glance"]["db"]["username"],**
      **node["glance"]["db"]["password"])**
      
     ...
      
    template "/etc/glance/glance-api.conf" do
     source "glance-api.conf.erb"
     owner "root"
     group "root"
     mode "0644"
     variables(
       "api_bind_address" =&gt; api_endpoint["host"],
       "api_bind_port" =&gt; api_endpoint["port"],
       "registry_ip_address" =&gt; registry_endpoint["host"],
       "registry_port" =&gt; registry_endpoint["port"],
       **"db_ip_address" =&gt; mysql_info["bind_address"],**
       **"db_user" =&gt; node["glance"]["db"]["username"],**
       **"db_password" =&gt; node["glance"]["db"]["password"],**
       **"db_name" =&gt; node["glance"]["db"]["name"],**
       "use_syslog" =&gt; node["glance"]["syslog"]["use"],
    
    

./cookbooks/glance/templates/default/glance-api-paste.ini.erb 
    
     Copy the [Glance-api-paste.ini.erb_for_Folsom] file to the glance-api-paste.ini.erb
    
    

./cookbooks/glance/templates/default/glance-api.conf.erb 
    
    **sql_connection = mysql://**
    
