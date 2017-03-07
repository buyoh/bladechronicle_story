require 'kconv'

if $*.size != 1
    STDOUT.puts "usage: ruby yumemi_cutter.rb [filename] "
    abort
end

filename_in = $*[0]
filename_out = filename_in+".out.txt"


class String
    def my_encode
        #self.kconv(Kconv::UTF8)
        NKF.nkf("-xm0 -w", self)
        #self.encode("cp932", :invalid => :replace, :undef => :replace)
    end
end

def time_parse(str)
    h,w,s = str.scan(/(\d\d)\:(\d\d)\:(\d\d)/)[0].map(&:to_i)
    return Time.utc(2017,3,8,h,w,s)
end


open(filename_in, "r:Shift_JIS"){|fin|
    open(filename_out,"w"){|fout|

        state = :idle
        running = true
        timeleft = nil
        queue = ""

        while finstr = fin.gets
            line = finstr.chomp.my_encode

            case state
            when :idle
                timestr,type,strings = line.split("\t")

                next if type != "ＮＰＣ"
                next if !(strings =~ /夢見の優香里/)
                time = time_parse(timestr)

                queue << strings << "\n"
                timeleft = time
                state = :yumemi_reading

            when :yumemi_reading
                if !(line=~/\t/)
                    queue << line << "\n"
                    next
                end

                timestr,type,strings = line.split("\t")
                strings = "" unless strings #下らない改行ケース
                time = time_parse(timestr)

                next if type != "ＮＰＣ"

                if time-timeleft > 60*8
                    queue.clear ; state = :idle
                    next
                end
                timeleft = time

                if strings =~ /夢見の優香里/ # 物語を見終わった後，必ず夢見の優香里に話しかけること
                    fout.print queue
                    fout.puts "------------------------------"
                    queue.clear
                    next
                end

                queue << strings << "\n"

                next
                
            end
        end
        
    }
}

