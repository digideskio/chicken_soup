if Object.const_defined?("Capistrano")
  Capistrano::Configuration.instance(:must_exist).load do
    require 'chicken_soup/global'
    require 'chicken_soup/environment'
    require 'chicken_soup/deploy'
  end
end
