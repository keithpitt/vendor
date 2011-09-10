require 'fakeweb'

FakeWeb.register_uri :get, "http://keithpitt:password@vendorage.com/users/keithpitt/api_key.json",
                     :body => { :api_key => "secret" }.to_json

FakeWeb.register_uri :get, "http://keithpitt:wrong@vendorage.com/users/keithpitt/api_key.json",
                     :status => 401

FakeWeb.register_uri :get, "http://keithpitt:error@vendorage.com/users/keithpitt/api_key.json",
                     :status => 500

FakeWeb.allow_net_connect = false
