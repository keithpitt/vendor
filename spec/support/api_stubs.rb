require 'fakeweb'

FakeWeb.register_uri :get, "http://keithpitt:password@vendorforge.org/users/keithpitt/api_key.json",
                     :body => { :api_key => "secret" }.to_json

FakeWeb.register_uri :get, "http://keithpitt:wrong@vendorforge.org/users/keithpitt/api_key.json",
                     :status => 401

FakeWeb.register_uri :get, "http://keithpitt:error@vendorforge.org/users/keithpitt/api_key.json",
                     :status => 500

FakeWeb.allow_net_connect = false
