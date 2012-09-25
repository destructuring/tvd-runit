#
# Cookbook Name:: runit
# Definition:: runit_service
#
# Copyright 2008-2009, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

define :runit_service, :only_if => false, :options => Hash.new, :env => Hash.new, :activate => true do
  params[:template_name] ||= params[:name]

  services_current = "#{params[:project_dir]}/current/service"
  services_run     = "#{params[:project_dir]}/service"
  services_defined = "#{params[:release_dir]}/service"

  svc_defined = "#{services_defined}/#{params[:name]}"
  svc_run = "#{services_run}/#{params[:name]}"
  svc_current = "#{services_current}/#{params[:name]}"

  directory services_defined

  directory svc_defined
  
  unless paras[:activate]
    execute "#{svc_defined}/down" do
      command "touch #{svc_defined}/down"
      creates "touch #{svc_defined}/down"
    end
  end

  cookbook_file "#{svc_defined}/run" do
    mode 0755
    source "sv-#{params[:template_name]}-run"
    cookbook params[:cookbook] if params[:cookbook]
  end
  directory "#{svc_defined}/log"

  cookbook_file "#{svc_defined}/log/run" do
    mode 0755
    source "sv-log-run"
    cookbook "runit"
  end

  template "#{svc_defined}/log/config" do
    mode 0644
    source "sv-log-config.erb"
    cookbook "runit"
    if params[:options].respond_to?(:has_key?)
      variables :options => params[:options]
    end
  end

  directory "#{svc_defined}/env"

  runit_env = {
    "PATH" => ENV['PATH'],
    "HOME" => node[:home_dir]
  }

  runit_env.merge(params[:env]).each do |varname, value|
    template "#{svc_defined}/env/#{varname}" do
      source "envdir.erb"
      mode 0644
      cookbook "runit"
      variables :value => value
    end
  end

  unless params[:project_dir] == params[:release_dir] || params[:activate] == false
    directory services_run

    directory svc_run

    directory "#{svc_run}/log"

    link "#{svc_run}/run" do
      to "#{svc_current}/run"
    end

    link "#{svc_run}/log/run" do
      to "#{svc_current}/log/run"
    end

    link "#{svc_run}/log/config" do
      to "#{svc_current}/log/config"
    end
    link "#{svc_run}/env" do
      to "#{svc_current}/env"
    end
  end
end
