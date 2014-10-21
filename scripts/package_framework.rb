#!/usr/bin/env ruby
require 'fileutils'
require 'redcarpet'
PROJECT_DIR = ENV['PROJECT_DIR']
#PROJECT_DIR = "/Users/camjknight/Moblico/MoblicoFrameworks/MoblicoSDK"
DEST_DIR = "/Users/camjknight/Moblico/Distributions/MoblicoSDK"
DOC_DIR = "/Users/camjknight/Moblico/Documentation/MoblicoSDK"

system("cp -fa #{PROJECT_DIR}/LICENSE #{DEST_DIR}")
system("rm -rf #{DEST_DIR}/MoblicoSDK.framework")
system("cp -fa #{PROJECT_DIR}/MoblicoSDK.framework #{DEST_DIR}")
system("rm -rf #{DEST_DIR}/Documentation")
system("cp -fa #{DOC_DIR}/html #{DEST_DIR}/Documentation")
system("cp -fa #{DOC_DIR}/docset #{DEST_DIR}/MoblicoSDK.docset")

markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :autolink => true, :space_after_headers => true)
infile = File.open("#{PROJECT_DIR}/readme.markdown", 'r')
out = markdown.render(infile.read)
infile.close
outfile = File.open("#{DEST_DIR}/readme.html", 'w')
outfile.write(out)
outfile.close