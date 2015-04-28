#!/usr/bin/env ruby
# coding: utf-8

require "optparse"
require "opencv"
# require "./cvmat-enhanced.rb"

# 使い方
#   $ ruby pinstriper.rb sample.png
# 目的
#   １つの画像を指定し実行する。
#   OpenCVマトリクスを生成。
#   マトリクスの縦列をすべて足し合わせて、最大値に対しての割合を数値で算出する
#   返ってきた数値 array から、csv ファイルを作る。

# -------------------------------------
#  引数解析
# -------------------------------------

opt = OptionParser.new
opt.parse!(ARGV) #=> ARGV is Array including string
unless ARGV.length == 1
  p "カットした画像を指定してください。"
  return true
end

# -------------------------------------
#  Configuration
# -------------------------------------
# p ARGV.class #=> Array
filename = ARGV[0]

# -------------------------------------
# メイン処理
# -------------------------------------

target = OpenCV::CvMat.load filename if File.exist?(filename)
width = target.width
height = target.height

result_red = ""
result_blue = ""
result_green = ""

for x in 0...width

  pos_x = x
  pos_y = 0

  one_stripe = target.sub_rect(pos_x, pos_y, 1, height)
  blue, green, red, * = one_stripe.split.map {|i| i.sum.to_ary[0] / height}
  # result = {
  #   x: x,
  #   b: blue,
  #   g: green,
  #   r: red
  # }
  # puts result

  result_green += "#{x}\t#{green}\n"
  result_red += "#{x}\t#{red}\n"
  result_blue += "#{x}\t#{blue}\n"

end

File.open("#{filename}.red.csv", "w") do |f|
  f.write result_red
end

File.open("#{filename}.blue.csv", "w") do |f|
  f.write result_blue
end

File.open("#{filename}.green.csv", "w") do |f|
  f.write result_green
end

