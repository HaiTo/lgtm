require 'mechanize'

LGTM_LINK_BASE = 'http://lgtm.in/i'.freeze
LGTM_HAITO_PAGE = 'http://lgtm.in/l/HaiTo'.freeze

REFLASH_TIME = 604_800.freeze

LAST_EXECUTED_AT_TIME_PATH = 'last_executed_at.time'.freeze
CACHED_LINKS_PATH = 'cached_links.links'.freeze
BASE_PATH = File.expand_path('..', __FILE__)

last_executed_at = begin File.read(BASE_PATH + '/' + LAST_EXECUTED_AT_TIME_PATH); rescue; nil;
                   end

cached_links = begin File.read(BASE_PATH + '/' + CACHED_LINKS_PATH); rescue; nil
               end

def fetch_links
  agent = Mechanize.new
  page = agent.get(LGTM_HAITO_PAGE)
  page.links.map(&:href).select {|link| link.match(LGTM_LINK_BASE) }
end

def update_executed_at!
  File.open(BASE_PATH + '/' + LAST_EXECUTED_AT_TIME_PATH, 'w') {|f| f.write(Time.now.to_i) }
end

links =
  if Time.now.to_i - last_executed_at.to_i > REFLASH_TIME
    update_executed_at!

    fetch_links
  else
    cached_links.nil? ? fetch_links : cached_links
  end



system("echo #{links.sample} | pbcopy")

