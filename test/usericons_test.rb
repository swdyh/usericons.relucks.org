 require 'rubygems'
 require 'sinatra'
 require 'sinatra/test/spec'
 require 'usericons'

 describe 'Usericons' do
   it "should show a default page" do
     get_it '/'
     should.be.ok
   end

   it "should redirect twitter icon url" do
     get_it '/twitter/swdyh'
     body.should.be.equal ''
     status.should.be 302
     headers['Location'].should.match(/^http:\/\/s3.amazonaws.com/)
   end

   it "should redirect hatena icon url" do
     get_it '/hatena/swdyh'
     body.should.be.equal ''
     status.should.be 302
     headers['Location'].should.match(/^http:\/\/www\.hatena\.ne\.jp\//)
   end

   it "should redirect twitter icon url with url options" do
     get_it '/?url=http://twitter.com/swdyh'
     body.should.be.equal ''
     status.should.be 302
     headers['Location'].should.match(/^http:\/\/s3.amazonaws.com/)
   end
 end


