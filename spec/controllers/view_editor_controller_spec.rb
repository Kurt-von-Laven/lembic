require 'spec_helper'

describe ViewEditorController do

  describe "GET 'editsection'" do
    it "returns http success" do
      get 'editsection'
      response.should be_success
    end
  end

  describe "GET 'editblock'" do
    it "returns http success" do
      get 'editblock'
      response.should be_success
    end
  end

  describe "GET 'editquestion'" do
    it "returns http success" do
      get 'editquestion'
      response.should be_success
    end
  end

end
