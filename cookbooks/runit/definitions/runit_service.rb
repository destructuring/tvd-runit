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

define :runit_service, :services_defined => nil, :only_if => false, :options => Hash.new do
  params[:template_name] ||= params[:name]
  params[:env] ||= {}

  svdir = "#{params[:services_defined]}/#{params[:name]}"

  directory svdir

  cookbook_file "#{svdir}/run" do
    mode 0755
    source "sv-#{params[:template_name]}-run"
    cookbook params[:cookbook] if params[:cookbook]
  end

  directory "#{svdir}/log"

  cookbook_file "#{svdir}/log/run" do
    mode 0755
    source "sv-log-run"
    cookbook "runit"
  end

  template "#{svdir}/log/config" do
    mode 0644
    source "sv-log-config.erb"
    cookbook "runit"
    if params[:options].respond_to?(:has_key?)
      variables :options => params[:options]
    end
  end

  directory "#{svdir}/env"

  runit_env = {
    "PATH" => ENV['PATH'],
    "HOME" => node[:home_dir]
  }

  runit_env.merge(params[:env]).each do |varname, value|
    template "#{svdir}/env/#{varname}" do
      source "envdir.erb"
      mode 0644
      cookbook "runit"
      variables :value => value
    end
  end
end
