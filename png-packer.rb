#!/usr/bin/env ruby
# coding: utf-8

# 使い方
#   $ ls *.png > filenames.dat
#   $ ruby png-packer.rb
# 目的
#   filenames.dat に書き込まれたファイル一覧から、.RW2 ファイルを rgb 比 1:1:1 で .png に現像する。
# 利点
#   ls を媒介することで、一括生成できる、ミスを防げる

targets = File.read("filenames.dat").split
targets.each do |filename|
  if File.extname(filename) == ".RW2"
    target = File.basename(filename, ".RW2")
    unless File.exist? "#{target}.png"
      `dcraw -v +M -o 0 -q 3 -4  -g 1 1 -r 1 1 1 1 #{target}.RW2`
      `convert #{target}.ppm #{target}.png`
    end
  end
end

`rm *.ppm`