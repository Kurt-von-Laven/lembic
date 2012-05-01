require 'spec_helper'

describe VariablesController do

  describe "GET 'type:string'" do
    it "returns http success" do
      get 'type:string'
      response.should be_success
    end
  end

  describe "GET 'value:string'" do
    it "returns http success" do
      get 'value:string'
      response.should be_success
    end
  end

end
