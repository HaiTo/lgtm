require 'lgtm/version'
require 'mechanize'

module Lgtm
  class Fixnum
    MAX = 4_611_686_018_427_387_903
  end

  class In
    LGTM_LINK_BASE = 'http://lgtm.in/i'.freeze
    NOT_SET_VALIAVLE_ALERT_1 = "please set enviromant variable LGTM_IN_USER_PATH \n".freeze
    NOT_SET_VALIAVLE_ALERT_2 = "lgtm.in mypage example ->  http://lgtm.in/l/HaiTo \n".freeze
    NOT_SET_VALIAVLE_ALERT_3 = "in .bashrc, .zshrc -> export LGTM_IN_USER_PATH='http://lgtm.in/l/HaiTo' \n".freeze

    REFLASH_TIME = 604_800

    LAST_EXECUTED_AT_TIME_PATH = 'last_executed_at.time'.freeze
    CACHED_LINKS_PATH = 'cached_links.links'.freeze
    BASE_PATH = '/tmp'.freeze

    LINK_PAR_PAGE_BASE = 32

    LGTM_MARKDOWN = '[![LGTM](__LGTM_IMAGE_DETAILS_PATH__)](__LGTM_IMAGE_PATH__)'.freeze
    LGTM_MARKDOWN_DETAIL_PATH_BASE = 'http://lgtm.in/p/'.freeze
    LGTM_MARKDOWN_IMAGE_PATH_BASE = 'http://lgtm.in/i/'.freeze

    LgtmLinkStruct = Struct.new(:index, :link, :image)

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

    def fetch_lgtm_link_markdown!(mode, picker)
      link_structs =
        if Time.now.to_i - @last_executed_at.to_i > REFLASH_TIME
          update_executed_at!

          link_structs = fetch_links
          cache_links!(link_structs)

          link_structs
        else
          @cached_links.nil? ? fetch_links : Marshal.load(@cached_links)
        end

      link_struct =
        case picker.to_i
        when 1..Fixnum::MAX
          link_structs.compact[picker.to_i]
        else
          link_structs.compact.sample
        end

      unless link_struct
        print "you could set to NUMBER at between 0 and #{link_structs.size}"
        exit(1)
      end

      case mode
      when :link
        link_hash = link_struct.link.split('/').last

        LGTM_MARKDOWN.gsub('__LGTM_IMAGE_DETAILS_PATH__', (LGTM_MARKDOWN_DETAIL_PATH_BASE + link_hash).to_s).gsub('__LGTM_IMAGE_PATH__', (LGTM_MARKDOWN_IMAGE_PATH_BASE + link_hash).to_s)
      when :image
        link_struct.image
      end
    end

    private

    def fetch_links
      agent = Mechanize.new
      cursor = 1
      links = []

      fetch_link_per_page!(cursor, links, agent)
    end

    def fetch_link_per_page!(cursor, links, agent)
      page = agent.get(@lgtm_my_page + "?page=#{cursor}")

      links << page.links.select {|link| link.href.match(LGTM_LINK_BASE) }.map.with_index(links.size + 1) {|link, index|
        LgtmLinkStruct.new(index, link.href, link.node.children[1].attributes['src'].value)
      }

      if links.flatten!.size % LINK_PAR_PAGE_BASE == 0
        fetch_link_per_page!(cursor + 1, links, agent)
      end

      links.flatten
    end

    def update_executed_at!
      File.open(BASE_PATH + '/' + LAST_EXECUTED_AT_TIME_PATH, 'w') {|f| f.write(Time.now.to_i) }
    end

    def cache_links!(links)
      File.open(BASE_PATH + '/' + CACHED_LINKS_PATH, 'w') {|f| f.write(Marshal.dump(links)) }
    end

    def load_cached_links!
      Marshal.load(@cached_links)
    rescue
      fetch_links
    end
  end
end
