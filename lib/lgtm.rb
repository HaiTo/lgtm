require "lgtm/version"
require 'mechanize'

module Lgtm
  class In
    LGTM_LINK_BASE = 'http://lgtm.in/i'.freeze
    NOT_SET_VALIAVLE_ALERT_1 = "please set enviromant variable LGTM_IN_USER_PATH \n"
    NOT_SET_VALIAVLE_ALERT_2 = "lgtm.in mypage example ->  http://lgtm.in/l/HaiTo \n"
    NOT_SET_VALIAVLE_ALERT_3 = "in .bashrc, .zshrc -> export LGTM_IN_USER_PATH='http://lgtm.in/l/HaiTo' \n"

    REFLASH_TIME = 604_800.freeze

    LAST_EXECUTED_AT_TIME_PATH = 'last_executed_at.time'.freeze
    CACHED_LINKS_PATH = 'cached_links.links'.freeze
    BASE_PATH = File.expand_path('..', __FILE__)

    LGTM_MARKDOWN = '[![LGTM](__LGTM_IMAGE_DETAILS_PATH__)](__LGTM_IMAGE_PATH__)'
    LGTM_MARKDOWN_DETAIL_PATH_BASE = 'http://lgtm.in/p/'.freeze
    LGTM_MARKDOWN_IMAGE_PATH_BASE = 'http://lgtm.in/i/'.freeze
    
    def not_set_valiavle_alert
      print NOT_SET_VALIAVLE_ALERT_1
      print NOT_SET_VALIAVLE_ALERT_2
      print NOT_SET_VALIAVLE_ALERT_3
      exit(1)
    end

    def initialize
      @lgtm_my_page = ENV['LGTM_IN_USER_PATH'].nil? ? not_set_valiavle_alert : ENV['LGTM_IN_USER_PATH']

      @last_executed_at = begin File.read(BASE_PATH + '/' + LAST_EXECUTED_AT_TIME_PATH); rescue; nil;
      end

      @cached_links = begin File.read(BASE_PATH + '/' + CACHED_LINKS_PATH); rescue; nil
      end
    end

    def fetch_lgtm_link_markdown!
      links =
        if Time.now.to_i - @last_executed_at.to_i > REFLASH_TIME
          update_executed_at!

          links = fetch_links
          cache_links!(links)

          links
        else
          @cached_links.nil? ? fetch_links : Marshal.load(@cached_links)
        end

      link = links.sample

      hash = link.split('/').last

      LGTM_MARKDOWN.gsub('__LGTM_IMAGE_DETAILS_PATH__', "#{LGTM_MARKDOWN_DETAIL_PATH_BASE + hash}").gsub('__LGTM_IMAGE_PATH__', "#{LGTM_MARKDOWN_IMAGE_PATH_BASE + hash}")
    end

    private

    def fetch_links
      agent = Mechanize.new
      page = agent.get(@lgtm_my_page)
      page.links.map(&:href).select {|link| link.match(LGTM_LINK_BASE) }
    end

    def update_executed_at!
      File.open(BASE_PATH + '/' + LAST_EXECUTED_AT_TIME_PATH, 'w') {|f| f.write(Time.now.to_i) }
    end

    def cache_links!(links)
      File.open(BASE_PATH + '/' + CACHED_LINKS_PATH, 'w') {|f| f.write(Marshal.dump(links)) }
    end
  end
end
