requirements

  - sinatra

        $ sudo gem install sinatra

  - syslog_logger

        $ sudo gem install syslog_logger

how to run

        $ ./trema run .../test-controller.rb


diff --git a/Gemfile b/Gemfile
index 882f7d3..886ee99 100644
--- a/Gemfile
+++ b/Gemfile
@@ -23,6 +23,8 @@ group :development do
   gem "relish", "~> 0.6"
   gem "rspec", "~> 2.13.0"
   gem "yard", "~> 0.8.5.2"
+  gem "sinatra"
+  gem "syslog_logger"
 end



