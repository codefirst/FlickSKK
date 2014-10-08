ARGF.each do|line|
  entry,_ = line.split ' ',2
  case
  when entry =~ /\A;/
    # 著作権表示等を残すためコメント行は削除しない
    print line
  when !entry.ascii_only?
    print line
  end
end
