require 'spec_helper'

require 'mocha'
require 'thin'
require 'uri'
require 'json'

describe DefaultController do

  describe "service apis" do

    before :each do
      u = User.new(:email => 'foo@bar.com')
      u.set_and_encrypt_password('foobar')
      u.save
      u.should be_valid
      @user = u

      a = App.new(
        :owner => u,
        :name => 'foobar',
        :framework => 'sinatra',
        :runtime => 'ruby18')
      a.save
      a.should be_valid
      @app = a

      svc = Service.new
      svc.label = "foo-bar"
      svc.url   = "http://localhost:56789"
      svc.token = 'foobar'
      svc.plans = ['free', 'nonfree']
      svc.save
      svc.should be_valid
      @svc = svc

      request.env['CONTENT_TYPE'] = Mime::JSON
      request.env['HTTP_AUTHORIZATION'] = UserToken.create('foo@bar.com').encode
    end

    describe '#service_info' do
      it "should list service" do
        get :service_info

        response.status.should == 200
        res = Yajl::Parser.parse(response.body)

        res['generic']['foo']['bar'].should_not be_nil
      end

      it "should list current version only for service with multiple versions" do
        svc = Service.find_by_label('foo-bar')
        svc.should_not be_nil

        svc.supported_versions = ['bar', 'baz']
        svc.version_aliases = {'current' => 'bar', 'next' => 'baz'}

        svc.save
        svc.should be_valid

        get :service_info

        response.status.should == 200
        res = Yajl::Parser.parse(response.body)

        foo_service = res['generic']['foo']
        foo_service.should_not be_nil

        foo_service['bar'].should_not be_nil
        foo_service['bar']['version'].should == "bar"

        foo_service['baz'].should be_nil
      end

      it "should list service alias" do
        svc = Service.find_by_label('foo-bar')
        svc.should_not be_nil

        svc.supported_versions = ['bar']
        svc.version_aliases = {'current' => 'bar'}
        svc.save
        svc.should be_valid

        get :service_info

        response.status.should == 200
        res = Yajl::Parser.parse(response.body)

        foo_service = res['generic']['foo']
        foo_service.should_not be_nil

        foo_service['bar'].has_key?('alias').should be_true
        foo_service['bar']['alias'].should == 'current'
      end
    end
  end
end
