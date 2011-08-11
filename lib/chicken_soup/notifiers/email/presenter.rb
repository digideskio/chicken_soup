require 'time'

module ChickenSoup
  module Email
    class Presenter
      LongDateFormat = "%A, %B %e, %Y at %l:%M%p %Z"

      def initialize(capistrano)
        @capistrano = capistrano
      end

      def application
        @capistrano[:application].titleize
      end

      def environment
        @capistrano[:rails_env].titleize
      end

      def deployed_by
        @capistrano[:local_user]
      end

      def deploy_date_in_long_format
        format_timestamp(@capistrano[:current_release], LongDateFormat)
      end

      def previous_deploy_date_in_long_format
        format_timestamp(@capistrano[:previous_release], LongDateFormat)
      end

      def notifiers
        @capistrano[:notifiers].join(", ")
      end

      def changes_since_last_deployment
        vc_log
      end

      private
      def format_timestamp(capistrano_timestamp, format)
        timestamp = convert_capistrano_timestamp(capistrano_timestamp)
        timestamp.strftime(format)
      end

      def convert_capistrano_timestamp(capistrano_timestamp)
        begin
          Date.strptime(capistrano_timestamp, "%Y%m%d%H%M%S")
        rescue
          Date.today
        end
      end
    end
  end
end
