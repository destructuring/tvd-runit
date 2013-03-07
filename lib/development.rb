def dev(nm_gem, workarea="git")
  gem nm_gem, (
    File.exists?(File.expand_path("../#{workarea}/#{nm_gem}", __FILE__)) ? 
      (ENV["EDIT_#{nm_gem.gsub(/[-]/, "_")}"] = "true"; { :path => "#{workarea}/#{nm_gem}" }) : 
      Dir["vendor/cache/#{nm_gem}-*.gem"].collect {|x| [x.gsub(/\d+/) {|num| sprintf("%011d", num) }, x] }.sort[0][1].split(/-/)[-1].gsub(/\.gem$/,"")
  )
end
