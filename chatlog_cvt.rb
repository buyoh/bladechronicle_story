#
# http://ideone.com/mkCHNK を改良したもの
#
# HowToUse
# ruby chatlog_cvt.rb filename.txt
#

require 'kconv'

if $*.size != 1
    STDOUT.puts "usage: ruby yumemi_cutter.rb [filename] "
    abort
end
filename_in = $*[0]
filename_out = filename_in+".out.html"

class String
    def my_encode
        #self.kconv(Kconv::UTF8)
        NKF.nkf("-xm0 -w", self)
        #self.encode("cp932", :invalid => :replace, :undef => :replace)
    end
end

 
@colorList={"ＧＭ" => "FF46FF", "勢力"=> "A0C8FF", "大声"=> "FFB478", "通常会話" => "FFFFFF", "ＮＰＣ" => "888888"}
# @colorList={"兵団" => "00DD22", "パーティ" => "00FFFF"}
@hideName=true
@displayedType={"ＧＭ" => true, "ＮＰＣ" => true}

open(filename_in, "r:Shift_JIS"){|fin|
    open(filename_out,"w"){|fout|
        fout.puts "<html><head><title>bladechronicle log</title></head>"
        fout.puts "<body bgcolor='black' style='color:white;font-family:sans-serif'>"
        fout.puts "<h2>bladechronicle log</h2>"
        fout.puts "<table border=1>"

        nameList={}

        while cin = fin.gets
            time,type,text=cin.my_encode.split("\t");
            next if time == "" || type == "" || text==""
            next if !(color = @colorList[type])
            
            t = text.scan(/\[[^\]]+\](.+)/)
            text = t.empty? ? text : t[0][0]
            name,text = text.scan(/([^:]+)\: (.+)/)[0]

            if !@hideName || @displayedType[type]
                ;
            else
                if (!nameList[name])
                    nameList[name] = sprintf("%03d",nameList.size)
                end
                name = nameList[name]
            end
            
            fout.puts "<tr><td>#{time}</td><td>#{type}</td><td>#{name}</td><td><span style='color:\##{color}'>#{text}</span></td></tr>"
        end

        fout.puts "</table>"
        fout.puts "</body></html>"
    }
}
