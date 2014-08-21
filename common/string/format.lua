--[[******************************************************************* 
  * Lua extend library Copyright (c) 2014 Wayde.Fei<waydeGIT@qq.com> 
  * string.format extension 
  * 
  *This program is free software: you can redistribute it and/or modify 
  *it under the terms of the GNU General Public License as published by 
  *the Free Software Foundation, either version 3 of the License, or 
  *(at your option) any later version. 
  * 
  *You should have received a copy of the GNU General Public License 
  *along with this program.  If not, see <http://www.gnu.org/licenses/>. 
  ********************************************************************]] 


string.format =(function(format)
    return function(fmt,...)
        local args={...}
        local fmtstr = ""
        local argslist={}
        local last=1
        local fmt_idxorder = 1
        local recall_start = 1
        local _arglist_idx=1
        function _arglist_insert_item(v)
            if (type(v) == "table" and type(v.toString) == "function") then
                v=v:toString()
            end

            argslist[_arglist_idx]=v
            _arglist_idx=_arglist_idx+1
        end
        function _checkBeforeCount(str,idx,start)
            local count=0
            for n=idx-1,start,-1 do
                if(str:sub(n,n)=="%") then
                    count=count+1
                else
                    n=start
                end
            end
            return math.mod(count,2)==0
        end

       
        function _recallargs(str,start)
            local recall_end = string.len(str)
            while(start <= recall_end) do
                local idx= string.find(str,"%%[^%%]",start)
                if(idx) then
                    if (_checkBeforeCount(str,idx,start)) then
                        _arglist_insert_item(args[fmt_idxorder])
                        fmt_idxorder = fmt_idxorder+1
                    end
                    start =  idx+1
                else
                    start = recall_end+1
                end            
            end
        end

        while(last<=string.len(fmt)) do
            local strstart, strend,value_f,value_op,value_s = string.find(fmt,"%%{(%-?%d*)([%.:]-)(%w*)}",last)
            if (strstart) then
                if (_checkBeforeCount(fmt,last,strstart)) then
                    local argidx = tonumber(value_f)
                    fmtstr = fmtstr .. string.sub(fmt,last,strstart-1)
                    _recallargs(fmtstr,recall_start)
                    if(argidx>0) then
                        fmtstr = fmtstr .. "%" 
                        recall_start =  string.len(fmtstr)+2          
                        local arg =args[argidx]                
                        local val=nil
                        if (arg) then
                            local argidx2 = tonumber(value_s) or value_s
                            if (string.len(argidx2)>0) then
                                val = value_op=="." and arg[argidx2] or value_op==":" and arg[argidx2](arg) or nil
                            else
                                val = arg
                            end
                        else
                            val = nil
                        end
                        _arglist_insert_item(val)
                    elseif(argidx<0) then
                        fmt_idxorder = -argidx
                    else
                        -- equ to zero
                    end
                else
                    fmtstr = fmtstr .. string.sub(fmt,last,strend)
                    _recallargs(fmtstr,recall_start) 
                end
                last = strend+1
            else
                fmtstr = fmtstr .. string.sub(fmt,last,string.len(fmt))
                _recallargs(fmtstr,recall_start) 
                last = string.len(fmt)+1
            end
        end

        return format(fmtstr,unpack(argslist)) 
    end
end)(string.format)
