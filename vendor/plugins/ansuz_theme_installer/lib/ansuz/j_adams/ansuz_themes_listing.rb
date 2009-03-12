require 'open-uri'
module Ansuz
  module JAdams
    class AnsuzThemesListing
      REPOSITORY = "http://ansuzcms.com/ansuz_themes.xml"

      # Returns an array of theme arrays.  A theme array 
      # looks like [name, repository_url]
      def self.listing
        ary = []
        xml.elements.each("themes/theme") do |theme|
          name = theme.elements["name"].text
          repository_url = theme.elements["repository_url"].text
          ary << [name, repository_url, install_dir_for_repo(repository_url)]
        end
        ary
      end

      def self.xml_document
        uri = URI.parse REPOSITORY
        uri.read
      end

      def self.install_dir_for_repo repo
        repo.split("/").last.split(".").first
      end

      def self.xml
        REXML::Document.new xml_document
      end

      # This method will install a theme, given a repository url
      def self.install repository_url, name
        `cd #{RAILS_ROOT}/themes; git clone #{repository_url} #{name}`
        `cd #{RAILS_ROOT}; rake theme_update_cache`
      end

      def self.update name
        `cd #{theme_folder_for(name)}; git pull`
        `cd #{RAILS_ROOT}; rake theme_update_cache`
      end

      def self.delete name
        `rm -fr #{theme_folder_for(name)}`
      end

      def self.installed?(name)
        File.exist?(theme_folder_for(name))
      end

      def self.theme_folder_for name
        "#{RAILS_ROOT}/themes/#{name}"
      end
    end
  end
end
