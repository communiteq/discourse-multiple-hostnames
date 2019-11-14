# name: discourse-multiple-hostnames
# about: Allow multiple hostnames for your forum
# version: 1.0
# authors: michael@discoursehosting.com
# url: https://github.com/discoursehosting/discourse-multiple-hostnames

after_initialize do

  module ::OverrideEnforceHostname
    def call(env)

      hostname = env[Rack::Request::HTTP_X_FORWARDED_HOST].presence || env[Rack::HTTP_HOST]
      env[Rack::Request::HTTP_X_FORWARDED_HOST] = nil

      set_hostname = Discourse.current_hostname
      if Discourse.current_hostname != hostname
        allowed_names = SiteSetting.extra_hostnames.split('|')
        allowed_names.each do |name|
          if name == hostname
            set_hostname = name
            break
          end
        end
      end
      env[Rack::HTTP_HOST] = set_hostname
      @app.call(env)
    end
  end

  class Middleware::EnforceHostname
    prepend OverrideEnforceHostname
  end

end

