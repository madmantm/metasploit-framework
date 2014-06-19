require 'metasploit/framework/mssql/client'
require 'metasploit/framework/login_scanner/base'
require 'metasploit/framework/login_scanner/rex_socket'
require 'metasploit/framework/login_scanner/ntlm'

module Metasploit
  module Framework
    module LoginScanner

      # This is the LoginScanner class for dealing with Microsoft SQL Servers.
      # It is responsible for taking a single target, and a list of credentials
      # and attempting them. It then saves the results
      class MSSQL
        include Metasploit::Framework::LoginScanner::Base
        include Metasploit::Framework::LoginScanner::RexSocket
        include Metasploit::Framework::LoginScanner::NTLM
        include Metasploit::Framework::MSSQL::Client

        # @!attribute windows_authentication
        #   @return [Boolean] Whether to use Windows Authentication instead of SQL Server Auth.
        attr_accessor :windows_authentication

        validates :windows_authentication,
          inclusion: { in: [true, false] }

        def attempt_login(credential)
          result_options = {
              credential: credential
          }

          begin
            if mssql_login(credential.public, credential.private, '', credential.realm)
              result_options[:status] = :success
            else
              result_options[:status] = :failed
            end
          rescue ::Rex::ConnectionError
            result_options[:status] = :connection_error
          end

          ::Metasploit::Framework::LoginScanner::Result.new(result_options)
        end

        private

        def set_sane_defaults
          self.max_send_size          = 0 if self.max_send_size.nil?
          self.send_delay             = 0 if self.send_delay.nil?
          self.send_lm                = true if self.send_lm.nil?
          self.send_ntlm              = true if self.send_ntlm.nil?
          self.send_spn               = true if self.send_spn.nil?
          self.use_lmkey              = false if self.use_lmkey.nil?
          self.use_ntlm2_session      = true if self.use_ntlm2_session.nil?
          self.use_ntlmv2             = true if self.use_ntlmv2.nil?
          self.windows_authentication = false if self.windows_authentication.nil?
        end
      end

    end
  end
end