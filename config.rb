Gollum::Page.send :remove_const, :FORMAT_NAMES if defined? Gollum::Page::FORMAT_NAMES
require 'omnigollum'
require 'omniauth/strategies/bitbucket'
#require 'omniauth/strategies/github'
require 'multi_json'

gollum_options = {
    :live_preview => true,
    :allow_uploads => true,
    :per_page_uploads => true,
    :allow_editing => true,
    :h1_title => true,
    :universal_toc => true,
    :mathjax => true,
    :websequencediagrams => true,
    :base_path => '/wiki',
}
auth_options = {
    :providers => Proc.new do
      provider :bitbucket, ENV["BITBUCKET_ID"], ENV["BITBUCKET_SECRET"]
    end,
    :dummy_auth => false,
    :authorized_users => /.*jirnexu\.com/,
    :author_format => Proc.new { |user| user.name },
    :author_email => Proc.new { |user| user.email },
}

Precious::App.set(:wiki_options, gollum_options)
Precious::App.set(:omnigollum, auth_options)

Precious::App.register Omnigollum::Sinatra
